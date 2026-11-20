# BUSINESS RULES & CLEANING DECISIONS
## Projet : Retail Intelligence

**Projet :** Data Analysis – Ventes, performance commerciale et clients  
**Source de données :** UCI Online Retail Dataset  
**Période couverte :** 01/12/2010 au 09/12/2011  
**Couche concernée :** STAGING → ANALYTICS  
**Statut :** Règles proposées et conventions analytiques documentées  
**Version :** 1.0  
**Date :** 04 novembre 2026

---

# 1. Contexte et objectifs

Ce document présente les règles métier et les décisions de nettoyage retenues pour le projet Retail Intelligence.

L'objectif est de définir un cadre cohérent permettant de transformer les données commerciales brutes en informations fiables pour l'analyse décisionnelle.

Le dataset utilisé est le jeu de données UCI Online Retail. Il contient des informations relatives aux factures, produits, quantités, prix unitaires, clients, dates de transaction et pays.

L'analyse du profilage RAW et des contrôles qualité STAGING a permis d'identifier plusieurs particularités :

- Des factures annulées.
- Des quantités négatives.
- Des prix unitaires nuls.
- Des prix unitaires négatifs.
- Des identifiants clients manquants.
- Des descriptions de produits manquantes.
- Des lignes commerciales exactement répétées.
- Des opérations d'ajustement comptable.

Certaines situations peuvent être interprétées à partir des informations disponibles. D'autres nécessitent des hypothèses analytiques.

Ce document distingue donc les observations issues des données, les hypothèses retenues pour le projet et les règles de traitement qui seront appliquées dans la couche ANALYTICS.

# 2. Principes généraux de gouvernance

Les principes suivants guident les décisions de nettoyage et de transformation.

## 2.1 Préservation des données sources

La couche RAW constitue la copie de référence des données initiales.

Aucune correction ou suppression ne doit être effectuée directement dans RAW.

Les transformations et les règles métier sont appliquées dans les couches STAGING et ANALYTICS.

## 2.2 Traçabilité

Chaque transformation doit être documentée et reproductible.

Les décisions de nettoyage doivent pouvoir être expliquées et justifiées.

## 2.3 Prudence dans le traitement des anomalies

Une valeur inhabituelle n'est pas automatiquement une erreur.

Les quantités négatives, prix nuls, prix négatifs et doublons doivent être interprétés avant toute suppression.

## 2.4 Transparence des hypothèses

Les règles définies dans le cadre de ce projet sont des conventions analytiques.

Elles ne doivent pas être présentées comme des règles officielles de l'entreprise ayant produit le dataset.

Toute hypothèse doit être documentée et appliquée de manière cohérente dans les indicateurs.

## 2.5 Respect des données disponibles

Aucun coût d'achat, coût logistique, coût opérationnel ou autre donnée financière absente du dataset ne sera inventé.

Le projet se concentre sur l'analyse des ventes et de la performance commerciale à partir des données réellement disponibles.

# 3. Référentiel des règles métier

## 3.1 Gestion des factures et des annulations

| ID | Règle métier | Justification | Décision de traitement |
|---|---|---|---|
| BR001 | Une facture dont le numéro commence par C est considérée comme annulée. | Le profilage a identifié 3 836 factures avec ce préfixe. | Classification dans `invoice_type = 'Cancelled'`. |
| BR002 | Les factures annulées sont exclues du chiffre d'affaires des ventes normales. | Éviter de mélanger les ventes et leurs annulations. | Exclusion du périmètre de calcul du chiffre d'affaires des ventes normales. |
| BR003 | Les factures annulées doivent être analysées séparément. | Elles peuvent renseigner sur le volume et la fréquence des annulations. | Création d'indicateurs dédiés aux annulations. |
| BR004 | Un montant négatif sur une facture normale ne signifie pas automatiquement une annulation. | Deux opérations négatives ont été identifiées comme des ajustements de créances douteuses. | Classification séparée des ajustements identifiés. |

**Précision :** le préfixe C est une convention observée dans le dataset. Il sert à classifier les factures dans ce projet, sans prétendre documenter l'intégralité des règles comptables du système source.

## 3.2 Gestion des quantités négatives

