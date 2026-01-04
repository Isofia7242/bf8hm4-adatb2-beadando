CREATE OR REPLACE PACKAGE pkg_exception IS
  -- entity delete
  delete_not_allowed_exc EXCEPTION;
  gc_delete_not_allowed_exc_code CONSTANT NUMBER := -20050;
  PRAGMA EXCEPTION_INIT(delete_not_allowed_exc, -20050);
	
	-- seat resevation
  seat_reserved_exc EXCEPTION;
  gc_seat_reserved_exc_code CONSTANT NUMBER := -20100;
  PRAGMA EXCEPTION_INIT(seat_reserved_exc, -20100);

  -- room layout (seat create)
  category_missing_exc EXCEPTION;
  gc_category_missing_exc_code CONSTANT NUMBER := -20010;
  PRAGMA EXCEPTION_INIT(category_missing_exc, -20010);

  invalid_room_size_exc EXCEPTION;
  gc_invalid_room_size_exc_code CONSTANT NUMBER := -20001;
  PRAGMA EXCEPTION_INIT(invalid_room_size_exc, -20001);

  room_not_found_exc EXCEPTION;
  gc_room_not_found_exc_code CONSTANT NUMBER := -20002;
  PRAGMA EXCEPTION_INIT(room_not_found_exc, -20002);
END pkg_exception;
