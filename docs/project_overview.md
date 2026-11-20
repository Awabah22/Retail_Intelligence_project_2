# Retail Intelligence
## Analyse des ventes, de la rentabilité et des clients

### 1. Présentation du projet

**Retail Intelligence** est un projet de Business Intelligence consacré à l'analyse des données de ventes d'une entreprise de commerce de détail.

L'objectif est de transformer un jeu de données transactionnelles en informations exploitables afin de mieux comprendre les performances commerciales, la rentabilité, le comportement des clients et la répartition géographique des ventes.

Ce projet a été réalisé dans le cadre du développement de compétences en Data Analysis, SQL, modélisation des données et Business Intelligence.

### 2. Objectifs du projet

Le projet poursuit plusieurs objectifs :

- Explorer et comprendre un jeu de données transactionnelles.
- Évaluer la qualité et la fiabilité des données.
- Identifier les valeurs manquantes, les doublons et les anomalies.
- Analyser les ventes et les indicateurs de performance commerciale.
- Étudier les performances des produits et des clients.
- Analyser la répartition géographique des ventes.
- Identifier les annulations et les mouvements de quantités négatives.
- Concevoir un tableau de bord interactif pour faciliter l'analyse et la prise de décision.

### 3. Jeu de données

Le projet utilise le jeu de données **Online Retail**, provenant de l'UCI Machine Learning Repository.

Il contient des transactions réalisées par un détaillant en ligne britannique entre décembre 2010 et décembre 2011.

| Caractéristique | Description |
|---|---|
| Source | UCI Machine Learning Repository |
| Jeu de données | Online Retail |
| Nombre de lignes | 541 909 |
| Nombre de colonnes | 8 |
| Période | Décembre 2010 – Décembre 2011 |
| Nombre de pays | 38 |
| Factures distinctes | 25 900 |
| Clients distincts non manquants | 4 372 |

Les principales informations disponibles sont les numéros de facture, les références produits, les descriptions, les quantités, les dates de transaction, les prix unitaires, les identifiants clients et les pays.

### 4. Technologies utilisées

| Technologie | Utilisation |
|---|---|
| PostgreSQL 18 | Stockage et exploration des données |
| SQL | Requêtes d'analyse, Data Profiling et contrôles de qualité |
| Power BI | Création du tableau de bord interactif |
| DAX | Création des mesures et indicateurs analytiques |
| Excel / CSV | Consultation et préparation du fichier source |
| Markdown | Documentation technique du projet |

### 5. Analyses réalisées

Le projet couvre plusieurs axes d'analyse :

- **Analyse globale :** vue d'ensemble des performances commerciales.
- **Analyse des ventes :** évolution des ventes dans le temps et indicateurs de performance.
- **Analyse des produits :** identification des produits les plus performants.
- **Analyse des clients :** étude de l'activité et de la contribution des clients.
- **Analyse géographique :** comparaison des performances selon les pays.
- **Analyse des annulations et mouvements négatifs :** étude des factures annulées, des quantités négatives et des transactions particulières.

### 6. Tableau de bord Power BI

Le rapport Power BI est organisé en six pages :

1. Executive Overview
2. Sales Performance
3. Product Analysis
4. Customer Analysis
5. Geographic Analysis
6. Cancellations & Negative Movements

Des filtres interactifs permettent d'explorer les données selon les années, les mois et les pays. Les filtres synchronisés facilitent la navigation entre les différentes pages du rapport.

### 7. Documentation du projet

La documentation est organisée autour de plusieurs éléments :

- `project_overview.md` : présentation générale du projet.
- `architecture.md` : description de l'architecture technique et du flux des données.
- `methodology.md` : description de la démarche de travail.
- Data Dictionary : définition des champs et de leur signification.
- Data Lineage : traçabilité du parcours des données.
- Profiling Report : résultats et interprétations du Data Profiling.

### 8. Résultat attendu

Le projet fournit une solution analytique permettant d'explorer les données transactionnelles, de mieux comprendre les performances commerciales et de présenter les résultats à travers un tableau de bord interactif.

Il constitue également une démonstration pratique de l'utilisation de SQL, PostgreSQL, Power BI et DAX dans un contexte de Business Intelligence.

### 9. Source des données

UCI Machine Learning Repository – Online Retail Dataset.

https://archive.ics.uci.edu/dataset/352/online+retail