-- Charger les procédures et fonctions pour les tests

@..\plsql\procedures_oper.sql  

 -- Test de la procédure ajouter_projet avec un bloc anonyme
 BEGIN
    ajouter_projet(
        p_titre             => 'Projet IA',
        p_domaine           => 'Intelligence Artificielle',
        p_budget            => 100000,
        p_date_debut        => TO_DATE('01-12-2025','DD-MM-YYYY'),
        p_date_fin          => TO_DATE('30-06-2026','DD-MM-YYYY'),
        p_id_chercheur_resp => 1
    );

    DBMS_OUTPUT.PUT_LINE('Projet ajouté avec succès.');

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Test terminé, insertion annulée.');

EXCEPTION
    WHEN OTHERS THEN
     	ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
END;
/
