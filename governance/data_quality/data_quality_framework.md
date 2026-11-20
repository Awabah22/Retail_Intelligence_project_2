# Data Quality Framework — Retail Intelligence

**Projet :** Retail Intelligence  
**Jeu de données :** Online Retail  
**Source :** UCI Machine Learning Repository  
**Base de données :** PostgreSQL  
**Architecture :** RAW → STAGING → ANALYTICS → Power BI  
**Statut :** Cadre de qualité initial — contrôles à implémenter

---

## 1. Objectif

Ce document définit le cadre de gestion de la qualité des données (*Data Quality Framework*) du projet Retail Intelligence.

Il décrit les dimensions de qualité, les règles de contrôle, les méthodes de validation et les procédures de traitement des anomalies tout au long du pipeline de données.

L'objectif est de garantir que les données utilisées pour les analyses commerciales et les tableaux de bord Power BI soient fiables, cohérentes, exploitables et conformes aux règles métier définies.

## 2. Périmètre

Le cadre de qualité couvre les huit colonnes du dataset Online Retail :

- InvoiceNo
- StockCode
- Description
- Quantity
- InvoiceDate
- UnitPrice
- CustomerID
- Country

Les contrôles seront principalement réalisés entre les couches RAW et STAGING, avant la mise à disposition des données dans ANALYTICS.

## 3. Dimensions de la qualité des données

Six dimensions sont retenues pour évaluer la qualité des données.

| Dimension | Définition | Objectif |
|---|---|---|
| Complétude (Completeness) | Mesure la présence des informations nécessaires. | Identifier les valeurs manquantes. |
| Exactitude (Accuracy) | Évalue si les données représentent correctement les informations attendues. | Identifier les valeurs incorrectes ou non plausibles. |
| Cohérence (Consistency) | Vérifie l'absence de contradictions entre les données. | Détecter les incohérences. |
| Validité (Validity) | Vérifie le respect des formats, types et règles définis. | Garantir la conformité des valeurs. |
| Unicité (Uniqueness) | Vérifie l'absence de duplications non souhaitées. | Identifier les doublons. |
| Actualité (Timeliness) | Évalue la fraîcheur et la disponibilité des données. | Suivre la date de mise à jour des données. |

## 4. Règles de contrôle de qualité

Les règles suivantes constituent le référentiel initial des contrôles de qualité.

| ID | Champ concerné | Règle de contrôle | Résultat attendu |
|---|---|---|---|
| DQ001 | InvoiceNo | Identifier les valeurs manquantes. | Identifiants renseignés. |
| DQ002 | InvoiceNo | Identifier les factures annulées. | Annulations identifiées. |
| DQ003 | StockCode | Identifier les codes produits manquants. | Codes renseignés. |
| DQ004 | Description | Identifier les descriptions manquantes. | Valeurs manquantes documentées. |
| DQ005 | Quantity | Vérifier la conversion en entier. | Valeurs numériques valides. |
| DQ006 | Quantity | Identifier les quantités nulles ou négatives. | Valeurs catégorisées. |
| DQ007 | InvoiceDate | Vérifier la validité des dates. | Dates correctement converties. |
| DQ008 | UnitPrice | Vérifier la conversion numérique. | Valeurs numériques valides. |
| DQ009 | UnitPrice | Identifier les prix négatifs ou nuls. | Valeurs examinées. |
| DQ010 | CustomerID | Identifier les identifiants clients manquants. | Absences documentées. |
| DQ011 | Country | Identifier les pays manquants. | Valeurs renseignées. |
| DQ012 | Toutes les colonnes | Identifier les lignes entièrement dupliquées. | Doublons identifiés. |
| DQ013 | Toutes les colonnes | Vérifier la cohérence générale des données. | Anomalies documentées. |

## 5. Gestion des anomalies

Les anomalies détectées ne doivent pas entraîner automatiquement la suppression des enregistrements.

Elles doivent être analysées selon leur nature et leur impact sur les analyses métier.

### 5.1 Valeurs manquantes

Les valeurs manquantes seront identifiées et classées selon leur importance métier.

Exemples :

