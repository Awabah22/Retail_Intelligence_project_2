# RAPPORT DE DATA PROFILING

## Projet Retail Intelligence – Analyse des ventes, de la rentabilité et des clients

| Métadonnée | Valeur |
|---|---|
| Couche analysée | RAW |
| Table source | `raw.online_retail_source` |
| Source des données | UCI Machine Learning Repository – Online Retail Dataset |
| Période couverte | Du 1er décembre 2010 au 9 décembre 2011 |
| Outil d'analyse | PostgreSQL 18 |
| Langage | SQL |
| Statut | **Data Profiling terminé** |

---

## 1. Contexte et objectifs

Dans le cadre du projet Retail Intelligence, une phase de Data Profiling a été réalisée afin d'évaluer la structure, la qualité, la cohérence et les caractéristiques générales du jeu de données Online Retail.

Le Data Profiling constitue une étape préalable essentielle à la transformation des données et à la construction d'un modèle analytique destiné à Power BI.

L'objectif est de comprendre les données disponibles, d'identifier les problèmes potentiels et de définir les règles de gestion nécessaires à la préparation de la couche STAGING.

Les objectifs spécifiques sont les suivants :

- Vérifier le volume et la structure du dataset.
- Identifier les valeurs manquantes.
- Mesurer la cardinalité des colonnes.
- Étudier la distribution des valeurs.
- Analyser les variables numériques.
- Vérifier la qualité des dates.
- Détecter les doublons exacts et partiels.
- Analyser les factures, les annulations et les montants.
- Définir les recommandations de traitement pour les prochaines étapes.

**Principe de gouvernance :** aucune donnée source n'a été supprimée ou modifiée pendant cette phase. Toutes les analyses ont été réalisées en lecture seule sur la couche RAW.

---

## 2. Présentation du dataset

Le dataset contient des transactions commerciales associées à des factures, des produits, des clients et des pays.

Il comporte huit colonnes :

| Colonne | Description métier |
|---|---|
| InvoiceNo | Identifiant de la facture |
| StockCode | Code du produit |
| Description | Désignation du produit |
| Quantity | Quantité associée à la ligne de facture |
| InvoiceDate | Date et heure de la transaction |
| UnitPrice | Prix unitaire |
| CustomerID | Identifiant du client |
| Country | Pays associé à la transaction |

### 2.1 Structure technique

Les huit colonnes ont été initialement chargées dans PostgreSQL avec le type `TEXT`.

Cette décision permet de préserver les valeurs d'origine et de reporter les conversions de types dans la couche STAGING.

| Indicateur | Résultat |
|---|---:|
| Nombre de lignes | 541 909 |
| Nombre de colonnes | 8 |
| Nombre de factures distinctes | 25 900 |
| Nombre de pays distincts | 38 |
| Nombre de clients distincts non manquants | 4 372 |
| Nombre de codes produits distincts | 4 070 |

---

## 3. Méthodologie de Data Profiling

Le profiling a été organisé en neuf scripts SQL indépendants.

| Script | Analyse réalisée |
|---|---|
| `01_row_count.sql` | Volume et structure du dataset |
| `02_missing_values.sql` | Valeurs manquantes |
| `03_cardinality.sql` | Cardinalité des colonnes |
| `04_value_distribution.sql` | Distribution des valeurs |
| `05_numeric_profiling.sql` | Analyse des variables numériques |
| `06_date_profiling.sql` | Analyse des dates |
| `07_duplicate_detection.sql` | Détection des doublons |
| `08_invoice_analysis.sql` | Analyse des factures |
| `09_profiling_summary.sql` | Synthèse globale |

Les contrôles ont été réalisés à partir de requêtes SQL utilisant notamment :

- COUNT et COUNT DISTINCT ;
- GROUP BY et HAVING ;
- MIN, MAX, AVG et MEDIAN ;
- COUNT FILTER ;
- des expressions régulières ;
- des fonctions de conversion et de normalisation ;
- des fonctions de fenêtrage.

Les valeurs numériques contenant une virgule décimale ont été normalisées lors des analyses avec REPLACE, sans modification de la source RAW.

Des requêtes complémentaires ont également été utilisées pour vérifier les mouvements négatifs et consolider les résultats de l'analyse des doublons.

---

## 4. Résultats du Data Profiling

### 4.1 Analyse du volume et de la structure

Le dataset contient 541 909 lignes réparties sur huit colonnes.

