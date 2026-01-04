DECLARE
  select_count NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO select_count
    FROM dba_users
   WHERE username = 'CINEMA';

  IF select_count = 1
  THEN
    EXECUTE IMMEDIATE 'DROP USER CINEMA CASCADE';
  END IF;
END;
/

CREATE USER cinema identified BY "cinema" DEFAULT tablespace users quota unlimited ON users;

ALTER USER cinema quota unlimited ON users;
grant CREATE session TO cinema;
grant CREATE TABLE TO cinema;
grant CREATE view TO cinema;
grant CREATE sequence TO cinema;
grant CREATE PROCEDURE TO cinema;
grant CREATE TRIGGER TO cinema;
grant CREATE TYPE TO cinema;