- CustomerID manquant : la transaction peut être conservée pour l'analyse des ventes, mais exclue de certaines analyses clients.
- Description manquante : vérifier si le StockCode permet toujours d'identifier le produit.
- InvoiceNo manquant : anomalie importante nécessitant une investigation.

### 5.2 Valeurs négatives

Les valeurs négatives doivent être interprétées selon leur contexte métier.

Exemples :

- Quantity négative : peut représenter un retour de produit.
- UnitPrice négatif : valeur à investiguer.

### 5.3 Factures annulées

Les factures dont le numéro commence par la lettre C seront identifiées comme des factures annulées.

Elles seront distinguées des transactions commerciales classiques afin d'éviter de fausser les indicateurs de ventes.

### 5.4 Doublons

Les doublons seront identifiés avant toute suppression.

Une distinction sera faite entre :

- Les doublons exacts : lignes présentant les mêmes valeurs dans toutes les colonnes.
- Les répétitions métier : transactions présentant certaines caractéristiques communes, mais pouvant correspondre à des opérations distinctes.

Aucune suppression ne sera effectuée sans validation de la règle métier correspondante.

## 6. Contrôles par couche de données

| Couche | Responsabilité |
|---|---|
| RAW | Préserver les données originales et identifier les problèmes à l'importation. |
| STAGING | Effectuer les contrôles, conversions, nettoyages et standardisations. |
| ANALYTICS | Vérifier la cohérence des données préparées pour les analyses métier. |
| Power BI | Contrôler la cohérence des indicateurs et des résultats présentés. |

## 7. Indicateurs de qualité des données

Les indicateurs suivants seront utilisés pour mesurer la qualité des données :

| Indicateur | Description |
|---|---|
| Taux de complétude | Pourcentage de valeurs renseignées. |
| Nombre de valeurs manquantes | Nombre de valeurs absentes par colonne. |
| Nombre de doublons | Nombre d'enregistrements dupliqués identifiés. |
| Taux de validité | Pourcentage de valeurs respectant les règles définies. |
| Nombre d'anomalies | Nombre de problèmes détectés lors des contrôles. |
| Taux de conformité | Pourcentage d'enregistrements respectant les règles applicables. |

Les seuils d'acceptation seront définis après le profilage initial des données.

## 8. Gestion et suivi des problèmes de qualité

Chaque anomalie détectée devra être documentée avec les informations suivantes :

- Identifiant du contrôle.
- Champ concerné.
- Type d'anomalie.
- Nombre d'enregistrements concernés.
- Niveau de gravité.
- Action corrective proposée.
- Statut du traitement.

Les anomalies seront classées selon trois niveaux de gravité :

| Niveau | Signification | Action |
|---|---|---|
| Critique | Anomalie susceptible de compromettre la fiabilité des analyses. | Investigation prioritaire. |
| Élevé | Anomalie ayant un impact potentiel sur certains indicateurs. | Correction ou traitement documenté. |
| Modéré | Anomalie sans impact majeur identifié sur les analyses principales. | Surveillance et documentation. |

## 9. Gouvernance et maintenance

Les pratiques suivantes seront appliquées :

- Préserver l'intégrité des données sources dans RAW.
- Documenter les règles de qualité.
- Effectuer les contrôles avant les transformations métier.
- Ne pas supprimer automatiquement les enregistrements présentant des anomalies.
- Documenter les corrections et les décisions métier.
- Maintenir la cohérence avec le Data Dictionary et le Data Lineage.
- Mettre à jour le framework lorsque de nouvelles règles sont introduites.

## 10. Statut de mise en œuvre

| Élément | Statut |
|---|---|
| Définition des dimensions de qualité | Défini |
| Identification des règles de contrôle | Défini |
| Définition des méthodes de traitement | Défini |
| Profilage des données | À réaliser |
| Implémentation des contrôles SQL | À réaliser |
| Validation des résultats | À réaliser |
| Définition des seuils d'acceptation | À réaliser |
| Suivi des indicateurs de qualité | À réaliser |

---

**Responsable du document :** Projet Retail Intelligence  
**Type de document :** Gouvernance et qualité des données (Data Governance / Data Quality)  
**Version :** 1.0