Les colonnes ont été chargées en TEXT et sont techniquement déclarées comme nullable.

Cette approche permet de conserver les valeurs brutes avant leur conversion dans STAGING.

**Conclusion :** la structure générale du dataset est exploitable pour les prochaines étapes de transformation.

### 4.2 Analyse des valeurs manquantes

Les valeurs manquantes ont été détectées en considérant les valeurs NULL, les chaînes vides et les chaînes composées uniquement d'espaces.

| Colonne | Valeurs manquantes | Pourcentage |
|---|---:|---:|
| InvoiceNo | 0 | 0 % |
| StockCode | 0 | 0 % |
| Description | 1 454 | 0,27 % |
| Quantity | 0 | 0 % |
| InvoiceDate | 0 | 0 % |
| UnitPrice | 0 | 0 % |
| CustomerID | 135 080 | 24,93 % |
| Country | 0 | 0 % |

**Observations :**

- CustomerID est la colonne présentant le plus grand nombre de valeurs manquantes.
- Description comporte un nombre limité de valeurs manquantes.
- Les six autres colonnes sont complètes selon les contrôles effectués.

**Risques métier :**

L'absence de CustomerID peut limiter les analyses de segmentation, de fidélisation et de comportement client.

L'absence de Description peut rendre l'identification métier de certains produits plus difficile, même lorsque StockCode est renseigné.

**Recommandations :**

- Conserver les transactions sans CustomerID.
- Ne pas supprimer automatiquement les lignes sans Description.
- Prévoir une catégorie technique telle que « Description manquante » dans les analyses appropriées.
- Distinguer les transactions dont le client est inconnu des transactions dont le client est identifié.

### 4.3 Analyse de la cardinalité

| Colonne | Valeurs distinctes |
|---|---:|
| InvoiceNo | 25 900 |
| CustomerID | 4 372 |
| UnitPrice | 1 630 |
| Description | 4 211 |
| Quantity | 722 |
| InvoiceDate | 23 260 |
| Country | 38 |
| StockCode | 4 070 |

**Observations :**

- InvoiceNo comporte 25 900 valeurs distinctes.
- CustomerID comporte 4 372 identifiants clients non manquants distincts.
- StockCode comporte 4 070 codes produits distincts.
- Country comporte 38 pays distincts.
- InvoiceDate comporte 23 260 valeurs distinctes, ce qui montre que plusieurs transactions partagent une même date et heure.

La cardinalité permet notamment d'anticiper les dimensions potentielles du futur modèle analytique.

### 4.4 Analyse de la distribution des valeurs

#### Distribution géographique

Le dataset comporte 38 pays.

Les cinq pays les plus représentés en nombre de lignes sont :

| Pays | Nombre de lignes | Part |
|---|---:|---:|
| United Kingdom | 495 478 | 91,43 % |
| Germany | 9 495 | 1,75 % |
| France | 8 557 | 1,58 % |
| EIRE | 8 196 | 1,51 % |
| Spain | 2 533 | 0,47 % |

Le Royaume-Uni représente 91,43 % des lignes du dataset.

**Interprétation :** la distribution géographique est fortement déséquilibrée. Les analyses comparatives entre pays devront tenir compte de cette concentration.

Les pourcentages présentés correspondent à la part des lignes, et non à la part du chiffre d'affaires.

#### Distribution des produits

Les produits les plus fréquents comprennent notamment :

| StockCode | Nombre de lignes |
|---|---:|
| 85123A | 2 313 |
| 22423 | 2 203 |
| 85099B | 2 159 |
| 47566 | 1 727 |
| 20725 | 1 639 |

Le code POST apparaît également parmi les vingt codes les plus fréquents, avec 1 256 lignes.

**Interprétation :** certains codes peuvent correspondre à des frais de livraison ou à des opérations particulières plutôt qu'à des produits classiques.

Une classification métier des codes spécifiques sera nécessaire.

#### Distribution des clients

Le groupe des lignes sans CustomerID représente 135 080 enregistrements.

Les identifiants clients les plus fréquents ont été étudiés en nombre de lignes, et non en nombre de factures.

Cette distinction est importante : un client peut apparaître plusieurs fois sur une même facture ou sur plusieurs factures.

#### Distribution des factures

Les factures les plus volumineuses en nombre de lignes comprennent notamment :

