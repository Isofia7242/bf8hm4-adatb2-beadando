ALTER SESSION SET CURRENT_SCHEMA = CINEMA;

BEGIN EXECUTE IMMEDIATE 'DROP TABLE movie CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE room CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE seat_category CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE seat CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE discount CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE screening CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE reservation CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE reservation_seat CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- movie
CREATE TABLE movie (
  id           NUMBER PRIMARY KEY,
  title        VARCHAR2(200) NOT NULL,
  description  CLOB,
  length_min   NUMBER NOT NULL,
  age_rating   NUMBER NOT NULL,
  
  archived     NUMBER(1) DEFAULT 0 NOT NULL CHECK (archived IN (0,1)),
  created_on   TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  created_by   VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL,
  last_mod_on  TIMESTAMP(6),
  last_mod_by  VARCHAR2(300),
  dml_flag     VARCHAR2(1) DEFAULT 'I' NOT NULL CHECK (dml_flag IN ('I','U', 'D')),
  version      NUMBER DEFAULT 1 NOT NULL
);

-- room
CREATE TABLE room (
  id           NUMBER PRIMARY KEY,
  name         VARCHAR2(200) NOT NULL,
  rows_count   NUMBER DEFAULT 0 NOT NULL CHECK (rows_count >= 0),
	cols_count   NUMBER DEFAULT 0 NOT NULL CHECK (cols_count >= 0),
	
  archived     NUMBER(1) DEFAULT 0 NOT NULL CHECK (archived IN (0,1)),
  created_on   TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  created_by   VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL,
  last_mod_on  TIMESTAMP(6),
  last_mod_by  VARCHAR2(300),
  dml_flag     VARCHAR2(1) DEFAULT 'I' NOT NULL CHECK (dml_flag IN ('I','U', 'D')),
  version      NUMBER DEFAULT 1 NOT NULL
);

-- seat category
CREATE TABLE seat_category (
  id               NUMBER PRIMARY KEY,
  name             VARCHAR2(100) NOT NULL,
  price_multiplier NUMBER(3) NOT NULL, -- example: 130(%)
  
  archived     NUMBER(1) DEFAULT 0 NOT NULL CHECK (archived IN (0,1)),
  created_on   TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  created_by   VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL,
  last_mod_on  TIMESTAMP(6),
  last_mod_by  VARCHAR2(300),
  dml_flag     VARCHAR2(1) DEFAULT 'I' NOT NULL CHECK (dml_flag IN ('I','U', 'D')),
  version      NUMBER DEFAULT 1 NOT NULL
);

ALTER TABLE seat_category ADD CONSTRAINT uq_seat_category_name UNIQUE (name);

-- seat
CREATE TABLE seat (
  id           NUMBER PRIMARY KEY,
  room_id      NUMBER NOT NULL,
  row_no       NUMBER NOT NULL,
  col_no       NUMBER NOT NULL,
  category_id  NUMBER NOT NULL,
  
  archived     NUMBER(1) DEFAULT 0 NOT NULL CHECK (archived IN (0,1)),
  created_on   TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  created_by   VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL,
  last_mod_on  TIMESTAMP(6),
  last_mod_by  VARCHAR2(300),
  dml_flag     VARCHAR2(1) DEFAULT 'I' NOT NULL CHECK (dml_flag IN ('I','U', 'D')),
  version      NUMBER DEFAULT 1 NOT NULL,

  CONSTRAINT fk_seat_room      FOREIGN KEY (room_id)     REFERENCES room(id),
  CONSTRAINT fk_seat_category  FOREIGN KEY (category_id) REFERENCES seat_category(id)
);

-- discount
CREATE TABLE discount (
  id       NUMBER PRIMARY KEY,
  name     VARCHAR2(100) NOT NULL,
  percent  NUMBER(3) DEFAULT 0 NOT NULL CHECK (percent BETWEEN 0 AND 100),
  
  archived     NUMBER(1) DEFAULT 0 NOT NULL CHECK (archived IN (0,1)),
  created_on   TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  created_by   VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL,
  last_mod_on  TIMESTAMP(6),
  last_mod_by  VARCHAR2(300),
  dml_flag     VARCHAR2(1) DEFAULT 'I' NOT NULL CHECK (dml_flag IN ('I','U', 'D')),
  version      NUMBER DEFAULT 1 NOT NULL
);

