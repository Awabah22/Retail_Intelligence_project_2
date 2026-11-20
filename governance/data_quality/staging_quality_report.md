# STAGING DATA QUALITY REPORT
## Projet : Retail Intelligence

**Phase :** STAGING  
**Table analysée :** `staging.online_retail_clean`  
**Volume analysé :** 541 909 lignes  
**Date du contrôle :** 04 novembre 2026  
**Statut général :** Contrôles exécutés et résultats documentés

---

## 1. Contexte et objectifs

Cette étape consiste à évaluer la qualité des données après leur transformation depuis la couche RAW vers la couche STAGING.

Les contrôles ont pour objectifs de :

- Vérifier la complétude des colonnes obligatoires.
- Contrôler la validité des valeurs numériques.
- Vérifier la cohérence des règles de transformation.
- Contrôler l'exactitude des montants calculés.
- Identifier les doublons métier.
- Vérifier l'intégrité des identifiants techniques.
- Contrôler la traçabilité des chargements.
- Identifier les anomalies nécessitant une analyse métier.

Les contrôles sont réalisés sans suppression automatique des données.

## 2. Présentation de la table STAGING

La table `staging.online_retail_clean` contient 14 colonnes :

| Catégorie | Colonnes |
|---|---|
| Identifiant technique | staging_id |
| Données métier | invoice_no, stock_code, description, quantity, invoice_date, unit_price, customer_id, country |
| Colonnes dérivées | invoice_type, line_amount, has_negative_quantity, has_zero_unit_price |
| Traçabilité | loaded_at |

Les prix unitaires sont stockés avec une précision de trois décimales (`NUMERIC(12,3)`) afin de préserver les valeurs particulières telles que 0.001.

Les montants de ligne sont également stockés avec trois décimales (`NUMERIC(14,3)`).

## 3. Résultats des contrôles qualité

### 3.1 STQ001 — Complétude

**Objectif :** vérifier l'absence de valeurs NULL dans les colonnes obligatoires.

| Indicateur | Résultat |
|---|---:|
| Nombre total de lignes | 541 909 |
| Invoice_no manquant | 0 |
| Stock_code manquant | 0 |
| Quantity manquante | 0 |
| Invoice_date manquante | 0 |
| Unit_price manquant | 0 |
| Country manquant | 0 |

**Conclusion :** aucune valeur manquante n'a été détectée dans les colonnes obligatoires contrôlées. Le contrôle est conforme.

### 3.2 STQ002 — Validité

**Objectif :** identifier les valeurs numériques particulières et vérifier la cohérence des montants.

| Indicateur | Résultat |
|---|---:|
| Quantités nulles | 0 |
| Quantités négatives | 10 624 |
| Prix unitaires nuls | 2 515 |
| Prix unitaires négatifs | 2 |
| Montants de ligne incorrects | 0 |

**Conclusion :** les montants calculés sont cohérents. Les quantités négatives, les prix nuls et les prix négatifs nécessitent une interprétation métier, mais ne doivent pas être automatiquement supprimés.

### 3.3 STQ003 — Cohérence

**Objectif :** vérifier la classification des factures.

| Indicateur | Résultat |
|---|---:|
| Types de factures annulées incorrects | 0 |
| Types de factures normales incorrects | 0 |
| Types de factures invalides | 0 |

**Conclusion :** la classification des factures selon le préfixe de leur numéro est cohérente.

Les factures dont le numéro commence par C sont classées comme `Cancelled`. Les autres sont classées comme `Normal`.

### 3.4 STQ004 — Exactitude

**Objectif :** vérifier le calcul des montants transactionnels.

Règle de calcul :

`line_amount = quantity × unit_price`

| Indicateur | Résultat |
|---|---:|
| Nombre total de lignes | 541 909 |
| Montants corrects | 541 909 |
| Montants incorrects | 0 |
| Montant transactionnel total | 9 747 747.934 |

**Conclusion :** tous les montants de ligne sont correctement calculés.

Ce montant représente une somme transactionnelle calculée à partir des quantités et des prix unitaires. Il ne représente pas le bénéfice ou la rentabilité, car les coûts d'achat ne sont pas disponibles.

### 3.5 STQ005 — Unicité

**Objectif :** identifier les lignes métier exactement répétées.

| Indicateur | Résultat |
|---|---:|
| Groupes de doublons exacts | 4 879 |
| Lignes appartenant aux groupes | 10 147 |
| Lignes supplémentaires en doublon | 5 268 |
| Nombre maximal d'occurrences | 20 |

**Conclusion :** des doublons exacts sont présents dans la table STAGING.

