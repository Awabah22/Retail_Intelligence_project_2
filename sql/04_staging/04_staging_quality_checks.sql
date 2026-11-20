# ============================================================
# PROJET : RETAIL INTELLIGENCE
# PHASE  : STAGING
# FICHIER: 04_staging_quality_checks.sql
# OBJET  : Contrôles qualité des données STAGING
# ============================================================


-- ============================================================
-- STQ001 : COMPLETUDE
-- Objectif : Vérifier les valeurs obligatoires manquantes.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE invoice_no IS NULL) AS missing_invoice_no,
    COUNT(*) FILTER (WHERE stock_code IS NULL) AS missing_stock_code,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE invoice_date IS NULL) AS missing_invoice_date,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS missing_unit_price,
    COUNT(*) FILTER (WHERE country IS NULL) AS missing_country

FROM staging.online_retail_clean;


-- ============================================================
-- STQ002 : VALIDITE
-- Objectif : Identifier les valeurs numériques particulières.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE quantity = 0) AS zero_quantity,

    COUNT(*) FILTER (WHERE quantity < 0) AS negative_quantity,

    COUNT(*) FILTER (WHERE unit_price = 0) AS zero_unit_price,

    COUNT(*) FILTER (WHERE unit_price < 0) AS negative_unit_price,

    COUNT(*) FILTER (
        WHERE line_amount <> quantity * unit_price
    ) AS incorrect_line_amount

FROM staging.online_retail_clean;


-- ============================================================
-- STQ003 : COHERENCE
-- Objectif : Vérifier la cohérence du type de facture.
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE LEFT(invoice_no, 1) = 'C'
          AND invoice_type <> 'Cancelled'
    ) AS incorrect_cancelled_type,

    COUNT(*) FILTER (
        WHERE LEFT(invoice_no, 1) <> 'C'
          AND invoice_type <> 'Normal'
    ) AS incorrect_normal_type,

    COUNT(*) FILTER (
        WHERE invoice_type NOT IN ('Normal', 'Cancelled')
    ) AS invalid_invoice_type

FROM staging.online_retail_clean;


-- ============================================================
-- STQ004 : EXACTITUDE
-- Objectif : Vérifier les montants calculés.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE line_amount = quantity * unit_price
    ) AS correct_amounts,

    COUNT(*) FILTER (
        WHERE line_amount <> quantity * unit_price
    ) AS incorrect_amounts,

    SUM(line_amount) AS total_transaction_amount

FROM staging.online_retail_clean;


-- ============================================================
-- STQ005 : UNICITE
-- Objectif : Identifier les lignes métier exactement répétées.
-- Aucune suppression automatique des doublons.
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
        invoice_type,
        line_amount,
        COUNT(*) AS occurrence_count

    FROM staging.online_retail_clean

    GROUP BY
        invoice_no,
        stock_code,
        description,
        quantity,
        invoice_date,
        unit_price,
        customer_id,
        country,
        invoice_type,
        line_amount

    HAVING COUNT(*) > 1
)

SELECT
    COUNT(*) AS duplicate_groups,

    SUM(occurrence_count) AS rows_in_duplicate_groups,

    SUM(occurrence_count - 1) AS excess_duplicate_rows,

    MAX(occurrence_count) AS maximum_occurrences

FROM duplicate_groups;


-- ============================================================
-- STQ006 : INTEGRITE TECHNIQUE
-- Objectif : Vérifier l'unicité de l'identifiant technique.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(staging_id) AS non_null_staging_ids,

    COUNT(DISTINCT staging_id) AS distinct_staging_ids,

    COUNT(*) - COUNT(DISTINCT staging_id) AS duplicate_staging_ids

FROM staging.online_retail_clean;


-- ============================================================
-- STQ007 : TRACABILITE
-- Objectif : Vérifier les informations de chargement.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE loaded_at IS NULL
    ) AS missing_loaded_at,

    MIN(loaded_at) AS first_load_timestamp,

    MAX(loaded_at) AS last_load_timestamp

FROM staging.online_retail_clean;


-- ============================================================
-- STQ008 : ANOMALIES METIER
-- Objectif : Identifier les situations nécessitant une analyse.
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE description IS NULL
    ) AS missing_description,

    COUNT(*) FILTER (
        WHERE has_negative_quantity = TRUE
    ) AS negative_quantity_flags,

    COUNT(*) FILTER (
        WHERE has_zero_unit_price = TRUE
    ) AS zero_price_flags,

    COUNT(*) FILTER (
        WHERE invoice_type = 'Cancelled'
          AND line_amount >= 0
    ) AS cancelled_invoices_non_negative_amount,

    COUNT(*) FILTER (
        WHERE invoice_type = 'Normal'
          AND line_amount < 0
    ) AS normal_invoices_negative_amount

FROM staging.online_retail_clean;


