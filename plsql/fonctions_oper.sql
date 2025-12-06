-- ==========================================
--          FOMCTIONS OPÉRATIONNELLES
-- ==========================================

/** Vérifier disponibilite équipement **/
CREATE OR REPLACE FUNCTION verifier_disponibilite_equipement(
    p_id_equipement IN NUMBER
) RETURN NUMBER
IS
    v_affectations AFFECTATION_EQUIP;
BEGIN
    SELECT affectation_rec(id_affect, date_affectation, duree_jours)
    BULK COLLECT INTO v_affectations
    FROM AFFECTATION_EQUIP
    WHERE id_equipement = p_id_equipement;

    IF v_affectations.COUNT = 0 THEN
        RETURN 1;  
    ELSE
        RETURN 0; 
    END IF;
END;
/
