ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

CREATE OR REPLACE TRIGGER trg_reservation_cancel
AFTER UPDATE OF status, archived ON reservation
FOR EACH ROW
BEGIN
  -- active -> canceled / archived 0 -> 1
  IF (NVL(:OLD.status,'?') = 'ACTIVE' AND NVL(:NEW.status,'?') = 'CANCELLED')
     OR (NVL(:OLD.archived,0) = 0 AND NVL(:NEW.archived,0) = 1)
  THEN
    UPDATE reservation_seat rs
       SET rs.archived    = 1
     WHERE rs.reservation_id = :NEW.id
       AND NVL(rs.archived,0) = 0;
  END IF;
END;
/
