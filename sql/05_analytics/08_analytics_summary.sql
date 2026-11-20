
-- ============================================================
-- RETAIL INTELLIGENCE
-- ANALYTICS SUMMARY
-- ============================================================
-- Objectif :
-- Produire les principales analyses métier à partir du
-- modèle analytique en étoile.
--
-- Source principale :
-- analytics.fact_sales_line
--
-- Dimensions :
-- analytics.dim_date
-- analytics.dim_product
-- analytics.dim_customer
-- analytics.dim_country
--
-- Grain de la table de faits :
-- Une ligne par ligne de transaction STAGING.
--
-- DEFINITION DU CHIFFRE D'AFFAIRES :
-- invoice_type = 'Normal'
-- quantity > 0
-- unit_price > 0
--
-- IMPORTANT :
-- Aucun calcul de coût, bénéfice ou marge :
-- la source ne contient pas de données de coûts.
--
-- Ce fichier contient uniquement des requêtes SELECT.
-- Il ne modifie pas les données.
-- ============================================================


-- ============================================================
-- 01. INDICATEURS GENERAUX
-- ============================================================
-- Objectif :
-- Obtenir une vue globale de l'activité commerciale.
-- ============================================================

SELECT
    COUNT(*) AS total_transaction_lines,

    COUNT(DISTINCT invoice_no) AS total_invoices,

    COUNT(DISTINCT product_key) AS total_products,

    COUNT(DISTINCT customer_key)
        FILTER (WHERE customer_key <> 0)
        AS identified_customers,

    COUNT(DISTINCT country_key) AS total_countries,

    SUM(line_amount) FILTER (
        WHERE invoice_type = 'Normal'
          AND quantity > 0
          AND unit_price > 0
    ) AS sales_revenue,

    SUM(quantity) FILTER (
        WHERE invoice_type = 'Normal'
          AND quantity > 0
          AND unit_price > 0
    ) AS units_sold,

    COUNT(DISTINCT invoice_no) FILTER (
        WHERE invoice_type = 'Normal'
          AND quantity > 0
          AND unit_price > 0
    ) AS qualifying_sales_invoices,

    ROUND(
        (
            SUM(line_amount) FILTER (
                WHERE invoice_type = 'Normal'
                  AND quantity > 0
                  AND unit_price > 0
            )
            /
            NULLIF(
                COUNT(DISTINCT invoice_no) FILTER (
                    WHERE invoice_type = 'Normal'
                      AND quantity > 0
                      AND unit_price > 0
                ),
                0
            )
        )::NUMERIC,
        2
    ) AS average_basket,

    ROUND(
        AVG(unit_price) FILTER (
            WHERE invoice_type = 'Normal'
              AND quantity > 0
              AND unit_price > 0
        ),
        2
    ) AS average_unit_price

FROM analytics.fact_sales_line;


-- ============================================================
-- 02. ANALYSE DES FACTURES
-- ============================================================
-- Objectif :
-- Comparer les factures normales et les factures annulées.
-- ============================================================

SELECT
    invoice_type,

    COUNT(DISTINCT invoice_no) AS invoice_count,

    COUNT(*) AS transaction_lines,

    SUM(line_amount) AS total_line_amount,

    SUM(quantity) AS total_quantity

FROM analytics.fact_sales_line

GROUP BY invoice_type

ORDER BY invoice_type;


-- ============================================================
-- 03. EVOLUTION MENSUELLE DES VENTES
-- ============================================================
-- Objectif :
-- Analyser le chiffre d'affaires par mois.
-- Calculer également l'évolution par rapport au mois précédent.
-- ============================================================

WITH monthly_sales AS (

    SELECT
        d.year_number,
        d.month_number,
        d.month_name,

        SUM(f.line_amount) AS monthly_revenue,

        SUM(f.quantity) AS monthly_units_sold,

        COUNT(DISTINCT f.invoice_no) AS monthly_invoices

    FROM analytics.fact_sales_line f

    INNER JOIN analytics.dim_date d
        ON f.date_key = d.date_key

    WHERE f.invoice_type = 'Normal'
      AND f.quantity > 0
      AND f.unit_price > 0

    GROUP BY
        d.year_number,
        d.month_number,
        d.month_name

),

