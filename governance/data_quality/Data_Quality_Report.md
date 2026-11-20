# Data Quality Report — Retail Intelligence

**Version :** 1.0  
**Couche concernée :** RAW  
**Source :** UCI Online Retail Dataset  
**Période des données :** 01/12/2010 – 09/12/2011  
**Volume source :** 541 909 lignes

## 1. Objectif

Ce rapport présente les résultats du premier audit de qualité réalisé sur la table `raw.online_retail_source`.

L'objectif est d'identifier les problèmes de qualité, de comprendre leur impact métier et de préparer les règles de transformation de la couche STAGING.

Aucune donnée source n'a été supprimée ou modifiée durant cet audit.

## 2. Résultats des contrôles

| Contrôle | Résultat | Observation |
|---|---:|---|
| Nombre de lignes | 541 909 | Conforme au volume source |
| Descriptions manquantes | 1 454 | Complétude à examiner |
| CustomerID manquants | 135 080 | Identification client incomplète |
| Groupes de doublons exacts | 4 879 | Répétitions à examiner |
| Lignes supplémentaires dues aux doublons | 5 268 | Unicité à examiner |
| Quantités négatives | 10 624 | Retours ou ajustements possibles |
| Quantités nulles ou égales à zéro | 0 | Aucun cas détecté |
| Prix négatifs | 2 | Ajustements comptables possibles |
| Prix nuls | 2 515 | Opérations à classifier |
| Lignes avec facture commençant par C | 9 288 | Annulations à distinguer |

## 3. Qualité des données

### 3.1 Complétude

- `description` : 1 454 valeurs manquantes.
- `customer_id` : 135 080 valeurs manquantes.
- Les six autres colonnes ne présentent aucune valeur manquante détectée.

### 3.2 Unicité

4 879 groupes de doublons exacts ont été identifiés, représentant 5 268 lignes supplémentaires.

Une analyse métier complémentaire est nécessaire avant toute suppression.

### 3.3 Validité des données

- Les prix utilisent une virgule comme séparateur décimal.
- Deux prix négatifs correspondent à des opérations intitulées « Adjust bad debt ».
- Les prix nuls nécessitent une classification.
- Les quantités négatives peuvent correspondre à des retours ou des annulations.

### 3.4 Cohérence temporelle

La période couverte est comprise entre le 1er décembre 2010 et le 9 décembre 2011.

Aucune erreur de conversion de date n'a été rencontrée lors du contrôle de la période.

### 3.5 Cohérence géographique

Le Royaume-Uni représente environ 91,43 % des lignes.

Certaines valeurs géographiques nécessitent une documentation et une normalisation éventuelle, notamment :
- EIRE
- RSA
- European Community
- Unspecified

## 4. Règles de traitement proposées pour STAGING

| Problème | Traitement envisagé |
|---|---|
| Prix avec virgule décimale | Normaliser puis convertir en NUMERIC |
| Quantité stockée en texte | Convertir en INTEGER |
| Date stockée en texte | Convertir en TIMESTAMP |
| CustomerID manquant | Conserver la transaction et prévoir un client inconnu si nécessaire |
| Description manquante | Examiner le produit et conserver la valeur source |
| Quantité négative | Identifier les retours et annulations |
| Facture commençant par C | Identifier les transactions annulées |
| Prix négatif | Isoler les ajustements comptables |
| Prix nul | Classifier les opérations |
| Doublons exacts | Analyser avant toute déduplication |
| Pays particuliers | Documenter et normaliser selon les règles métier |

## 5. Conclusion

Le volume de données importé est conforme au dataset source.

Plusieurs problèmes de complétude, d'unicité et de validité ont été identifiés. Certains correspondent potentiellement à des opérations commerciales ou comptables légitimes.

Les données RAW seront conservées sans modification. Les règles de nettoyage, de typage et de classification seront appliquées dans la couche STAGING, avec traçabilité des transformations.

**Statut :** Audit initial RAW réalisé — classification métier et contrôles complémentaires à poursuivre.
