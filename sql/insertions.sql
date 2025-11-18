-- ========================
-- TABLE CHERCHEUR
-- ========================
INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche) VALUES (1, 'Dupont', 'Alice', 'Biotech', TO_DATE('2018-03-15', 'YYYY-MM-DD'));
INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche) VALUES (2, 'Nguyen', 'Bao', 'IA', TO_DATE('2019-06-10', 'YYYY-MM-DD'));
INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche) VALUES (3, 'Martin', 'Chloé', 'Physique', TO_DATE('2020-01-25', 'YYYY-MM-DD'));
INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche) VALUES (4, 'Roy', 'David', 'Chimie', TO_DATE('2017-11-02', 'YYYY-MM-DD'));
INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche) VALUES (5, 'Tremblay', 'Éric', 'Mathématiques', TO_DATE('2016-05-18', 'YYYY-MM-DD'));

-- ========================
-- TABLE PROJET
-- ========================
INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
VALUES (101, 'NanoCapteurs', 'Biotech', 500000, TO_DATE('2023-01-01','YYYY-MM-DD'), TO_DATE('2025-01-01','YYYY-MM-DD'), 1);
INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
VALUES (102, 'DeepPredict', 'IA', 350000, TO_DATE('2022-09-01','YYYY-MM-DD'), TO_DATE('2024-09-01','YYYY-MM-DD'), 2);
INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
VALUES (103, 'QuantumSense', 'Physique', 450000, TO_DATE('2023-03-10','YYYY-MM-DD'), TO_DATE('2025-03-10','YYYY-MM-DD'), 3);

-- ========================
-- TABLE EQUIPEMENT
-- ========================
INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
VALUES (201, 'Microscope BioPro X', 'Analyse biologique', TO_DATE('2019-04-20','YYYY-MM-DD'), 'Disponible');
INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
VALUES (202, 'Serveur GPU A100', 'Calcul haute performance', TO_DATE('2021-12-10','YYYY-MM-DD'), 'Disponible');
INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
VALUES (203, 'Laser Quantix', 'Instrumentation', TO_DATE('2020-08-05','YYYY-MM-DD'), 'En maintenance');
INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
VALUES (204, 'Spectromètre NanoX', 'Analyse chimique', TO_DATE('2018-06-01','YYYY-MM-DD'), 'Hors service');

-- ========================
-- TABLE AFFECTATION_EQUIP
-- ========================
INSERT INTO AFFECTATION_EQUIP (id_affect, id_projet, id_equipement, date_affectation, duree_jours)
VALUES (301, 101, 201, TO_DATE('2023-02-01','YYYY-MM-DD'), 90);
INSERT INTO AFFECTATION_EQUIP (id_affect, id_projet, id_equipement, date_affectation, duree_jours)
VALUES (302, 102, 202, TO_DATE('2023-04-15','YYYY-MM-DD'), 120);
INSERT INTO AFFECTATION_EQUIP (id_affect, id_projet, id_equipement, date_affectation, duree_jours)
VALUES (303, 103, 203, TO_DATE('2024-01-10','YYYY-MM-DD'), 60);

-- ========================
-- TABLE EXPERIENCE
-- ========================
INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, resultat, statut)
VALUES (401, 101, 'Analyse ADN MicroCapteurs', TO_DATE('2023-04-10','YYYY-MM-DD'), 'Succès partiel', 'Terminée');
INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, resultat, statut)
VALUES (402, 101, 'Test bio-compatibilité', TO_DATE('2023-06-20','YYYY-MM-DD'), NULL, 'En cours');
INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, resultat, statut)
VALUES (403, 102, 'Optimisation des réseaux neuronaux', TO_DATE('2023-03-05','YYYY-MM-DD'), 'Précision 94%', 'Terminée');
INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, resultat, statut)
VALUES (404, 103, 'Simulation quantique Photon', TO_DATE('2024-02-14','YYYY-MM-DD'), NULL, 'En cours');

-- ========================
-- TABLE ECHANTILLON
-- ========================
INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
VALUES (501, 401, 'Cellules souches', TO_DATE('2023-04-12','YYYY-MM-DD'), 12.5);
INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
VALUES (502, 401, 'Protéines', TO_DATE('2023-04-15','YYYY-MM-DD'), 18.3);
INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
VALUES (503, 403, 'Jeux de données IA', TO_DATE('2023-03-06','YYYY-MM-DD'), 200.0);

-- ========================
-- TABLE LOG_OPERATION
-- ========================
INSERT INTO LOG_OPERATION (id_log, table_concernee, operation, utilisateur, date_op, description)
VALUES (601, 'CHERCHEUR', 'INSERT', 'admin_rd', SYSDATE, 'Ajout initial de chercheurs');
INSERT INTO LOG_OPERATION (id_log, table_concernee, operation, utilisateur, date_op, description)
VALUES (602, 'PROJET', 'INSERT', 'admin_rd', SYSDATE, 'Création des projets initiaux');
INSERT INTO LOG_OPERATION (id_log, table_concernee, operation, utilisateur, date_op, description)
VALUES (603, 'EQUIPEMENT', 'INSERT', 'admin_rd', SYSDATE, 'Ajout d’équipements au stock');
