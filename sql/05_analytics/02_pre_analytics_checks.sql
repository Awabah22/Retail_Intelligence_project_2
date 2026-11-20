
-- PA001 : Nombre de produits distincts dans STAGING

SELECT
    COUNT(DISTINCT stock_code) AS total_distinct_products,
    COUNT(*) AS total_transaction_lines
FROM staging.online_retail_clean;


-- PA002 : Détecter les codes produits associés à plusieurs descriptions

SELECT
    stock_code,
    COUNT(DISTINCT description) AS description_count,
    COUNT(*) AS transaction_lines
FROM staging.online_retail_clean
WHERE description IS NOT NULL
GROUP BY stock_code
HAVING COUNT(DISTINCT description) > 1
ORDER BY description_count DESC, stock_code;


-- PA003 : Synthèse de la cohérence stock_code / description

WITH product_profile AS (
    SELECT
        stock_code,
        COUNT(DISTINCT description) AS description_count,
        COUNT(*) AS transaction_lines,
        COUNT(description) AS non_null_descriptions
    FROM staging.online_retail_clean
    GROUP BY stock_code
)

SELECT
    COUNT(*) AS total_products,

    COUNT(*) FILTER (
        WHERE description_count = 1
    ) AS products_with_one_description,

    COUNT(*) FILTER (
        WHERE description_count > 1
    ) AS products_with_multiple_descriptions,

    COUNT(*) FILTER (
        WHERE non_null_descriptions = 0
    ) AS products_without_description,

    COUNT(*) FILTER (
        WHERE description_count = 0
    ) AS products_with_only_null_description

FROM product_profile;


-- PA004 : Examiner les descriptions associées à chaque code produit

SELECT DISTINCT
    stock_code,
    description
FROM staging.online_retail_clean
WHERE stock_code IN (
    SELECT stock_code
    FROM staging.online_retail_clean
    WHERE description IS NOT NULL
    GROUP BY stock_code
    HAVING COUNT(DISTINCT description) > 1
)
ORDER BY stock_code, description;


-- PA004 : Détail des descriptions et de leur fréquence
-- pour les codes produits ayant plusieurs descriptions

WITH inconsistent_products AS (
    SELECT
        stock_code
    FROM staging.online_retail_clean
    GROUP BY stock_code
    HAVING COUNT(DISTINCT description) > 1
)

SELECT
    s.stock_code,
    s.description,
    COUNT(*) AS transaction_lines
FROM staging.online_retail_clean s
INNER JOIN inconsistent_products p
    ON s.stock_code = p.stock_code
GROUP BY
    s.stock_code,
    s.description
ORDER BY
    s.stock_code,
    transaction_lines DESC,
    s.description;



-- PA005 : Analyse détaillée de quelques produits

SELECT
    stock_code,
    description,
    COUNT(*) AS transaction_lines
FROM staging.online_retail_clean
WHERE stock_code IN (
    '20713',
    '23084',
    '85123A',
    '84997A',
    '84997a'
)
GROUP BY
    stock_code,
    description
ORDER BY
    stock_code,
    transaction_lines DESC;



-- PA006 : Vérification des volumes par code produit

SELECT
    stock_code,
    COUNT(*) AS total_transaction_lines,
    COUNT(description) AS non_null_descriptions,
    COUNT(DISTINCT description) AS distinct_descriptions
FROM staging.online_retail_clean
WHERE stock_code IN ('20713', '23084', '85123A')
GROUP BY stock_code
ORDER BY stock_code;


-- PA007 : Profil des descriptions de référence
-- Une description de référence par stock_code

WITH description_frequency AS (
    SELECT
        stock_code,
        description,
        COUNT(*) AS occurrence_count
    FROM staging.online_retail_clean
    WHERE description IS NOT NULL
    GROUP BY stock_code, description
),

ranked_descriptions AS (
    SELECT
        stock_code,
        description,
        occurrence_count,
        ROW_NUMBER() OVER (
            PARTITION BY stock_code
            ORDER BY occurrence_count DESC, description ASC
        ) AS description_rank,
        COUNT(*) OVER (
            PARTITION BY stock_code
        ) AS description_count
    FROM description_frequency
)

