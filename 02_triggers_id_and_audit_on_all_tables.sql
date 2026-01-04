ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

-- sequence
CREATE SEQUENCE seq_movie         START WITH 1000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_room          START WITH 1500 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_seat_category START WITH 2000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_seat          START WITH 2500 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_discount      START WITH 3000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_screening     START WITH 3500 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_reservation   START WITH 4000 INCREMENT BY 1 NOCACHE;

-- triggers
-- reservation_seat nem rendelkezik azonosítóval
CREATE OR REPLACE TRIGGER movie_trg
  BEFORE INSERT OR UPDATE ON movie
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.id IS NULL THEN
      :NEW.id := seq_movie.NEXTVAL;
    END IF;

    :NEW.created_on := SYSTIMESTAMP;
    :NEW.created_by := SYS_CONTEXT('USERENV','SESSION_USER');
    :NEW.dml_flag   := 'I';
    :NEW.version    := 1;
  ELSE
    IF :OLD.archived = 0 AND :NEW.archived = 1 THEN
      :NEW.dml_flag := 'D';
    ELSE
      :NEW.dml_flag := 'U';
    END IF;

    :NEW.version := NVL(:OLD.version, 0) + 1;
  END IF;

  :NEW.last_mod_on := SYSTIMESTAMP;
  :NEW.last_mod_by := SYS_CONTEXT('USERENV','SESSION_USER');
END;
/
CREATE OR REPLACE TRIGGER room_trg
  BEFORE INSERT OR UPDATE ON room
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.id IS NULL THEN
      :NEW.id := seq_room.NEXTVAL;
    END IF;

    :NEW.created_on := SYSTIMESTAMP;
    :NEW.created_by := SYS_CONTEXT('USERENV','SESSION_USER');
    :NEW.dml_flag   := 'I';
    :NEW.version    := 1;
  ELSE
    IF :OLD.archived = 0 AND :NEW.archived = 1 THEN
      :NEW.dml_flag := 'D';
    ELSE
      :NEW.dml_flag := 'U';
    END IF;

    :NEW.version := NVL(:OLD.version, 0) + 1;
  END IF;

  :NEW.last_mod_on := SYSTIMESTAMP;
  :NEW.last_mod_by := SYS_CONTEXT('USERENV','SESSION_USER');
END;
/
CREATE OR REPLACE TRIGGER seat_category_trg
  BEFORE INSERT OR UPDATE ON seat_category
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.id IS NULL THEN
      :NEW.id := seq_seat_category.NEXTVAL;
    END IF;

    :NEW.created_on := SYSTIMESTAMP;
    :NEW.created_by := SYS_CONTEXT('USERENV','SESSION_USER');
    :NEW.dml_flag   := 'I';
    :NEW.version    := 1;
  ELSE
    IF :OLD.archived = 0 AND :NEW.archived = 1 THEN
      :NEW.dml_flag := 'D';
    ELSE
      :NEW.dml_flag := 'U';
    END IF;

    :NEW.version := NVL(:OLD.version, 0) + 1;
  END IF;

  :NEW.last_mod_on := SYSTIMESTAMP;
  :NEW.last_mod_by := SYS_CONTEXT('USERENV','SESSION_USER');
END;
/
CREATE OR REPLACE TRIGGER seat_trg
  BEFORE INSERT OR UPDATE ON seat
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.id IS NULL THEN
      :NEW.id := seq_seat.NEXTVAL;
    END IF;

    :NEW.created_on := SYSTIMESTAMP;
    :NEW.created_by := SYS_CONTEXT('USERENV','SESSION_USER');
    :NEW.dml_flag   := 'I';
    :NEW.version    := 1;
  ELSE
    IF :OLD.archived = 0 AND :NEW.archived = 1 THEN
      :NEW.dml_flag := 'D';
    ELSE
      :NEW.dml_flag := 'U';
    END IF;

    :NEW.version := NVL(:OLD.version, 0) + 1;
  END IF;

  :NEW.last_mod_on := SYSTIMESTAMP;
  :NEW.last_mod_by := SYS_CONTEXT('USERENV','SESSION_USER');
END;
/
CREATE OR REPLACE TRIGGER discount_trg
  BEFORE INSERT OR UPDATE ON discount
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.id IS NULL THEN
      :NEW.id := seq_discount.NEXTVAL;
    END IF;

    :NEW.created_on := SYSTIMESTAMP;
    :NEW.created_by := SYS_CONTEXT('USERENV','SESSION_USER');
    :NEW.dml_flag   := 'I';
    :NEW.version    := 1;
  ELSE
    IF :OLD.archived = 0 AND :NEW.archived = 1 THEN
      :NEW.dml_flag := 'D';
    ELSE
      :NEW.dml_flag := 'U';
    END IF;

    :NEW.version := NVL(:OLD.version, 0) + 1;
  END IF;

  :NEW.last_mod_on := SYSTIMESTAMP;
  :NEW.last_mod_by := SYS_CONTEXT('USERENV','SESSION_USER');
END;
/
CREATE OR REPLACE TRIGGER screening_trg
  BEFORE INSERT OR UPDATE ON screening
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.id IS NULL THEN
      :NEW.id := seq_screening.NEXTVAL;
    END IF;

    :NEW.created_on := SYSTIMESTAMP;
    :NEW.created_by := SYS_CONTEXT('USERENV','SESSION_USER');
    :NEW.dml_flag   := 'I';
    :NEW.version    := 1;
  ELSE
    IF :OLD.archived = 0 AND :NEW.archived = 1 THEN
      :NEW.dml_flag := 'D';
    ELSE
      :NEW.dml_flag := 'U';
    END IF;

    :NEW.version := NVL(:OLD.version, 0) + 1;
  END IF;

  :NEW.last_mod_on := SYSTIMESTAMP;
  :NEW.last_mod_by := SYS_CONTEXT('USERENV','SESSION_USER');
END;
/
CREATE OR REPLACE TRIGGER reservation_trg
  BEFORE INSERT OR UPDATE ON reservation
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    IF :NEW.id IS NULL THEN
      :NEW.id := seq_reservation.NEXTVAL;
    END IF;

    :NEW.created_on := SYSTIMESTAMP;
    :NEW.created_by := SYS_CONTEXT('USERENV','SESSION_USER');
    :NEW.dml_flag   := 'I';
    :NEW.version    := 1;
  ELSE
    IF :OLD.archived = 0 AND :NEW.archived = 1 THEN
      :NEW.dml_flag := 'D';
    ELSE
      :NEW.dml_flag := 'U';
    END IF;

    :NEW.version := NVL(:OLD.version, 0) + 1;
  END IF;

  :NEW.last_mod_on := SYSTIMESTAMP;
  :NEW.last_mod_by := SYS_CONTEXT('USERENV','SESSION_USER');
END;
/
CREATE OR REPLACE TRIGGER reservation_seat_trg
  BEFORE INSERT OR UPDATE ON reservation_seat
  FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.created_on := SYSTIMESTAMP;
    :NEW.created_by := SYS_CONTEXT('USERENV','SESSION_USER');
    :NEW.dml_flag   := 'I';
    :NEW.version    := 1;
  ELSE
    IF :OLD.archived = 0 AND :NEW.archived = 1 THEN
      :NEW.dml_flag := 'D';
    ELSE
      :NEW.dml_flag := 'U';
    END IF;

    :NEW.version := NVL(:OLD.version, 0) + 1;
  END IF;

  :NEW.last_mod_on := SYSTIMESTAMP;
  :NEW.last_mod_by := SYS_CONTEXT('USERENV','SESSION_USER');
END;
/
