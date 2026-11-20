
-- Projet : Retail Intelligence
-- Couche : RAW
-- Objectif : conserver les données sources sans transformation

CREATE TABLE IF NOT EXISTS raw.online_retail_source (
    invoice_no    TEXT,
    stock_code    TEXT,
    description   TEXT,
    quantity      TEXT,
    invoice_date  TEXT,
    unit_price    TEXT,
    customer_id   TEXT,
    country       TEXT
);

-- Documentation de la table
COMMENT ON TABLE raw.online_retail_source IS
'Table de réception des données originales du dataset Online Retail UCI.';

COMMENT ON COLUMN raw.online_retail_source.invoice_no IS
'Numéro de facture source.';

COMMENT ON COLUMN raw.online_retail_source.stock_code IS
'Identifiant du produit source.';

COMMENT ON COLUMN raw.online_retail_source.customer_id IS
'Identifiant client source, potentiellement manquant.';
