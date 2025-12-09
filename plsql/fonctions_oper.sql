-- ==========================================
--          FOMCTIONS OPÉRATIONNELLES
-- ==========================================

/** Calculer la durée d'un projet en jours **/
CREATE OR REPLACE FUNCTION calculer_duree_projet(
    p_id_projet IN NUMBER
) RETURN NUMBER
IS
    v_date_debut DATE;
    v_date_fin   DATE;
    v_duree      NUMBER;
BEGIN
    -- Récupérer les dates du projet
    SELECT date_debut, date_fin
    INTO v_date_debut, v_date_fin
    FROM PROJET
    WHERE id_projet = p_id_projet;

    -- Calculer la durée
    v_duree := v_date_fin - v_date_debut;

    RETURN v_duree;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20030, 'Le projet avec ID ' || p_id_projet || ' n''existe pas.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20031, 'Erreur lors du calcul de la durée : ' || SQLERRM);
END;
/


/** Vérifier disponibilite équipement **/
CREATE OR REPLACE FUNCTION verifier_disponibilite_equipement(p_id_equipement IN NUMBER)
RETURN NUMBER
IS
    -- Définition du type de record pour l'équipement
    TYPE equipement_record IS RECORD (
        id_equipement EQUIPEMENT.id_equipement%TYPE,
        etat         EQUIPEMENT.etat%TYPE
    );

    -- Table de records
    TYPE equipement_table IS TABLE OF equipement_record;

    l_equipements equipement_table;
    l_disponibilite NUMBER := 0; 
BEGIN
    -- Récupérer l'équipement demandé
    SELECT id_equipement, etat
    BULK COLLECT INTO l_equipements
    FROM EQUIPEMENT
    WHERE id_equipement = p_id_equipement;

    -- Si l'équipement existe et est "Disponible"
    IF l_equipements.COUNT = 1 AND l_equipements(1).etat = 'Disponible' THEN
        -- Vérifier qu'il n'est pas déjà affecté à un projet
        DECLARE
            v_count NUMBER;
        BEGIN
            SELECT COUNT(*)
            INTO v_count
            FROM AFFECTATION_EQUIP
            WHERE id_equipement = p_id_equipement
              AND (SYSDATE BETWEEN date_affectation AND date_affectation + NVL(duree_jours,0));

            IF v_count = 0 THEN
                l_disponibilite := 1; 
            END IF;
        END;
    END IF;

    RETURN l_disponibilite;
END;
/

