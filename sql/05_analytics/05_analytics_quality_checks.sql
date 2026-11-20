
-- AC001 : Vérification du nombre de dates

SELECT
    COUNT(*) AS total_dates,
    MIN(full_date) AS first_date,
    MAX(full_date) AS last_date,
    COUNT(DISTINCT date_key) AS distinct_date_keys,
    COUNT(DISTINCT full_date) AS distinct_full_dates
FROM analytics.dim_date;


-- AC002 : Vérification des attributs calendaires

SELECT *
FROM analytics.dim_date
ORDER BY full_date
LIMIT 15;


-- AC003 : Vérification des week-ends

SELECT
    day_name,
    day_of_week,
    COUNT(*) AS total_dates
FROM analytics.dim_date
WHERE is_weekend = TRUE
GROUP BY day_name, day_of_week
ORDER BY day_of_week;


-- AC004 : Vérification des dates manquantes

SELECT
    COUNT(*) AS missing_calendar_dates
FROM GENERATE_SERIES(
    DATE '2010-12-01',
    DATE '2011-12-09',
    INTERVAL '1 day'
) AS expected_dates(calendar_date)

LEFT JOIN analytics.dim_date d
    ON d.full_date = expected_dates.calendar_date

WHERE d.full_date IS NULL;

-- ============================================================
-- AC005 : Vérification du nombre de produits
-- ============================================================

SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT stock_code) AS distinct_stock_codes,
    MIN(product_key) AS min_product_key,
    MAX(product_key) AS max_product_key
FROM analytics.dim_product;

-- ============================================================
-- AC006 : Vérification de l'unicité des stock_code
-- ============================================================

SELECT
    stock_code,
    COUNT(*) AS occurrences
FROM analytics.dim_product
GROUP BY stock_code
HAVING COUNT(*) > 1;

-- ============================================================
-- AC007 : Vérification des clés techniques
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(product_key) AS non_null_product_keys,
    COUNT(DISTINCT product_key) AS distinct_product_keys,
    COUNT(*) - COUNT(product_key) AS null_product_keys,
    COUNT(product_key) - COUNT(DISTINCT product_key)
        AS duplicate_product_keys
FROM analytics.dim_product;

-- ============================================================
-- AC008 : Vérification des descriptions manquantes
-- ============================================================

SELECT
    COUNT(*) AS total_products,

    COUNT(product_description)
        AS products_with_description,

    COUNT(*) FILTER (
        WHERE product_description IS NULL
    ) AS products_without_description,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE product_description IS NULL
        ) / COUNT(*),
        2
    ) AS missing_description_percentage

FROM analytics.dim_product;

-- ============================================================
-- AC009 : Vérification de la correspondance STAGING / DIM_PRODUCT
-- ============================================================

-- Codes présents dans STAGING mais absents de DIM_PRODUCT

SELECT
    'STAGING_ONLY' AS anomaly_type,
    s.stock_code
FROM (
    SELECT DISTINCT stock_code
    FROM staging.online_retail_clean
) s

LEFT JOIN analytics.dim_product p
    ON s.stock_code = p.stock_code

WHERE p.stock_code IS NULL

UNION ALL

-- Codes présents dans DIM_PRODUCT mais absents de STAGING

SELECT
    'DIMENSION_ONLY' AS anomaly_type,
    p.stock_code
FROM analytics.dim_product p

LEFT JOIN (
    SELECT DISTINCT stock_code
    FROM staging.online_retail_clean
) s
    ON p.stock_code = s.stock_code

WHERE s.stock_code IS NULL;

-- ============================================================
-- AC010 : Vérification de la règle métier BR024
-- Description la plus fréquente, puis ordre alphabétique
-- ============================================================

WITH description_counts AS (

    SELECT
        stock_code,
        description,
        COUNT(*) AS description_count

    FROM staging.online_retail_clean

    WHERE description IS NOT NULL

    GROUP BY
        stock_code,
        description

),

ranked_descriptions AS (

    SELECT
        stock_code,
        description,

        ROW_NUMBER() OVER (
            PARTITION BY stock_code
            ORDER BY
                description_count DESC,
                description ASC
        ) AS description_rank

    FROM description_counts

),

expected_products AS (

    SELECT
        s.stock_code,
        r.description AS expected_description

    FROM (
        SELECT DISTINCT stock_code
        FROM staging.online_retail_clean
    ) s

    LEFT JOIN ranked_descriptions r
        ON s.stock_code = r.stock_code
       AND r.description_rank = 1

)

SELECT
    p.stock_code,
    p.product_description AS actual_description,
    e.expected_description

FROM analytics.dim_product p

JOIN expected_products e
    ON p.stock_code = e.stock_code

WHERE p.product_description
      IS DISTINCT FROM e.expected_description;



-- ============================================================
-- AC011 : Vérification du nombre de clients
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(customer_id) AS identified_customers,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS unknown_customer_rows,

    COUNT(DISTINCT customer_id) AS distinct_customer_ids

FROM analytics.dim_customer;


