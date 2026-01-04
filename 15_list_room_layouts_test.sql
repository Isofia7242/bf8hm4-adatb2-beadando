DECLARE
  l_list ty_room_layout_l;
BEGIN
  pkg_room_layout_list.list_room_layouts(l_list);

  IF l_list IS NOT NULL THEN
    FOR i IN l_list.FIRST .. l_list.LAST LOOP
      DBMS_OUTPUT.PUT_LINE(
        'ID=' || l_list(i).room_id ||
        ', Név=' || l_list(i).room_name ||
        ', Méret=' || l_list(i).rows_count || 'x' || l_list(i).cols_count ||
        ', Sor kategóriák=' || l_list(i).row_categories
      );
    END LOOP;
  END IF;
END;
/
