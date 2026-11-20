# Architecture technique – Retail Intelligence

## 1. Présentation générale

L'architecture de Retail Intelligence repose sur une organisation des données en plusieurs couches afin de faciliter leur stockage, leur exploration, leur préparation et leur exploitation analytique.

Le projet utilise PostgreSQL comme système de gestion de base de données et Power BI comme outil de visualisation et d'analyse.

L'organisation logique du flux de données est la suivante :

**Source → RAW → STAGING → ANALYTICS → Power BI**

## 2. Vue d'ensemble de l'architecture

```text
             SOURCE DE DONNÉES
          UCI Online Retail.xlsx
                    |
                    v
              CSV / IMPORT
                    |
                    v
             POSTGRESQL 18
                    |
          +---------+---------+
          |                   |
          v                   |
       RAW SCHEMA             |
          |                   |
          |                   |
          v                   |
     STAGING SCHEMA           |
          |                   |
          v                   |
    ANALYTICS SCHEMA          |
          |                   |
          v                   |
                POWER BI
          |
          v
     TABLEAU DE BORD
```

Cette représentation décrit le flux logique de l'architecture. Elle ne signifie pas que toutes les couches ont nécessairement fait l'objet de transformations matérialisées dans PostgreSQL.

## 3. Source des données

La source utilisée est le jeu de données Online Retail de l'UCI Machine Learning Repository.

Le fichier original est fourni au format Excel. Il a été utilisé comme point de départ pour l'importation des transactions dans PostgreSQL.

Les données contiennent notamment :

- InvoiceNo
- StockCode
- Description
- Quantity
- InvoiceDate
- UnitPrice
- CustomerID
- Country

## 4. Couche RAW

La couche RAW constitue la zone de stockage des données sources importées.

Dans PostgreSQL, elle est représentée par le schéma `raw`.

Table principale :

`raw.online_retail_source`

Caractéristiques :

- Conservation des 541 909 lignes du jeu de données.
- Présence des huit colonnes d'origine.
- Colonnes initialement définies en type TEXT.
- Absence de transformations destructives lors du chargement initial.

Cette couche sert de référence pour les analyses et les contrôles de qualité.

## 5. Couche STAGING

La couche STAGING représente l'espace logique destiné à la préparation des données avant leur utilisation analytique.

Son rôle est notamment de permettre :

- La conversion des types de données.
- L'harmonisation des formats.
- Le traitement documenté des valeurs manquantes.
- L'identification des transactions particulières.
- La préparation des données pour les analyses.

Les règles de transformation doivent préserver la traçabilité avec les données RAW.

Les opérations de nettoyage ne doivent pas conduire à supprimer automatiquement les transactions négatives, les annulations ou les répétitions sans analyse préalable.

## 6. Couche ANALYTICS

La couche ANALYTICS représente la zone destinée à organiser les données pour les besoins de l'analyse métier.

Elle peut accueillir les structures analytiques nécessaires à la production des indicateurs, à l'analyse des ventes, des produits, des clients et des performances géographiques.

Cette couche constitue le niveau logique de préparation des données pour leur exploitation dans Power BI.

## 7. Couche de visualisation : Power BI

Power BI constitue la couche de restitution et d'exploration des résultats.

Le rapport est organisé en six pages :

1. Executive Overview
2. Sales Performance
3. Product Analysis
4. Customer Analysis
5. Geographic Analysis
6. Cancellations & Negative Movements

Les indicateurs sont construits à l'aide de mesures DAX.

Les filtres Année, Mois et Pays sont synchronisés entre les pages afin de permettre une exploration cohérente des données.

## 8. Gouvernance et documentation

La documentation accompagne l'architecture technique et facilite la compréhension du projet.

Elle comprend :

- Un dictionnaire de données pour décrire les colonnes.
- Un document de Data Lineage pour représenter le parcours des données.
- Un rapport de Data Profiling pour présenter les résultats des contrôles exploratoires.

## 9. Principes architecturaux

L'architecture repose sur les principes suivants :

- Séparation entre les données sources et les données préparées.
- Conservation des données brutes.
- Traçabilité des transformations.
- Contrôle de la qualité des données.
- Organisation des données selon les besoins analytiques.
- Séparation entre stockage, traitement et visualisation.

## 10. Technologies

- PostgreSQL 18 : stockage et gestion des données.
- SQL : exploration et analyse des données.
- Power BI : visualisation et restitution.
- DAX : calcul des indicateurs.
- Excel / CSV : formats de données sources et d'importation.