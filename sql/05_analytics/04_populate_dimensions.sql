
-- ============================================================
-- PROJET : RETAIL INTELLIGENCE
-- Fichier : 04_populate_dimensions.sql
-- Objectif : alimentation des dimensions ANALYTICS
-- Étape actuelle : DIM_DATE
-- ============================================================


-- ============================================================
-- DIMENSION 1 : DIM_DATE
-- Génération du calendrier continu
-- Période : 2010-12-01 au 2011-12-09
-- Nombre de dates attendu : 374
-- ============================================================

BEGIN;

INSERT INTO analytics.dim_date (
    date_key,
    full_date,
    year_number,
    quarter_number,
    month_number,
    month_name,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend
)

SELECT
    -- Clé au format YYYYMMDD
    TO_CHAR(calendar_date, 'YYYYMMDD')::INTEGER,

    -- Date complète
    calendar_date,

    -- Année
    EXTRACT(YEAR FROM calendar_date)::SMALLINT,

    -- Trimestre
    EXTRACT(QUARTER FROM calendar_date)::SMALLINT,

    -- Numéro du mois
    EXTRACT(MONTH FROM calendar_date)::SMALLINT,

    -- Nom du mois en anglais
    (ARRAY[
        'January', 'February', 'March', 'April',
        'May', 'June', 'July', 'August',
        'September', 'October', 'November', 'December'
    ])[EXTRACT(MONTH FROM calendar_date)::INTEGER],

    -- Jour du mois
    EXTRACT(DAY FROM calendar_date)::SMALLINT,

    -- Jour de la semaine ISO : lundi = 1, dimanche = 7
    EXTRACT(ISODOW FROM calendar_date)::SMALLINT,

    -- Nom du jour en anglais
    (ARRAY[
        'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday', 'Sunday'
    ])[EXTRACT(ISODOW FROM calendar_date)::INTEGER],

    -- Identification du week-end
    EXTRACT(ISODOW FROM calendar_date) IN (6, 7)

FROM GENERATE_SERIES(
    DATE '2010-12-01',
    DATE '2011-12-09',
    INTERVAL '1 day'
) AS generated_dates(calendar_date)

-- Permet de réexécuter le script sans créer de doublons.
ON CONFLICT (date_key)
DO UPDATE SET
    full_date = EXCLUDED.full_date,
    year_number = EXCLUDED.year_number,
    quarter_number = EXCLUDED.quarter_number,
    month_number = EXCLUDED.month_number,
    month_name = EXCLUDED.month_name,
    day_of_month = EXCLUDED.day_of_month,
    day_of_week = EXCLUDED.day_of_week,
    day_name = EXCLUDED.day_name,
    is_weekend = EXCLUDED.is_weekend;

COMMIT;


-- ============================================================
-- FIN DU CHARGEMENT DE DIM_DATE
-- ============================================================


-- ============================================================
-- ANALYTICS : CHARGEMENT DE LA DIMENSION PRODUIT
-- Table : analytics.dim_product
-- Source : staging.online_retail_clean
-- Règle métier : BR024
-- Grain : une ligne par stock_code distinct
-- ============================================================

BEGIN;

-- 1. Compter les occurrences de chaque description
--    non NULL pour chaque code produit.

WITH description_counts AS (

    SELECT
        stock_code,
        description,
        COUNT(*) AS description_count

    FROM staging.online_retail_clean

    WHERE description IS NOT NULL

    GROUP BY
        stock_code,
        description

),

-- 2. Classer les descriptions par fréquence décroissante.
--    En cas d'égalité, ordre alphabétique croissant.

ranked_descriptions AS (

    SELECT
        stock_code,
        description,
        description_count,

        ROW_NUMBER() OVER (
            PARTITION BY stock_code
            ORDER BY
                description_count DESC,
                description ASC
        ) AS description_rank

    FROM description_counts

),

-- 3. Récupérer tous les codes produits distincts,
--    y compris ceux dont toutes les descriptions sont NULL.

product_reference AS (

    SELECT
        s.stock_code,
        r.description AS product_description

    FROM (
        SELECT DISTINCT stock_code
        FROM staging.online_retail_clean
    ) s

    LEFT JOIN ranked_descriptions r
        ON s.stock_code = r.stock_code
       AND r.description_rank = 1

)

-- 4. Charger la dimension produit.

INSERT INTO analytics.dim_product (
    stock_code,
    product_description
)

SELECT
    stock_code,
    product_description

FROM product_reference

ON CONFLICT (stock_code)
DO UPDATE SET
    product_description = EXCLUDED.product_description;

COMMIT;

-- veriffication du chargement des donnes 
SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT stock_code) AS distinct_stock_codes,
    COUNT(*) FILTER (
        WHERE product_description IS NULL
    ) AS products_without_description,
    COUNT(*) FILTER (
        WHERE product_description IS NOT NULL
    ) AS products_with_description
FROM analytics.dim_product;



-- ============================================================
-- ANALYTICS : CHARGEMENT DE LA DIMENSION CLIENT
-- Table : analytics.dim_customer
-- Source : staging.online_retail_clean
-- Grain : une ligne par customer_id identifié
-- Membre inconnu : customer_key = 0
-- ============================================================

BEGIN;

-- 1. Insérer le membre inconnu.
--    OVERRIDING SYSTEM VALUE autorise l'insertion
--    explicite de customer_key = 0 malgré IDENTITY ALWAYS.

INSERT INTO analytics.dim_customer (
    customer_key,
    customer_id
)
OVERRIDING SYSTEM VALUE
VALUES (
    0,
    NULL
)
ON CONFLICT (customer_key) DO NOTHING;


-- 2. Charger les clients identifiés depuis STAGING.
--    Les customer_id NULL sont exclus.
--    customer_key est généré automatiquement.

INSERT INTO analytics.dim_customer (
    customer_id
)
SELECT DISTINCT
    customer_id
FROM staging.online_retail_clean
WHERE customer_id IS NOT NULL
ON CONFLICT (customer_id) DO NOTHING;

COMMIT;


-- ============================================================
-- ANALYTICS : CHARGEMENT DE LA DIMENSION PAYS
-- Table : analytics.dim_country
-- Source : staging.online_retail_clean
-- Grain : une ligne par country distinct
-- ============================================================

BEGIN;

INSERT INTO analytics.dim_country (
    country_name
)

SELECT DISTINCT
    country

FROM staging.online_retail_clean

WHERE country IS NOT NULL

ON CONFLICT (country_name) DO NOTHING;

COMMIT;
