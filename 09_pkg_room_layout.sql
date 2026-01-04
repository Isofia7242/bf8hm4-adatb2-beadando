--------------------------
-- Szék (seat) generálás.
-- sorok és oszlopok száma alapján generálunk 'Standard' székeket

-- Szék kategória módosítás soronkélnt (seat.category_id)
-- sorok szerint tudunk kategóriát módosítani
--------------------------


-- Elsõdlegesen a meglévõ nem archivált 'seat' entity-t módosítja, ha már létezik.
-- A felesleges entity-t archiválja, ha kisebb az új terem, mint a korábbi volt.
-- Más esetben létrehoz új 'seat' entity-t.


-- Ez után soronként lehet módosítani a székek kategóriáját

ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

CREATE OR REPLACE PACKAGE pkg_room_layout AS
	-- terem méret ('Standard' székek, a korábbi székeket archiválja)
  PROCEDURE set_room_layout(
    p_room_id IN NUMBER,
    p_rows    IN NUMBER,
    p_cols    IN NUMBER
  );
	
	-- sor kategória állítás id alapján
	PROCEDURE set_row_category_by_id(
    p_room_id     IN NUMBER,
    p_row_no      IN NUMBER,
    p_category_id IN NUMBER
  );

  -- sor kategória állítás név alapján
  PROCEDURE set_row_category_by_name(
    p_room_id        IN NUMBER,
    p_row_no         IN NUMBER,
    p_category_name  IN VARCHAR2
  );

END pkg_room_layout;
/

CREATE OR REPLACE PACKAGE BODY pkg_room_layout AS
  -- 'Standard' szék kiválasztása
  FUNCTION get_standard_category_id RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT sc.id
      INTO v_id
      FROM seat_category sc
     WHERE sc.name = 'Standard'
       AND NVL(sc.archived,0) = 0;

    RETURN v_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      pkg_err_log.err_log(
        p_err_message => 'There is no seat_category with name: Standard',
        p_err_value   => 'name=Standard',
        p_api         => 'pkg_room_layout.get_standard_category_id'
      );
			RAISE pkg_exception.category_missing_exc;
    WHEN OTHERS THEN
      pkg_err_log.err_log(
        p_err_message => SQLERRM,
        p_err_value   => 'backtrace=' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
        p_api         => 'pkg_room_layout.get_standard_category_id'
      );
      RAISE;
  END;
	
	-- set_room_layout
  PROCEDURE set_room_layout(
    p_room_id IN NUMBER,
    p_rows    IN NUMBER,
    p_cols    IN NUMBER
  ) IS
    v_exists NUMBER;
    v_std_id NUMBER;
  BEGIN
    IF p_rows IS NULL OR p_cols IS NULL OR p_rows < 1 OR p_cols < 1 THEN
			pkg_err_log.err_log(
        p_err_message => 'Must have: p_rows and p_cols >= 1',
        p_err_value   => 'room_id='||p_room_id||', rows='||NVL(TO_CHAR(p_rows),'NULL')||', cols='||NVL(TO_CHAR(p_cols),'NULL'),
        p_api         => 'pkg_room_layout.set_room_layout'
      );
			RAISE pkg_exception.invalid_room_size_exc;
    END IF;

    -- létezik a terem?
    SELECT COUNT(*) INTO v_exists
      FROM room r
     WHERE r.id = p_room_id
       AND NVL(r.archived,0) = 0;

    IF v_exists = 0 THEN
			pkg_err_log.err_log(
        p_err_message => 'Nincs ilyen terem',
        p_err_value   => 'room_id='||p_room_id,
        p_api         => 'pkg_room_layout.set_room_layout'
      );
			RAISE pkg_exception.room_not_found_exc;
    END IF;

    v_std_id := get_standard_category_id();

    -- room méret mentése
    UPDATE room
       SET rows_count = p_rows,
           cols_count = p_cols
     WHERE id = p_room_id;

    -- rács generálás: minden szék alapból 'Standard'
    FOR r IN 1 .. p_rows LOOP
      FOR c IN 1 .. p_cols LOOP
        MERGE INTO seat s
        USING (SELECT p_room_id room_id, r row_no, c col_no FROM dual) x
        ON (s.room_id = x.room_id AND s.row_no = x.row_no AND s.col_no = x.col_no) -- exact same chair
        WHEN MATCHED THEN
          UPDATE SET
            s.category_id = v_std_id
        WHEN NOT MATCHED THEN
          INSERT (
            id, room_id, row_no, col_no, category_id
          ) VALUES (
            seq_seat.NEXTVAL, p_room_id, r, c, v_std_id
          );
      END LOOP;
    END LOOP;

    -- kilógó székek archiválása (ha kisebb lett a terem, mint korábban volt)
    UPDATE seat s
       SET s.archived    = 1,
           s.last_mod_on = SYSTIMESTAMP,
           s.last_mod_by = SYS_CONTEXT('USERENV','SESSION_USER'),
           s.dml_flag    = 'U',
           s.version     = NVL(s.version,1) + 1
     WHERE s.room_id = p_room_id
       AND NVL(s.archived,0) = 0
       AND (s.row_no > p_rows OR s.col_no > p_cols);

  END set_room_layout;
	
	-- set_row_category_by_id
	PROCEDURE set_row_category_by_id(
    p_room_id     IN NUMBER,
    p_row_no      IN NUMBER,
    p_category_id IN NUMBER
  ) IS
    v_exists NUMBER;
  BEGIN
    -- kategória létezik?
    SELECT COUNT(*) INTO v_exists
      FROM seat_category sc
     WHERE sc.id = p_category_id
       AND NVL(sc.archived,0) = 0;

    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Nincs ilyen seat_category (id='||p_category_id||')');
    END IF;

    UPDATE seat s
       SET s.category_id = p_category_id,
           s.last_mod_on = SYSTIMESTAMP,
           s.last_mod_by = SYS_CONTEXT('USERENV','SESSION_USER'),
           s.dml_flag    = 'U',
           s.version     = NVL(s.version,1) + 1
     WHERE s.room_id = p_room_id
       AND s.row_no  = p_row_no
       AND NVL(s.archived,0) = 0;
  END set_row_category_by_id;

  -- set_row_category_by_name
  PROCEDURE set_row_category_by_name(
    p_room_id        IN NUMBER,
    p_row_no         IN NUMBER,
    p_category_name  IN VARCHAR2
  ) IS
    v_id NUMBER;
  BEGIN
    SELECT sc.id
      INTO v_id
      FROM seat_category sc
     WHERE sc.name = p_category_name
       AND NVL(sc.archived,0) = 0;

    set_row_category_by_id(p_room_id, p_row_no, v_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20004, 'Nincs aktív seat_category névvel: '||p_category_name);
    WHEN TOO_MANY_ROWS THEN
      RAISE_APPLICATION_ERROR(-20005, 'Több aktív seat_category van névvel: '||p_category_name);
  END set_row_category_by_name;

END pkg_room_layout;
/


-- példa
-- 1501-as terem 5 sor x 6 oszlop ('Standard' székekkel)

/*
BEGIN
  pkg_room_layout.set_room_layout(p_room_id => 1501, p_rows => 6, p_cols => 6);
END;
/

-- 1. sor VIP (név alapján)
BEGIN
  pkg_room_layout.set_row_category_by_name(1501, 1, 'VIP');
END;
/