- 573585 : 1 114 lignes ;
- 581219 : 749 lignes ;
- 581492 : 731 lignes ;
- 580729 : 721 lignes ;
- 558475 : 705 lignes.

La facture 573585 présente le plus grand nombre de lignes observé.

Cela constitue une observation à conserver pour les analyses ultérieures, sans conclure automatiquement à une anomalie.

### 4.5 Analyse des variables numériques

Les colonnes Quantity et UnitPrice ont été étudiées après normalisation des séparateurs décimaux.

#### Statistiques générales

| Indicateur | Quantity | UnitPrice |
|---|---:|---:|
| Nombre de valeurs valides | 541 909 | 541 909 |
| Minimum | -80 995 | -11 062,06 |
| Maximum | 80 995 | 38 970 |
| Moyenne | 9,55 | 4,61 |
| Médiane | 3 | 2,08 |

#### Valeurs négatives

| Colonne | Nombre de valeurs négatives |
|---|---:|
| Quantity | 10 624 |
| UnitPrice | 2 |

Les quantités négatives peuvent correspondre à des retours, des annulations ou des ajustements.

Les deux prix négatifs ont été identifiés comme des écritures particulières :

- InvoiceNo A563186 : Adjust bad debt.
- InvoiceNo A563187 : Adjust bad debt.

Ces deux opérations ne doivent pas être interprétées comme des ventes ordinaires.

#### Investigation complémentaire des quantités négatives

Une analyse complémentaire a permis de répartir les 10 624 lignes présentant une quantité négative selon le type de facture.

| Type de facture | Lignes négatives | Unités négatives |
|---|---:|---:|
| Factures annulées | 9 288 | 277 574 |
| Factures normales | 1 336 | 206 957 |
| **Total** | **10 624** | **484 531** |

Une investigation spécifique des 1 336 lignes négatives associées aux factures normales a révélé les caractéristiques suivantes :

| Contrôle | Nombre de lignes concernées |
|---|---:|
| Quantités négatives sur factures normales | 1 336 |
| Prix unitaires égaux à zéro | 1 336 |
| Montants de ligne égaux à zéro | 1 336 |
| Identifiants clients manquants | 1 336 |
| Lignes associées au Royaume-Uni | 1 336 |

Ainsi, les 1 336 lignes présentent toutes les mêmes caractéristiques.

Ces observations suggèrent que ces lignes ne représentent pas nécessairement des retours clients classiques. Certaines descriptions mentionnent des produits endommagés ou détruits. Elles pourraient donc correspondre à des mouvements ou ajustements de stock.

**Point d'attention :** ces lignes doivent être identifiées et traitées avec précaution lors de la transformation des données dans la couche STAGING, afin de ne pas les confondre avec les ventes commerciales.

#### Valeurs nulles

| Colonne | Nombre de valeurs nulles |
|---|---:|
| Quantity | 0 |
| UnitPrice | 2 515 |

L'investigation des prix nuls a mis en évidence plusieurs descriptions particulières :

- damaged ;
- damages ;
- water damaged ;
- Unsaleable, destroyed ;
- thrown away ;
- found ;
- sold as set on dotcom ;
- adjustment ;
- check.

Un nombre important de ces lignes présente également une description manquante.

**Conclusion :** un prix unitaire nul ne signifie pas nécessairement qu'un article a été offert gratuitement. Il peut s'agir d'une opération de gestion de stock ou d'un ajustement.

#### Valeurs extrêmes

Les observations suivantes ont été identifiées :

| Facture | Produit / description | Quantité | Prix unitaire |
|---|---|---:|---:|
| C556445 | Manual | -1 | 38 970 |
| A563186 | Adjust bad debt | 1 | -11 062,06 |
| A563187 | Adjust bad debt | 1 | -11 062,06 |
| 581483 | PAPER CRAFT, LITTLE BIRDIE | 80 995 | 2,08 |
| C581484 | PAPER CRAFT, LITTLE BIRDIE | -80 995 | 2,08 |

Les factures 581483 et C581484 présentent des quantités opposées pour le même produit, au même prix unitaire et pour le même client.

Cette correspondance suggère une opération d'annulation ou de contrepassation, mais doit être confirmée par l'analyse métier.

**Recommandations :**

- Conserver les valeurs négatives.
- Ne pas supprimer les valeurs extrêmes uniquement en raison de leur amplitude.
- Identifier les opérations comptables et les ajustements.
- Prévoir des règles de classification dans STAGING.

