
-- ============================================================
-- ANALYTICS : CREATION DE LA TABLE DE FAITS
-- Table : analytics.fact_sales_line
-- Grain : une ligne par ligne de transaction STAGING
-- Source : staging.online_retail_clean
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.fact_sales_line (

    sales_line_key BIGINT GENERATED ALWAYS AS IDENTITY,

    staging_id BIGINT NOT NULL,

    date_key INTEGER NOT NULL,
    product_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    country_key BIGINT NOT NULL,

    invoice_no VARCHAR(20) NOT NULL,
    invoice_type VARCHAR(20) NOT NULL,

    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,3) NOT NULL,
    line_amount NUMERIC(14,3) NOT NULL,

    has_negative_quantity BOOLEAN NOT NULL,
    has_zero_unit_price BOOLEAN NOT NULL,
    has_negative_unit_price BOOLEAN NOT NULL,

    invoice_hour SMALLINT NOT NULL,

    -- Clé primaire
    CONSTRAINT pk_fact_sales_line
        PRIMARY KEY (sales_line_key),

    -- Une seule ligne de fait par ligne STAGING
    CONSTRAINT uq_fact_sales_line_staging_id
        UNIQUE (staging_id),

    -- Clés étrangères
    CONSTRAINT fk_fact_sales_line_date
        FOREIGN KEY (date_key)
        REFERENCES analytics.dim_date(date_key),

    CONSTRAINT fk_fact_sales_line_product
        FOREIGN KEY (product_key)
        REFERENCES analytics.dim_product(product_key),

    CONSTRAINT fk_fact_sales_line_customer
        FOREIGN KEY (customer_key)
        REFERENCES analytics.dim_customer(customer_key),

    CONSTRAINT fk_fact_sales_line_country
        FOREIGN KEY (country_key)
        REFERENCES analytics.dim_country(country_key),

    -- Contraintes de cohérence
    CONSTRAINT ck_fact_sales_line_invoice_type
        CHECK (invoice_type IN ('Normal', 'Cancelled')),

    CONSTRAINT ck_fact_sales_line_invoice_hour
        CHECK (invoice_hour BETWEEN 0 AND 23)

);

-- Documentation

COMMENT ON TABLE analytics.fact_sales_line IS
'Table de faits au grain transaction : une ligne par ligne STAGING.';

COMMENT ON COLUMN analytics.fact_sales_line.sales_line_key IS
'Clé primaire technique de la ligne de fait.';

COMMENT ON COLUMN analytics.fact_sales_line.staging_id IS
'Identifiant de la ligne source STAGING assurant la traçabilité.';

COMMENT ON COLUMN analytics.fact_sales_line.customer_key IS
'Clé étrangère client. La valeur 0 représente le client inconnu.';

COMMENT ON COLUMN analytics.fact_sales_line.has_negative_unit_price IS
'Indique si le prix unitaire est négatif.';

COMMENT ON COLUMN analytics.fact_sales_line.invoice_hour IS
'Heure extraite de la date et heure de la facture.';

-- verification de la création de la tableSELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name = 'fact_sales_line'
ORDER BY ordinal_position;