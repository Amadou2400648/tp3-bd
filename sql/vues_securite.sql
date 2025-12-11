
-- Création des utilisateurs
CREATE USER ADMIN_LAB IDENTIFIED BY admin_123
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

CREATE USER GEST_LAB IDENTIFIED BY gest_123
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;

CREATE USER LECT_LAB IDENTIFIED BY lect_123
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;

-- Autorisation de connexion
GRANT CREATE SESSION TO ADMIN_LAB, GEST_LAB, LECT_LAB;

-- Création du rôle commun
CREATE ROLE ROLE_LAB_RESEARCH;

GRANT ROLE_LAB_RESEARCH TO GEST_LAB;
GRANT ROLE_LAB_RESEARCH TO LECT_LAB;

GRANT INSERT ANY TABLE TO GEST_LAB;
GRANT EXECUTE ANY PROCEDURE TO GEST_LAB;

-- Privilèges du schéma principal
GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE,CREATE TRIGGER,
      UNLIMITED TABLESPACE TO ADMIN_LAB;

/** Vue des données hachées pour la sécurité **/
SELECT STANDARD_HASH(nom, 'SHA256') FROM CHERCHEUR;
SELECT STANDARD_HASH(TO_CHAR(mesure), 'SHA256') FROM ECHANTILLON;


/** Vue des projets publics **/
CREATE OR REPLACE VIEW V_PROJETS_PUBLICS AS
SELECT *
FROM PROJET
WHERE date_fin IS NOT NULL
  AND date_fin <= SYSDATE;


/** Vue des résultats des expériences **/
CREATE OR REPLACE VIEW V_RESULTATS_EXPERIENCE AS
SELECT
    e.id_exp,
    e.titre_exp,
    e.date_realisation,
    e.statut,
    p.titre AS titre_projet,
    p.domaine AS domaine_projet,
    c.nom AS nom_chercheur,
    c.prenom AS prenom_chercheur,
    COUNT(ec.id_echantillon) AS nb_echantillons,
    AVG(ec.mesure) AS moyenne_mesure,
    e.resultat AS resultat_exp,
    (p.date_fin - p.date_debut) AS duree_projet
FROM EXPERIENCE e
JOIN PROJET p ON e.id_projet = p.id_projet
JOIN CHERCHEUR c ON p.id_chercheur_resp = c.id_chercheur
LEFT JOIN ECHANTILLON ec ON ec.id_exp = e.id_exp
GROUP BY
    e.id_exp, e.titre_exp, e.date_realisation, e.statut,
    p.titre, p.domaine, c.nom, c.prenom, e.resultat, p.date_fin, p.date_debut;


-- Accorder uniquement les vues et fonctions de reporting
GRANT SELECT ON V_PROJETS_PUBLICS TO LECT_LAB;
GRANT SELECT ON V_RESULTATS_EXPERIENCE TO LECT_LAB;
GRANT EXECUTE ON moyenne_mesures_experience TO LECT_LAB;
GRANT EXECUTE ON budget_moyen_par_domaine TO LECT_LAB;