### 4.6 Analyse des dates

Le format des dates source a été identifié comme :

`DD/MM/YYYY HH24:MI`

La conversion PostgreSQL a été effectuée avec :

`TO_TIMESTAMP(BTRIM(invoice_date), 'DD/MM/YYYY HH24:MI')`

| Indicateur | Résultat |
|---|---:|
| Nombre total de lignes | 541 909 |
| Dates convertibles | 541 909 |
| Dates non convertibles | 0 |
| Date minimale | 01/12/2010 08:26 |
| Date maximale | 09/12/2011 12:50 |

Toutes les dates ont pu être converties.

#### Distribution annuelle

| Année | Nombre de lignes | Pourcentage |
|---|---:|---:|
| 2010 | 42 481 | 7,84 % |
| 2011 | 499 428 | 92,16 % |

#### Distribution mensuelle

Les mois les plus représentés sont :

| Mois | Nombre de lignes | Pourcentage |
|---|---:|---:|
| Novembre 2011 | 84 711 | 15,63 % |
| Octobre 2011 | 60 742 | 11,21 % |
| Septembre 2011 | 50 226 | 9,27 % |

Décembre 2011 ne couvre que les neuf premiers jours. Les comparaisons mensuelles doivent donc tenir compte de cette période incomplète.

#### Distribution hebdomadaire

Le jeudi est le jour présentant le plus grand nombre de lignes, avec 103 857 enregistrements (19,17 %).

Aucune ligne n'a été enregistrée le samedi.

Cette observation décrit le calendrier présent dans le dataset, sans permettre à elle seule d'expliquer les habitudes commerciales.

#### Distribution horaire

Les heures les plus représentées sont :

| Heure | Nombre de lignes | Pourcentage |
|---|---:|---:|
| 12 h | 78 709 | 14,52 % |
| 15 h | 77 519 | 14,30 % |
| 13 h | 72 259 | 13,33 % |
| 14 h | 67 471 | 12,45 % |
| 11 h | 57 674 | 10,64 % |

L'activité est principalement concentrée entre 11 h et 16 h.

**Conclusion :** les dates sont exploitables pour construire une dimension temporelle dans le futur modèle analytique.

### 4.7 Détection des doublons

La détection a été réalisée à partir des huit colonnes de la table source.

#### Doublons exacts

| Indicateur | Résultat |
|---|---:|
| Groupes de doublons exacts | 4 879 |
| Lignes appartenant à ces groupes | 10 147 |
| Lignes supplémentaires | 5 268 |
| Répétition maximale | 20 |
| Part des lignes supplémentaires dans le dataset | 0,97 % |

Un doublon exact correspond ici à plusieurs lignes identiques sur les huit colonnes.

Les résultats montrent que certaines lignes identiques apparaissent plusieurs fois sur une même facture.

Cependant, une répétition identique ne constitue pas automatiquement une erreur métier.

#### Doublons partiels

La clé d'analyse utilisée était :

`InvoiceNo + StockCode + InvoiceDate + CustomerID`

Résultats :

| Indicateur | Résultat |
|---|---:|
| Groupes partiels | 9 688 |
| Lignes appartenant aux groupes | 20 365 |
| Lignes supplémentaires selon cette clé | 10 677 |
| Groupes avec lignes identiques uniquement | 4 495 |
| Groupes présentant des variations | 5 193 |

Les groupes partiels peuvent contenir des lignes totalement identiques ou des lignes partageant la même clé mais présentant des différences de quantité, de description, de prix ou de pays.

#### Analyse complémentaire des groupes mixtes

Une vérification complémentaire a identifié :

| Indicateur | Résultat |
|---|---:|
| Groupes exacts présents dans des groupes partiels avec variations | 384 |
| Lignes appartenant à ces groupes exacts | 822 |

Ces résultats montrent que certains groupes partiels peuvent contenir des répétitions strictement identiques ainsi que d'autres lignes présentant des valeurs différentes.

**Interprétation :**

- Les doublons exacts représentent des répétitions sur les huit colonnes.
- Les doublons partiels représentent des lignes partageant une clé d'analyse mais présentant éventuellement des différences sur d'autres colonnes.
- Les groupes partiels contenant des variations ne sont pas nécessairement des erreurs.
- Les groupes mixtes montrent que les deux formes de répétition peuvent coexister dans un même ensemble de transactions.

