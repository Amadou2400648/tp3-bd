/** Rapport d'activité des projets **/
CREATE OR REPLACE PROCEDURE rapport_activite_projets IS

  CURSOR cur_projets IS
    SELECT id_projet, titre FROM PROJET;

  v_nb_experiences      NUMBER;
  v_nb_terminées        NUMBER;
  v_taux_reussite       NUMBER;
  v_moyenne_mesures     NUMBER;

BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Rapport d''activité des projets ---');

  FOR r_projet IN cur_projets LOOP
    -- Nombre total d'expériences pour le projet
    SELECT COUNT(*)
    INTO v_nb_experiences
    FROM EXPERIENCE
    WHERE id_projet = r_projet.id_projet;

    -- Nombre d'expériences terminées
    SELECT COUNT(*)
    INTO v_nb_terminées
    FROM EXPERIENCE
    WHERE id_projet = r_projet.id_projet
      AND statut = 'Terminée';

    -- Calcul du taux de réussite
    IF v_nb_experiences > 0 THEN
      v_taux_reussite := (v_nb_terminées / v_nb_experiences) * 100;
    ELSE
      v_taux_reussite := 0;
    END IF;

    -- Affichage du projet et du taux
    DBMS_OUTPUT.PUT_LINE('Projet : ' || r_projet.titre);
    DBMS_OUTPUT.PUT_LINE('  Nombre d''expériences : ' || v_nb_experiences);
    DBMS_OUTPUT.PUT_LINE('  Taux de réussite : ' || ROUND(v_taux_reussite,2) || '%');

    -- Pour chaque expérience, afficher la moyenne des mesures
    FOR r_exp IN (SELECT id_exp, titre_exp FROM EXPERIENCE WHERE id_projet = r_projet.id_projet) LOOP
      v_moyenne_mesures := moyenne_mesures_experience(r_exp.id_exp);
      DBMS_OUTPUT.PUT_LINE('    Expérience : ' || r_exp.titre_exp || ' | Moyenne mesures : ' || NVL(TO_CHAR(v_moyenne_mesures), 'N/A'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur dans le rapport : ' || SQLERRM);
END rapport_activite_projets;
/

/** Calculer le budget moyen par domaine **/
CREATE OR REPLACE FUNCTION budget_moyen_par_domaine
RETURN SYS_REFCURSOR IS
  -- Déclaration d'un curseur de sortie
  v_result SYS_REFCURSOR;

  -- Table PL/SQL en mémoire pour stocker les totaux et compte
  TYPE t_domaine IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
  v_total_budget t_domaine; -- somme des budgets par domaine
  v_count_domaine t_domaine; -- nombre de projets par domaine

  v_domaine PROJET.domaine%TYPE;
  v_budget  PROJET.budget%TYPE;

BEGIN
  -- Initialiser les tables en mémoire
  v_total_budget := t_domaine();
  v_count_domaine := t_domaine();

  -- Parcourir tous les projets
  FOR r IN (SELECT domaine, budget FROM PROJET) LOOP
    IF v_total_budget.EXISTS(r.domaine) THEN
      v_total_budget(r.domaine) := v_total_budget(r.domaine) + NVL(r.budget,0);
      v_count_domaine(r.domaine) := v_count_domaine(r.domaine) + 1;
    ELSE
      v_total_budget(r.domaine) := NVL(r.budget,0);
      v_count_domaine(r.domaine) := 1;
    END IF;
  END LOOP;

  -- Créer un curseur de sortie pour afficher les résultats
  OPEN v_result FOR
    SELECT domaine,
           ROUND(v_total_budget(domaine)/v_count_domaine(domaine),2) AS budget_moyen
    FROM TABLE(
      CAST(MULTISET(
        SELECT COLUMN_VALUE AS domaine FROM TABLE(CAST(MULTISET(SELECT KEY FROM v_total_budget) AS SYS.ODCIVARCHAR2LIST))
      ) AS SYS.ODCIVARCHAR2LIST)
    );

  RETURN v_result;
END budget_moyen_par_domaine;
/