monthly_comparison AS (

    SELECT
        *,

        LAG(monthly_revenue) OVER (
            ORDER BY year_number, month_number
        ) AS previous_month_revenue

    FROM monthly_sales

)

SELECT
    year_number,
    month_number,
    month_name,

    monthly_revenue,
    monthly_units_sold,
    monthly_invoices,

    previous_month_revenue,

    ROUND(
        100.0 * (
            monthly_revenue - previous_month_revenue
        ) / NULLIF(previous_month_revenue, 0),
        2
    ) AS revenue_growth_percentage

FROM monthly_comparison

ORDER BY year_number, month_number;


-- ============================================================
-- 04. EVOLUTION QUOTIDIENNE DES VENTES
-- ============================================================
-- Objectif :
-- Analyser le chiffre d'affaires et les factures par jour.
-- ============================================================

SELECT
    d.full_date,
    d.day_name,

    SUM(f.line_amount) AS daily_revenue,

    SUM(f.quantity) AS daily_units_sold,

    COUNT(DISTINCT f.invoice_no) AS daily_invoices

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_date d
    ON f.date_key = d.date_key

WHERE f.invoice_type = 'Normal'
  AND f.quantity > 0
  AND f.unit_price > 0

GROUP BY
    d.full_date,
    d.day_name

ORDER BY d.full_date;


-- ============================================================
-- 05. ANALYSE DES VENTES PAR JOUR DE SEMAINE
-- ============================================================
-- Objectif :
-- Identifier les jours générant le plus de ventes.
-- ============================================================

SELECT
    d.day_of_week,
    d.day_name,

    SUM(f.line_amount) AS sales_revenue,

    SUM(f.quantity) AS units_sold,

    COUNT(DISTINCT f.invoice_no) AS invoice_count

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_date d
    ON f.date_key = d.date_key

WHERE f.invoice_type = 'Normal'
  AND f.quantity > 0
  AND f.unit_price > 0

GROUP BY
    d.day_of_week,
    d.day_name

ORDER BY d.day_of_week;


-- ============================================================
-- 06. ANALYSE DES VENTES PAR HEURE
-- ============================================================
-- Objectif :
-- Identifier les heures avec le plus d'activité commerciale.
-- ============================================================

SELECT
    invoice_hour,

    SUM(line_amount) AS sales_revenue,

    SUM(quantity) AS units_sold,

    COUNT(DISTINCT invoice_no) AS invoice_count,

    COUNT(*) AS transaction_lines

FROM analytics.fact_sales_line

WHERE invoice_type = 'Normal'
  AND quantity > 0
  AND unit_price > 0

GROUP BY invoice_hour

ORDER BY invoice_hour;


-- ============================================================
-- 07. TOP 10 DES PRODUITS PAR CHIFFRE D'AFFAIRES
-- ============================================================
-- Objectif :
-- Identifier les produits générant le plus de chiffre d'affaires.
-- ============================================================

SELECT
    p.stock_code,
    p.product_description,

    SUM(f.line_amount) AS sales_revenue,

    SUM(f.quantity) AS units_sold,

    COUNT(DISTINCT f.invoice_no) AS invoice_count

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_product p
    ON f.product_key = p.product_key

WHERE f.invoice_type = 'Normal'
  AND f.quantity > 0
  AND f.unit_price > 0

GROUP BY
    p.stock_code,
    p.product_description

ORDER BY sales_revenue DESC

LIMIT 10;


-- ============================================================
-- 08. TOP 10 DES PRODUITS PAR QUANTITES VENDUES
-- ============================================================
-- Objectif :
-- Identifier les produits les plus vendus en volume.
-- ============================================================

SELECT
    p.stock_code,
    p.product_description,

    SUM(f.quantity) AS units_sold,

    SUM(f.line_amount) AS sales_revenue,

    COUNT(DISTINCT f.invoice_no) AS invoice_count

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_product p
    ON f.product_key = p.product_key

WHERE f.invoice_type = 'Normal'
  AND f.quantity > 0
  AND f.unit_price > 0

GROUP BY
    p.stock_code,
    p.product_description

ORDER BY units_sold DESC

