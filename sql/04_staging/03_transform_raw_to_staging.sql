
-- ============================================================
-- PROJET : RETAIL INTELLIGENCE
-- PHASE  : STAGING
-- FICHIER: 03_transform_raw_to_staging.sql
-- OBJET  : Transformation et chargement des donnees RAW
--          vers STAGING
-- VERSION: 2.0 - Precision numerique corrigee
-- ============================================================


-- 1. Actualisation de la table STAGING

TRUNCATE TABLE staging.online_retail_clean
RESTART IDENTITY;


-- 2. Transformation et chargement des donnees

INSERT INTO staging.online_retail_clean (

    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country,
    invoice_type,
    line_amount,
    has_negative_quantity,
    has_zero_unit_price

)

SELECT

    -- Identification de la facture
    BTRIM(invoice_no),

    -- Identification du produit
    BTRIM(stock_code),

    -- Nettoyage de la description
    NULLIF(BTRIM(description), ''),

    -- Conversion de la quantite
    REPLACE(BTRIM(quantity), ',', '.')::NUMERIC::INTEGER,

    -- Conversion de la date
    TO_TIMESTAMP(
        BTRIM(invoice_date),
        'DD/MM/YYYY HH24:MI'
    )::TIMESTAMP,

    -- Conversion du prix avec 3 decimales
    REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC(12,3),

    -- Nettoyage de l'identifiant client
    NULLIF(BTRIM(customer_id), ''),

    -- Nettoyage du pays
    BTRIM(country),

    -- Classification des factures
    CASE
        WHEN LEFT(BTRIM(invoice_no), 1) = 'C'
            THEN 'Cancelled'
        ELSE 'Normal'
    END,

    -- Calcul du montant avec 3 decimales
    (
        REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        *
        REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC(12,3)
    )::NUMERIC(14,3),

    -- Identification des quantites negatives
    (
        REPLACE(BTRIM(quantity), ',', '.')::NUMERIC < 0
    ),

    -- Flag calcule sur le prix apres conversion
    (
        REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC(12,3) = 0
    )

FROM raw.online_retail_source;


-- 3. Verification du chargement

SELECT
    COUNT(*) AS total_rows_loaded
FROM staging.online_retail_clean;


-- 4. Verification des indicateurs

SELECT
    COUNT(*) FILTER (
        WHERE has_negative_quantity
    ) AS negative_quantity_rows,

    COUNT(*) FILTER (
        WHERE has_zero_unit_price
    ) AS zero_unit_price_rows,

    COUNT(*) FILTER (
        WHERE unit_price < 0
    ) AS negative_unit_price_rows,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE description IS NULL
    ) AS missing_description

FROM staging.online_retail_clean;


-- 5. Verification de la precision numerique

SELECT
    invoice_no,
    stock_code,
    unit_price,
    has_zero_unit_price,
    line_amount
FROM staging.online_retail_clean
WHERE invoice_no IN (
    '561226',
    '568200',
    '568375',
    '550193'
)
AND stock_code IN ('PADS', 'BANK CHARGES')
ORDER BY invoice_no;
