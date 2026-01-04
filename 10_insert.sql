ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

-- movie
INSERT INTO movie (title, description, length_min, age_rating)
VALUES ('Oppenheimer', 'J. Robert Oppenheimer élettörténete', 180, 16);

INSERT INTO movie (title, description, length_min, age_rating)
VALUES ('Dune: Part Two', 'Arrakis és a sivatagi háború folytatása', 166, 12);

INSERT INTO movie (title, description, length_min, age_rating)
VALUES ('The Dark Knight', 'Batman és Joker összecsapása', 152, 12);

-- room
INSERT INTO room (name) VALUES ('Terem A');
INSERT INTO room (name) VALUES ('Terem B');
INSERT INTO room (name) VALUES ('Terem C');

-- seat_category
INSERT INTO seat_category (name, price_multiplier) VALUES ('Standard', 100);
INSERT INTO seat_category (name, price_multiplier) VALUES ('Premium', 130);
INSERT INTO seat_category (name, price_multiplier) VALUES ('VIP', 160);

-- seats

-- Terem A
DECLARE
  v_room_id NUMBER;
BEGIN
  SELECT id INTO v_room_id
  FROM room
  WHERE name = 'Terem A' AND archived = 0;

  pkg_room_layout.set_room_layout(v_room_id, 6, 6);
  pkg_room_layout.set_row_category_by_name(v_room_id, 1, 'VIP');
  pkg_room_layout.set_row_category_by_name(v_room_id, 2, 'Premium');
END;
/
-- Terem B
DECLARE
  v_room_id NUMBER;
BEGIN
  SELECT id INTO v_room_id
  FROM room
  WHERE name = 'Terem B' AND archived = 0;

  pkg_room_layout.set_room_layout(v_room_id, 5, 4);
  pkg_room_layout.set_row_category_by_name(v_room_id, 1, 'VIP');
  pkg_room_layout.set_row_category_by_name(v_room_id, 2, 'VIP');
  pkg_room_layout.set_row_category_by_name(v_room_id, 3, 'Premium');
END;
/

-- Terem C
DECLARE
  v_room_id NUMBER;
BEGIN
  SELECT id INTO v_room_id
  FROM room
  WHERE name = 'Terem C' AND archived = 0;

  pkg_room_layout.set_room_layout(v_room_id, 5, 4);
  pkg_room_layout.set_row_category_by_name(v_room_id, 1, 'VIP');
  pkg_room_layout.set_row_category_by_name(v_room_id, 2, 'Premium');
  pkg_room_layout.set_row_category_by_name(v_room_id, 3, 'Premium');
END;
/

-- discount
INSERT INTO discount (name, percent) VALUES ('Student', 20);
INSERT INTO discount (name, percent) VALUES ('Senior', 30);
INSERT INTO discount (name, percent) VALUES ('None', 0);

-- screening
INSERT INTO screening (movie_id, room_id, starts_at, base_price)
SELECT m.id, r.id, SYSTIMESTAMP + INTERVAL '1' DAY, 2200
FROM movie m, room r
WHERE m.title='Oppenheimer' AND r.name='Terem A';

INSERT INTO screening (movie_id, room_id, starts_at, base_price)
SELECT m.id, r.id, SYSTIMESTAMP + INTERVAL '2' DAY, 2400
FROM movie m, room r
WHERE m.title='Dune: Part Two' AND r.name='Terem B';

INSERT INTO screening (movie_id, room_id, starts_at, base_price)
SELECT m.id, r.id, SYSTIMESTAMP + INTERVAL '3' DAY, 2000
FROM movie m, room r
WHERE m.title='The Dark Knight' AND r.name='Terem C';

-- reservation
INSERT INTO reservation (screening_id, customer_name, contact, status)
SELECT s.id, 'Kiss Anna', 'anna@test.hu', 'REDEEMED'
FROM screening s
JOIN movie m ON m.id = s.movie_id
WHERE m.title = 'Oppenheimer';

INSERT INTO reservation (screening_id, customer_name, contact, status)
SELECT s.id, 'Nagy Béla', 'bela@test.hu', 'REDEEMED'
FROM screening s
JOIN movie m ON m.id = s.movie_id
WHERE m.title = 'Dune: Part Two';

INSERT INTO reservation (screening_id, customer_name, contact, status)
SELECT s.id, 'Tóth Csaba', 'csaba@test.hu', 'ACTIVE'
FROM screening s
JOIN movie m ON m.id = s.movie_id
WHERE m.title = 'The Dark Knight';

-- reservation_seat

-- Oppenheimer / Terem A
INSERT INTO reservation_seat (reservation_id, seat_id, discount_id)
SELECT r.id, s.id, d.id
FROM reservation r
JOIN screening sc ON sc.id = r.screening_id
JOIN movie m ON m.id = sc.movie_id
JOIN seat s ON s.room_id = sc.room_id AND s.row_no = 1 AND s.col_no = 1
LEFT JOIN discount d ON d.name = 'Student'
WHERE m.title = 'Oppenheimer';

-- Dune / Terem B
INSERT INTO reservation_seat (reservation_id, seat_id, discount_id)
SELECT r.id, s.id, d.id
FROM reservation r
JOIN screening sc ON sc.id = r.screening_id
JOIN movie m ON m.id = sc.movie_id
JOIN seat s ON s.room_id = sc.room_id AND s.row_no = 2 AND s.col_no = 2
LEFT JOIN discount d ON d.name = 'Senior'
WHERE m.title = 'Dune: Part Two';

-- Dark Knight / Terem C
INSERT INTO reservation_seat (reservation_id, seat_id, discount_id)
SELECT r.id, s.id, d.id
FROM reservation r
JOIN screening sc ON sc.id = r.screening_id
JOIN movie m ON m.id = sc.movie_id
JOIN seat s ON s.room_id = sc.room_id AND s.row_no = 1 AND s.col_no = 2
LEFT JOIN discount d ON d.name = 'None'
WHERE m.title = 'The Dark Knight';

COMMIT;