| ID | Règle métier | Justification | Décision de traitement |
|---|---|---|---|
| BR005 | Une quantité négative représente une opération particulière à analyser. | 10 624 lignes présentent une quantité négative. | Conservation des lignes et identification par un indicateur. |
| BR006 | Les quantités négatives sont analysées séparément des quantités positives. | Elles peuvent correspondre à des retours, annulations ou corrections. | Création d'indicateurs de retours ou d'opérations négatives. |
| BR007 | Les quantités négatives ne sont pas automatiquement supprimées. | Leur suppression pourrait entraîner une perte d'information commerciale. | Conservation dans STAGING et classification dans ANALYTICS. |

**Précision :** en l'absence d'une documentation métier complète, toutes les quantités négatives ne seront pas automatiquement qualifiées de retours clients.

## 3.3 Gestion des prix unitaires nuls

| ID | Règle métier | Justification | Décision de traitement |
|---|---|---|---|
| BR008 | Un prix unitaire nul est considéré comme une opération particulière. | 2 515 lignes présentent un prix unitaire égal à zéro. | Conservation et identification des lignes. |
| BR009 | Les lignes à prix nul sont exclues du calcul des ventes positives facturées. | Elles ne génèrent aucun montant transactionnel positif. | Exclusion du périmètre des ventes positives facturées, mais conservation dans les analyses dédiées. |
| BR010 | Les opérations à prix nul doivent être analysées séparément. | Elles peuvent correspondre à des gratuités, produits endommagés ou anomalies. | Création d'indicateurs dédiés. |

**Précision :** un prix nul ne permet pas, à lui seul, de conclure qu'un produit est gratuit ou qu'il s'agit d'une erreur.

## 3.4 Gestion des prix unitaires négatifs

| ID | Règle métier | Justification | Décision de traitement |
|---|---|---|---|
| BR011 | Les prix unitaires négatifs sont considérés comme des opérations financières particulières. | Deux lignes présentent un prix unitaire négatif. | Conservation et identification séparée. |
| BR012 | Les prix négatifs ne sont pas intégrés aux analyses ordinaires de prix de vente. | Ils correspondent à des ajustements de créances douteuses identifiés dans les descriptions. | Exclusion du périmètre des ventes positives facturées et analyse séparée. |

## 3.5 Gestion des clients manquants

| ID | Règle métier | Justification | Décision de traitement |
|---|---|---|---|
| BR013 | Les transactions sans CustomerID sont conservées. | 135 080 lignes ne possèdent pas d'identifiant client. | Conservation des transactions dans les analyses globales valides. |
| BR014 | Les clients sans identifiant ne sont pas comptabilisés comme des clients distincts identifiés. | Un identifiant manquant ne permet pas d'identifier une personne unique. | Exclusion des NULL du calcul des clients distincts. |
| BR015 | Aucun identifiant client artificiel ne sera créé. | L'identité des clients inconnus ne peut pas être reconstituée de manière fiable. | Conservation de NULL. |

## 3.6 Gestion des descriptions manquantes

| ID | Règle métier | Justification | Décision de traitement |
|---|---|---|---|
| BR016 | Les descriptions manquantes sont conservées comme NULL. | 1 454 lignes présentent une description manquante. | Conservation sans création de description artificielle. |
| BR017 | Le StockCode est utilisé comme référence produit principale lorsqu'il est disponible. | Le code produit est renseigné même lorsque certaines descriptions sont absentes. | Utilisation de StockCode pour identifier les produits. |

**Précision :** une description manquante pourra être enrichie ultérieurement uniquement si une source de référence fiable est disponible.

## 3.7 Gestion des doublons

| ID | Règle métier | Justification | Décision de traitement |
|---|---|---|---|
| BR018 | Les lignes exactement répétées ne sont pas automatiquement supprimées. | 4 879 groupes de doublons exacts ont été identifiés. | Conservation des lignes dans STAGING. |
| BR019 | Les doublons doivent faire l'objet d'une analyse avant toute suppression. | Une répétition peut correspondre à des lignes commerciales distinctes ou à une duplication accidentelle. | Analyse des groupes concernés. |
| BR020 | Les indicateurs commerciaux doivent être calculés sans déduplication arbitraire. | Une suppression injustifiée pourrait modifier les quantités et montants. | Conservation de l'intégralité des lignes tant qu'aucune règle fiable de déduplication n'est établie. |

