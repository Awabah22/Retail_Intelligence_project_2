-- Projet : Retail Intelligence
-- Audit RAW : verification du volume de donnees

SELECT
    COUNT(*) AS total_rows
FROM raw.online_retail_source;

-- Audit RAW : detection des valeurs manquantes

SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(invoice_no), '') IS NULL
    ) AS missing_invoice_no,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(stock_code), '') IS NULL
    ) AS missing_stock_code,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(description), '') IS NULL
    ) AS missing_description,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(quantity), '') IS NULL
    ) AS missing_quantity,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(invoice_date), '') IS NULL
    ) AS missing_invoice_date,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(unit_price), '') IS NULL
    ) AS missing_unit_price,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(customer_id), '') IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(country), '') IS NULL
    ) AS missing_country

FROM raw.online_retail_source;

-- Audit RAW : detection des doublons exacts

SELECT
    COUNT(*) AS duplicate_groups,
    SUM(nb_occurrences - 1) AS extra_duplicate_rows
FROM (
    SELECT COUNT(*) AS nb_occurrences
    FROM raw.online_retail_source
    GROUP BY
        invoice_no,
        stock_code,
        description,
        quantity,
        invoice_date,
        unit_price,
        customer_id,
        country
    HAVING COUNT(*) > 1
) AS duplicates;

-- Inspection des descriptions manquantes

SELECT *
FROM raw.online_retail_source
WHERE NULLIF(BTRIM(description), '') IS NULL
LIMIT 20;

-- Analyse des lignes sans description

SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country
FROM raw.online_retail_source
WHERE NULLIF(BTRIM(description), '') IS NULL
LIMIT 30;

-- Caracteristiques des lignes sans description

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT invoice_no) AS distinct_invoices,
    COUNT(DISTINCT stock_code) AS distinct_products,
    COUNT(*) FILTER (
        WHERE unit_price::NUMERIC = 0
    ) AS zero_price_rows,
    COUNT(*) FILTER (
        WHERE quantity::NUMERIC < 0
    ) AS negative_quantity_rows,
    COUNT(*) FILTER (
        WHERE invoice_no LIKE 'C%'
    ) AS cancelled_invoice_rows
FROM raw.online_retail_source
WHERE NULLIF(BTRIM(description), '') IS NULL;

-- Audit des quantites et des prix

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE quantity::NUMERIC < 0
    ) AS negative_quantities,

    COUNT(*) FILTER (
        WHERE quantity::NUMERIC = 0
    ) AS zero_quantities,

    COUNT(*) FILTER (
        WHERE REPLACE(unit_price, ',', '.')::NUMERIC < 0
    ) AS negative_prices,

    COUNT(*) FILTER (
        WHERE REPLACE(unit_price, ',', '.')::NUMERIC = 0
    ) AS zero_prices,

    COUNT(*) FILTER (
        WHERE invoice_no LIKE 'C%'
    ) AS cancelled_invoices

FROM raw.online_retail_source;

-- Examiner les factures annulees

SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country
FROM raw.online_retail_source
WHERE invoice_no LIKE 'C%'
LIMIT 20;

# prix unitaires négatifs
SELECT *
FROM raw.online_retail_source
WHERE REPLACE(unit_price, ',', '.')::NUMERIC < 0;

# prix unitaires nuls
SELECT *
FROM raw.online_retail_source
WHERE REPLACE(unit_price, ',', '.')::NUMERIC = 0
LIMIT 20;

# factures annulées
SELECT *
FROM raw.online_retail_source
WHERE invoice_no LIKE 'C%'
LIMIT 20;

-- Audit RAW : periode et validite des dates

SELECT
    MIN(TO_DATE(invoice_date, 'DD/MM/YYYY HH24:MI')) AS first_invoice_date,
    MAX(TO_DATE(invoice_date, 'DD/MM/YYYY HH24:MI')) AS last_invoice_date,
    COUNT(*) AS total_rows
FROM raw.online_retail_source;

-- Audit RAW : repartition des transactions par pays

SELECT
    country,
    COUNT(*) AS total_transactions
FROM raw.online_retail_source
GROUP BY country
ORDER BY total_transactions DESC;