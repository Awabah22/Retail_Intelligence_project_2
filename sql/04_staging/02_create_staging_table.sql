
-- ============================================================
-- PROJET : RETAIL INTELLIGENCE
-- PHASE  : STAGING
-- FICHIER: 02_create_staging_table.sql
-- OBJET  : Creation de la table principale STAGING
-- ============================================================


-- 1. Creation du schema STAGING
CREATE SCHEMA IF NOT EXISTS staging;


-- 2. Creation de la table principale
CREATE TABLE IF NOT EXISTS staging.online_retail_clean (

    -- Identifiant technique
    staging_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Colonnes sources transformees
    invoice_no VARCHAR(20) NOT NULL,
    stock_code VARCHAR(20) NOT NULL,
    description TEXT,

    quantity INTEGER NOT NULL,
    invoice_date TIMESTAMP NOT NULL,
    unit_price NUMERIC(12,3) NOT NULL,

    customer_id VARCHAR(20),
    country VARCHAR(100) NOT NULL,

    -- Colonnes derivees
    invoice_type VARCHAR(20) NOT NULL,
    line_amount NUMERIC(14,3) NOT NULL,

    has_negative_quantity BOOLEAN NOT NULL,
    has_zero_unit_price BOOLEAN NOT NULL,

    -- Tracabilite technique
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP

);


-- 3. Verification de la creation
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
  AND table_name = 'online_retail_clean';
