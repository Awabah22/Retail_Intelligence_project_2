
-- ============================================================
-- PROJET : RETAIL INTELLIGENCE
-- Fichier : 03_create_dimensions.sql
-- Objectif : Création des dimensions du modèle décisionnel
-- Base de données : retail_intelligence
-- Schéma : analytics
-- ============================================================


-- ============================================================
-- DIMENSION 1 : DIM_DATE
-- Objectif : permettre les analyses temporelles
-- Grain : une ligne par jour calendaire
-- Période prévue : 2010-12-01 au 2011-12-09
-- Nombre de lignes prévu : 374
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.dim_date (

    -- Clé technique au format YYYYMMDD
    date_key INTEGER PRIMARY KEY,

    -- Date complète
    full_date DATE NOT NULL UNIQUE,

    -- Attributs calendaires
    year_number SMALLINT NOT NULL,

    quarter_number SMALLINT NOT NULL,

    month_number SMALLINT NOT NULL,

    month_name VARCHAR(20) NOT NULL,

    day_of_month SMALLINT NOT NULL,

    -- Convention ISO : lundi = 1, dimanche = 7
    day_of_week SMALLINT NOT NULL,

    day_name VARCHAR(20) NOT NULL,

    -- TRUE si samedi ou dimanche
    is_weekend BOOLEAN NOT NULL,

    -- Contraintes de cohérence
    CONSTRAINT chk_dim_date_quarter
        CHECK (quarter_number BETWEEN 1 AND 4),

    CONSTRAINT chk_dim_date_month
        CHECK (month_number BETWEEN 1 AND 12),

    CONSTRAINT chk_dim_date_day
        CHECK (day_of_month BETWEEN 1 AND 31),

    CONSTRAINT chk_dim_date_weekday
        CHECK (day_of_week BETWEEN 1 AND 7),

    CONSTRAINT chk_dim_date_year
        CHECK (year_number BETWEEN 1900 AND 2100),

    CONSTRAINT chk_dim_date_key
        CHECK (
            date_key = TO_CHAR(full_date, 'YYYYMMDD')::INTEGER
        )

);


-- ============================================================
-- COMMENTAIRES DE DOCUMENTATION
-- ============================================================

COMMENT ON TABLE analytics.dim_date IS
'Dimension temporelle du projet Retail Intelligence. Une ligne par jour calendaire.';

COMMENT ON COLUMN analytics.dim_date.date_key IS
'Clé primaire au format YYYYMMDD.';

COMMENT ON COLUMN analytics.dim_date.full_date IS
'Date calendaire complète.';

COMMENT ON COLUMN analytics.dim_date.day_of_week IS
'Jour de la semaine selon la norme ISO : lundi = 1, dimanche = 7.';

COMMENT ON COLUMN analytics.dim_date.is_weekend IS
'Indique si la date correspond à un samedi ou un dimanche.';


-- ============================================================
-- VERIFICATION DE LA CREATION
-- ============================================================

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'analytics'
  AND table_name = 'dim_date';


-- ============================================================
-- ANALYTICS : CREATION DE LA DIMENSION PRODUIT
-- Table : analytics.dim_product
-- Grain : une ligne par stock_code distinct
-- Source : staging.online_retail_clean
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.dim_product (

    product_key BIGINT GENERATED ALWAYS AS IDENTITY,

    stock_code VARCHAR(20) NOT NULL,

    product_description TEXT,

    CONSTRAINT pk_dim_product
        PRIMARY KEY (product_key),

    CONSTRAINT uq_dim_product_stock_code
        UNIQUE (stock_code)

);

-- Documentation de la table
COMMENT ON TABLE analytics.dim_product IS
'Dimension produit contenant une ligne par code produit distinct.';

COMMENT ON COLUMN analytics.dim_product.product_key IS
'Clé primaire technique générée automatiquement.';

COMMENT ON COLUMN analytics.dim_product.stock_code IS
'Code produit d origine provenant de la source.';

COMMENT ON COLUMN analytics.dim_product.product_description IS
'Description de référence sélectionnée selon la règle métier BR024.';

-- verification de la création de la table
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name = 'dim_product'
ORDER BY ordinal_position;


-- ============================================================
-- ANALYTICS : CREATION DE LA DIMENSION CLIENT
-- Table : analytics.dim_customer
-- Grain : une ligne par customer_id identifié
-- Source : staging.online_retail_clean
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.dim_customer (

    customer_key BIGINT GENERATED ALWAYS AS IDENTITY,

    customer_id VARCHAR(20),

    CONSTRAINT pk_dim_customer
        PRIMARY KEY (customer_key),

    CONSTRAINT uq_dim_customer_customer_id
        UNIQUE (customer_id),

    CONSTRAINT ck_dim_customer_key
        CHECK (customer_key >= 0)

);

-- Documentation de la table

COMMENT ON TABLE analytics.dim_customer IS
'Dimension client contenant une ligne par identifiant client identifié, ainsi qu un membre inconnu.';

COMMENT ON COLUMN analytics.dim_customer.customer_key IS
'Clé primaire technique générée automatiquement. La valeur 0 représente le client inconnu.';

COMMENT ON COLUMN analytics.dim_customer.customer_id IS
'Identifiant client provenant de la source. NULL pour le membre inconnu.';

-- verification de la création de la table
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name = 'dim_customer'
ORDER BY ordinal_position;


-- ============================================================
-- ANALYTICS : CREATION DE LA DIMENSION PAYS
-- Table : analytics.dim_country
-- Grain : une ligne par pays distinct
-- Source : staging.online_retail_clean
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics.dim_country (

    country_key BIGINT GENERATED ALWAYS AS IDENTITY,

    country_name VARCHAR(100) NOT NULL,

    CONSTRAINT pk_dim_country
        PRIMARY KEY (country_key),

    CONSTRAINT uq_dim_country_name
        UNIQUE (country_name),

    CONSTRAINT ck_dim_country_name
        CHECK (BTRIM(country_name) <> '')

);

-- Documentation de la table

COMMENT ON TABLE analytics.dim_country IS
'Dimension pays contenant une ligne par valeur distincte du pays provenant de la source.';

COMMENT ON COLUMN analytics.dim_country.country_key IS
'Clé primaire technique générée automatiquement.';

COMMENT ON COLUMN analytics.dim_country.country_name IS
'Nom du pays conservé conformément à la valeur présente dans la source.';

-- verification de la création de la table
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name = 'dim_country'
ORDER BY ordinal_position;