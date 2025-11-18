-- ====================================
-- TP Intro a Datawarehousing 
-- Etapa 1 - Adquisición
-- Versión SQLite
-- ====================================

PRAGMA foreign_keys = ON;

-- ====================================
-- 1) DQM Creations
CREATE TABLE IF NOT EXISTS DQM_check_catalog(
  check_id    INTEGER PRIMARY KEY,
  check_code  TEXT UNIQUE,
  description TEXT
);

INSERT OR IGNORE INTO DQM_check_catalog(check_code, description) VALUES
  ('CAST_NUMERIC','no casteable a número'),
  ('CAST_DATE','no casteable a fecha'),
  ('PK_DUPLICATES','duplicados en clave primaria'),
  ('NULL_MANDATORY','nulos en campos obligatorios'),
  ('FK_ORPHANS','huérfanos en integridad referencial'),
  ('PROF_TABLE','perfilado por tabla'),
  ('PROF_FIELD','perfilado por campo');

-- issues y perfiles
CREATE TABLE IF NOT EXISTS DQM_cast_issues(
  issue_id      INTEGER PRIMARY KEY,
  table_name    TEXT,
  column_name   TEXT,
  check_code    TEXT,
  invalid_count INTEGER,
  sample_value  TEXT,
  created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS DQM_pk_issues(
  issue_id         INTEGER PRIMARY KEY,
  table_name       TEXT,
  check_code       TEXT,
  duplicates_count INTEGER,
  created_at       DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS DQM_fk_issues(
  issue_id      INTEGER PRIMARY KEY,
  table_name    TEXT,
  fk_name       TEXT,
  check_code    TEXT,
  orphan_count  INTEGER,
  created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS DQM_table_profile(
  profile_id  INTEGER PRIMARY KEY,
  table_name  TEXT,
  row_count   INTEGER,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS DQM_field_profile(
  profile_id     INTEGER PRIMARY KEY,
  table_name     TEXT,
  column_name    TEXT,
  null_count     INTEGER,
  distinct_count INTEGER,
  min_val        TEXT,
  max_val        TEXT,
  example_value  TEXT,
  created_at     DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ====================================
-- 3) Creación de tablas TXT

DROP TABLE IF EXISTS TXT_categories;
CREATE TABLE TXT_categories(
  category_id   TEXT,
  category_name TEXT,
  description   TEXT,
  picture       TEXT
);

DROP TABLE IF EXISTS TXT_customers;
CREATE TABLE TXT_customers(
  customer_id   TEXT,
  company_name  TEXT,
  contact_name  TEXT,
  contact_title TEXT,
  address       TEXT,
  city          TEXT,
  region        TEXT,
  postalCode    TEXT,
  country       TEXT,
  phone         TEXT,
  fax           TEXT
);

DROP TABLE IF EXISTS TXT_employee_territories;
CREATE TABLE TXT_employee_territories(
  employee_id TEXT,
  territory_id TEXT
);

DROP TABLE IF EXISTS TXT_employees;
CREATE TABLE TXT_employees(
  employee_id      TEXT,
  last_name        TEXT,
  first_name       TEXT,
  title            TEXT,
  title_of_courtesy TEXT,
  birth_date       TEXT,
  hire_date        TEXT,
  address          TEXT,
  city             TEXT,
  region           TEXT,
  postalCode       TEXT,
  country          TEXT,
  home_phone       TEXT,
  extension        TEXT,
  photo            TEXT,
  notes            TEXT,
  reports_to       TEXT,
  photo_path       TEXT
);

DROP TABLE IF EXISTS TXT_order_details;
CREATE TABLE TXT_order_details(
  order_id   TEXT,
  product_id TEXT,
  unit_price TEXT,
  quantity   TEXT,
  discount   TEXT
);

DROP TABLE IF EXISTS TXT_orders;
CREATE TABLE TXT_orders(
  order_id        TEXT,
  customer_id     TEXT,
  employee_id     TEXT,
  order_date      TEXT,
  required_date   TEXT,
  shipped_date    TEXT,
  ship_via        TEXT,
  freight         TEXT,
  ship_name       TEXT,
  ship_address    TEXT,
  ship_city       TEXT,
  ship_region     TEXT,
  ship_postal_code TEXT,
  ship_country    TEXT
);

DROP TABLE IF EXISTS TXT_products;
CREATE TABLE TXT_products(
  product_id        TEXT,
  product_name      TEXT,
  supplier_id       TEXT,
  category_id       TEXT,
  quantity_per_unit TEXT,
  unit_price        TEXT,
  units_in_stock    TEXT,
  units_on_order    TEXT,
  reorder_level     TEXT,
  discontinued      TEXT
);

DROP TABLE IF EXISTS TXT_regions;
CREATE TABLE TXT_regions(
  region_id          TEXT,
  region_description TEXT
);

DROP TABLE IF EXISTS TXT_shippers;
CREATE TABLE TXT_shippers(
  shipper_id   TEXT,
  company_name TEXT,
  phone        TEXT
);

DROP TABLE IF EXISTS TXT_suppliers;
CREATE TABLE TXT_suppliers(
  supplier_id   TEXT,
  company_name  TEXT,
  contact_name  TEXT,
  contact_title TEXT,
  address       TEXT,
  city          TEXT,
  region        TEXT,
  postalCode    TEXT,
  country       TEXT,
  phone         TEXT,
  fax           TEXT,
  home_page     TEXT
);

DROP TABLE IF EXISTS TXT_territories;
CREATE TABLE TXT_territories(
  territory_id          TEXT,
  territory_description TEXT,
  region_id             TEXT
);
