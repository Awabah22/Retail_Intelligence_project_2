# Méthodologie – Retail Intelligence

## 1. Introduction

Ce document présente la démarche méthodologique suivie dans le cadre du projet Retail Intelligence.

L'objectif est de décrire les différentes étapes de travail, depuis la découverte du jeu de données jusqu'à la création du tableau de bord interactif.

La démarche privilégie une approche progressive, fondée sur l'exploration des données, l'évaluation de leur qualité et l'analyse métier.

## 2. Étape 1 – Compréhension du besoin

La première étape consiste à définir les objectifs analytiques du projet.

Les principales questions étudiées sont :

- Comment évoluent les ventes dans le temps ?
- Quels produits contribuent le plus à l'activité commerciale ?
- Quels clients sont les plus actifs ?
- Quels pays représentent la plus grande part des transactions ?
- Quelle est l'importance des factures annulées ?
- Comment interpréter les quantités et les montants négatifs ?

Ces questions servent de base à la définition des axes d'analyse et des indicateurs.

## 3. Étape 2 – Collecte et importation des données

Le jeu de données Online Retail est récupéré depuis l'UCI Machine Learning Repository.

Le fichier source est ensuite préparé pour son importation dans PostgreSQL.

Les données sont chargées dans la table :

`raw.online_retail_source`

La structure RAW conserve les huit colonnes du fichier source et les valeurs initiales sont stockées en TEXT.

Cette approche permet de préserver les données telles qu'elles ont été importées avant toute transformation.

## 4. Étape 3 – Data Profiling

Le Data Profiling constitue une étape essentielle du projet.

Il permet d'évaluer la structure, la complétude, la cohérence et les caractéristiques des données avant leur utilisation analytique.

Plusieurs contrôles SQL ont été réalisés.

### 4.1 Volume et structure

- Comptage du nombre total de lignes.
- Vérification du nombre de colonnes.
- Identification de la période couverte par les transactions.

### 4.2 Valeurs manquantes

Analyse des colonnes présentant des valeurs absentes, notamment :

- CustomerID
- Description

### 4.3 Cardinalité

Calcul du nombre de valeurs distinctes pour chaque colonne afin de mieux comprendre la structure des données.

### 4.4 Distribution des valeurs

Analyse des pays, des produits et des factures les plus représentés dans le jeu de données.

### 4.5 Profilage numérique

Étude des colonnes Quantity et UnitPrice à travers :

- Le minimum et le maximum.
- La moyenne et la médiane.
- Les valeurs négatives.
- Les valeurs nulles.
- Les valeurs extrêmes.

### 4.6 Profilage des dates

Vérification du format des dates, de leur conversion et de leur répartition par année, mois, jour de semaine et heure.

### 4.7 Détection des doublons

Identification des répétitions exactes et partielles afin d'évaluer leur fréquence et leur nature.

Une répétition n'est pas automatiquement considérée comme une erreur : plusieurs opérations peuvent concerner une même facture et un même produit.

### 4.8 Analyse des factures et mouvements particuliers

Étude des factures normales, des factures annulées, des montants nuls et négatifs ainsi que des quantités négatives.

Une attention particulière est accordée aux transactions inhabituelles afin d'éviter de les interpréter incorrectement comme des ventes classiques ou des retours clients.

Les résultats détaillés et leurs interprétations sont présentés dans :

`governance/data_quality/profiling_report.md`

## 5. Étape 4 – Préparation et organisation analytique

Les résultats du Data Profiling permettent d'identifier les points de vigilance nécessaires à la préparation des données.

Les principaux éléments à considérer sont :

- La conversion des colonnes vers des types adaptés.
- La gestion documentée des valeurs manquantes.
- La conservation des informations sources.
- La distinction entre factures normales et annulées.
- L'identification des mouvements de quantités négatives.
- L'analyse des prix nuls et négatifs.
- La prudence dans le traitement des doublons.

Les décisions de transformation doivent être fondées sur les résultats observés et non sur des suppositions.

## 6. Étape 5 – Analyse des données

L'analyse métier est organisée autour de six dimensions :

### 6.1 Analyse globale

Présentation des principaux indicateurs permettant d'obtenir une vue d'ensemble de l'activité.

### 6.2 Analyse des ventes

Étude de l'évolution temporelle des ventes et des indicateurs de performance commerciale.

### 6.3 Analyse des produits

Identification des produits les plus présents et étude de leur contribution à l'activité.

### 6.4 Analyse des clients

Exploration de l'activité des clients et de leur contribution aux transactions.

### 6.5 Analyse géographique

Comparaison des transactions et des performances selon les pays.

### 6.6 Analyse des annulations et mouvements négatifs

Étude des factures annulées, des quantités négatives et des opérations particulières afin de mieux comprendre les limites du jeu de données.

## 7. Étape 6 – Visualisation avec Power BI

Les résultats sont présentés dans un rapport Power BI interactif.

Le rapport comprend six pages :

- Executive Overview
- Sales Performance
- Product Analysis
- Customer Analysis
- Geographic Analysis
- Cancellations & Negative Movements

Des mesures DAX permettent de calculer les indicateurs nécessaires.

Des segments de filtrage synchronisés facilitent l'exploration des résultats par année, mois et pays.

## 8. Étape 7 – Documentation

La documentation permet de conserver une trace du travail réalisé et de faciliter la compréhension du projet.

Elle comprend :

- La présentation générale du projet.
- La description de l'architecture technique.
- La méthodologie de travail.
- Le dictionnaire de données.
- Le Data Lineage.
- Le rapport de Data Profiling.

## 9. Limites méthodologiques

Le jeu de données couvre une période limitée, de décembre 2010 à décembre 2011.

Il présente également plusieurs caractéristiques qui nécessitent une interprétation prudente :

- Une forte concentration des transactions au Royaume-Uni.
- Des identifiants clients manquants.
- Des descriptions de produits absentes.
- Des factures annulées.
- Des prix et quantités nuls ou négatifs.
- Des répétitions de lignes pouvant correspondre à des opérations distinctes.

Les résultats décrivent le jeu de données disponible et ne doivent pas être généralisés à l'ensemble du secteur du commerce de détail.

## 10. Conclusion

La méthodologie adoptée permet de suivre une démarche structurée de Business Intelligence, en accordant une importance particulière à la compréhension et à la qualité des données avant leur exploitation.

Le projet met en pratique l'utilisation de SQL, PostgreSQL, Power BI et DAX pour explorer des données transactionnelles, produire des analyses métier et restituer les résultats dans un tableau de bord interactif.