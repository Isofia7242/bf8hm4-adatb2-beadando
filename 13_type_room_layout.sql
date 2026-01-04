ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

CREATE OR REPLACE TYPE ty_room_layout AS OBJECT (
  room_id        NUMBER,
  room_name      VARCHAR2(200),
  rows_count     NUMBER,
  cols_count     NUMBER,
  row_categories VARCHAR2(4000) -- "Standard,VIP,VIP,Standard"
);
/

CREATE OR REPLACE TYPE ty_room_layout_l AS TABLE OF ty_room_layout;
/