SELECT
    COUNT(DISTINCT stock_code) AS products_with_description,
    COUNT(*) FILTER (
        WHERE description_rank = 1
          AND description_count = 1
    ) AS products_with_one_description,
    COUNT(*) FILTER (
        WHERE description_rank = 1
          AND description_count > 1
    ) AS products_with_multiple_descriptions,
    SUM(occurrence_count) FILTER (
        WHERE description_rank = 1
    ) AS lines_matching_reference_description
FROM ranked_descriptions;


-- ============================================================
-- PA008 : Vérification des pays
-- Objectif : contrôler les valeurs géographiques
-- avant la création de analytics.dim_country
-- ============================================================

-- PA008.1 : Nombre de pays distincts et contrôle des valeurs manquantes

SELECT
    COUNT(DISTINCT country) AS total_distinct_countries,

    COUNT(*) FILTER (
        WHERE country IS NULL
    ) AS missing_countries,

    COUNT(*) FILTER (
        WHERE BTRIM(country) = ''
    ) AS empty_countries

FROM staging.online_retail_clean;


-- PA008.2 : Répartition des transactions par pays

SELECT
    country,
    COUNT(*) AS total_transaction_lines,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    COUNT(DISTINCT customer_id) AS identified_customers

FROM staging.online_retail_clean

GROUP BY country

ORDER BY total_transaction_lines DESC, country ASC;


-- PA008.3 : Détection des différences de casse et d'espaces

SELECT
    LOWER(BTRIM(country)) AS normalized_country,
    COUNT(DISTINCT country) AS original_variants,
    STRING_AGG(
        DISTINCT country,
        ' | '
        ORDER BY country
    ) AS original_values,
    COUNT(*) AS total_transaction_lines

FROM staging.online_retail_clean

GROUP BY LOWER(BTRIM(country))

HAVING COUNT(DISTINCT country) > 1

ORDER BY normalized_country;


-- ============================================================
-- PA009.1 : Profil général des identifiants clients
-- Objectif : vérifier la complétude et la cardinalité
-- ============================================================

SELECT
    COUNT(*) AS total_transaction_lines,

    COUNT(customer_id) AS lines_with_customer_id,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE BTRIM(customer_id) = ''
    ) AS empty_customer_id,

    COUNT(DISTINCT customer_id) AS distinct_customers

FROM staging.online_retail_clean;


-- ============================================================
-- PA009.2 : Distribution des transactions par client
-- Objectif : analyser l'activité des clients identifiés
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS total_transaction_lines,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    COUNT(DISTINCT country) AS distinct_countries

FROM staging.online_retail_clean

WHERE customer_id IS NOT NULL

GROUP BY customer_id

ORDER BY total_transaction_lines DESC

LIMIT 20;


-- ============================================================
-- PA009.3 : Contrôle du format des identifiants clients
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE customer_id IS NOT NULL
          AND customer_id <> BTRIM(customer_id)
    ) AS ids_with_extra_spaces,

    COUNT(*) FILTER (
        WHERE customer_id IS NOT NULL
          AND BTRIM(customer_id) = ''
    ) AS empty_ids,

    COUNT(*) FILTER (
        WHERE customer_id IS NOT NULL
          AND customer_id !~ '^[0-9]+$'
    ) AS non_numeric_ids

FROM staging.online_retail_clean;


-- ============================================================
-- PA010.1 : Profil général des dates
-- Objectif : vérifier la couverture temporelle
-- ============================================================

SELECT
    MIN(invoice_date) AS first_transaction,
    MAX(invoice_date) AS last_transaction,

    MIN(invoice_date::DATE) AS first_transaction_date,
    MAX(invoice_date::DATE) AS last_transaction_date,

    COUNT(DISTINCT invoice_date::DATE) AS distinct_transaction_dates,

    COUNT(*) FILTER (
        WHERE invoice_date IS NULL
    ) AS missing_dates,

    COUNT(DISTINCT EXTRACT(YEAR FROM invoice_date)) AS distinct_years

