-- Charger les procédures et fonctions pour les tests

@..\plsql\procedures_oper.sql  

 -- Test de la procédure ajouter_projet avec un bloc anonyme
DECLARE
    v_id NUMBER;
BEGIN
    ajouter_projet('Projet IA','Intelligence Artificielle',100000,TO_DATE('01-12-2025','DD-MM-YYYY'),TO_DATE('30-06-2026','DD-MM-YYYY'),1,v_id);

    DBMS_OUTPUT.PUT_LINE('Projet ajouté avec succès.');

    DELETE FROM PROJET WHERE ID_PROJET = v_id;
    DBMS_OUTPUT.PUT_LINE('Test terminé, insertion annulée.');

EXCEPTION
    WHEN OTHERS THEN
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

-- Tester Supprimer projet
DECLARE
    v_id_projet   NUMBER;
    v_id_exp      NUMBER;
    v_id_echant   NUMBER;
    v_id_affect   NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== DÉBUT TEST SUPPRESSION PROJET ===');

    -- Insérer un projet de test et récupérer son ID
    INSERT INTO PROJET(titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES ('Projet Test Suppression', 'Test', 50000, SYSDATE, SYSDATE+10, 1)
    RETURNING id_projet INTO v_id_projet;

    DBMS_OUTPUT.PUT_LINE('Projet inséré, ID = ' || v_id_projet);

    -- Insérer une expérience liée au projet
    INSERT INTO EXPERIENCE(description, id_projet)
    VALUES ('Experience test', v_id_projet)
    RETURNING id_exp INTO v_id_exp;

    DBMS_OUTPUT.PUT_LINE('Experience insérée, ID = ' || v_id_exp);

    -- Insérer un échantillon lié à l’expérience
    INSERT INTO ECHANTILLON(nom_ech, id_exp)
    VALUES ('Echantillon test', v_id_exp)
    RETURNING id_echantillon INTO v_id_echant;

    DBMS_OUTPUT.PUT_LINE('Échantillon inséré, ID = ' || v_id_echant);

    -- Insérer une affectation liée au projet
    INSERT INTO AFFECTATION_EQUIP(id_equip, id_projet)
    VALUES (1, v_id_projet)
    RETURNING id_affect INTO v_id_affect;

    DBMS_OUTPUT.PUT_LINE('Affectation insérée, ID = ' || v_id_affect);

    COMMIT;

    -- Appeler la procédure de suppression
    DBMS_OUTPUT.PUT_LINE('> Suppression du projet...');
    supprimer_projet(v_id_projet);

    
    -- Vérifications

    DECLARE
        v_count NUMBER;
    BEGIN
        -- vérifier projet
        SELECT COUNT(*) INTO v_count FROM PROJET WHERE id_projet = v_id_projet;
        DBMS_OUTPUT.PUT_LINE('Projet existe encore ? : ' || v_count);

        -- vérifier expériences
        SELECT COUNT(*) INTO v_count FROM EXPERIENCE WHERE id_exp = v_id_exp;
        DBMS_OUTPUT.PUT_LINE('Expérience existe encore ? : ' || v_count);

        -- vérifier échantillons
        SELECT COUNT(*) INTO v_count FROM ECHANTILLON WHERE id_echantillon = v_id_echant;
        DBMS_OUTPUT.PUT_LINE('Échantillon existe encore ? : ' || v_count);

        -- vérifier affectations
        SELECT COUNT(*) INTO v_count FROM AFFECTATION_EQUIP WHERE id_affect = v_id_affect;
        DBMS_OUTPUT.PUT_LINE('Affectation existe encore ? : ' || v_count);
    END;

    DBMS_OUTPUT.PUT_LINE('=== FIN TEST ===');

END;
/
