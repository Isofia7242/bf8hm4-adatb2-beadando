ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

BEGIN EXECUTE IMMEDIATE 'DROP TABLE error_log CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

create table error_log(
  id          number PRIMARY KEY,
  err_id      number,
  err_time    timestamp default sysdate,
  err_message varchar2(4000),
  err_value   varchar2(4000),
  api         varchar2(100)
);

create sequence error_log_seq start with 300 increment by 1 nocache;

CREATE OR REPLACE TRIGGER error_log_id_trg
  BEFORE INSERT ON error_log
  FOR EACH ROW
BEGIN
  IF :new.id IS NULL
  THEN
    :new.id := error_log_seq.nextval;
  END IF;
END;
/
