-- Requête 1 — Vérifier les quantités négatives selon le type de facture

WITH parsed AS (
    SELECT
        BTRIM(invoice_no) AS invoice_no,

        CASE
            WHEN REPLACE(BTRIM(quantity), ',', '.') 
                 ~ '^-?[0-9]+([.][0-9]+)?$'
            THEN REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        END AS quantity_num

    FROM raw.online_retail_source
)

SELECT
    CASE
        WHEN invoice_no LIKE 'C%' THEN 'Cancelled'
        ELSE 'Normal'
    END AS invoice_type,

    COUNT(*) FILTER (
        WHERE quantity_num < 0
    ) AS negative_quantity_lines,

    ABS(
        COALESCE(
            SUM(quantity_num) FILTER (WHERE quantity_num < 0),
            0
        )
    ) AS negative_quantity_units

FROM parsed
GROUP BY 1
ORDER BY 1;


-- Requête 2 — Examiner les quantités négatives des factures normales

WITH parsed AS (
    SELECT
        BTRIM(invoice_no) AS invoice_no,
        NULLIF(BTRIM(customer_id), '') AS customer_id,
        BTRIM(country) AS country,

        CASE
            WHEN REPLACE(BTRIM(quantity), ',', '.') 
                 ~ '^-?[0-9]+([.][0-9]+)?$'
            THEN REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        END AS quantity_num,

        CASE
            WHEN REPLACE(BTRIM(unit_price), ',', '.') 
                 ~ '^-?[0-9]+([.][0-9]+)?$'
            THEN REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        END AS unit_price_num

    FROM raw.online_retail_source
),

target AS (
    SELECT
        *,
        quantity_num * unit_price_num AS line_amount

    FROM parsed

    WHERE invoice_no NOT LIKE 'C%'
      AND quantity_num < 0
)

SELECT
    COUNT(*) AS negative_lines_normal,

    COUNT(*) FILTER (
        WHERE unit_price_num = 0
    ) AS zero_unit_price_lines,

    COUNT(*) FILTER (
        WHERE line_amount = 0
    ) AS zero_amount_lines,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_lines,

    COUNT(*) FILTER (
        WHERE country = 'United Kingdom'
    ) AS uk_lines,

    ABS(SUM(quantity_num)) AS negative_quantity_units

FROM target;