FROM staging.online_retail_clean;


-- ============================================================
-- PA010.2 : Répartition temporelle mensuelle
-- Objectif : analyser les volumes par mois
-- ============================================================

SELECT
    EXTRACT(YEAR FROM invoice_date)::INTEGER AS transaction_year,

    EXTRACT(MONTH FROM invoice_date)::INTEGER AS transaction_month,

    TO_CHAR(invoice_date, 'YYYY-MM') AS year_month,

    COUNT(*) AS total_transaction_lines,

    COUNT(DISTINCT invoice_no) AS total_invoices

FROM staging.online_retail_clean

GROUP BY
    EXTRACT(YEAR FROM invoice_date),
    EXTRACT(MONTH FROM invoice_date),
    TO_CHAR(invoice_date, 'YYYY-MM')

ORDER BY
    transaction_year,
    transaction_month;


-- ============================================================
-- PA010.3 : Profil des heures de transaction
-- Objectif : vérifier les heures présentes dans le dataset
-- ============================================================

SELECT
    MIN(EXTRACT(HOUR FROM invoice_date)) AS minimum_hour,

    MAX(EXTRACT(HOUR FROM invoice_date)) AS maximum_hour,

    COUNT(DISTINCT EXTRACT(HOUR FROM invoice_date)) AS distinct_hours,

    COUNT(*) FILTER (
        WHERE EXTRACT(HOUR FROM invoice_date) NOT BETWEEN 0 AND 23
    ) AS invalid_hours

FROM staging.online_retail_clean;


-- ============================================================
-- PA010.4 : Distribution des transactions par heure
-- Objectif : analyser l'activité horaire
-- ============================================================

SELECT
    EXTRACT(HOUR FROM invoice_date)::INTEGER AS invoice_hour,

    COUNT(*) AS total_transaction_lines,

    COUNT(DISTINCT invoice_no) AS total_invoices

FROM staging.online_retail_clean

GROUP BY EXTRACT(HOUR FROM invoice_date)

ORDER BY invoice_hour;


-- ============================================================
-- PA011.1 : Vérification de la traçabilité technique
-- Objectif : contrôler staging_id avant son intégration
-- dans analytics.fact_sales_line
-- ============================================================

SELECT
    COUNT(*) AS total_staging_rows,

    COUNT(staging_id) AS non_null_staging_ids,

    COUNT(DISTINCT staging_id) AS distinct_staging_ids,

    COUNT(*) - COUNT(DISTINCT staging_id)
        AS duplicate_staging_ids

FROM staging.online_retail_clean;


-- ============================================================
-- PA011.2 : Vérification de la couverture des lignes
-- Objectif : identifier les lignes incomplètes pour le futur
-- chargement de fact_sales_line
-- ============================================================

SELECT
    COUNT(*) AS total_staging_rows,

    COUNT(*) FILTER (
        WHERE invoice_no IS NULL
    ) AS missing_invoice_no,

    COUNT(*) FILTER (
        WHERE stock_code IS NULL
    ) AS missing_stock_code,

    COUNT(*) FILTER (
        WHERE invoice_date IS NULL
    ) AS missing_invoice_date,

    COUNT(*) FILTER (
        WHERE quantity IS NULL
    ) AS missing_quantity,

    COUNT(*) FILTER (
        WHERE unit_price IS NULL
    ) AS missing_unit_price,

    COUNT(*) FILTER (
        WHERE line_amount IS NULL
    ) AS missing_line_amount,

    COUNT(*) FILTER (
        WHERE country IS NULL
    ) AS missing_country

FROM staging.online_retail_clean;


-- ============================================================
-- PA011.3 : Contrôle des valeurs nécessaires aux dimensions
-- Objectif : vérifier la disponibilité des clés métier
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT invoice_date::DATE) AS distinct_dates,

    COUNT(DISTINCT stock_code) AS distinct_products,

    COUNT(DISTINCT customer_id) AS distinct_customers,

    COUNT(DISTINCT country) AS distinct_countries,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS rows_without_customer

FROM staging.online_retail_clean;
