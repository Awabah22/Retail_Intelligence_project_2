
-- ============================================================
-- RETAIL INTELLIGENCE
-- DPF-008.1 : Classification des factures
-- Objectif :
-- Distinguer les factures normales et les factures annulees.
-- Source : raw.online_retail_source
-- ============================================================

SELECT

    COUNT(DISTINCT NULLIF(BTRIM(invoice_no), ''))
        AS total_distinct_invoices,

    COUNT(DISTINCT NULLIF(BTRIM(invoice_no), ''))
        FILTER (
            WHERE UPPER(BTRIM(invoice_no)) NOT LIKE 'C%'
        ) AS normal_invoices,

    COUNT(DISTINCT NULLIF(BTRIM(invoice_no), ''))
        FILTER (
            WHERE UPPER(BTRIM(invoice_no)) LIKE 'C%'
        ) AS cancelled_invoices

FROM raw.online_retail_source;



-- ============================================================
-- DPF-008.2 : Repartition des lignes par type de facture
-- Objectif : compter les lignes appartenant aux factures
-- normales et aux factures annulees.
-- ============================================================

SELECT

    CASE
        WHEN UPPER(BTRIM(invoice_no)) LIKE 'C%'
            THEN 'Cancelled'
        ELSE 'Normal'
    END AS invoice_type,

    COUNT(*) AS total_lines,

    COUNT(DISTINCT invoice_no) AS distinct_invoices,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_lines

FROM raw.online_retail_source

WHERE NULLIF(BTRIM(invoice_no), '') IS NOT NULL

GROUP BY
    CASE
        WHEN UPPER(BTRIM(invoice_no)) LIKE 'C%'
            THEN 'Cancelled'
        ELSE 'Normal'
    END

ORDER BY invoice_type;


-- ============================================================
-- DPF-008.3 : Distribution du nombre de lignes par facture
-- Objectif : analyser la taille des factures.
-- ============================================================

WITH invoice_line_counts AS (

    SELECT
        invoice_no,

        CASE
            WHEN UPPER(BTRIM(invoice_no)) LIKE 'C%'
                THEN 'Cancelled'
            ELSE 'Normal'
        END AS invoice_type,

        COUNT(*) AS line_count

    FROM raw.online_retail_source

    WHERE NULLIF(BTRIM(invoice_no), '') IS NOT NULL

    GROUP BY
        invoice_no,
        CASE
            WHEN UPPER(BTRIM(invoice_no)) LIKE 'C%'
                THEN 'Cancelled'
            ELSE 'Normal'
        END
)

SELECT

    invoice_type,

    COUNT(*) AS total_invoices,

    MIN(line_count) AS minimum_lines,

    ROUND(AVG(line_count), 2) AS average_lines,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY line_count) AS median_lines,

    MAX(line_count) AS maximum_lines

FROM invoice_line_counts

GROUP BY invoice_type

ORDER BY invoice_type;



-- ============================================================
-- DPF-008.4 : Top 20 des factures par nombre de lignes
-- Objectif : identifier les factures les plus volumineuses.
-- ============================================================

SELECT

    invoice_no,

    CASE
        WHEN UPPER(BTRIM(invoice_no)) LIKE 'C%'
            THEN 'Cancelled'
        ELSE 'Normal'
    END AS invoice_type,

    COUNT(*) AS total_lines,

    COUNT(DISTINCT stock_code) AS distinct_products

FROM raw.online_retail_source

WHERE NULLIF(BTRIM(invoice_no), '') IS NOT NULL

GROUP BY
    invoice_no

ORDER BY total_lines DESC

LIMIT 20;



-- ============================================================
-- DPF-008.5 : Quantites et montants par facture
-- Objectif : analyser les volumes et les montants financiers.
-- ============================================================

WITH transaction_values AS (

    SELECT

        invoice_no,

        UPPER(BTRIM(invoice_no)) LIKE 'C%'
            AS is_cancelled,

        CASE
            WHEN REPLACE(BTRIM(quantity), ',', '.')
                 ~ '^[+-]?[0-9]+([.][0-9]+)?$'
            THEN REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        END AS quantity_value,

        CASE
            WHEN REPLACE(BTRIM(unit_price), ',', '.')
                 ~ '^[+-]?[0-9]+([.][0-9]+)?$'
            THEN REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        END AS unit_price_value

    FROM raw.online_retail_source

    WHERE NULLIF(BTRIM(invoice_no), '') IS NOT NULL
)

SELECT

    invoice_no,

    CASE
        WHEN is_cancelled THEN 'Cancelled'
        ELSE 'Normal'
    END AS invoice_type,

    COUNT(*) AS total_lines,

    SUM(quantity_value) AS total_quantity,

    ROUND(
        SUM(quantity_value * unit_price_value),
        2
    ) AS total_amount

FROM transaction_values

GROUP BY
    invoice_no,
    is_cancelled

ORDER BY total_amount DESC

LIMIT 20;


-- ============================================================
-- DPF-008.6 : Classification des factures selon leur montant
-- Objectif : identifier les factures positives, nulles
-- et negatives.
-- ============================================================

