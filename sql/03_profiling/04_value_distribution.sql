
/*
============================================================
PROJECT : RETAIL INTELLIGENCE
MODULE  : DATA PROFILING
FILE    : 04_value_distribution.sql
PURPOSE : Analyse de la distribution des valeurs
DATABASE: PostgreSQL
TABLE   : raw.online_retail_source
============================================================

ANALYSES:
1. Distribution des lignes par pays
2. Distribution des lignes par produit
3. Distribution des lignes par client
4. Distribution des lignes par facture

NOTE:
COUNT(*) représente le nombre de lignes, et non le
nombre de commandes ou de factures.
============================================================
*/


-- ==========================================================
-- DPF-002.1 : DISTRIBUTION PAR PAYS
-- Objectif : mesurer le volume de lignes par pays.
-- ==========================================================

WITH country_distribution AS (
    SELECT
        COALESCE(
            NULLIF(BTRIM(country), ''),
            '[VALEUR MANQUANTE]'
        ) AS country,
        COUNT(*) AS total_rows
    FROM raw.online_retail_source
    GROUP BY 1
)

SELECT
    country,
    total_rows,
    ROUND(
        100.0 * total_rows / SUM(total_rows) OVER (),
        2
    ) AS percentage
FROM country_distribution
ORDER BY total_rows DESC;


-- ==========================================================
-- DPF-002.2 : DISTRIBUTION PAR PRODUIT
-- Objectif : identifier les codes produits les plus fréquents.
-- Limitation : affichage des 20 premiers résultats.
-- ==========================================================

SELECT
    COALESCE(
        NULLIF(BTRIM(stock_code), ''),
        '[VALEUR MANQUANTE]'
    ) AS stock_code,
    COUNT(*) AS total_rows
FROM raw.online_retail_source
GROUP BY 1
ORDER BY total_rows DESC
LIMIT 20;


-- ==========================================================
-- DPF-002.3 : DISTRIBUTION PAR CLIENT
-- Objectif : identifier les clients ayant le plus de lignes.
-- Les clients sans identifiant sont également affichés.
-- ==========================================================

SELECT
    COALESCE(
        NULLIF(BTRIM(customer_id), ''),
        '[VALEUR MANQUANTE]'
    ) AS customer_id,
    COUNT(*) AS total_rows
FROM raw.online_retail_source
GROUP BY 1
ORDER BY total_rows DESC
LIMIT 20;


-- ==========================================================
-- DPF-002.4 : DISTRIBUTION PAR FACTURE
-- Objectif : connaître le nombre de lignes par facture.
-- Limitation : affichage des 20 premières factures.
-- ==========================================================

SELECT
    COALESCE(
        NULLIF(BTRIM(invoice_no), ''),
        '[VALEUR MANQUANTE]'
    ) AS invoice_no,
    COUNT(*) AS total_rows
FROM raw.online_retail_source
GROUP BY 1
ORDER BY total_rows DESC
LIMIT 20;
