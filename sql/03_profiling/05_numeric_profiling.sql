
/*
PROJECT : RETAIL INTELLIGENCE
MODULE  : DATA PROFILING
FILE    : 05_numeric_profiling.sql
PURPOSE : Analyse statistique des colonnes numériques
DATABASE: PostgreSQL
TABLE   : raw.online_retail_source

IMPORTANT :
Les colonnes quantity et unit_price sont stockées
en TEXT dans la couche RAW.

Les conversions sont temporaires.
Les données sources ne sont jamais modifiées.
*/


-- =====================================================
-- DPF-005.0 : VALIDATION DES FORMATS NUMERIQUES
-- =====================================================

SELECT
    'quantity' AS column_name,
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(quantity), '') IS NOT NULL
          AND BTRIM(quantity) !~ '^[+-]?[0-9]+([.,][0-9]+)?$'
    ) AS invalid_numeric_values
FROM raw.online_retail_source

UNION ALL

SELECT
    'unit_price' AS column_name,
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(unit_price), '') IS NOT NULL
          AND BTRIM(unit_price) !~ '^[+-]?[0-9]+([.,][0-9]+)?$'
    ) AS invalid_numeric_values
FROM raw.online_retail_source;


-- =====================================================
-- DPF-005.1 : PROFILAGE NUMERIQUE GENERAL
-- =====================================================

WITH normalized AS (
    SELECT
        CASE
            WHEN BTRIM(quantity) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        END AS quantity_numeric,

        CASE
            WHEN BTRIM(unit_price) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        END AS unit_price_numeric

    FROM raw.online_retail_source
)

SELECT
    'quantity' AS column_name,
    COUNT(*) AS total_records,
    COUNT(quantity_numeric) AS valid_records,
    MIN(quantity_numeric) AS minimum_value,
    MAX(quantity_numeric) AS maximum_value,
    ROUND(AVG(quantity_numeric), 2) AS average_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY quantity_numeric
    ) AS median_value
FROM normalized

UNION ALL

SELECT
    'unit_price',
    COUNT(*),
    COUNT(unit_price_numeric),
    MIN(unit_price_numeric),
    MAX(unit_price_numeric),
    ROUND(AVG(unit_price_numeric), 2),
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY unit_price_numeric
    )
FROM normalized;


-- =====================================================
-- DPF-005.2 : DETECTION DES VALEURS NEGATIVES
-- =====================================================

WITH normalized AS (
    SELECT
        CASE
            WHEN BTRIM(quantity) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        END AS quantity_numeric,

        CASE
            WHEN BTRIM(unit_price) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        END AS unit_price_numeric

    FROM raw.online_retail_source
)

SELECT
    'quantity' AS column_name,
    COUNT(*) FILTER (
        WHERE quantity_numeric < 0
    ) AS negative_values
FROM normalized

UNION ALL

SELECT
    'unit_price',
    COUNT(*) FILTER (
        WHERE unit_price_numeric < 0
    )
FROM normalized;


-- =====================================================
-- DPF-005.3 : DETECTION DES VALEURS EGALES A ZERO
-- =====================================================

WITH normalized AS (
    SELECT
        CASE
            WHEN BTRIM(quantity) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        END AS quantity_numeric,

        CASE
            WHEN BTRIM(unit_price) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        END AS unit_price_numeric

    FROM raw.online_retail_source
)

SELECT
    'quantity' AS column_name,
    COUNT(*) FILTER (
        WHERE quantity_numeric = 0
    ) AS zero_values
FROM normalized

UNION ALL

SELECT
    'unit_price',
    COUNT(*) FILTER (
        WHERE unit_price_numeric = 0
    )
FROM normalized;


-- =====================================================
-- DPF-005.4 : DISTRIBUTION DES QUANTITES
-- =====================================================

WITH normalized AS (
    SELECT
        CASE
            WHEN BTRIM(quantity) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        END AS quantity_numeric

    FROM raw.online_retail_source
)

SELECT
    quantity_numeric,
    COUNT(*) AS number_of_records
FROM normalized
WHERE quantity_numeric IS NOT NULL
GROUP BY quantity_numeric
ORDER BY number_of_records DESC
LIMIT 20;


-- =====================================================
-- DPF-005.5 : DISTRIBUTION DES PRIX UNITAIRES
-- =====================================================

WITH normalized AS (
    SELECT
        CASE
            WHEN BTRIM(unit_price) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        END AS unit_price_numeric

    FROM raw.online_retail_source
)

SELECT
    unit_price_numeric,
    COUNT(*) AS number_of_records
FROM normalized
WHERE unit_price_numeric IS NOT NULL
GROUP BY unit_price_numeric
ORDER BY number_of_records DESC
LIMIT 20;

-- Investigation A — Identifier les deux prix négatifs
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    customer_id,
    country
FROM raw.online_retail_source
WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC < 0;

-- Investigation B — Identifier les prix égaux à zéro
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    customer_id,
    country
FROM raw.online_retail_source
WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC = 0
LIMIT 30;

-- DPF-005.6 — Identification des valeurs numériques extrêmes
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    customer_id,
    country
FROM raw.online_retail_source
WHERE
    REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        IN (-80995, 80995)
    OR
    REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        IN (-11062.06, 38970);

