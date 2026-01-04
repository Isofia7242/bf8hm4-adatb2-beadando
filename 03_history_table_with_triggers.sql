ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE change_history CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_change_history';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE change_history (
  id          NUMBER PRIMARY KEY,
  table_name  VARCHAR2(100) NOT NULL,
  operation   VARCHAR2(10)  NOT NULL CHECK (operation IN ('INSERT','UPDATE','DELETE')),
  record_key  VARCHAR2(200) NOT NULL,
  params_json CLOB,
  changed_on  TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  changed_by  VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL
);

CREATE SEQUENCE seq_change_history START WITH 1 INCREMENT BY 1 NOCACHE;

-- movie
CREATE OR REPLACE TRIGGER movie_hist_trg
AFTER INSERT OR UPDATE ON movie
FOR EACH ROW
DECLARE
  l_operation VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    l_operation := 'INSERT';
  ELSIF :OLD.archived = 0 AND :NEW.archived = 1 THEN
    l_operation := 'DELETE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  INSERT INTO change_history (id, table_name, operation, record_key, params_json)
  VALUES (
    seq_change_history.NEXTVAL,
    'MOVIE',
    l_operation,
    'id=' || :NEW.id,
    '{"id":'||:NEW.id||
    ',"title":"' || REPLACE(:NEW.title,'"','\"') ||
    '","length_min":'||NVL(TO_CHAR(:NEW.length_min),'null')||
    ',"age_rating":'||NVL(TO_CHAR(:NEW.age_rating),'null')||
    ',"archived":'||:NEW.archived||
    ',"version":'||NVL(TO_CHAR(:NEW.version),'null')||'}'
  );
END;
/

-- room
CREATE OR REPLACE TRIGGER room_hist_trg
AFTER INSERT OR UPDATE ON room
FOR EACH ROW
DECLARE
  l_operation VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    l_operation := 'INSERT';
  ELSIF :OLD.archived = 0 AND :NEW.archived = 1 THEN
    l_operation := 'DELETE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  INSERT INTO change_history (id, table_name, operation, record_key, params_json)
  VALUES (
    seq_change_history.NEXTVAL,
    'ROOM',
    l_operation,
    'id=' || :NEW.id,
    '{"id":'||:NEW.id||
    ',"name":"' || REPLACE(:NEW.name,'"','\"') ||
    '","archived":'||:NEW.archived||
    ',"version":'||NVL(TO_CHAR(:NEW.version),'null')||'}'
  );
END;
/

-- seat_category
CREATE OR REPLACE TRIGGER seat_category_hist_trg
AFTER INSERT OR UPDATE ON seat_category
FOR EACH ROW
DECLARE
  l_operation VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    l_operation := 'INSERT';
  ELSIF :OLD.archived = 0 AND :NEW.archived = 1 THEN
    l_operation := 'DELETE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  INSERT INTO change_history (id, table_name, operation, record_key, params_json)
  VALUES (
    seq_change_history.NEXTVAL,
    'SEAT_CATEGORY',
    l_operation,
    'id=' || :NEW.id,
    '{"id":'||:NEW.id||
    ',"name":"' || REPLACE(:NEW.name,'"','\"') ||
    '","price_multiplier":'||NVL(TO_CHAR(:NEW.price_multiplier),'null')||
    ',"archived":'||:NEW.archived||
    ',"version":'||NVL(TO_CHAR(:NEW.version),'null')||'}'
  );
END;
/

-- seat
CREATE OR REPLACE TRIGGER seat_hist_trg
AFTER INSERT OR UPDATE ON seat
FOR EACH ROW
DECLARE
  l_operation VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    l_operation := 'INSERT';
  ELSIF :OLD.archived = 0 AND :NEW.archived = 1 THEN
    l_operation := 'DELETE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  INSERT INTO change_history (id, table_name, operation, record_key, params_json)
  VALUES (
    seq_change_history.NEXTVAL,
    'SEAT',
    l_operation,
    'id=' || :NEW.id,
    '{"id":'||:NEW.id||
    ',"room_id":'||NVL(TO_CHAR(:NEW.room_id),'null')||
    ',"row_no":'||NVL(TO_CHAR(:NEW.row_no),'null')||
    ',"col_no":'||NVL(TO_CHAR(:NEW.col_no),'null')||
    ',"category_id":'||NVL(TO_CHAR(:NEW.category_id),'null')||
    ',"archived":'||:NEW.archived||
    ',"version":'||NVL(TO_CHAR(:NEW.version),'null')||'}'
  );
