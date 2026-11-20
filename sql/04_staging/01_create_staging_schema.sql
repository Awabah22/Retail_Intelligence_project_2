```sql
-- ============================================================
-- PROJET : RETAIL INTELLIGENCE
-- PHASE  : STAGING
-- FICHIER: 01_create_staging_schema.sql
-- OBJET  : Creation du schema STAGING
-- ============================================================

-- Creation du schema STAGING s'il n'existe pas
CREATE SCHEMA IF NOT EXISTS staging;

-- Verification
SELECT
    schema_name
FROM information_schema.schemata
WHERE schema_name = 'staging';
```