# Traçabilité des données (Data Lineage) — Retail Intelligence

**Projet :** Retail Intelligence  
**Jeu de données :** Online Retail  
**Source :** UCI Machine Learning Repository  
**Base de données :** PostgreSQL  
**Architecture :** RAW → STAGING → ANALYTICS → Power BI  
**Statut :** Documentation initiale

---

## 1. Objectif

Ce document décrit la traçabilité des données (*Data Lineage*) du projet Retail Intelligence.

Il permet de suivre l'origine, la circulation, les transformations et l'utilisation des données tout au long du pipeline de traitement.

L'objectif est de garantir la traçabilité, la transparence, la cohérence et la fiabilité des données à travers toutes les couches de l'architecture.

## 2. Vue d'ensemble du flux de données

Le projet repose sur une architecture de données organisée en plusieurs couches :

```text
Online Retail.xlsx
       |
       v
Extraction CSV
       |
       v
Couche RAW
(raw.online_retail_source)
       |
       v
Couche STAGING
(nettoyage et transformation)
       |
       v
Couche ANALYTICS
(données prêtes pour l'analyse métier)
       |
       v
Power BI
(tableaux de bord et indicateurs clés de performance)
```

## 3. Système source

| Attribut | Description |
|---|---|
| Nom de la source | Jeu de données Online Retail |
| Format original | Excel (.xlsx) |
| Format après extraction | CSV |
| Fichier source | Online Retail.xlsx |
| Nombre d'enregistrements | 541 909 |
| Nombre de colonnes | 8 |
| Domaine des données | Commerce de détail / Commerce électronique |
| Type de source | Jeu de données transactionnelles historiques |

## 4. Couche RAW

**Table cible :** `raw.online_retail_source`

La couche RAW stocke les données originales provenant de la source, sans appliquer de transformations métier.

Les huit colonnes sources sont initialement stockées au format TEXT afin de préserver les valeurs importées et de reporter la conversion des types de données à la couche STAGING.

| Colonne source | Colonne RAW | Transformation |
|---|---|---|
| InvoiceNo | InvoiceNo | Ingestion directe |
| StockCode | StockCode | Ingestion directe |
| Description | Description | Ingestion directe |
| Quantity | Quantity | Ingestion directe |
| InvoiceDate | InvoiceDate | Ingestion directe |
| UnitPrice | UnitPrice | Ingestion directe |
| CustomerID | CustomerID | Ingestion directe |
| Country | Country | Ingestion directe |

**Méthode d'ingestion :** Importation du fichier CSV dans PostgreSQL.

**Séparateur CSV :** Point-virgule (;)

## 5. Couche STAGING

**Schéma cible :** `staging`

La couche STAGING est responsable du contrôle de la qualité des données, de leur standardisation et de leurs transformations techniques.

Les transformations prévues comprennent :

| Champ source | Transformation | Résultat attendu |
|---|---|---|
| InvoiceNo | Suppression des espaces superflus et standardisation | Identifiant de facture nettoyé |
| StockCode | Suppression des espaces superflus | Code produit standardisé |
| Description | Suppression des espaces superflus et gestion des valeurs manquantes | Description du produit nettoyée |
| Quantity | Conversion de TEXT en INTEGER | Quantité numérique |
| InvoiceDate | Conversion de TEXT en TIMESTAMP | Date et heure standardisées |
| UnitPrice | Conversion de TEXT en NUMERIC | Prix unitaire numérique |
| CustomerID | Gestion des valeurs manquantes et conversion du type | Identifiant client |
| Country | Suppression des espaces superflus et standardisation | Nom de pays nettoyé |

**Contrôles supplémentaires de la qualité des données :**

- Identifier les valeurs manquantes.
- Identifier les enregistrements en double.
- Identifier les factures annulées.
- Identifier les quantités et les prix unitaires négatifs.
- Vérifier la validité des types de données.
- Détecter les valeurs incohérentes.

**Remarque :** Ces transformations sont prévues à ce stade. Leur mise en œuvre et leur validation seront documentées au fur et à mesure de la réalisation du pipeline.

## 6. Couche ANALYTICS

**Schéma cible :** `analytics`

La couche ANALYTICS contiendra des jeux de données préparés pour les besoins de l'analyse et du reporting métier.

Les principaux objectifs analytiques prévus sont :

- Analyse de la performance des ventes.
- Analyse du chiffre d'affaires et de la rentabilité.
- Analyse de la performance des produits.
- Analyse du comportement des clients.
- Analyse géographique des ventes.
- Analyse des ventes selon les périodes.

Les indicateurs métier seront calculés à partir des données préalablement transformées et validées.

## 7. Couche de restitution — Power BI

Power BI exploitera les jeux de données provenant de la couche ANALYTICS.

Cette couche de restitution permettra de produire des tableaux de bord interactifs et des indicateurs clés de performance (KPI).

Les indicateurs prévus comprennent :

- Chiffre d'affaires total.
- Nombre total de commandes.
- Nombre total de clients.
- Nombre total de produits.
- Panier moyen.
- Chiffre d'affaires par pays.
- Chiffre d'affaires par produit.
- Évolution mensuelle du chiffre d'affaires.
- Comportement d'achat des clients.

## 8. Traçabilité et suivi des données

Chaque élément de données doit pouvoir être suivi depuis sa source d'origine jusqu'à son utilisation finale dans les analyses.

La documentation de la traçabilité sera mise à jour chaque fois qu'une nouvelle transformation, une nouvelle table ou un nouveau jeu de données destiné au reporting sera introduit.

| Couche | Objet | Rôle |
|---|---|---|
| Source | Online Retail.xlsx | Données originales |
| Extraction | Fichier CSV | Transfert des données |
| RAW | raw.online_retail_source | Stockage des données brutes |
| STAGING | Tables staging | Nettoyage et standardisation |
| ANALYTICS | Tables analytics | Données préparées pour l'analyse métier |
| Restitution | Power BI | Visualisation des données |

## 9. Gouvernance et maintenance

Les bonnes pratiques suivantes seront appliquées :

- Préserver les données sources dans la couche RAW.
- Documenter toutes les transformations.
- Maintenir la cohérence avec le dictionnaire de données (*Data Dictionary*).
- Suivre les problèmes liés à la qualité des données.
- Garantir la traçabilité entre les différentes couches.
- Mettre à jour ce document au fur et à mesure de l'évolution du pipeline.

---

**Responsable du document :** Projet Retail Intelligence  
**Type de document :** Gouvernance et traçabilité des données (Data Governance / Data Lineage)  
**Version :** 1.0