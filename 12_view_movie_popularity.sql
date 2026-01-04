ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

-- film népszerûség statisztika (vetítések, foglalás, eladott jegyek, bevétel)
CREATE OR REPLACE VIEW v_movie_popularity AS
SELECT
  m.title AS movie_title,

  COUNT(DISTINCT scn.id) AS screenings_count,
  COUNT(DISTINCT r.id) AS reservations_count,
  COUNT(rs.seat_id) AS sold_tickets,

  SUM(scn.base_price * (sc.price_multiplier / 100)) AS gross_amount, -- bruttó bevétel
  SUM((scn.base_price * (sc.price_multiplier / 100)) * (NVL(d.percent, 0) / 100)) AS discount_amount, -- elengedett kedvezmény
  SUM((scn.base_price * (sc.price_multiplier / 100)) * (1 - (NVL(d.percent, 0) / 100))) AS net_amount -- nettó bevétel

FROM movie m
JOIN screening scn
  ON scn.movie_id = m.id
JOIN reservation r
  ON r.screening_id = scn.id
JOIN reservation_seat rs
  ON rs.reservation_id = r.id
JOIN seat s
  ON s.id = rs.seat_id
JOIN seat_category sc
  ON sc.id = s.category_id
LEFT JOIN discount d
  ON d.id = rs.discount_id

WHERE NVL(m.archived,0) = 0
  AND NVL(scn.archived,0) = 0
  AND NVL(r.archived,0) = 0
  AND NVL(rs.archived,0) = 0
  AND NVL(s.archived,0) = 0
  AND NVL(sc.archived,0) = 0
  AND r.status IN ('REDEEMED')

GROUP BY
  m.id, m.title;

-- példa lekérdezés
SELECT * FROM v_movie_popularity ORDER BY sold_tickets DESC, net_amount DESC;
