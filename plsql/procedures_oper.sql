-- Charger les fonctions dont dependent les procedures
@fonctions_oper.sql

-- ==========================================
--          PROCÉDURES OPÉRATIONNELLES
-- ==========================================

/** Ajouter un nouveau projet **/
CREATE OR REPLACE PROCEDURE ajouter_projet(
    p_titre             IN PROJET.titre%TYPE,
    p_domaine           IN PROJET.domaine%TYPE,
    p_budget            IN PROJET.budget%TYPE,
    p_date_debut        IN PROJET.date_debut%TYPE,
    p_date_fin          IN PROJET.date_fin%TYPE,
    p_id_chercheur_resp IN CHERCHEUR.id_chercheur%TYPE
)
IS
    v_count NUMBER;
BEGIN
    -- Vérifier que le chercheur existe
    SELECT COUNT(*) INTO v_count
    FROM CHERCHEUR
    WHERE id_chercheur = p_id_chercheur_resp;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Le chercheur responsable n''existe pas.');
    END IF;

    IF p_date_debut > p_date_fin THEN
	    RAISE_APPLICATION_ERROR(-20020,'La date de début ne peut pas être après la date de fin.');
	END IF;

    -- Insérer le projet
    INSERT INTO PROJET (
        titre, domaine, budget, date_debut, date_fin, id_chercheur_resp
    ) VALUES (
        p_titre, p_domaine, p_budget, p_date_debut, p_date_fin, p_id_chercheur_resp
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Annuler la transaction en cas d'erreur
        ROLLBACK;
        -- Afficher un message d'erreur détaillé
        RAISE_APPLICATION_ERROR(-20011, 'Erreur lors de l''ajout du projet : ' || SQLERRM);
END;
/

/** Affecter un équipement à un projet. **/
CREATE OR REPLACE PROCEDURE affecter_equipement(
    p_id_projet        IN NUMBER,
    p_id_equipement    IN NUMBER,
    p_date_affectation IN DATE
)
IS
    v_libre NUMBER;
    v_duree_projet_jours NUMBER;
BEGIN
    -- Vérifier la disponibilité de l'équipement
    v_libre := verifier_disponibilite_equipement(p_id_equipement);

    IF v_libre = 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'L''équipement est déjà affecté à un autre projet.');
    END IF;

    v_duree_projet_jours := calculer_duree_projet(p_id_projet);

    -- Insérer l'affectation
    INSERT INTO AFFECTATION_EQUIP (
        id_projet, id_equipement, date_affectation, duree_jours
    ) VALUES (
        p_id_projet, p_id_equipement, p_date_affectation, v_duree_projet_jours
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20021, 'Erreur lors de l''affectation de l''équipement : ' || SQLERRM);
END;
/

/** Supprimer projet **/
CREATE OR REPLACE PROCEDURE supprimer_projet(p_id_projet IN NUMBER) IS
  -- Curseur pour les affectations d'équipement liées au projet
  CURSOR cur_affect IS
    SELECT id_affect FROM AFFECTATION_EQUIP WHERE id_projet = p_id_projet
    FOR UPDATE;

  -- Curseur pour les expériences liées au projet
  CURSOR cur_exp IS
    SELECT id_exp FROM EXPERIENCE WHERE id_projet = p_id_projet
    FOR UPDATE;

  -- Curseur pour les échantillons liés aux expériences du projet
  CURSOR cur_echant IS
    SELECT e.id_echantillon
    FROM ECHANTILLON e
    JOIN EXPERIENCE ex ON e.id_exp = ex.id_exp
    WHERE ex.id_projet = p_id_projet
    FOR UPDATE;

BEGIN
  -- Supprimer les échantillons liés aux expériences
  FOR r_echant IN cur_echant LOOP
    DELETE FROM ECHANTILLON WHERE id_echantillon = r_echant.id_echantillon;
  END LOOP;

  -- Supprimer les expériences liées au projet
  FOR r_exp IN cur_exp LOOP
    DELETE FROM EXPERIENCE WHERE id_exp = r_exp.id_exp;
  END LOOP;

  -- Supprimer les affectations d'équipement liées au projet
  FOR r_affect IN cur_affect LOOP
    DELETE FROM AFFECTATION_EQUIP WHERE id_affect = r_affect.id_affect;
  END LOOP;

  -- Enfin, supprimer le projet lui-même
  DELETE FROM PROJET WHERE id_projet = p_id_projet;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Erreur lors de la suppression du projet : ' || SQLERRM);
END supprimer_projet;
/

/** journaliser_action **/
CREATE OR REPLACE PROCEDURE journaliser_action(
  p_table       IN VARCHAR2,
  p_operation   IN VARCHAR2,
  p_utilisateur IN VARCHAR2,
  p_description IN VARCHAR2
) IS
BEGIN
  INSERT INTO LOG_OPERATION (table_concernee, operation, utilisateur, date_op, description)
  VALUES (p_table, SUBSTR(p_operation,1,10), p_utilisateur, SYSDATE, p_description);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20010, 'Erreur journaliser_action : ' || SQLERRM);
END journaliser_action;
/

/** planifier_experience **/
CREATE OR REPLACE PROCEDURE planifier_experience(
  p_id_projet        IN NUMBER,
  p_titre_exp        IN VARCHAR2,
  p_date_realisation IN DATE,
  p_resultat         IN VARCHAR2,
  p_statut           IN VARCHAR2,
  p_type_echantillon IN VARCHAR2,
  p_date_prelevement IN DATE,
  p_mesure           IN NUMBER,
  p_id_equipement    IN NUMBER,
  p_date_affectation IN DATE,
  p_duree_jours      IN NUMBER
) IS
  v_id_exp NUMBER;
  v_id_echant NUMBER;
BEGIN
  -- Vérifier que le projet existe
  DECLARE 
    v_tmp NUMBER; 
  BEGIN 
    SELECT 1 INTO v_tmp FROM PROJET WHERE id_projet = p_id_projet;
  END;

  IF p_statut IS NOT NULL AND p_statut NOT IN ('En cours','Terminée','Annulée') THEN
    RAISE_APPLICATION_ERROR(-20030, 'Statut non valide.');
  END IF;

  -- Insérer expérience
  INSERT INTO EXPERIENCE (id_projet, titre_exp, date_realisation, resultat, statut)
  VALUES (p_id_projet, p_titre_exp, p_date_realisation, p_resultat, p_statut)
  RETURNING id_exp INTO v_id_exp;

  -- Insérer échantillon 
  IF p_type_echantillon IS NOT NULL THEN
    INSERT INTO ECHANTILLON (id_exp, type_echantillon, date_prelevement, mesure)
    VALUES (v_id_exp, p_type_echantillon, p_date_prelevement, p_mesure)
    RETURNING id_echantillon INTO v_id_echant;
  END IF;

  -- Appel d'affectation d'équipement
  IF p_id_equipement IS NOT NULL THEN
    affecter_equipement(p_id_projet, p_id_equipement, p_date_affectation, p_duree_jours);
  END IF;

  -- Journaliser
  journaliser_action('EXPERIENCE', 'INSERT', USER,
    'Planification experience id=' || v_id_exp || ' projet=' || p_id_projet || ' titre=' || NVL(p_titre_exp,'<null>'));

  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20031, 'Projet introuvable lors de planification experience.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20032, 'Erreur planifier_experience : ' || SQLERRM);
END planifier_experience;
/