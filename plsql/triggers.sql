-- Trigger pour valider date_embauche
CREATE OR REPLACE TRIGGER CHERCHEUR_DATE_TRG
BEFORE INSERT OR UPDATE ON CHERCHEUR
FOR EACH ROW
BEGIN
  IF :NEW.date_embauche > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20001, 'La date d''embauche ne peut pas être dans le futur.');
  END IF;
END;
/

-- Trigger pour valider date_acquisition <= SYSDATE
CREATE OR REPLACE TRIGGER EQUIPEMENT_DATE_TRG
BEFORE INSERT OR UPDATE ON EQUIPEMENT
FOR EACH ROW
BEGIN
  IF :NEW.date_acquisition > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20002, 'La date d''acquisition ne peut pas être dans le futur.');
  END IF;
END;
/

-- Trigger pour valider date_affectation >= PROJET.date_debut
CREATE OR REPLACE TRIGGER AFFECTATION_DATE_TRG
BEFORE INSERT OR UPDATE ON AFFECTATION_EQUIP
FOR EACH ROW
DECLARE
  v_date_debut PROJET.date_debut%TYPE;
BEGIN
  SELECT date_debut 
    INTO v_date_debut
    FROM PROJET
   WHERE id_projet = :NEW.id_projet;
   
  IF :NEW.date_affectation < v_date_debut THEN
    RAISE_APPLICATION_ERROR(-20003, 'La date d''affectation ne peut pas être avant le début du projet.');
  END IF;
END;
/

-- Trigger pour éviter qu’un équipement soit affecté à deux projets en même temps
CREATE OR REPLACE TRIGGER AFFECTATION_CHEV_TRG
BEFORE INSERT OR UPDATE ON AFFECTATION_EQUIP
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO v_count
    FROM AFFECTATION_EQUIP
   WHERE id_equipement = :NEW.id_equipement
     AND id_affect != NVL(:NEW.id_affect, 0)
     AND ( :NEW.date_affectation BETWEEN date_affectation AND date_affectation + duree_jours - 1
           OR date_affectation BETWEEN :NEW.date_affectation AND :NEW.date_affectation + :NEW.duree_jours - 1 );

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Cet équipement est déjà affecté à un projet pendant cette période.');
  END IF;
END;
/