-- ============================================================
-- AC012 : Vérification du membre inconnu
-- ============================================================

SELECT
    customer_key,
    customer_id,
    COUNT(*) AS occurrences

FROM analytics.dim_customer

WHERE customer_key = 0

GROUP BY
    customer_key,
    customer_id;



-- ============================================================
-- AC013 : Vérification de l'unicité des customer_id
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS occurrences

FROM analytics.dim_customer

WHERE customer_id IS NOT NULL

GROUP BY customer_id

HAVING COUNT(*) > 1;


-- ============================================================
-- AC014 : Vérification des clés techniques
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(customer_key) AS non_null_customer_keys,

    COUNT(DISTINCT customer_key) AS distinct_customer_keys,

    COUNT(*) - COUNT(customer_key) AS null_customer_keys,

    COUNT(customer_key) - COUNT(DISTINCT customer_key)
        AS duplicate_customer_keys

FROM analytics.dim_customer;



-- ============================================================
-- AC015 : Vérification de la correspondance STAGING / DIM_CUSTOMER
-- Le membre inconnu (customer_key = 0) est exclu du contrôle.
-- ============================================================

-- Clients présents dans STAGING mais absents de DIM_CUSTOMER

SELECT
    'STAGING_ONLY' AS anomaly_type,
    s.customer_id

FROM (
    SELECT DISTINCT customer_id
    FROM staging.online_retail_clean
    WHERE customer_id IS NOT NULL
) s

WHERE NOT EXISTS (
    SELECT 1
    FROM analytics.dim_customer c
    WHERE c.customer_id = s.customer_id
)

UNION ALL

-- Clients identifiés présents dans DIM_CUSTOMER mais absents de STAGING

SELECT
    'DIMENSION_ONLY' AS anomaly_type,
    c.customer_id

FROM analytics.dim_customer c

WHERE c.customer_key <> 0

AND NOT EXISTS (
    SELECT 1
    FROM staging.online_retail_clean s
    WHERE s.customer_id = c.customer_id
);

-- ============================================================
-- AC016 : Vérification de la gestion du client inconnu
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE customer_key = 0
    ) AS unknown_key_rows,

    COUNT(*) FILTER (
        WHERE customer_key = 0
          AND customer_id IS NULL
    ) AS valid_unknown_rows,

    COUNT(*) FILTER (
        WHERE customer_key <> 0
          AND customer_id IS NULL
    ) AS invalid_null_customer_rows,

    COUNT(*) FILTER (
        WHERE customer_key <> 0
          AND customer_id IS NOT NULL
    ) AS identified_customer_rows

FROM analytics.dim_customer;

-- ============================================================
-- AC017 : Vérification du nombre de pays
-- ============================================================

SELECT
    COUNT(*) AS total_countries,

    COUNT(DISTINCT country_name) AS distinct_countries,

    MIN(country_key) AS min_country_key,

    MAX(country_key) AS max_country_key

FROM analytics.dim_country;

-- ============================================================
-- AC018 : Vérification de l'unicité des country_name
-- ============================================================

SELECT
    country_name,
    COUNT(*) AS occurrences

FROM analytics.dim_country

GROUP BY country_name

HAVING COUNT(*) > 1;

-- ============================================================
-- AC019 : Vérification des clés techniques
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(country_key) AS non_null_country_keys,

    COUNT(DISTINCT country_key) AS distinct_country_keys,

    COUNT(*) - COUNT(country_key) AS null_country_keys,

    COUNT(country_key) - COUNT(DISTINCT country_key)
        AS duplicate_country_keys

FROM analytics.dim_country; 

-- ============================================================
-- AC020 : Vérification des valeurs manquantes
-- ============================================================

SELECT
    COUNT(*) AS total_countries,

    COUNT(*) FILTER (
        WHERE country_name IS NULL
    ) AS null_country_names,

    COUNT(*) FILTER (
        WHERE BTRIM(country_name) = ''
    ) AS empty_country_names

FROM analytics.dim_country;

-- ============================================================
-- AC021 : Vérification de la correspondance STAGING / DIM_COUNTRY
-- ============================================================

-- Pays présents dans STAGING mais absents de DIM_COUNTRY

SELECT
    'STAGING_ONLY' AS anomaly_type,
    s.country

FROM (
    SELECT DISTINCT country
    FROM staging.online_retail_clean
    WHERE country IS NOT NULL
) s

WHERE NOT EXISTS (
    SELECT 1
    FROM analytics.dim_country c
    WHERE c.country_name = s.country
)

UNION ALL

-- Pays présents dans DIM_COUNTRY mais absents de STAGING

SELECT
    'DIMENSION_ONLY' AS anomaly_type,
    c.country_name

FROM analytics.dim_country c

WHERE NOT EXISTS (
    SELECT 1
    FROM staging.online_retail_clean s
    WHERE s.country = c.country_name
);

-- ============================================================
-- AC022 : Vérification du nombre de lignes de faits
-- ============================================================

