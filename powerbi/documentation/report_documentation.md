# Power BI Report Documentation – Retail Intelligence

## 1. Présentation

Ce document décrit le rapport Power BI développé dans le cadre du projet Retail Intelligence.

Le rapport permet d'explorer les données transactionnelles du jeu de données Online Retail et d'analyser les performances commerciales selon plusieurs dimensions : ventes, produits, clients, géographie et annulations.

Il constitue la couche de visualisation et d'aide à l'analyse du projet.

## 2. Organisation du rapport

Le rapport est composé de six pages analytiques.

| Page | Objectif |
|---|---|
| Executive Overview | Présenter une vue globale des principaux indicateurs. |
| Sales Performance | Analyser l'évolution et les performances des ventes. |
| Product Analysis | Explorer les performances et la contribution des produits. |
| Customer Analysis | Étudier l'activité et la contribution des clients. |
| Geographic Analysis | Comparer les résultats selon les pays. |
| Cancellations & Negative Movements | Examiner les factures annulées et les mouvements de quantités négatives. |

### 2.1 Executive Overview

Cette page fournit une synthèse des principaux indicateurs du rapport. Elle permet d'obtenir rapidement une vue d'ensemble de l'activité commerciale.

### 2.2 Sales Performance

Cette page est consacrée à l'évolution des ventes et à l'analyse des performances commerciales dans le temps.

### 2.3 Product Analysis

Cette page permet d'étudier les produits, leur présence dans les transactions et leurs performances.

### 2.4 Customer Analysis

Cette page permet d'explorer l'activité des clients et leur contribution aux transactions.

### 2.5 Geographic Analysis

Cette page présente la répartition géographique de l'activité et permet de comparer les pays.

### 2.6 Cancellations & Negative Movements

Cette page est consacrée à l'analyse des factures annulées et des mouvements de quantités négatives. Elle permet de distinguer ces opérations des ventes classiques et d'attirer l'attention sur les particularités du jeu de données.

## 3. Filtres et navigation

Le rapport utilise des segments de filtrage synchronisés entre les six pages.

Les principaux filtres sont :

- **YEAR** : filtrage par année.
- **MONTH** : filtrage par mois.
- **COUNTRY** : filtrage par pays.

La synchronisation des filtres permet de conserver un contexte d'analyse cohérent lors du passage d'une page à une autre.

Un navigateur de pages facilite également la navigation dans le rapport.

## 4. Identité visuelle

Le rapport utilise une identité visuelle cohérente sur l'ensemble des pages.

| Élément | Couleur |
|---|---|
| Couleur principale | Terracotta – `#C9662D` |
| Fond beige | `#F2EADF` |
| Texte principal | Brun foncé – `#30271F` |
| Texte secondaire | `#71675E` |
| Bordures | `#E5D8C9` |
| Cartes | Blanc |

La police principale utilisée est Segoe UI.

Cette palette permet de conserver une présentation homogène, lisible et structurée.

## 5. Mesures et indicateurs

Les indicateurs analytiques sont construits à l'aide de mesures DAX dans Power BI.

Les mesures permettent de calculer et de présenter les informations nécessaires aux différentes analyses du rapport.

Les résultats doivent être interprétés en tenant compte des caractéristiques du jeu de données, notamment des factures annulées, des prix nuls ou négatifs et des quantités négatives.

## 6. Utilisation du rapport

Pour explorer le rapport :

1. Ouvrir la page Executive Overview pour commencer par la vue générale.
2. Utiliser les filtres YEAR, MONTH et COUNTRY pour sélectionner le périmètre d'analyse.
3. Consulter les différentes pages pour approfondir l'analyse.
4. Examiner la page Cancellations & Negative Movements pour comprendre les opérations particulières.
5. Réinitialiser les filtres si nécessaire afin de retrouver la vue globale.

## 7. Fichier du rapport

Le fichier Power BI principal est destiné à être conservé dans le dossier `reports`.

Format recommandé :

`Retail_Intelligence.pbix`

Ce fichier contient le rapport Power BI et permet de consulter et de modifier les pages, les visuels, les mesures et les paramètres du rapport.

## 8. Limites et précautions d'interprétation

Les analyses reposent sur le jeu de données Online Retail, qui couvre la période de décembre 2010 à décembre 2011.

Certaines transactions comportent des valeurs particulières, notamment des quantités négatives, des prix nuls ou des factures annulées.

Ces opérations ne doivent pas être interprétées automatiquement comme des ventes classiques ou des retours clients sans analyse complémentaire.

Les résultats du rapport doivent donc être interprétés en tenant compte des règles de calcul et des caractéristiques de la source.