ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

-- Bevétel kedvezmények szerint bontva (csak 'REDEEMD' foglalásokat vesz figyelembe)
CREATE OR REPLACE VIEW v_discount_revenue AS
SELECT
  COALESCE(d.name, 'NO_DISCOUNT') AS discount_name,
  NVL(d.percent, 0) || '%' AS discount,
  COUNT(*) AS sold,

  SUM(screening.base_price * (sc.price_multiplier / 100)) AS gross_amount, -- bruttó
  SUM((screening.base_price * (sc.price_multiplier / 100)) * (NVL(d.percent, 0) / 100)) AS discount_amount, -- elengedett kedvezmén
  SUM((screening.base_price * (sc.price_multiplier / 100)) * (1 - (NVL(d.percent, 0) / 100))) AS net_amount -- nettó

FROM reservation_seat rs
JOIN reservation r
  ON r.id = rs.reservation_id
JOIN seat s
  ON s.id = rs.seat_id
JOIN seat_category sc
  ON sc.id = s.category_id
JOIN screening
  ON screening.id = r.screening_id
LEFT JOIN discount d
  ON d.id = rs.discount_id

WHERE NVL(rs.archived,0) = 0
  AND NVL(r.archived,0) = 0
  AND NVL(s.archived,0) = 0
  AND NVL(sc.archived,0) = 0
  AND NVL(screening.archived,0) = 0
  AND r.status IN ('REDEEMED')

GROUP BY
  NVL(d.id, 0),
  COALESCE(d.name, 'NO_DISCOUNT'),
  NVL(d.percent, 0);

-- példa lekérdezés
SELECT * FROM v_discount_revenue ORDER BY net_amount DESC;
