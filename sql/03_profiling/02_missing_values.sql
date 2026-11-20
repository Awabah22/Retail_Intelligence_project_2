
/*
============================================================
PROJECT : RETAIL INTELLIGENCE
MODULE  : DATA PROFILING
FILE    : 02_missing_values.sql
PURPOSE : Analyse des valeurs manquantes
DATABASE: PostgreSQL
TABLE   : raw.online_retail_source
============================================================
*/


-- DPF-002 : Analyse des valeurs manquantes par colonne

SELECT
    COUNT(*) AS total_records,

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


-- DPF-002.1 : Taux de valeurs manquantes par colonne

SELECT
    column_name,
    missing_values,
    total_records,
    ROUND(
        100.0 * missing_values / NULLIF(total_records, 0),
        2
    ) AS missing_percentage
FROM (
    SELECT
        COUNT(*) AS total_records,

        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(invoice_no), '') IS NULL
        ) AS invoice_no,

        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(stock_code), '') IS NULL
        ) AS stock_code,

        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(description), '') IS NULL
        ) AS description,

        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(quantity), '') IS NULL
        ) AS quantity,

        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(invoice_date), '') IS NULL
        ) AS invoice_date,

        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(unit_price), '') IS NULL
        ) AS unit_price,

        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(customer_id), '') IS NULL
        ) AS customer_id,

        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(country), '') IS NULL
        ) AS country

    FROM raw.online_retail_source
) AS profiling

CROSS JOIN LATERAL (
    VALUES
        ('invoice_no', invoice_no),
        ('stock_code', stock_code),
        ('description', description),
        ('quantity', quantity),
        ('invoice_date', invoice_date),
        ('unit_price', unit_price),
        ('customer_id', customer_id),
        ('country', country)
) AS missing_data(column_name, missing_values)

ORDER BY missing_values DESC;
