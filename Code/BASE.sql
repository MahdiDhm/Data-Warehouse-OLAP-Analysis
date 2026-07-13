---  Chargement les données dans une table 
CREATE TABLE achats_clients (
    identifiant_client INTEGER,
    date_achat TIMESTAMP,
    categorie_produit TEXT,
    prix_produit NUMERIC,
    quantite INTEGER,
    montant_total_achat NUMERIC,
    methode_paiement TEXT,
    age_client INTEGER,
    retours NUMERIC,
    nom_client TEXT,
    age INTEGER,
    genre TEXT,
    taux_de_desabonnement INTEGER
);
SELECT * FROM achats_clients

---  1)Prétraitement

-- Ajouter les colonnes année, mois, jour
ALTER TABLE achats_clients ADD COLUMN annee INT;
ALTER TABLE achats_clients ADD COLUMN mois INT;
ALTER TABLE achats_clients ADD COLUMN jour_semaine TEXT;

-- Remplir les colonnes
UPDATE achats_clients
SET
    annee = EXTRACT(YEAR FROM date_achat),
    mois = EXTRACT(MONTH FROM date_achat),
    jour_semaine = TO_CHAR(date_achat, 'Day');

--- Supprimer la colonne age (puisqu’elle est dupliquée avec age_client)
ALTER TABLE achats_clients DROP COLUMN age;

---- visualiser les lignes ou retours est null
SELECT *
FROM achats_clients 
WHERE retours IS NULL

--- Supprimer les lignes où retours est NULL
DELETE FROM achats_clients
WHERE retours IS NULL;
--- DELETE 47596


--- détection des doublons
SELECT COUNT(*) AS nb_doublons
FROM (
    SELECT COUNT(*)
    FROM achats_clients
    GROUP BY identifiant_client, date_achat, categorie_produit, prix_produit, quantite,
             montant_total_achat, methode_paiement, age_client, retours,
             nom_client, genre,taux_de_desabonnement
    HAVING COUNT(*) > 1
) AS sous_requete;
----on a pas des doublons .


---- 2)Modélisation en étoile pour achats_clients
--- Dimension dim_client
CREATE TABLE dim_client (
    id_client SERIAL PRIMARY KEY,
    nom_client TEXT,
    age INT,
    genre TEXT,
    methode_paiement TEXT
);
---- Dimension dim_produit
CREATE TABLE dim_produit (
    id_produit SERIAL PRIMARY KEY,
    categorie_produit TEXT,
    prix_produit NUMERIC
);
---- Dimension dim_temps
CREATE TABLE dim_temps (
    id_temps SERIAL PRIMARY KEY,
    date_achat DATE,
    annee INT,
    mois INT,
    jour_semaine TEXT
);
---- Table de faits : faits_achats
CREATE TABLE faits_achats (
    id_achat SERIAL PRIMARY KEY,
    id_client INT REFERENCES dim_client(id_client),
    id_produit INT REFERENCES dim_produit(id_produit),
    id_temps INT REFERENCES dim_temps(id_temps),
    quantite INT,
    montant_total NUMERIC,
    retours NUMERIC,
    taux_de_desabonnement INT
);
--- Insérer les donnees dans dim_client
INSERT INTO dim_client (nom_client, age, genre, methode_paiement)
SELECT DISTINCT nom_client, age_client, genre, methode_paiement
FROM achats_clients;
---- INSERT 0 119004

--- Insérer les donnees dans dim_produit
INSERT INTO dim_produit (categorie_produit, prix_produit)
SELECT DISTINCT categorie_produit, prix_produit
FROM achats_clients;
--- INSERT 0 1964

--- Insérer les donnees dans dim_temps
INSERT INTO dim_temps (date_achat, annee, mois, jour_semaine)
SELECT DISTINCT DATE(date_achat), annee, mois, jour_semaine
FROM achats_clients;
--- INSERT 0 1354

