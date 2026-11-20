# Data Dictionary — Retail Intelligence

**Projet :** Retail Intelligence — Sales, Profitability & Customer Analytics  
**Source :** UCI Online Retail Dataset  
**Table source :** `raw.online_retail_source`  
**Couche documentée :** RAW  
**Version :** 1.0  
**Date :** Novembre 2026  
**Statut :** Version initiale — à valider pendant la conception de STAGING

---

## 1. Présentation de la source

Le dataset Online Retail contient les transactions commerciales d'une entreprise britannique spécialisée dans la vente en ligne de cadeaux et d'articles pour la maison.

| Propriété | Description |
|---|---|
| Source | UCI Machine Learning Repository |
| Dataset | Online Retail |
| Période | 01/12/2010 – 09/12/2011 |
| Nombre de lignes | 541 909 |
| Nombre de colonnes | 8 |
| Format original | Excel (.xlsx) |
| Format importé | CSV UTF-8 |
| Séparateur CSV | Point-virgule (;) |
| Table RAW | `raw.online_retail_source` |

## 2. Dictionnaire des colonnes

### 2.1 InvoiceNo

| Propriété | Description |
|---|---|
| Nom technique | `invoice_no` |
| Nom métier | Numéro de facture |
| Définition métier | Identifiant permettant d'identifier une facture ou une transaction commerciale. |
| Type source | TEXT |
| Type cible envisagé | VARCHAR(20) |
| Nullabilité | Non nullable dans l'audit RAW |
| Clé potentielle | Identifiant de facture |
| Règles de gestion | Les numéros commençant par C indiquent généralement des factures annulées. |
| Contraintes | La valeur doit être conservée sous forme textuelle. |
| Transformation | Supprimer les espaces superflus si nécessaire et identifier les factures annulées. |
| Exemple | `536365`, `C538081` |

**Attention :** `invoice_no` ne constitue pas une clé unique de ligne, car une facture peut contenir plusieurs produits.

### 2.2 StockCode

| Propriété | Description |
|---|---|
| Nom technique | `stock_code` |
| Nom métier | Référence produit |
| Définition métier | Code permettant d'identifier un produit ou un article commercial. |
| Type source | TEXT |
| Type cible envisagé | VARCHAR(50) |
| Nullabilité | Non nullable dans l'audit RAW |
| Clé potentielle | Identifiant produit |
| Règles de gestion | Plusieurs transactions peuvent concerner le même produit. Certains codes peuvent représenter des opérations particulières. |
| Contraintes | Conserver les lettres, chiffres et caractères présents dans le code. |
| Transformation | Normalisation des espaces sans altérer le code original. |
| Exemple | `85123A`, `22630`, `B` |

### 2.3 Description

| Propriété | Description |
|---|---|
| Nom technique | `description` |
| Nom métier | Désignation du produit |
| Définition métier | Description textuelle permettant de comprendre la nature du produit ou de l'opération. |
| Type source | TEXT |
| Type cible envisagé | TEXT |
| Nullabilité | Nullable |
| Clé potentielle | Aucune |
| Règles de gestion | Une description peut être absente ou correspondre à une opération non commerciale. |
| Contraintes | Les valeurs vides doivent être identifiées. |
| Transformation | Nettoyage des espaces et conservation des valeurs manquantes avec traçabilité. |
| Exemple | `WHITE HANGING HEART T-LIGHT HOLDER` |

**Observation RAW :** 1 454 descriptions manquantes.

### 2.4 Quantity

| Propriété | Description |
|---|---|
| Nom technique | `quantity` |
| Nom métier | Quantité de produits |
| Définition métier | Nombre d'unités associées à une ligne de transaction. |
| Type source | TEXT |
| Type cible envisagé | INTEGER |
| Nullabilité | Non nullable dans l'audit RAW |
| Clé potentielle | Aucune |
| Règles de gestion | Une quantité positive correspond généralement à une vente. Une quantité négative peut représenter un retour ou une annulation. |
| Contraintes | La valeur doit être convertible en entier. |
| Transformation | Conversion TEXT vers INTEGER après validation. |
| Exemple | `6`, `-33` |

**Observation RAW :** 10 624 quantités négatives et aucune quantité nulle.

### 2.5 InvoiceDate

| Propriété | Description |
|---|---|
| Nom technique | `invoice_date` |
| Nom métier | Date et heure de transaction |
| Définition métier | Date et heure auxquelles la transaction a été enregistrée. |
| Type source | TEXT |
| Type cible envisagé | TIMESTAMP |
| Nullabilité | Non nullable dans l'audit RAW |
| Clé potentielle | Aucune |
| Règles de gestion | La date doit respecter le format source DD/MM/YYYY HH24:MI. |
| Contraintes | La valeur doit être une date valide. |
| Transformation | Conversion en TIMESTAMP avec prise en compte du format jour/mois/année. |
| Exemple | `01/12/2010 08:26` |

### 2.6 UnitPrice