**Précision :** le fait que deux lignes possèdent les mêmes valeurs métier ne prouve pas qu'elles correspondent à une seule transaction. La déduplication nécessiterait une règle métier supplémentaire ou un identifiant source fiable.

## 3.8 Gestion des dates et périodes

| ID | Règle métier | Justification | Décision de traitement |
|---|---|---|---|
| BR021 | La date de facture constitue la référence temporelle de l'analyse commerciale. | InvoiceDate représente la date associée à la transaction. | Utilisation de `invoice_date` pour les analyses temporelles. |
| BR022 | Les analyses temporelles doivent tenir compte de la période réellement disponible. | Les données couvrent du 01/12/2010 au 09/12/2011. | Présentation explicite des dates de début et de fin. |
| BR023 | Décembre 2011 ne doit pas être comparé directement à des mois complets. | Le dataset s'arrête au 9 décembre 2011. | Signalement de la période partielle dans les analyses mensuelles. |

# 4. Conventions analytiques pour les indicateurs

Les règles suivantes définissent les conventions retenues pour construire les futurs indicateurs de la couche ANALYTICS.

## 4.1 Chiffre d'affaires des ventes normales

Le chiffre d'affaires des ventes normales sera calculé à partir des lignes répondant aux conditions suivantes :

- Facture classée `Normal`.
- Quantité positive.
- Prix unitaire positif.

Formule :

`Chiffre d'affaires des ventes normales = SUM(quantity × unit_price)`

Cette convention exclut les factures annulées, les opérations à quantité négative et les opérations à prix nul ou négatif.

Elle représente un chiffre d'affaires transactionnel brut selon le périmètre analytique défini pour le projet. Elle ne constitue pas nécessairement un chiffre d'affaires comptable officiel.

## 4.2 Analyse des retours et opérations négatives

Les lignes à quantité négative seront analysées séparément.

Indicateurs possibles :

- Nombre de lignes à quantité négative.
- Quantité négative totale.
- Montant associé aux quantités négatives.
- Évolution des opérations négatives dans le temps.
- Produits présentant le plus d'opérations négatives.

Ces indicateurs ne seront pas automatiquement interprétés comme des retours clients confirmés.

## 4.3 Analyse des annulations

Indicateurs possibles :

- Nombre de factures annulées.
- Pourcentage de factures annulées.
- Montant associé aux factures annulées.
- Évolution des annulations par mois.
- Répartition des annulations par pays.

Les factures annulées seront présentées séparément des ventes normales.

## 4.4 Analyse des clients

Indicateurs possibles :

- Nombre de clients distincts identifiés.
- Nombre de factures par client.
- Montant transactionnel par client.
- Panier moyen par client.
- Fréquence d'achat.
- Répartition des clients par pays.
- Évolution de l'activité des clients.

Les transactions sans CustomerID pourront contribuer aux indicateurs globaux de ventes, mais ne seront pas utilisées pour identifier des clients distincts.

## 4.5 Analyse des produits

Indicateurs possibles :

- Quantité vendue par produit.
- Chiffre d'affaires transactionnel par produit.
- Nombre de factures contenant chaque produit.
- Classement des produits selon le montant transactionnel.
- Produits présentant des opérations négatives.
- Produits présentant des prix nuls.

Les descriptions manquantes ne doivent pas empêcher l'identification d'un produit lorsque son StockCode est disponible.

## 4.6 Analyse géographique

Indicateurs possibles :

- Chiffre d'affaires transactionnel par pays.
- Nombre de factures par pays.
- Quantités vendues par pays.
- Nombre de clients identifiés par pays.
- Répartition géographique des annulations et opérations négatives.

## 4.7 Limites de l'analyse de rentabilité

Le dataset ne contient pas les coûts d'achat des produits ni les coûts opérationnels.

Par conséquent, les indicateurs suivants ne seront pas calculés :

- Coût des marchandises vendues.
- Marge brute.
- Marge nette.
- Bénéfice net.
- Retour sur investissement.

Le projet se concentrera sur l'analyse du chiffre d'affaires transactionnel, des ventes, des clients, des produits et de la performance commerciale.

Aucune donnée de coût simulée ne sera introduite.

# 5. Décisions de nettoyage et de conservation

