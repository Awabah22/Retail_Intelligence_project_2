
-- ============================================================
-- Fichier : 01_create_analytics_schema.sql
-- Projet  : Retail Intelligence
-- Objectif : Création du schéma ANALYTICS
-- Base de données : retail_intelligence
-- ============================================================

-- Création du schéma analytique
CREATE SCHEMA IF NOT EXISTS analytics;

-- Vérification de la création du schéma
SELECT
    schema_name
FROM information_schema.schemata
WHERE schema_name = 'analytics';