| Propriété | Description |
|---|---|
| Nom technique | `unit_price` |
| Nom métier | Prix unitaire |
| Définition métier | Prix associé à une unité du produit ou de l'article enregistré dans la transaction. |
| Type source | TEXT |
| Type cible envisagé | NUMERIC(12,2) |
| Nullabilité | Non nullable dans l'audit RAW |
| Clé potentielle | Aucune |
| Règles de gestion | Le prix peut être nul ou négatif pour certaines opérations particulières. |
| Contraintes | La valeur doit être convertible en nombre décimal après normalisation du séparateur. |
| Transformation | Remplacer la virgule décimale par un point, puis convertir en NUMERIC. |
| Exemple | `2,55`, `-11062,06` |

**Observation RAW :** 2 prix négatifs et 2 515 prix nuls.

### 2.7 CustomerID

| Propriété | Description |
|---|---|
| Nom technique | `customer_id` |
| Nom métier | Identifiant client |
| Définition métier | Identifiant permettant de rattacher une transaction à un client. |
| Type source | TEXT |
| Type cible envisagé | VARCHAR(20) |
| Nullabilité | Nullable |
| Clé potentielle | Identifiant client |
| Règles de gestion | Un client peut réaliser plusieurs transactions. Certaines transactions ne possèdent pas d'identifiant client. |
| Contraintes | Conserver le format original et ne pas inventer d'identifiant client. |
| Transformation | Nettoyage des espaces et gestion des valeurs manquantes. |
| Exemple | `17850`, `16898` |

**Observation RAW :** 135 080 valeurs manquantes.

### 2.8 Country

| Propriété | Description |
|---|---|
| Nom technique | `country` |
| Nom métier | Pays |
| Définition métier | Pays associé à la transaction commerciale. |
| Type source | TEXT |
| Type cible envisagé | VARCHAR(100) |
| Nullabilité | Non nullable dans l'audit RAW |
| Clé potentielle | Attribut géographique |
| Règles de gestion | Plusieurs transactions peuvent appartenir au même pays. Certaines valeurs représentent des catégories particulières plutôt que des pays. |
| Contraintes | La valeur doit être conservée et appartenir à une catégorie géographique documentée. |
| Transformation | Normalisation des espaces et harmonisation éventuelle des appellations. |
| Exemple | `United Kingdom`, `Germany`, `France`, `EIRE` |

**Observation RAW :** 38 valeurs géographiques distinctes.

---

## 3. Règles de gestion transversales

| ID | Règle | Description |
|---|---|---|
| BR-001 | Identification des annulations | Les factures commençant par C doivent être identifiées séparément. |
| BR-002 | Gestion des retours | Les quantités négatives doivent être analysées comme des mouvements particuliers. |
| BR-003 | Gestion des prix nuls | Les prix nuls doivent être examinés avant leur éventuelle exclusion. |
| BR-004 | Gestion des ajustements | Les opérations comptables telles que Adjust bad debt doivent être distinguées des ventes de produits. |
| BR-005 | Identification client | Les transactions sans CustomerID restent exploitables pour certaines analyses commerciales. |
| BR-006 | Calcul du chiffre d'affaires | Le montant de ligne peut être calculé par Quantity × UnitPrice, après validation des règles métier. |
| BR-007 | Analyse des doublons | Les doublons exacts doivent être examinés avant toute déduplication. |
| BR-008 | Traçabilité | Les données originales doivent rester conservées dans la couche RAW. |

## 4. Règles de transformation RAW vers STAGING

| Colonne source | Transformation prévue | Type cible |
|---|---|---|
| invoice_no | Nettoyage des espaces et identification des annulations | VARCHAR(20) |
| stock_code | Nettoyage des espaces | VARCHAR(50) |
| description | Nettoyage des espaces, gestion des valeurs manquantes | TEXT |
| quantity | Conversion numérique avec validation | INTEGER |
| invoice_date | Conversion selon le format DD/MM/YYYY HH24:MI | TIMESTAMP |
| unit_price | Normalisation du séparateur décimal et conversion | NUMERIC(12,2) |
| customer_id | Nettoyage et gestion des valeurs manquantes | VARCHAR(20) |
| country | Nettoyage et harmonisation géographique | VARCHAR(100) |

## 5. Limites et points de vigilance

1. Le dataset ne contient pas de coût d'achat des produits. Le bénéfice réel et la marge réelle ne peuvent donc pas être calculés directement.
2. Les transactions annulées, les retours et les ajustements comptables doivent être distingués.
3. Les valeurs manquantes ne doivent pas être supprimées automatiquement.
4. Les doublons exacts nécessitent une analyse complémentaire.
5. Les transformations doivent être documentées et reproductibles.

## 6. Historique des versions

| Version | Date | Modification |
|---|---|---|
| 1.0 | Novembre 2026 | Création du dictionnaire initial des 8 colonnes RAW |

---

**Fin du document — Data Dictionary Retail Intelligence**