SELECT
    COUNT(*) AS total_fact_rows,

    COUNT(DISTINCT staging_id) AS distinct_staging_ids,

    MIN(staging_id) AS min_staging_id,

    MAX(staging_id) AS max_staging_id

FROM analytics.fact_sales_line;

-- ============================================================
-- AC023 : Vérification de la traçabilité STAGING / FACT
-- ============================================================

SELECT
    'STAGING_ONLY' AS anomaly_type,
    s.staging_id

FROM staging.online_retail_clean s

LEFT JOIN analytics.fact_sales_line f
    ON s.staging_id = f.staging_id

WHERE f.staging_id IS NULL

UNION ALL

SELECT
    'FACT_ONLY' AS anomaly_type,
    f.staging_id

FROM analytics.fact_sales_line f

LEFT JOIN staging.online_retail_clean s
    ON f.staging_id = s.staging_id

WHERE s.staging_id IS NULL;

-- ============================================================
-- AC024 : Vérification des clés étrangères
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE d.date_key IS NULL
    ) AS missing_date_dimension,

    COUNT(*) FILTER (
        WHERE p.product_key IS NULL
    ) AS missing_product_dimension,

    COUNT(*) FILTER (
        WHERE c.customer_key IS NULL
    ) AS missing_customer_dimension,

    COUNT(*) FILTER (
        WHERE co.country_key IS NULL
    ) AS missing_country_dimension

FROM analytics.fact_sales_line f

LEFT JOIN analytics.dim_date d
    ON f.date_key = d.date_key

LEFT JOIN analytics.dim_product p
    ON f.product_key = p.product_key

LEFT JOIN analytics.dim_customer c
    ON f.customer_key = c.customer_key

LEFT JOIN analytics.dim_country co
    ON f.country_key = co.country_key;

-- ============================================================
-- AC025 : Vérification des clés techniques
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(sales_line_key) AS non_null_sales_line_keys,

    COUNT(DISTINCT sales_line_key) AS distinct_sales_line_keys,

    COUNT(*) - COUNT(sales_line_key) AS null_sales_line_keys,

    COUNT(sales_line_key) - COUNT(DISTINCT sales_line_key)
        AS duplicate_sales_line_keys

FROM analytics.fact_sales_line;  

-- ============================================================
-- AC026 : Vérification de l'unicité de staging_id
-- ============================================================

SELECT
    staging_id,
    COUNT(*) AS occurrences

FROM analytics.fact_sales_line

GROUP BY staging_id

HAVING COUNT(*) > 1;

-- ============================================================
-- AC027 : Vérification des indicateurs de qualité
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE has_negative_quantity = TRUE
    ) AS negative_quantity_lines,

    COUNT(*) FILTER (
        WHERE has_zero_unit_price = TRUE
    ) AS zero_price_lines,

    COUNT(*) FILTER (
        WHERE has_negative_unit_price = TRUE
    ) AS negative_price_lines,

    COUNT(*) FILTER (
        WHERE has_negative_quantity
              IS DISTINCT FROM (quantity < 0)
    ) AS incorrect_negative_quantity_flags,

    COUNT(*) FILTER (
        WHERE has_zero_unit_price
              IS DISTINCT FROM (unit_price = 0)
    ) AS incorrect_zero_price_flags,

    COUNT(*) FILTER (
        WHERE has_negative_unit_price
              IS DISTINCT FROM (unit_price < 0)
    ) AS incorrect_negative_price_flags

FROM analytics.fact_sales_line;

-- ============================================================
-- AC028 : Vérification du membre client inconnu
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE customer_key = 0
    ) AS fact_lines_with_unknown_customer,

    COUNT(*) FILTER (
        WHERE customer_key <> 0
    ) AS fact_lines_with_identified_customer,

    COUNT(*) FILTER (
        WHERE customer_key = 0
          AND customer_id_check.customer_id IS NOT NULL
    ) AS incorrect_unknown_customer_mapping,

    COUNT(*) FILTER (
        WHERE customer_key <> 0
          AND customer_id_check.customer_id IS NULL
    ) AS incorrect_identified_customer_mapping

FROM analytics.fact_sales_line f

LEFT JOIN staging.online_retail_clean customer_id_check
    ON f.staging_id = customer_id_check.staging_id;

-- ============================================================
-- AC029 : Vérification de la cohérence des montants
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE line_amount
              IS DISTINCT FROM (quantity * unit_price)::NUMERIC(14,3)
    ) AS incorrect_line_amounts,

    SUM(line_amount) AS total_line_amount

FROM analytics.fact_sales_line;    

-- ============================================================
-- AC030 : Vérification des heures de facture
-- ============================================================

SELECT
    MIN(invoice_hour) AS min_invoice_hour,

    MAX(invoice_hour) AS max_invoice_hour,

    COUNT(DISTINCT invoice_hour) AS distinct_invoice_hours,

    COUNT(*) FILTER (
        WHERE invoice_hour NOT BETWEEN 0 AND 23
    ) AS invalid_invoice_hours

FROM analytics.fact_sales_line;