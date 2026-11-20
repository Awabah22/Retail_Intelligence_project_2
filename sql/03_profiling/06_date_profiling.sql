
-- ============================================================
-- DPF-006.0 : INSPECTION DU FORMAT DES DATES
-- Objectif : examiner les valeurs de invoice_date avant conversion
-- ============================================================

-- 1. Afficher les 20 premières dates
SELECT
    invoice_date
FROM raw.online_retail_source
LIMIT 20;


-- 2. Identifier les formats qui ne correspondent pas
-- au format attendu : M/D/YYYY H:MI ou MM/DD/YYYY HH:MI

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE BTRIM(invoice_date)
        ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'
    ) AS expected_format,

    COUNT(*) FILTER (
        WHERE BTRIM(invoice_date)
        !~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'
    ) AS unexpected_format

FROM raw.online_retail_source;


-- 3. Afficher les éventuelles dates au format inattendu
SELECT
    invoice_date
FROM raw.online_retail_source
WHERE BTRIM(invoice_date)
      !~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'
LIMIT 50;


-- ============================================================
-- DPF-006.1 : CONVERSION ET VALIDATION DES DATES
-- Objectif : vérifier que les dates peuvent être converties
-- en véritables valeurs TIMESTAMP
-- ============================================================


-- ============================================================
-- DPF-006.1 : CONVERSION ET VALIDATION DES DATES
-- Format testé : DD/MM/YYYY HH24:MI
-- ============================================================

WITH date_conversion AS (
    SELECT
        invoice_date,
        CASE
            WHEN BTRIM(invoice_date)
                 ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'
            THEN
                TO_TIMESTAMP(
                    BTRIM(invoice_date),
                    'DD/MM/YYYY HH24:MI'
                )::TIMESTAMP
            ELSE NULL
        END AS invoice_timestamp

    FROM raw.online_retail_source
)

SELECT
    COUNT(*) AS total_records,

    COUNT(invoice_timestamp) AS valid_dates,

    COUNT(*) - COUNT(invoice_timestamp) AS invalid_dates,

    MIN(invoice_timestamp) AS earliest_date,

    MAX(invoice_timestamp) AS latest_date

FROM date_conversion;


-- ============================================================
-- DPF-006.2 : REPARTITION DES TRANSACTIONS PAR ANNEE
-- ============================================================

WITH date_conversion AS (
    SELECT
        TO_TIMESTAMP(
            BTRIM(invoice_date),
            'DD/MM/YYYY HH24:MI'
        )::TIMESTAMP AS invoice_timestamp

    FROM raw.online_retail_source
)

SELECT
    EXTRACT(YEAR FROM invoice_timestamp) AS transaction_year,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM date_conversion

GROUP BY EXTRACT(YEAR FROM invoice_timestamp)

ORDER BY transaction_year;


-- ============================================================
-- DPF-006.3 : REPARTITION DES TRANSACTIONS PAR MOIS
-- ============================================================

WITH date_conversion AS (
    SELECT
        TO_TIMESTAMP(
            BTRIM(invoice_date),
            'DD/MM/YYYY HH24:MI'
        )::TIMESTAMP AS invoice_timestamp

    FROM raw.online_retail_source
),

monthly_distribution AS (
    SELECT
        EXTRACT(YEAR FROM invoice_timestamp)::INTEGER AS transaction_year,
        EXTRACT(MONTH FROM invoice_timestamp)::INTEGER AS transaction_month,
        COUNT(*) AS total_records

    FROM date_conversion

    GROUP BY
        EXTRACT(YEAR FROM invoice_timestamp),
        EXTRACT(MONTH FROM invoice_timestamp)
)

SELECT
    transaction_year,
    transaction_month,
    TO_CHAR(
        MAKE_DATE(transaction_year, transaction_month, 1),
        'YYYY-MM'
    ) AS year_month,
    total_records,

    ROUND(
        total_records * 100.0 / SUM(total_records) OVER (),
        2
    ) AS percentage

FROM monthly_distribution

ORDER BY
    transaction_year,
    transaction_month;


-- ============================================================
-- DPF-006.4 : REPARTITION DES TRANSACTIONS
-- PAR JOUR DE LA SEMAINE
-- ============================================================

WITH date_conversion AS (
    SELECT
        TO_TIMESTAMP(
            BTRIM(invoice_date),
            'DD/MM/YYYY HH24:MI'
        )::TIMESTAMP AS invoice_timestamp

    FROM raw.online_retail_source
)

SELECT
    EXTRACT(ISODOW FROM invoice_timestamp)::INTEGER
        AS day_number,

    TO_CHAR(invoice_timestamp, 'FMDay')
        AS day_name,

    COUNT(*) AS total_records,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM date_conversion

GROUP BY
    EXTRACT(ISODOW FROM invoice_timestamp),
    TO_CHAR(invoice_timestamp, 'FMDay')

ORDER BY day_number;


-- ============================================================
-- DPF-006.5 : REPARTITION DES TRANSACTIONS PAR HEURE
-- ============================================================

WITH date_conversion AS (
    SELECT
        TO_TIMESTAMP(
            BTRIM(invoice_date),
            'DD/MM/YYYY HH24:MI'
        )::TIMESTAMP AS invoice_timestamp

    FROM raw.online_retail_source
)

SELECT
    EXTRACT(HOUR FROM invoice_timestamp)::INTEGER
        AS transaction_hour,

    COUNT(*) AS total_records,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM date_conversion

GROUP BY
    EXTRACT(HOUR FROM invoice_timestamp)

ORDER BY transaction_hour;
