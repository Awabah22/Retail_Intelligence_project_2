
-- ============================================================
-- ANALYTICS : CHARGEMENT DE LA TABLE DE FAITS
-- Table : analytics.fact_sales_line
-- Source : staging.online_retail_clean
-- Grain : une ligne par transaction STAGING
-- ============================================================

BEGIN;

INSERT INTO analytics.fact_sales_line (

    staging_id,

    date_key,
    product_key,
    customer_key,
    country_key,

    invoice_no,
    invoice_type,

    quantity,
    unit_price,
    line_amount,

    has_negative_quantity,
    has_zero_unit_price,
    has_negative_unit_price,

    invoice_hour
)

SELECT

    s.staging_id,

    d.date_key,
    p.product_key,

    -- Client inconnu si customer_id est NULL
    COALESCE(c.customer_key, 0),

    co.country_key,

    s.invoice_no,
    s.invoice_type,

    s.quantity,
    s.unit_price,
    s.line_amount,

    s.has_negative_quantity,
    s.has_zero_unit_price,

    (s.unit_price < 0) AS has_negative_unit_price,

    EXTRACT(HOUR FROM s.invoice_date)::SMALLINT

FROM staging.online_retail_clean s

INNER JOIN analytics.dim_date d
    ON s.invoice_date::DATE = d.full_date

INNER JOIN analytics.dim_product p
    ON s.stock_code = p.stock_code

LEFT JOIN analytics.dim_customer c
    ON s.customer_id = c.customer_id

INNER JOIN analytics.dim_country co
    ON s.country = co.country_name

ON CONFLICT (staging_id) DO NOTHING;

COMMIT;

-- verification du chargement des donnes