--- Insérer les donnees dans faits_achats
INSERT INTO faits_achats (
    id_client, id_produit, id_temps, quantite, montant_total, retours, taux_de_desabonnement
)
SELECT 
    dc.id_client,
    dp.id_produit,
    dt.id_temps,
    ac.quantite,
    ac.montant_total_achat,
    ac.retours,
    ac.taux_de_desabonnement
FROM achats_clients ac
JOIN dim_client dc
    ON ac.nom_client = dc.nom_client 
    AND ac.age_client = dc.age 
    AND ac.genre = dc.genre 
    AND ac.methode_paiement = dc.methode_paiement
JOIN dim_produit dp
    ON ac.categorie_produit = dp.categorie_produit 
    AND ac.prix_produit = dp.prix_produit
JOIN dim_temps dt
    ON DATE(ac.date_achat) = dt.date_achat 
    AND ac.annee = dt.annee 
    AND ac.mois = dt.mois 
    AND ac.jour_semaine = dt.jour_semaine;
---- INSERT 0 202404


SELECT * FROM faits_achats
SELECT * FROM dim_produit
SELECT * FROM dim_temps
SELECT * FROM dim_client

---Data mart des ventes (dm_ventes_produits)
---But : Analyser les quantités vendues et les revenus par produit, catégorie, période.
CREATE MATERIALIZED VIEW dm_ventes_produits AS
SELECT 
    dp.categorie_produit,
    dt.annee,
    dt.mois,
    SUM(fa.quantite) AS total_quantite,
    SUM(fa.montant_total) AS total_ventes
FROM faits_achats fa
JOIN dim_produit dp ON fa.id_produit = dp.id_produit
JOIN dim_temps dt ON fa.id_temps = dt.id_temps
GROUP BY dp.categorie_produit, dt.annee, dt.mois;


---Data mart client (dm_comportement_clients)
---But : Étudier le comportement des clients (retours, désabonnement, méthode de paiement).
CREATE MATERIALIZED VIEW dm_comportement_clients AS
SELECT 
    dc.nom_client,
    dc.age,
    dc.genre,
    dc.methode_paiement,
    COUNT(*) AS nb_achats,
    SUM(fa.montant_total) AS total_depenses,
    AVG(fa.retours) AS taux_retour_moyen,
    AVG(fa.taux_de_desabonnement) AS taux_desabonnement_moyen
FROM faits_achats fa
JOIN dim_client dc ON fa.id_client = dc.id_client
GROUP BY dc.nom_client, dc.age, dc.genre, dc.methode_paiement;


---Data mart temps (dm_ventes_temps)
---But : Observer l’évolution des ventes au fil du temps (utile pour tendance et prévision).
CREATE MATERIALIZED VIEW dm_ventes_temps AS
SELECT 
    dt.annee,
    dt.mois,
    dt.jour_semaine,
    SUM(fa.montant_total) AS total_ventes,
    SUM(fa.quantite) AS total_quantite
FROM faits_achats fa
JOIN dim_temps dt ON fa.id_temps = dt.id_temps
GROUP BY dt.annee, dt.mois, dt.jour_semaine;


---Data mart par méthode de paiement (dm_ventes_paiement)
---But : Savoir quelle méthode de paiement est la plus utilisée et rentable.
CREATE MATERIALIZED VIEW dm_ventes_paiement AS
SELECT 
    dc.methode_paiement,
    COUNT(*) AS nb_achats,
    SUM(fa.montant_total) AS total_ventes
FROM faits_achats fa
JOIN dim_client dc ON fa.id_client = dc.id_client
GROUP BY dc.methode_paiement;

---Data mart des produits retournés (dm_retours_produits)
---But : Identifier les catégories avec le plus de retours.

CREATE MATERIALIZED VIEW dm_retours_produits AS
SELECT 
    dp.categorie_produit,
    AVG(fa.retours) AS taux_moyen_retour,
    SUM(fa.retours) AS nb_total_retours,
    COUNT(*) AS nb_achats
FROM faits_achats fa
JOIN dim_produit dp ON fa.id_produit = dp.id_produit
GROUP BY dp.categorie_produit;