| Situation | Traitement retenu | Couche concernée |
|---|---|---|
| Espaces superflus | Suppression avec BTRIM() | STAGING |
| Chaînes vides dans description et customer_id | Conversion en NULL | STAGING |
| Dates au format source | Conversion en TIMESTAMP | STAGING |
| Valeurs numériques textuelles | Conversion vers les types numériques | STAGING |
| Prix de précision 0.001 | Conservation avec trois décimales | STAGING |
| Montant de ligne | Calcul quantity × unit_price | STAGING |
| Factures annulées | Classification par préfixe C | STAGING |
| Quantités négatives | Conservation et identification | STAGING / ANALYTICS |
| Prix nuls | Conservation et identification | STAGING / ANALYTICS |
| Prix négatifs | Conservation et identification | STAGING / ANALYTICS |
| Clients manquants | Conservation sous forme NULL | STAGING / ANALYTICS |
| Descriptions manquantes | Conservation sous forme NULL | STAGING / ANALYTICS |
| Doublons exacts | Conservation jusqu'à validation métier | STAGING |
| Ajustements comptables identifiés | Analyse séparée | ANALYTICS |

# 6. Règles en attente de confirmation

Certaines décisions ne peuvent pas être confirmées uniquement à partir du dataset.

| Sujet | Information manquante | Décision retenue provisoirement |
|---|---|---|
| Doublons exacts | Identification des duplications accidentelles | Conservation |
| Quantités négatives | Nature exacte de chaque opération | Analyse séparée |
| Prix nuls | Motif exact de chaque gratuité ou anomalie | Analyse séparée |
| Factures annulées | Règles comptables officielles | Classification selon le préfixe C |
| Clients manquants | Politique d'identification des clients | Conservation des transactions |
| Descriptions manquantes | Référentiel produits officiel | Conservation de NULL |
| Prix négatifs | Documentation comptable complète | Analyse séparée |

Ces règles pourront évoluer si de nouvelles informations fiables sont disponibles.

# 7. Mise en œuvre dans l'architecture de données

Les règles seront appliquées progressivement dans les différentes couches.

| Couche | Responsabilité |
|---|---|
| RAW | Préserver les données sources sans modification. |
| STAGING | Nettoyer techniquement, convertir les types et identifier les anomalies. |
| ANALYTICS | Appliquer les conventions métier, classifier les opérations et construire les indicateurs. |
| POWER BI | Présenter les indicateurs et faciliter l'analyse décisionnelle. |

Les transformations ANALYTICS devront être documentées et reproductibles dans les scripts SQL.

Les règles métier devront être cohérentes entre les tables, les mesures SQL et les indicateurs Power BI.

# 8. Conclusion

Les règles définies dans ce document constituent le référentiel analytique du projet Retail Intelligence.

Elles permettent de transformer les observations du profilage et des contrôles qualité en décisions explicites pour l'analyse commerciale.

Les anomalies ne sont pas supprimées arbitrairement. Elles sont conservées, identifiées et traitées selon leur signification possible.

Les conventions analytiques retenues permettent de construire des indicateurs cohérents tout en respectant les limites du dataset.

Le projet privilégie ainsi la transparence, la traçabilité et la fiabilité des résultats plutôt que l'introduction de données ou d'hypothèses non vérifiées.

---

### BR024 — Sélection de la description de référence d'un produit

**Objectif :** disposer d'une description représentative par produit dans la dimension `dim_product`.

**Constat :**
- 4 070 codes produits distincts.
- 3 311 produits possèdent une seule description non NULL.
- 647 produits possèdent plusieurs descriptions distinctes.
- 112 produits ne possèdent aucune description exploitable.

**Règles de gestion :**
1. Chaque code `stock_code` exact correspond à un produit distinct dans `dim_product`.
2. Si un produit possède une seule description non NULL, celle-ci est retenue.
3. Si plusieurs descriptions existent, la description ayant le plus grand nombre d'occurrences est retenue.
4. En cas d'égalité, un classement alphabétique croissant permet de départager les descriptions de manière déterministe.
5. Si toutes les descriptions sont NULL, la description de référence reste NULL.
6. Les descriptions secondaires restent conservées dans STAGING.
7. Les codes produits ne sont pas normalisés automatiquement en majuscules ou minuscules.

**Limite :** la description retenue est une description de référence statistique. Sa fréquence ne garantit pas qu'elle représente la désignation officielle du produit.