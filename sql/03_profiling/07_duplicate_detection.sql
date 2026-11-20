
-- ============================================================
-- DPF-007.1 : DETECTION DES DOUBLONS EXACTS
-- Objectif : identifier les lignes identiques
-- sur les 8 colonnes de la source
-- ============================================================

SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country,

    COUNT(*) AS duplicate_count

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

ORDER BY duplicate_count DESC

LIMIT 50;


-- ============================================================
-- DPF-007.2 : QUANTIFICATION DES DOUBLONS EXACTS
-- Objectif : mesurer le nombre de groupes et de lignes concernées
-- ============================================================

WITH duplicate_groups AS (

    SELECT
        invoice_no,
        stock_code,
        description,
        quantity,
        invoice_date,
        unit_price,
        customer_id,
        country,

        COUNT(*) AS duplicate_count

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

    SUM(duplicate_count) AS total_rows_in_duplicate_groups,

    SUM(duplicate_count - 1) AS excess_duplicate_rows,

    MAX(duplicate_count) AS maximum_repetitions,

    ROUND(
        SUM(duplicate_count - 1) * 100.0 /
        (SELECT COUNT(*) FROM raw.online_retail_source),
        2
    ) AS excess_rows_percentage

FROM duplicate_groups;


-- ============================================================
-- DPF-007.3 : DETECTION DES DOUBLONS PARTIELS
-- Clé d'analyse :
-- invoice_no + stock_code + invoice_date + customer_id
-- ============================================================

WITH partial_duplicate_groups AS (

    SELECT
        invoice_no,
        stock_code,
        invoice_date,
        customer_id,

        COUNT(*) AS line_count

    FROM raw.online_retail_source

    GROUP BY
        invoice_no,
        stock_code,
        invoice_date,
        customer_id

    HAVING COUNT(*) > 1
)

SELECT

    COUNT(*) AS partial_duplicate_groups,

    SUM(line_count) AS total_rows_in_groups,

    SUM(line_count - 1) AS additional_rows,

    MAX(line_count) AS maximum_repetitions

FROM partial_duplicate_groups;



-- ============================================================
-- DPF-007.3 : EXEMPLES DE DOUBLONS PARTIELS
-- ============================================================

WITH partial_duplicate_groups AS (
    SELECT
        invoice_no,
        stock_code,
        invoice_date,
        customer_id
    FROM raw.online_retail_source
    GROUP BY
        invoice_no,
        stock_code,
        invoice_date,
        customer_id
    HAVING COUNT(*) > 1
)

SELECT
    r.invoice_no,
    r.stock_code,
    r.description,
    r.quantity,
    r.invoice_date,
    r.unit_price,
    r.customer_id,
    r.country,

    COUNT(*) OVER (
        PARTITION BY
            r.invoice_no,
            r.stock_code,
            r.invoice_date,
            r.customer_id
    ) AS group_size

FROM raw.online_retail_source r

INNER JOIN partial_duplicate_groups p
    ON r.invoice_no = p.invoice_no
    AND r.stock_code = p.stock_code
    AND r.invoice_date = p.invoice_date
    AND r.customer_id IS NOT DISTINCT FROM p.customer_id

ORDER BY
    group_size DESC,
    r.invoice_no,
    r.stock_code

LIMIT 50;



-- ============================================================
-- DPF-007.4 : CLASSIFICATION DES GROUPES DE REPETITIONS
-- Objectif : distinguer les groupes identiques des groupes
-- contenant des informations différentes
-- ============================================================

WITH partial_groups AS (

    SELECT
        invoice_no,
        stock_code,
        invoice_date,
        customer_id,

        COUNT(*) AS line_count,

        COUNT(
            DISTINCT ROW(
                description,
                quantity,
                unit_price,
                country
            )
        ) AS distinct_variants

    FROM raw.online_retail_source

    GROUP BY
        invoice_no,
        stock_code,
        invoice_date,
        customer_id

    HAVING COUNT(*) > 1
)

SELECT

    COUNT(*) AS total_partial_groups,

    COUNT(*) FILTER (
        WHERE distinct_variants = 1
    ) AS groups_with_identical_lines,

    COUNT(*) FILTER (
        WHERE distinct_variants > 1
    ) AS groups_with_different_values,

    SUM(line_count) AS total_rows,

    SUM(line_count) FILTER (
        WHERE distinct_variants > 1
    ) AS rows_in_groups_with_variations

FROM partial_groups;



-- DPF-007.5 : Vérification de cohérence des groupes exacts

WITH exact_groups AS (
    SELECT
        invoice_no,
        stock_code,
        invoice_date,
        customer_id,
        description,
        quantity,
        unit_price,
        country,
        COUNT(*) AS repetitions
    FROM raw.online_retail_source
    GROUP BY
        invoice_no,
        stock_code,
        invoice_date,
        customer_id,
        description,
        quantity,
        unit_price,
        country
    HAVING COUNT(*) > 1
),

partial_groups AS (
    SELECT
        invoice_no,
        stock_code,
        invoice_date,
        customer_id,
        COUNT(*) AS repetitions,
        COUNT(
            DISTINCT ROW(
                description,
                quantity,
                unit_price,
                country
            )
        ) AS distinct_variants
    FROM raw.online_retail_source
    GROUP BY
        invoice_no,
        stock_code,
        invoice_date,
        customer_id
    HAVING COUNT(*) > 1
)

SELECT
    (SELECT COUNT(*) FROM exact_groups)
        AS exact_duplicate_groups,

    (SELECT COUNT(*) FROM partial_groups
     WHERE distinct_variants = 1)
        AS partial_groups_with_identical_lines,

    (SELECT COUNT(*) FROM partial_groups
     WHERE distinct_variants > 1)
        AS partial_groups_with_variations;



-- DPF-007.6 : Nombre de groupes exacts dans les groupes partiels mixtes

WITH exact_groups AS (
    SELECT
        invoice_no,
        stock_code,
        invoice_date,
        customer_id,
        description,
        quantity,
        unit_price,
        country,
        COUNT(*) AS repetitions
    FROM raw.online_retail_source
    GROUP BY
        invoice_no,
        stock_code,
        invoice_date,
        customer_id,
        description,
        quantity,
        unit_price,
        country
    HAVING COUNT(*) > 1
),

mixed_partial_groups AS (
    SELECT
        invoice_no,
        stock_code,
        invoice_date,
        customer_id
    FROM raw.online_retail_source
    GROUP BY
        invoice_no,
        stock_code,
        invoice_date,
        customer_id
    HAVING COUNT(*) > 1
       AND COUNT(DISTINCT ROW(
           description,
           quantity,
           unit_price,
           country
       )) > 1
)

SELECT
    COUNT(*) AS exact_groups_inside_mixed_groups,
    SUM(e.repetitions) AS rows_in_these_exact_groups
FROM exact_groups e
INNER JOIN mixed_partial_groups p
    ON e.invoice_no = p.invoice_no
    AND e.stock_code = p.stock_code
    AND e.invoice_date = p.invoice_date
    AND e.customer_id IS NOT DISTINCT FROM p.customer_id;
