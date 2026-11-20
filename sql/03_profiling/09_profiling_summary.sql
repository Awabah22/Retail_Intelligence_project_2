
-- ============================================================
-- DPF-009 : DATA PROFILING SUMMARY
-- Projet : Retail Intelligence
-- Source : raw.online_retail_source
-- Objectif : synthese globale du Data Profiling.
-- ============================================================


-- ============================================================
-- DPF-009.1 : VOLUME GLOBAL DU DATASET
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT invoice_no) AS distinct_invoices,
    COUNT(DISTINCT stock_code) AS distinct_products,
    COUNT(DISTINCT customer_id) AS distinct_customers,
    COUNT(DISTINCT country) AS distinct_countries

FROM raw.online_retail_source;


-- ============================================================
-- DPF-009.2 : VALEURS MANQUANTES
-- ============================================================

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


-- ============================================================
-- DPF-009.3 : SYNTHESE DES DOUBLONS EXACTS
-- ============================================================

WITH duplicate_groups AS (
    SELECT
        COUNT(*) AS group_size
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
)

SELECT
    COUNT(*) AS duplicate_groups,

    SUM(group_size) AS rows_in_duplicate_groups,

    SUM(group_size - 1) AS excess_duplicate_rows,

    MAX(group_size) AS maximum_repetitions,

    ROUND(
        SUM(group_size - 1) * 100.0 /
        (SELECT COUNT(*) FROM raw.online_retail_source),
        2
    ) AS excess_rows_percentage

FROM duplicate_groups;


-- ============================================================
-- DPF-009.4 : SYNTHESE DES ANOMALIES NUMERIQUES
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE REPLACE(BTRIM(quantity), ',', '.')::NUMERIC < 0
    ) AS negative_quantities,

    COUNT(*) FILTER (
        WHERE REPLACE(BTRIM(quantity), ',', '.')::NUMERIC = 0
    ) AS zero_quantities,

    COUNT(*) FILTER (
        WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC < 0
    ) AS negative_unit_prices,

    COUNT(*) FILTER (
        WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC = 0
    ) AS zero_unit_prices,

    MIN(REPLACE(BTRIM(quantity), ',', '.')::NUMERIC)
        AS minimum_quantity,

    MAX(REPLACE(BTRIM(quantity), ',', '.')::NUMERIC)
        AS maximum_quantity,

    MIN(REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC)
        AS minimum_unit_price,

    MAX(REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC)
        AS maximum_unit_price

FROM raw.online_retail_source;


-- ============================================================
-- DPF-009.5 : SYNTHESE DES DATES
-- ============================================================

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE BTRIM(invoice_date) ~
        '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'
    ) AS structurally_valid_dates,

    COUNT(*) FILTER (
        WHERE BTRIM(invoice_date) !~
        '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'
    ) AS structurally_invalid_dates,

    MIN(
        TO_TIMESTAMP(
            BTRIM(invoice_date),
            'DD/MM/YYYY HH24:MI'
        )::TIMESTAMP
    ) AS earliest_date,

    MAX(
        TO_TIMESTAMP(
            BTRIM(invoice_date),
            'DD/MM/YYYY HH24:MI'
        )::TIMESTAMP
    ) AS latest_date

FROM raw.online_retail_source;


-- ============================================================
-- DPF-009.6 : SYNTHESE DES FACTURES
-- ============================================================

WITH invoice_totals AS (
    SELECT
        invoice_no,

        CASE
            WHEN LEFT(BTRIM(invoice_no), 1) = 'C'
                THEN 'Cancelled'
            ELSE 'Normal'
        END AS invoice_type,

        COUNT(*) AS total_lines,

        SUM(
            REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
            *
            REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        ) AS total_amount

    FROM raw.online_retail_source

    GROUP BY
        invoice_no,
        CASE
            WHEN LEFT(BTRIM(invoice_no), 1) = 'C'
                THEN 'Cancelled'
            ELSE 'Normal'
        END
)

SELECT
    COUNT(*) AS total_invoices,

    COUNT(*) FILTER (
        WHERE invoice_type = 'Normal'
    ) AS normal_invoices,

    COUNT(*) FILTER (
        WHERE invoice_type = 'Cancelled'
    ) AS cancelled_invoices,

    COUNT(*) FILTER (
        WHERE total_amount > 0
    ) AS positive_amount_invoices,

    COUNT(*) FILTER (
        WHERE total_amount = 0
    ) AS zero_amount_invoices,

    COUNT(*) FILTER (
        WHERE total_amount < 0
    ) AS negative_amount_invoices,

    ROUND(AVG(total_lines), 2) AS average_lines_per_invoice,

    MAX(total_lines) AS maximum_lines_per_invoice

FROM invoice_totals;