LIMIT 10;


-- ============================================================
-- 09. PRODUITS CONCERNES PAR DES OPERATIONS
--     A QUANTITE NEGATIVE
-- ============================================================
-- Objectif :
-- Identifier les produits concernés par des quantités négatives.
-- ATTENTION :
-- Ne pas assimiler automatiquement ces opérations à des retours.
-- ============================================================

SELECT
    p.stock_code,
    p.product_description,

    COUNT(*) AS negative_quantity_lines,

    SUM(f.quantity) AS net_negative_quantity,

    SUM(f.line_amount) AS associated_line_amount,

    COUNT(DISTINCT f.invoice_no) AS invoice_count

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_product p
    ON f.product_key = p.product_key

WHERE f.has_negative_quantity = TRUE

GROUP BY
    p.stock_code,
    p.product_description

ORDER BY negative_quantity_lines DESC

LIMIT 20;


-- ============================================================
-- 10. ANALYSE GENERALE DES CLIENTS
-- ============================================================
-- Objectif :
-- Analyser les ventes réalisées auprès des clients identifiés.
-- Le membre inconnu (customer_key = 0) est exclu.
-- ============================================================

SELECT
    COUNT(DISTINCT f.customer_key) AS identified_customers,

    SUM(f.line_amount) AS sales_revenue,

    COUNT(DISTINCT f.invoice_no) AS invoice_count,

    SUM(f.quantity) AS units_sold,

    ROUND(
        SUM(f.line_amount)
        /
        NULLIF(COUNT(DISTINCT f.invoice_no), 0),
        2
    ) AS average_basket_per_invoice,

    ROUND(
        SUM(f.line_amount)
        /
        NULLIF(COUNT(DISTINCT f.customer_key), 0),
        2
    ) AS average_revenue_per_customer

FROM analytics.fact_sales_line f

WHERE f.customer_key <> 0
  AND f.invoice_type = 'Normal'
  AND f.quantity > 0
  AND f.unit_price > 0;


-- ============================================================
-- 11. TOP 20 DES CLIENTS PAR CHIFFRE D'AFFAIRES
-- ============================================================
-- Objectif :
-- Identifier les clients générant le plus de chiffre d'affaires.
-- Les clients inconnus sont exclus.
-- ============================================================

SELECT
    c.customer_id,

    SUM(f.line_amount) AS sales_revenue,

    COUNT(DISTINCT f.invoice_no) AS invoice_count,

    SUM(f.quantity) AS units_sold,

    ROUND(
        SUM(f.line_amount)
        /
        NULLIF(COUNT(DISTINCT f.invoice_no), 0),
        2
    ) AS average_basket

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_customer c
    ON f.customer_key = c.customer_key

WHERE f.customer_key <> 0
  AND f.invoice_type = 'Normal'
  AND f.quantity > 0
  AND f.unit_price > 0

GROUP BY c.customer_id

ORDER BY sales_revenue DESC

LIMIT 20;


-- ============================================================
-- 12. ANALYSE GEOGRAPHIQUE DES VENTES
-- ============================================================
-- Objectif :
-- Analyser le chiffre d'affaires, les quantités et les factures
-- par pays.
-- ============================================================

SELECT
    co.country_name,

    SUM(f.line_amount) AS sales_revenue,

    SUM(f.quantity) AS units_sold,

    COUNT(DISTINCT f.invoice_no) AS invoice_count,

    COUNT(DISTINCT f.customer_key)
        FILTER (WHERE f.customer_key <> 0)
        AS identified_customers

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_country co
    ON f.country_key = co.country_key

WHERE f.invoice_type = 'Normal'
  AND f.quantity > 0
  AND f.unit_price > 0

GROUP BY co.country_name

ORDER BY sales_revenue DESC;


-- ============================================================
-- 13. ANALYSE DES FACTURES ANNULEES
-- ============================================================
-- Objectif :
-- Mesurer les factures annulées séparément des ventes normales.
-- ============================================================

