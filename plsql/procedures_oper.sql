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