**Point de vigilance :** les indicateurs de doublons exacts et partiels reposent sur des clés différentes et se chevauchent. Ils ne doivent pas être additionnés pour calculer un nombre global de lignes dupliquées.

**Recommandations :**

- Ne pas supprimer automatiquement les doublons exacts.
- Étudier les répétitions dans leur contexte métier.
- Conserver les lignes distinctes appartenant à une même facture et à un même produit.
- Définir une règle métier avant toute déduplication dans STAGING.

### 4.8 Analyse des factures

L'analyse des factures a permis d'étudier les annulations, le nombre de lignes et les montants calculés.

#### Classification des factures

Les factures dont l'identifiant commence par C ont été classées comme annulées.

| Type de facture | Nombre | Pourcentage |
|---|---:|---:|
| Factures normales | 22 064 | 85,19 % |
| Factures annulées | 3 836 | 14,81 % |
| **Total** | **25 900** | **100 %** |

Cette règle est une convention de classification fondée sur le format des identifiants.

Elle ne signifie pas que toutes les quantités négatives correspondent à des factures annulées.

#### Lignes par type de facture

| Type | Nombre de lignes | Part des lignes |
|---|---:|---:|
| Normal | 532 621 | 98,29 % |
| Annulé | 9 288 | 1,71 % |
| **Total** | **541 909** | **100 %** |

Les factures annulées représentent 14,81 % du nombre de factures, mais seulement 1,71 % du nombre de lignes.

La vérification des quantités négatives a également montré que les 9 288 lignes associées aux factures annulées présentent une quantité négative.

#### Nombre de lignes par facture

| Type | Minimum | Moyenne | Médiane | Maximum |
|---|---:|---:|---:|---:|
| Normal | 1 | 24,14 | 13 | 1 114 |
| Annulé | 1 | 2,42 | 1 | 101 |

Les factures normales présentent un nombre de lignes nettement supérieur aux factures annulées.

La moyenne des factures normales est supérieure à la médiane, ce qui traduit une distribution influencée par quelques factures particulièrement volumineuses.

#### Montants par facture

Le montant de chaque ligne a été calculé selon la formule :

`Quantity × UnitPrice`

Le montant total d'une facture correspond à la somme des montants de ses lignes.

Cette mesure représente un montant transactionnel calculé à partir des données disponibles. Elle ne constitue pas une mesure de rentabilité, car aucune donnée de coût d'achat ou de marge n'est disponible dans le dataset.

Les principales observations sont :

- Montant maximal observé : 168 469,60.
- Certaines factures présentent des montants nuls.
- Toutes les factures identifiées comme annulées ont un montant total négatif.
- Deux factures normales présentent un montant total négatif.

#### Répartition des factures par montant

| Type de facture | Nombre |
|---|---:|
| Factures normales à montant positif | 19 960 |
| Factures normales à montant nul | 2 102 |
| Factures normales à montant négatif | 2 |
| Factures annulées à montant négatif | 3 836 |

Les deux factures normales à montant négatif correspondent aux ajustements `Adjust bad debt`.

#### Investigation des factures à montant nul

Les 2 102 factures normales à montant nul ont fait l'objet d'un contrôle complémentaire.

| Indicateur | Résultat |
|---|---:|
| Factures normales à montant nul | 2 102 |
| Factures composées uniquement de lignes à prix nul | 2 102 |
| Factures contenant des prix non nuls | 0 |
| Factures comportant plusieurs lignes | 6 |

Les 2 102 factures à montant nul sont donc exclusivement constituées de lignes dont le prix unitaire est nul.

Les descriptions associées montrent plusieurs types d'opérations possibles, notamment des articles endommagés, des ajustements et des articles retrouvés.

Ces factures ne doivent pas être considérées automatiquement comme des ventes commerciales classiques.

---

## 5. Synthèse des problèmes et observations

| Problème ou observation | Volume / résultat | Niveau d'attention |
|---|---:|---|
| CustomerID manquant | 135 080 lignes | Élevé |
| Description manquante | 1 454 lignes | Modéré |
| Quantités négatives | 10 624 lignes | À interpréter |
| Prix unitaires négatifs | 2 lignes | Élevé |
| Prix unitaires nuls | 2 515 lignes | Élevé |
| Doublons exacts supplémentaires | 5 268 lignes | À investiguer |
| Groupes de doublons partiels avec variations | 5 193 groupes | À investiguer |
| Factures annulées | 3 836 factures | À classifier |
| Factures normales à montant nul | 2 102 factures | À classifier |
| Valeurs extrêmes | Plusieurs observations | À investiguer |
| Dates non convertibles | 0 ligne | Conforme |