WITH invoice_amounts AS (

    SELECT

        invoice_no,

        CASE
            WHEN UPPER(BTRIM(invoice_no)) LIKE 'C%'
                THEN 'Cancelled'
            ELSE 'Normal'
        END AS invoice_type,

        SUM(
            REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
            *
            REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        ) AS total_amount

    FROM raw.online_retail_source

    WHERE NULLIF(BTRIM(invoice_no), '') IS NOT NULL

    GROUP BY
        invoice_no

)

SELECT

    invoice_type,

    COUNT(*) AS total_invoices,

    COUNT(*) FILTER (
        WHERE total_amount > 0
    ) AS positive_amount_invoices,

    COUNT(*) FILTER (
        WHERE total_amount = 0
    ) AS zero_amount_invoices,

    COUNT(*) FILTER (
        WHERE total_amount < 0
    ) AS negative_amount_invoices,

    ROUND(MIN(total_amount), 2) AS minimum_amount,

    ROUND(MAX(total_amount), 2) AS maximum_amount

FROM invoice_amounts

GROUP BY invoice_type

ORDER BY invoice_type;


-- ============================================================
-- DPF-008.7 : Investigation des factures normales
-- a montant nul ou negatif
-- ============================================================

WITH invoice_amounts AS (

    SELECT
        invoice_no,

        COUNT(*) AS total_lines,

        SUM(
            REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
            *
            REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        ) AS total_amount,

        SUM(
            REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
        ) AS total_quantity,

        COUNT(*) FILTER (
            WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC = 0
        ) AS zero_price_lines

    FROM raw.online_retail_source

    WHERE NULLIF(BTRIM(invoice_no), '') IS NOT NULL
      AND UPPER(BTRIM(invoice_no)) NOT LIKE 'C%'

    GROUP BY invoice_no

)

SELECT
    invoice_no,
    total_lines,
    total_quantity,
    zero_price_lines,
    ROUND(total_amount, 2) AS total_amount

FROM invoice_amounts

WHERE total_amount <= 0

ORDER BY total_amount ASC, invoice_no

LIMIT 30;


-- ============================================================
-- DPF-008.8 : Investigation des factures a montant nul
-- Objectif : examiner les produits et descriptions concernes.
-- ============================================================

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

WHERE invoice_no IN (
    '536414',
    '536545',
    '536546',
    '536547',
    '536549',
    '536550',
    '536552',
    '536553',
    '536554',
    '536589',
    '536764',
    '536765',
    '536941',
    '536942',
    '536995',
    '536996',
    '536997',
    '536998',
    '536999',
    '537000'
)

ORDER BY invoice_no;

-- ============================================================
-- DPF-008.9 : Profil des lignes avec un prix unitaire nul
-- Objectif : analyser les descriptions et les quantités.
-- ============================================================

SELECT
    CASE
        WHEN NULLIF(BTRIM(description), '') IS NULL
            THEN 'Description manquante'
        ELSE BTRIM(description)
    END AS description_category,

    COUNT(*) AS total_lines,

    COUNT(*) FILTER (
        WHERE REPLACE(BTRIM(quantity), ',', '.')::NUMERIC > 0
    ) AS positive_quantity_lines,

    COUNT(*) FILTER (
        WHERE REPLACE(BTRIM(quantity), ',', '.')::NUMERIC < 0
    ) AS negative_quantity_lines,

    COUNT(*) FILTER (
        WHERE REPLACE(BTRIM(quantity), ',', '.')::NUMERIC = 0
    ) AS zero_quantity_lines

FROM raw.online_retail_source

WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC = 0

GROUP BY
    CASE
        WHEN NULLIF(BTRIM(description), '') IS NULL
            THEN 'Description manquante'
        ELSE BTRIM(description)
    END

ORDER BY total_lines DESC
LIMIT 30;


-- ============================================================
-- DPF-008.10 : Analyse des factures normales a montant nul
-- Objectif : verifier la composition des factures a 0.
-- ============================================================

WITH invoice_totals AS (
    SELECT
        invoice_no,

        COUNT(*) AS total_lines,

        COUNT(*) FILTER (
            WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC = 0
        ) AS zero_price_lines,

        COUNT(*) FILTER (
            WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC > 0
        ) AS positive_price_lines,

        COUNT(*) FILTER (
            WHERE REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC < 0
        ) AS negative_price_lines,

        SUM(
            REPLACE(BTRIM(quantity), ',', '.')::NUMERIC
            *
            REPLACE(BTRIM(unit_price), ',', '.')::NUMERIC
        ) AS total_amount

    FROM raw.online_retail_source

    WHERE LEFT(BTRIM(invoice_no), 1) <> 'C'

    GROUP BY invoice_no
)

SELECT
    COUNT(*) AS total_zero_amount_invoices,

    COUNT(*) FILTER (
        WHERE zero_price_lines = total_lines
    ) AS invoices_only_zero_price,

    COUNT(*) FILTER (
        WHERE positive_price_lines > 0
           OR negative_price_lines > 0
    ) AS invoices_with_nonzero_prices,

    COUNT(*) FILTER (
        WHERE total_lines > 1
    ) AS invoices_with_multiple_lines

FROM invoice_totals

WHERE total_amount = 0;