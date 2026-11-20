/*
============================================================
PROJECT : RETAIL INTELLIGENCE
MODULE  : DATA PROFILING
FILE    : 03_cardinality.sql
PURPOSE : Analyse de la cardinalité des colonnes sources
DATABASE: PostgreSQL
TABLE   : raw.online_retail_source
============================================================
*/

SELECT
    'invoice_no' AS column_name,
    COUNT(DISTINCT NULLIF(BTRIM(invoice_no), '')) AS distinct_values
FROM raw.online_retail_source

UNION ALL

SELECT 'stock_code',
    COUNT(DISTINCT NULLIF(BTRIM(stock_code), ''))
FROM raw.online_retail_source

UNION ALL

SELECT 'description',
    COUNT(DISTINCT NULLIF(BTRIM(description), ''))
FROM raw.online_retail_source

UNION ALL

SELECT 'quantity',
    COUNT(DISTINCT NULLIF(BTRIM(quantity), ''))
FROM raw.online_retail_source

UNION ALL

SELECT 'invoice_date',
    COUNT(DISTINCT NULLIF(BTRIM(invoice_date), ''))
FROM raw.online_retail_source

UNION ALL

SELECT 'unit_price',
    COUNT(DISTINCT NULLIF(BTRIM(unit_price), ''))
FROM raw.online_retail_source

UNION ALL

SELECT 'customer_id',
    COUNT(DISTINCT NULLIF(BTRIM(customer_id), ''))
FROM raw.online_retail_source

UNION ALL

SELECT 'country',
    COUNT(DISTINCT NULLIF(BTRIM(country), ''))
FROM raw.online_retail_source;