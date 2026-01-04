ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_delete_movie'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_delete_room'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_delete_seat_category'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_delete_seat'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_delete_discount'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_delete_screening'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_delete_reservation'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_delete_reservation_seat'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- soft delete miatt nem engedélyezett a tényleges törlés (logolással)
CREATE OR REPLACE TRIGGER trg_no_delete_movie
BEFORE DELETE ON movie
FOR EACH ROW
BEGIN
  pkg_err_log.err_log(
    p_err_message => 'Physical DELETE blocked',
    p_err_value   => 'id='||:OLD.id,
    p_api         => 'trg_no_delete_movie'
  );
  RAISE_APPLICATION_ERROR(
    pkg_exception.gc_delete_not_allowed_exc_code,
    'DELETE is not allowed on MOVIE. Use UPDATE archived=1.'
  );
END;
/

CREATE OR REPLACE TRIGGER trg_no_delete_room
BEFORE DELETE ON room
FOR EACH ROW
BEGIN
  pkg_err_log.err_log(
    p_err_message => 'Physical DELETE blocked',
    p_err_value   => 'id='||:OLD.id,
    p_api         => 'trg_no_delete_room'
  );
  RAISE_APPLICATION_ERROR(
    pkg_exception.gc_delete_not_allowed_exc_code,
    'DELETE is not allowed on ROOM. Use UPDATE archived=1.'
  );
END;
/

CREATE OR REPLACE TRIGGER trg_no_delete_seat_category
BEFORE DELETE ON seat_category
FOR EACH ROW
BEGIN
  pkg_err_log.err_log(
    p_err_message => 'Physical DELETE blocked',
    p_err_value   => 'id='||:OLD.id,
    p_api         => 'trg_no_delete_seat_category'
  );
  RAISE_APPLICATION_ERROR(
    pkg_exception.gc_delete_not_allowed_exc_code,
    'DELETE is not allowed on SEAT_CATEGORY. Use UPDATE archived=1.'
  );
END;
/

CREATE OR REPLACE TRIGGER trg_no_delete_seat
BEFORE DELETE ON seat
FOR EACH ROW
BEGIN
  pkg_err_log.err_log(
    p_err_message => 'Physical DELETE blocked',
    p_err_value   => 'id='||:OLD.id||
                     ';room_id='||:OLD.room_id||
                     ';row_no='||:OLD.row_no||
                     ';col_no='||:OLD.col_no,
    p_api         => 'trg_no_delete_seat'
  );
  RAISE_APPLICATION_ERROR(
    pkg_exception.gc_delete_not_allowed_exc_code,
    'DELETE is not allowed on SEAT. Use UPDATE archived=1.'
  );
END;
/

CREATE OR REPLACE TRIGGER trg_no_delete_discount
BEFORE DELETE ON discount
FOR EACH ROW
BEGIN
  pkg_err_log.err_log(
    p_err_message => 'Physical DELETE blocked',
    p_err_value   => 'id='||:OLD.id||';name='||:OLD.name,
    p_api         => 'trg_no_delete_discount'
  );
  RAISE_APPLICATION_ERROR(
    pkg_exception.gc_delete_not_allowed_exc_code,
    'DELETE is not allowed on DISCOUNT. Use UPDATE archived=1.'
  );
END;
/

CREATE OR REPLACE TRIGGER trg_no_delete_screening
BEFORE DELETE ON screening
FOR EACH ROW
BEGIN
  pkg_err_log.err_log(
    p_err_message => 'Physical DELETE blocked',
    p_err_value   => 'id='||:OLD.id||
                     ';movie_id='||:OLD.movie_id||
                     ';room_id='||:OLD.room_id,
    p_api         => 'trg_no_delete_screening'
  );
  RAISE_APPLICATION_ERROR(
    pkg_exception.gc_delete_not_allowed_exc_code,
    'DELETE is not allowed on SCREENING. Use UPDATE archived=1.'
  );
END;
/

CREATE OR REPLACE TRIGGER trg_no_delete_reservation
BEFORE DELETE ON reservation
FOR EACH ROW
BEGIN
  pkg_err_log.err_log(
    p_err_message => 'Physical DELETE blocked',
    p_err_value   => 'id='||:OLD.id||
                     ';screening_id='||:OLD.screening_id||
                     ';customer='||:OLD.customer_name,
    p_api         => 'trg_no_delete_reservation'
  );
  RAISE_APPLICATION_ERROR(
    pkg_exception.gc_delete_not_allowed_exc_code,
    'DELETE is not allowed on RESERVATION. Use UPDATE archived=1.'
  );
END;
/

CREATE OR REPLACE TRIGGER trg_no_delete_reservation_seat
BEFORE DELETE ON reservation_seat
FOR EACH ROW
BEGIN
  pkg_err_log.err_log(
    p_err_message => 'Physical DELETE blocked',
    p_err_value   => 'reservation_id='||:OLD.reservation_id||
                     ';seat_id='||:OLD.seat_id,
    p_api         => 'trg_no_delete_reservation_seat'
  );
  RAISE_APPLICATION_ERROR(
    pkg_exception.gc_delete_not_allowed_exc_code,
    'DELETE is not allowed on RESERVATION_SEAT. Use UPDATE archived=1.'
  );
END;
/
