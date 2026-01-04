ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

CREATE OR REPLACE PACKAGE pkg_room_layout_list AS
  PROCEDURE list_room_layouts(
    p_list OUT ty_room_layout_l
  );
END pkg_room_layout_list;
/

CREATE OR REPLACE PACKAGE BODY pkg_room_layout_list AS

  PROCEDURE list_room_layouts(
    p_list OUT ty_room_layout_l
  ) IS
  BEGIN
    p_list := ty_room_layout_l();

    SELECT ty_room_layout(
             r.id,
             r.name,
             r.rows_count,
             r.cols_count,
             (
               SELECT LISTAGG(sc.name, ',') WITHIN GROUP (ORDER BY sr.row_no)
               FROM (
                 SELECT DISTINCT st.room_id, st.row_no, st.category_id
                 FROM seat st
                 WHERE NVL(st.archived,0) = 0
               ) sr
               JOIN seat_category sc ON sc.id = sr.category_id
               WHERE sr.room_id = r.id
             )
           )
    BULK COLLECT INTO p_list
    FROM room r
    WHERE NVL(r.archived,0) = 0
    ORDER BY r.id;

  END list_room_layouts;

END pkg_room_layout_list;
/