Ils sont conservés à ce stade afin de préserver l'intégralité des données sources. Une analyse métier complémentaire sera nécessaire avant toute décision de déduplication.

### 3.6 STQ006 — Intégrité technique

**Objectif :** vérifier l'unicité des identifiants techniques.

| Indicateur | Résultat |
|---|---:|
| Nombre total de lignes | 541 909 |
| Identifiants non nuls | 541 909 |
| Identifiants distincts | 541 909 |
| Identifiants dupliqués | 0 |

**Conclusion :** tous les enregistrements possèdent un identifiant technique unique. L'intégrité technique est respectée.

### 3.7 STQ007 — Traçabilité

**Objectif :** vérifier la présence des informations de chargement.

| Indicateur | Résultat |
|---|---|
| Nombre total de lignes | 541 909 |
| Dates de chargement manquantes | 0 |
| Premier chargement | 2026-11-04 12:39:43 UTC |
| Dernier chargement | 2026-11-04 12:39:43 UTC |

**Conclusion :** toutes les lignes disposent d'un horodatage de chargement. La traçabilité technique est assurée pour cette opération.

### 3.8 STQ008 — Anomalies métier

**Objectif :** identifier les situations particulières nécessitant une analyse métier.

| Indicateur | Résultat |
|---|---:|
| Identifiants clients manquants | 135 080 |
| Descriptions manquantes | 1 454 |
| Quantités négatives | 10 624 |
| Prix unitaires nuls | 2 515 |
| Factures annulées avec montant non négatif | 0 |
| Factures normales avec montant négatif | 2 |

**Conclusion :** les anomalies détectées correspondent aux particularités déjà identifiées lors du profilage RAW.

Les deux factures normales présentant un montant négatif correspondent aux opérations d'ajustement de créances douteuses identifiées précédemment.

## 4. Synthèse des résultats

| Contrôle | Dimension | Résultat principal |
|---|---|---|
| STQ001 | Complétude | 0 valeur obligatoire manquante |
| STQ002 | Validité | 0 montant incorrect |
| STQ003 | Cohérence | 0 incohérence de classification |
| STQ004 | Exactitude | 541 909 montants corrects |
| STQ005 | Unicité | 4 879 groupes de doublons exacts |
| STQ006 | Intégrité technique | 0 identifiant dupliqué |
| STQ007 | Traçabilité | 0 date de chargement manquante |
| STQ008 | Anomalies métier | Plusieurs particularités identifiées |

## 5. Recommandations pour la suite

Les recommandations suivantes sont retenues pour la préparation de la couche ANALYTICS :

1. **Clients manquants :** conserver les transactions et prévoir une gestion adaptée des clients non identifiés.
2. **Descriptions manquantes :** analyser les références produits concernées avant toute correction.
3. **Quantités négatives :** préserver les retours et autres ajustements jusqu'à leur classification métier.
4. **Prix nuls :** conserver les opérations et analyser leur nature.
5. **Prix négatifs :** maintenir les ajustements comptables identifiés.
6. **Doublons exacts :** ne pas supprimer automatiquement les lignes répétées ; approfondir leur signification métier.
7. **Montants négatifs :** distinguer les factures annulées des ajustements comptables.
8. **Traçabilité :** conserver l'identifiant technique et l'horodatage de chargement.

## 6. Limites de l'analyse

Les contrôles réalisés portent principalement sur la qualité structurelle, technique et certaines règles métier des données.

Ils ne permettent pas, à eux seuls, de confirmer :

- La réalité commerciale de chaque transaction.
- La signification exacte de tous les doublons.
- La nature définitive de chaque quantité négative.
- La rentabilité réelle des ventes, faute de données de coûts.
- L'exactitude de toutes les descriptions et informations métier par rapport à une source externe.

Ces éléments nécessitent des règles métier supplémentaires et, si possible, des données de référence.

## 7. Conclusion générale

La couche STAGING contient les 541 909 lignes issues de la couche RAW.

Les huit contrôles qualité ont permis de vérifier la complétude des colonnes obligatoires, la validité des valeurs numériques, la cohérence des transformations, l'exactitude des montants, l'unicité des identifiants techniques et la traçabilité des chargements.

Des particularités métier subsistent, notamment les quantités négatives, les prix nuls, les clients manquants et les doublons exacts. Elles sont documentées et conservées afin de ne pas altérer les informations sources.

La couche STAGING constitue ainsi une base structurée pour poursuivre les transformations et construire la couche ANALYTICS, sous réserve de la définition des règles métier nécessaires à cette prochaine étape.