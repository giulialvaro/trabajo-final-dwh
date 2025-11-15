-- ====================================
-- Creación de tablas TMP

DROP TABLE IF EXISTS TMP_categories;
CREATE TABLE TMP_categories(
  category_id TEXT PRIMARY KEY,
  category_name VARCHAR,
  description VARCHAR,
  picture VARCHAR
);

DROP TABLE IF EXISTS TMP_customers;
CREATE TABLE TMP_customers(
  customer_id TEXT PRIMARY KEY,
  company_name VARCHAR,
  contact_name VARCHAR,
  contact_title VARCHAR,
  address VARCHAR,
  city VARCHAR,
  region VARCHAR,
  postalCode TEXT,
  country VARCHAR,
  phone INTEGER,
  fax VARCHAR
);

DROP TABLE IF EXISTS TMP_employee_territories;
CREATE TABLE TMP_employee_territories(
  employee_id VARCHAR FOREIGN KEY,
  territory_id VARCHAR FOREIGN KEY
);

DROP TABLE IF EXISTS TMP_employees;
CREATE TABLE TMP_employees(
  employee_id TEXT PRIMARY KEY,
  last_name TEXT,
  first_name TEXT,
  title TEXT,
  title_of_courtesy TEXT,
  birth_date TEXT,
  hire_date TEXT,
  address TEXT,
  city TEXT,
  region TEXT,
  postalCode TEXT,
  country TEXT,
  home_phone TEXT,
  extension TEXT,
  photo TEXT,
  notes TEXT,
  reports_to TEXT,
  photo_path TEXT
);

DROP TABLE IF EXISTS TMP_order_details;
CREATE TABLE TMP_order_details(
  order_id TEXT PRIMARY KEY,
  product_id TEXT FOREIGN KEY,
  unit_price TEXT,
  quantity TEXT,
  discount TEXT
);

DROP TABLE IF EXISTS TMP_orders;
CREATE TABLE TMP_orders(
  order_id TEXT FOREIGN KEY,
  customer_id TEXT FOREIGN KEY,
  employee_id TEXT FOREIGN KEY,
  order_date TEXT,
  required_date TEXT,
  shipped_date TEXT,
  ship_via TEXT,
  freight TEXT,
  ship_name TEXT,
  ship_address TEXT,
  ship_city TEXT,
  ship_region TEXT,
  ship_postal_code TEXT,
  ship_country TEXT
);

DROP TABLE IF EXISTS TMP_products;
CREATE TABLE TMP_products(
  product_id TEXT PRIMARY KEY,
  product_name TEXT,
  supplier_id TEXT FOREIGN KEY,
  category_id TEXT FOREIGN KEY,
  quantity_per_unit TEXT,
  unit_price TEXT,
  units_in_stock TEXT,
  units_on_order TEXT,
  reorder_level TEXT,
  discontinued TEXT
);

DROP TABLE IF EXISTS TMP_regions;
CREATE TABLE TMP_regions(
  region_id TEXT PRIMARY KEY,
  region_description TEXT
);

DROP TABLE IF EXISTS TMP_shippers;
CREATE TABLE TMP_shippers(
  shipper_id TEXT PRIMARY KEY,
  company_name TEXT,
  phone TEXT
);

DROP TABLE IF EXISTS TMP_suppliers;
CREATE TABLE TMP_suppliers(
  supplier_id TEXT PRIMARY KEY,
  company_name TEXT,
  contact_name TEXT,
  contact_title TEXT,
  address TEXT,
  city TEXT,
  region TEXT,
  postalCode TEXT,
  country TEXT,
  phone TEXT,
  fax TEXT,
  home_page TEXT
);

DROP TABLE IF EXISTS TMP_territories;
CREATE TABLE TMP_territories(
  territory_id TEXT PRIMARY KEY,
  territory_description TEXT,
  region_id TEXT FOREIGN KEY
);
