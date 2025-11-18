-- ====================================
-- TP Intro a Datawarehouring 
-- Etapa 1 - Adquisición
-- ====================================

DROP TABLE IF EXISTS TMP_categories;
CREATE TABLE TMP_categories(
  category_id TEXT PRIMARY KEY,
  category_name VARCHAR(100),
  description VARCHAR(100_,
  picture VARCHAR(500)
);

DROP TABLE IF EXISTS TMP_customers;
CREATE TABLE TMP_customers(
  customer_id TEXT PRIMARY KEY,
  company_name VARCHAR(100),
  contact_name VARCHAR(100),
  contact_title VARCHAR(100),
  address VARCHAR(100),
  city VARCHAR(100),
  region VARCHAR(100),
  postalCode VARCHAR(100),
  country VARCHAR(100),
  phone VARCHAR(100),
  fax VARCHAR(100)
);

DROP TABLE IF EXISTS TMP_employee_territories;
CREATE TABLE TMP_employee_territories(
  employee_id VARCHAR(100) FOREIGN KEY,
  territory_id VARCHAR(100) FOREIGN KEY
);

DROP TABLE IF EXISTS TMP_employees;
CREATE TABLE TMP_employees(
  employee_id TEXT PRIMARY KEY,
  last_name VARCHAR(100),
  first_name VARCHAR(100),
  title VARCHAR(100),
  title_of_courtesy VARCHAR(100),
  birth_date DATE,
  hire_date DATE,
  address VARCHAR(100),
  city VARCHAR(100), 
  region VARCHAR(100),
  postalCode VARCHAR(100),
  country VARCHAR(100),
  home_phone VARCHAR(100),
  extension VARCHAR(100),
  photo VARCHAR(100),
  notes VARCHAR(100),
  reports_to VARCHAR(100),
  photo_path VARCHAR(100)
);

DROP TABLE IF EXISTS TMP_order_details;
CREATE TABLE TMP_order_details(
  order_id VARCHAR(100) PRIMARY KEY,
  product_id VARCHAR(100) FOREIGN KEY,
  unit_price INTEGER,
  quantity INTEGER,
  discount INTEGER --ES BOOL? 
);

DROP TABLE IF EXISTS TMP_orders;
CREATE TABLE TMP_orders(
  order_id VARCHAR(100) FOREIGN KEY,
  customer_id VARCHAR(100) FOREIGN KEY,
  employee_id VARCHAR(100) FOREIGN KEY,
  order_date DATE,
  required_date DATE,
  shipped_date DATE,
  ship_via VARCHAR(100),
  freight VARCHAR(100), --CHEQUEAR
  ship_name VARCHAR(100),
  ship_address VARCHAR(100),
  ship_city VARCHAR(100),
  ship_region VARCHAR(100),
  ship_postal_code VARCHAR(100),
  ship_country VARCHAR(100)
);

DROP TABLE IF EXISTS TMP_products;
CREATE TABLE TMP_products(
  product_id VARCHAR(100) PRIMARY KEY,
  product_name VARCHAR(100),
  supplier_id VARCHAR(100) FOREIGN KEY,
  category_id VARCHAR(100) FOREIGN KEY,
  quantity_per_unit INTEGER,
  unit_price INTEGER,
  units_in_stock INTEGER,
  units_on_order INTEGER,
  reorder_level VARCHAR(100), --CHEQUEAR
  discontinued VARCHAR(100) --ES BOOL? 
);

DROP TABLE IF EXISTS TMP_regions;
CREATE TABLE TMP_regions(
  region_id VARCHAR(100) PRIMARY KEY,
  region_description VARCHAR(100)
);

DROP TABLE IF EXISTS TMP_shippers;
CREATE TABLE TMP_shippers(
  shipper_id VARCHAR(100) PRIMARY KEY,
  company_name VARCHAR(100),
  phone VARCHAR(100)
);

DROP TABLE IF EXISTS TMP_suppliers;
CREATE TABLE TMP_suppliers(
  supplier_id VARCHAR(100) PRIMARY KEY,
  company_name VARCHAR(100),
  contact_name VARCHAR(100),
  contact_title VARCHAR(100),
  address VARCHAR(100),
  city VARCHAR(100),
  region VARCHAR(100),
  postalCode VARCHAR(100),
  country VARCHAR(100),
  phone VARCHAR(100),
  fax VARCHAR(100),
  home_page VARCHAR(100)
);

DROP TABLE IF EXISTS TMP_territories;
CREATE TABLE TMP_territories(
  territory_id VARCHAR(100) PRIMARY KEY,
  territory_description VARCHAR(100),
  region_id VARCHAR(100) FOREIGN KEY
);