Le niveau d'attention représente une priorité d'investigation et non une preuve de corruption des données.

---

## 6. Recommandations pour la couche STAGING

À partir des observations du Data Profiling, les recommandations suivantes sont proposées.

### 6.1 Conversion et normalisation des types

- Convertir Quantity en type numérique approprié.
- Convertir UnitPrice en type numérique avec précision décimale.
- Convertir InvoiceDate en TIMESTAMP.
- Conserver InvoiceNo, StockCode et CustomerID sous des types compatibles avec leurs identifiants.
- Normaliser les espaces et les chaînes vides.
- Uniformiser les formats de texte lorsque cela est pertinent.

### 6.2 Gestion des valeurs manquantes

- Conserver les lignes sans CustomerID.
- Conserver les lignes sans Description.
- Prévoir des indicateurs permettant d'identifier les informations manquantes.
- Éviter les remplacements arbitraires des identifiants clients.

### 6.3 Gestion des opérations particulières

Prévoir une classification des opérations à partir des informations disponibles :

- Factures normales.
- Factures annulées.
- Retours et quantités négatives.
- Ajustements comptables.
- Articles endommagés ou invendables.
- Transactions à prix nul.
- Frais de livraison et codes spécifiques.

Les règles devront être confirmées à partir des caractéristiques des transactions et de la documentation métier disponible.

### 6.4 Gestion des doublons

- Conserver la source RAW intacte.
- Documenter les groupes de doublons exacts.
- Étudier les doublons partiels.
- Ne pas supprimer une ligne uniquement parce qu'elle partage une clé avec une autre ligne.
- Définir une règle métier avant toute déduplication.

### 6.5 Préparation analytique

La préparation de la couche analytique devra notamment distinguer :

- Les ventes ordinaires.
- Les annulations.
- Les retours.
- Les ajustements.
- Les transactions à montant nul.

Cette distinction est indispensable pour éviter de produire des indicateurs commerciaux trompeurs dans Power BI.

---

## 7. Limites de l'analyse

Cette phase de Data Profiling présente plusieurs limites :

1. Les données ne contiennent pas les coûts d'achat des produits. La rentabilité réelle ne peut donc pas être calculée directement.
2. Les identifiants clients manquants limitent certaines analyses comportementales.
3. Les descriptions manquantes ou ambiguës empêchent parfois une classification métier fiable.
4. Certaines opérations particulières nécessitent une documentation métier complémentaire.
5. La répétition de lignes identiques ne permet pas, à elle seule, de conclure à une erreur.
6. Les résultats géographiques sont fortement concentrés sur le Royaume-Uni.
7. La période de décembre 2011 est incomplète.
8. Certaines opérations à quantité ou prix négatif nécessitent une investigation métier complémentaire pour déterminer leur nature exacte.

Ces limites devront être prises en compte dans la conception des indicateurs et dans l'interprétation des résultats analytiques.

---

## 8. Conclusion générale

La phase de Data Profiling a permis d'évaluer les 541 909 lignes du dataset Online Retail et d'identifier les principales caractéristiques et anomalies potentielles des données.

Les analyses ont mis en évidence :

- Une forte proportion de valeurs manquantes dans CustomerID.
- Des opérations commerciales et comptables présentant des quantités ou des prix négatifs.
- Des transactions à prix unitaire nul.
- Des groupes de doublons exacts et partiels.
- Des factures annulées et des factures normales à montant nul.
- Une distribution géographique fortement concentrée sur le Royaume-Uni.
- Des dates entièrement convertibles au format identifié.
- Des mouvements négatifs sur factures normales présentant des caractéristiques communes : prix nul, montant nul, identifiant client manquant et pays égal au Royaume-Uni.

Les résultats montrent que le dataset est exploitable pour un projet d'analyse commerciale, à condition de mettre en place des règles de transformation et de gestion adaptées.

La couche RAW est conservée sans modification. Les traitements, conversions, classifications et contrôles complémentaires seront réalisés dans la couche STAGING.

Cette phase constitue ainsi le socle de qualité et de gouvernance nécessaire à la construction de la future couche ANALYTICS et à la réalisation des tableaux de bord Power BI.

**Statut final : DATA PROFILING TERMINÉ.**