END;
/

-- discount
CREATE OR REPLACE TRIGGER discount_hist_trg
AFTER INSERT OR UPDATE ON discount
FOR EACH ROW
DECLARE
  l_operation VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    l_operation := 'INSERT';
  ELSIF :OLD.archived = 0 AND :NEW.archived = 1 THEN
    l_operation := 'DELETE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  INSERT INTO change_history (id, table_name, operation, record_key, params_json)
  VALUES (
    seq_change_history.NEXTVAL,
    'DISCOUNT',
    l_operation,
    'id=' || :NEW.id,
    '{"id":'||:NEW.id||
    ',"name":"' || REPLACE(:NEW.name,'"','\"') ||
    '","percent":'||NVL(TO_CHAR(:NEW.percent),'null')||
    ',"archived":'||:NEW.archived||
    ',"version":'||NVL(TO_CHAR(:NEW.version),'null')||'}'
  );
END;
/

-- screening
CREATE OR REPLACE TRIGGER screening_hist_trg
AFTER INSERT OR UPDATE ON screening
FOR EACH ROW
DECLARE
  l_operation VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    l_operation := 'INSERT';
  ELSIF :OLD.archived = 0 AND :NEW.archived = 1 THEN
    l_operation := 'DELETE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  INSERT INTO change_history (id, table_name, operation, record_key, params_json)
  VALUES (
    seq_change_history.NEXTVAL,
    'SCREENING',
    l_operation,
    'id=' || :NEW.id,
    '{"id":'||:NEW.id||
    ',"movie_id":'||NVL(TO_CHAR(:NEW.movie_id),'null')||
    ',"room_id":'||NVL(TO_CHAR(:NEW.room_id),'null')||
    ',"starts_at":"' || TO_CHAR(:NEW.starts_at, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') ||
    '","base_price":'||NVL(TO_CHAR(:NEW.base_price),'null')||
    ',"archived":'||:NEW.archived||
    ',"version":'||NVL(TO_CHAR(:NEW.version),'null')||'}'
  );
END;
/

-- reservation
CREATE OR REPLACE TRIGGER reservation_hist_trg
AFTER INSERT OR UPDATE ON reservation
FOR EACH ROW
DECLARE
  l_operation VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    l_operation := 'INSERT';
  ELSIF :OLD.archived = 0 AND :NEW.archived = 1 THEN
    l_operation := 'DELETE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  INSERT INTO change_history (id, table_name, operation, record_key, params_json)
  VALUES (
    seq_change_history.NEXTVAL,
    'RESERVATION',
    l_operation,
    'id=' || :NEW.id,
    '{"id":'||:NEW.id||
    ',"screening_id":'||NVL(TO_CHAR(:NEW.screening_id),'null')||
    ',"customer_name":"' || REPLACE(:NEW.customer_name,'"','\"') ||
    '","contact":"' || REPLACE(:NEW.contact,'"','\"') ||
    '","status":"' || REPLACE(:NEW.status,'"','\"') ||
    '","archived":'||:NEW.archived||
    ',"version":'||NVL(TO_CHAR(:NEW.version),'null')||'}'
  );
END;
/

-- reservation_seat
CREATE OR REPLACE TRIGGER reservation_seat_hist_trg
AFTER INSERT OR UPDATE ON reservation_seat
FOR EACH ROW
DECLARE
  l_operation VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    l_operation := 'INSERT';
  ELSIF :OLD.archived = 0 AND :NEW.archived = 1 THEN
    l_operation := 'DELETE';
  ELSE
    l_operation := 'UPDATE';
  END IF;

  INSERT INTO change_history (id, table_name, operation, record_key, params_json)
  VALUES (
    seq_change_history.NEXTVAL,
    'RESERVATION_SEAT',
    l_operation,
    'reservation_id='||:NEW.reservation_id||';seat_id='||:NEW.seat_id,
    '{"reservation_id":'||:NEW.reservation_id||
    ',"seat_id":'||:NEW.seat_id||
    ',"discount_id":'||CASE WHEN :NEW.discount_id IS NULL THEN 'null' ELSE TO_CHAR(:NEW.discount_id) END||
    ',"archived":'||:NEW.archived||
    ',"version":'||NVL(TO_CHAR(:NEW.version),'null')||'}'
  );
END;
/