ALTER TABLE discount ADD CONSTRAINT uq_discount_name UNIQUE (name);

-- screening
CREATE TABLE screening (
  id         NUMBER PRIMARY KEY,
  movie_id   NUMBER NOT NULL,
  room_id    NUMBER NOT NULL,
  starts_at  TIMESTAMP WITH TIME ZONE NOT NULL,
  base_price NUMBER(6) NOT NULL,
  
  archived     NUMBER(1) DEFAULT 0 NOT NULL CHECK (archived IN (0,1)),
  created_on   TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  created_by   VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL,
  last_mod_on  TIMESTAMP(6),
  last_mod_by  VARCHAR2(300),
  dml_flag     VARCHAR2(1) DEFAULT 'I' NOT NULL CHECK (dml_flag IN ('I','U', 'D')),
  version      NUMBER DEFAULT 1 NOT NULL,

  CONSTRAINT fk_screening_movie FOREIGN KEY (movie_id) REFERENCES movie(id),
  CONSTRAINT fk_screening_room  FOREIGN KEY (room_id)  REFERENCES room(id)
);

-- reservation
CREATE TABLE reservation (
  id            NUMBER PRIMARY KEY,
  screening_id  NUMBER NOT NULL,
  customer_name VARCHAR2(200) NOT NULL,
  contact       VARCHAR2(200) NOT NULL,
  status        VARCHAR2(100) DEFAULT 'ACTIVE' NOT NULL CHECK (status IN ('ACTIVE','CANCELLED', 'REDEEMED')),
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
  
  archived     NUMBER(1) DEFAULT 0 NOT NULL CHECK (archived IN (0,1)),
  created_on   TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  created_by   VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL,
  last_mod_on  TIMESTAMP(6),
  last_mod_by  VARCHAR2(300),
  dml_flag     VARCHAR2(1) DEFAULT 'I' NOT NULL CHECK (dml_flag IN ('I','U', 'D')),
  version      NUMBER DEFAULT 1 NOT NULL,

  CONSTRAINT fk_res_screening FOREIGN KEY (screening_id) REFERENCES screening(id)
);

-- reservation seats
CREATE TABLE reservation_seat (
  reservation_id NUMBER NOT NULL,
  seat_id        NUMBER NOT NULL,
  discount_id    NUMBER,
  
  archived     NUMBER(1) DEFAULT 0 NOT NULL CHECK (archived IN (0,1)),
  created_on   TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
  created_by   VARCHAR2(300) DEFAULT SYS_CONTEXT('USERENV','SESSION_USER') NOT NULL,
  last_mod_on  TIMESTAMP(6),
  last_mod_by  VARCHAR2(300),
  dml_flag     VARCHAR2(1) DEFAULT 'I' NOT NULL CHECK (dml_flag IN ('I','U', 'D')),
  version      NUMBER DEFAULT 1 NOT NULL,


  CONSTRAINT pk_reservation_seat PRIMARY KEY (reservation_id, seat_id),
  CONSTRAINT fk_rs_reservation   FOREIGN KEY (reservation_id) REFERENCES reservation(id) ON DELETE CASCADE,
  CONSTRAINT fk_rs_discount      FOREIGN KEY (discount_id)  REFERENCES discount(id),
  CONSTRAINT fk_rs_seat          FOREIGN KEY (seat_id)        REFERENCES seat(id)
);

CREATE UNIQUE INDEX ux_rs_active
ON reservation_seat (
  CASE WHEN NVL(archived,0)=0 THEN reservation_id END,
  CASE WHEN NVL(archived,0)=0 THEN seat_id END
);

CREATE UNIQUE INDEX ux_seat_position
ON seat (
  CASE WHEN NVL(archived,0)=0 THEN room_id END,
  CASE WHEN NVL(archived,0)=0 THEN row_no END,
  CASE WHEN NVL(archived,0)=0 THEN col_no END
);