SELECT
    COUNT(DISTINCT invoice_no) AS cancelled_invoice_count,

    COUNT(*) AS cancelled_transaction_lines,

    SUM(quantity) AS cancelled_total_quantity,

    SUM(line_amount) AS cancelled_total_line_amount,

    COUNT(*) FILTER (
        WHERE line_amount > 0
    ) AS cancelled_positive_amount_lines,

    COUNT(*) FILTER (
        WHERE line_amount < 0
    ) AS cancelled_negative_amount_lines,

    COUNT(*) FILTER (
        WHERE line_amount = 0
    ) AS cancelled_zero_amount_lines

FROM analytics.fact_sales_line

WHERE invoice_type = 'Cancelled';


-- ============================================================
-- 14. INDICATEURS DE QUALITE DES DONNEES
-- ============================================================
-- Objectif :
-- Suivre les principales anomalies et particularités des données.
-- ============================================================ 

SELECT
    COUNT(*) AS total_transaction_lines,

    COUNT(*) FILTER (
        WHERE f.has_negative_quantity
    ) AS negative_quantity_lines,

    COUNT(*) FILTER (
        WHERE f.has_zero_unit_price
    ) AS zero_unit_price_lines,

    COUNT(*) FILTER (
        WHERE f.has_negative_unit_price
    ) AS negative_unit_price_lines,

    COUNT(*) FILTER (
        WHERE f.customer_key = 0
    ) AS lines_without_identified_customer,

    COUNT(*) FILTER (
        WHERE s.description IS NULL
    ) AS lines_with_missing_source_description,

    COUNT(*) FILTER (
        WHERE p.product_description IS NULL
    ) AS lines_without_reference_description,

    COUNT(*) FILTER (
        WHERE f.invoice_type = 'Cancelled'
    ) AS cancelled_transaction_lines

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_product p
    ON f.product_key = p.product_key

INNER JOIN staging.online_retail_clean s
    ON f.staging_id = s.staging_id;



-- ============================================================
-- 15. ANALYSE DES PRIX UNITAIRES NEGATIFS
-- ============================================================
-- Objectif :
-- Examiner les lignes présentant un prix unitaire négatif.
-- ============================================================

SELECT
    f.invoice_no,
    f.invoice_type,
    p.stock_code,
    p.product_description,
    f.quantity,
    f.unit_price,
    f.line_amount,
    f.has_negative_unit_price

FROM analytics.fact_sales_line f

INNER JOIN analytics.dim_product p
    ON f.product_key = p.product_key

WHERE f.has_negative_unit_price = TRUE

ORDER BY f.invoice_no, p.stock_code;


-- ============================================================
-- FIN DU FICHIER ANALYTICS SUMMARY
-- ============================================================

-- verification du produit 23843
SELECT
    f.invoice_no,
    f.invoice_type,
    f.quantity,
    f.unit_price,
    f.line_amount,
    f.has_negative_quantity,
    f.has_zero_unit_price,
    f.has_negative_unit_price
FROM analytics.fact_sales_line f
INNER JOIN analytics.dim_product p
    ON f.product_key = p.product_key
WHERE p.stock_code = '23843'
ORDER BY ABS(f.quantity) DESC;

-- Vérification B — Transaction à 6 h
SELECT
    f.invoice_no,
    f.invoice_type,
    p.stock_code,
    p.product_description,
    f.quantity,
    f.unit_price,
    f.line_amount
FROM analytics.fact_sales_line f
INNER JOIN analytics.dim_product p
    ON f.product_key = p.product_key
WHERE f.invoice_hour = 6
  AND f.quantity > 0
  AND f.unit_price > 0
ORDER BY f.invoice_no;

-- verification de la répartition du chiffre d'affaires entre clients identifiés et non identifiés.
SELECT
    CASE
        WHEN customer_key = 0 THEN 'Unknown customer'
        ELSE 'Identified customer'
    END AS customer_status,

    COUNT(*) AS transaction_lines,
    COUNT(DISTINCT invoice_no) AS invoice_count,
    SUM(line_amount) AS sales_revenue,
    SUM(quantity) AS units_sold

FROM analytics.fact_sales_line

WHERE invoice_type = 'Normal'
  AND quantity > 0
  AND unit_price > 0

GROUP BY
    CASE
        WHEN customer_key = 0 THEN 'Unknown customer'
        ELSE 'Identified customer'
    END

ORDER BY customer_status;