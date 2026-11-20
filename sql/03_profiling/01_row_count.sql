
/*
============================================================
PROJECT : RETAIL INTELLIGENCE
MODULE  : DATA PROFILING
FILE    : 01_row_count.sql
PURPOSE : Vérification du nombre d'enregistrements
DATABASE: PostgreSQL
TABLE   : raw.online_retail_source
============================================================
*/


-- DPF-001 : Nombre total de lignes dans la table RAW

SELECT
    COUNT(*) AS total_records
FROM raw.online_retail_source;


-- DPF-001.1 : Vérification du nombre de colonnes

SELECT
    COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'online_retail_source';


-- DPF-001.2 : Vérification de la structure de la table

SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'online_retail_source'
ORDER BY ordinal_position;
