-- Charger les procédures et fonctions pour les tests

@..\plsql\procedures_oper.sql  

 -- Test de la procédure ajouter_projet avec un bloc anonyme
 BEGIN
    ajouter_projet('Projet IA','Intelligence Artificielle',100000,TO_DATE('01-12-2025','DD-MM-YYYY'),TO_DATE('30-06-2026','DD-MM-YYYY'),1);

    DBMS_OUTPUT.PUT_LINE('Projet ajouté avec succès.');

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Test terminé, insertion annulée.');

EXCEPTION
    WHEN OTHERS THEN
     	ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
END;
/

-- Tester la procédure affecter_equipement
BEGIN
    -- Test 1 : affecter un équipement libre
    affecter_equipement(1, 2,SYSDATE,7);
    DBMS_OUTPUT.PUT_LINE('Équipement affecté avec succès.');

    -- Test 2 : essayer d'affecter le même équipement à nouveau
    BEGIN
        affecter_equipement(1,2,SYSDATE,5);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur attendue : ' || SQLERRM);
    END;

    -- Annuler les insertions pour ne pas modifier la base
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Test terminé, toutes les modifications annulées.');
END;
/
