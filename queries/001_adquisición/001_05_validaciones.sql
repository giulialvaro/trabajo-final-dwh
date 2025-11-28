/* ===========================================================
   001_05_validacion_txt_tmp.sql
   VALIDACIONES TXT → CARGA TMP → VALIDACIÓN FK
   ORDEN ALFABÉTICO
   =========================================================== */

PRAGMA foreign_keys = OFF;   -- evitamos errores durante inserts


/* ===========================================================
   1) CATEGORIES
   =========================================================== */

-- PK duplicada
SELECT category_id, COUNT(*)
FROM TXT_categories
GROUP BY category_id
HAVING COUNT(*) > 1;

-- category_id entero
SELECT *
FROM TXT_categories
WHERE category_id IS NOT NULL
  AND CAST(category_id AS INTEGER) IS NULL;

-- Carga TMP
DELETE FROM TMP_categories;

INSERT INTO TMP_categories(category_id, category_name, description, picture)
SELECT
  CAST(category_id AS INTEGER),
  category_name,
  description,
  picture
FROM TXT_categories;


/* ===========================================================
   2) CUSTOMERS
   =========================================================== */

-- PK duplicada
SELECT customer_id, COUNT(*)
FROM TXT_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Carga TMP
DELETE FROM TMP_customers;

INSERT INTO TMP_customers
SELECT *
FROM TXT_customers;


/* ===========================================================
   3) EMPLOYEES
   * Corrección: TMP_employees SIN FK para permitir carga estable
   =========================================================== */

-- Validaciones TXT
SELECT employee_id, COUNT(*)
FROM TXT_employees
GROUP BY employee_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_employees
WHERE CAST(employee_id AS INTEGER) IS NULL;

SELECT *
FROM TXT_employees
WHERE reports_to <> ''
  AND reports_to IS NOT NULL
  AND CAST(reports_to AS INTEGER) IS NULL;

SELECT *
FROM TXT_employees
WHERE birth_date NOT GLOB '????-??-??*'
  AND birth_date IS NOT NULL;

SELECT *
FROM TXT_employees
WHERE hire_date NOT GLOB '????-??-??*'
  AND hire_date IS NOT NULL;

-- RECREAR TMP_employees SIN FK
DROP TABLE IF EXISTS TMP_employees;

CREATE TABLE TMP_employees(
  employee_id INTEGER PRIMARY KEY,
  last_name TEXT,
  first_name TEXT,
  title TEXT,
  title_of_courtesy TEXT,
  birth_date TEXT,
  hire_date TEXT,
  address TEXT,
  city TEXT, 
  region TEXT,
  postal_code TEXT,
  country TEXT,
  home_phone TEXT,
  extension TEXT,
  photo BLOB,
  notes TEXT,
  reports_to INTEGER,
  photo_path TEXT
);

-- Carga TMP
INSERT INTO TMP_employees
SELECT
  CAST(employee_id AS INTEGER),
  last_name,
  first_name,
  title,
  title_of_courtesy,
  birth_date,
  hire_date,
  address,
  city,
  region,
  postalCode,
  country,
  home_phone,
  extension,
  photo,
  notes,
  CAST(NULLIF(TRIM(reports_to), '') AS INTEGER),
  photo_path
FROM TXT_employees;

-- Validación self-referential manual
SELECT e.*
FROM TMP_employees e
LEFT JOIN TMP_employees b 
    ON e.reports_to = b.employee_id
WHERE e.reports_to IS NOT NULL
  AND b.employee_id IS NULL;


/* ===========================================================
   4) EMPLOYEE_TERRITORIES
   =========================================================== */

-- Duplicados PK compuesta
SELECT employee_id, territory_id, COUNT(*)
FROM TXT_employee_territories
GROUP BY employee_id, territory_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_employee_territories
WHERE CAST(employee_id AS INTEGER) IS NULL;

DELETE FROM TMP_employee_territories;

INSERT INTO TMP_employee_territories
SELECT
  CAST(employee_id AS INTEGER),
  territory_id
FROM TXT_employee_territories;

-- FK employee
SELECT et.*
FROM TMP_employee_territories et
LEFT JOIN TMP_employees e ON et.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

-- FK territory
SELECT et.*
FROM TMP_employee_territories et
LEFT JOIN TMP_territories t ON et.territory_id = t.territory_id
WHERE t.territory_id IS NULL;


/* ===========================================================
   5) ORDER_DETAILS
   =========================================================== */

SELECT order_id, product_id, COUNT(*)
FROM TXT_order_details
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_order_details
WHERE CAST(order_id AS INTEGER) IS NULL;

SELECT *
FROM TXT_order_details
WHERE CAST(product_id AS INTEGER) IS NULL;

SELECT *
FROM TXT_order_details
WHERE unit_price NOT GLOB '[0-9]*.[0-9]*'
  AND unit_price NOT GLOB '[0-9]*';

DELETE FROM TMP_order_details;

INSERT INTO TMP_order_details
SELECT
  CAST(order_id AS INTEGER),
  CAST(product_id AS INTEGER),
  CAST(unit_price AS REAL),
  CAST(quantity AS INTEGER),
  CAST(discount AS REAL)
FROM TXT_order_details;

SELECT od.*
FROM TMP_order_details od
LEFT JOIN TMP_orders o ON od.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT od.*
FROM TMP_order_details od
LEFT JOIN TMP_products p ON od.product_id = p.product_id
WHERE p.product_id IS NULL;


/* ===========================================================
   6) ORDERS
   =========================================================== */

SELECT order_id, COUNT(*)
FROM TXT_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_orders
WHERE customer_id IS NULL OR customer_id = '';

SELECT *
FROM TXT_orders
WHERE employee_id <> ''
  AND CAST(employee_id AS INTEGER) IS NULL;

SELECT *
FROM TXT_orders
WHERE ship_via <> ''
  AND CAST(ship_via AS INTEGER) IS NULL;

SELECT *
FROM TXT_orders
WHERE order_date NOT GLOB '????-??-??*'
  AND order_date IS NOT NULL;

DELETE FROM TMP_orders;

INSERT INTO TMP_orders
SELECT
  CAST(order_id AS INTEGER),
  customer_id,
  CAST(employee_id AS INTEGER),
  order_date,
  required_date,
  shipped_date,
  CAST(ship_via AS INTEGER),
  CAST(freight AS REAL),
  ship_name,
  ship_address,
  ship_city,
  ship_region,
  ship_postal_code,
  ship_country
FROM TXT_orders;

-- FK customer
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_customers c USING(customer_id)
WHERE c.customer_id IS NULL;

-- FK employee
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_employees e ON o.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

-- FK shipper
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_shippers s ON o.ship_via = s.shipper_id
WHERE s.shipper_id IS NULL;


/* ===========================================================
   7) PRODUCTS
   =========================================================== */

SELECT product_id, COUNT(*)
FROM TXT_products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_products
WHERE supplier_id <> '' AND CAST(supplier_id AS INTEGER) IS NULL;

SELECT *
FROM TXT_products
WHERE category_id <> '' AND CAST(category_id AS INTEGER) IS NULL;

SELECT *
FROM TXT_products
WHERE unit_price NOT GLOB '[0-9]*.[0-9]*'
  AND unit_price NOT GLOB '[0-9]*';

DELETE FROM TMP_products;

INSERT INTO TMP_products
SELECT
  CAST(product_id AS INTEGER),
  product_name,
  CAST(supplier_id AS INTEGER),
  CAST(category_id AS INTEGER),
  quantity_per_unit,
  CAST(unit_price AS REAL),
  CAST(units_in_stock AS INTEGER),
  CAST(units_on_order AS INTEGER),
  CAST(reorder_level AS INTEGER),
  CAST(discontinued AS INTEGER)
FROM TXT_products;

SELECT p.*
FROM TMP_products p
LEFT JOIN TMP_suppliers s ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;

SELECT p.*
FROM TMP_products p
LEFT JOIN TMP_categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL;


/* ===========================================================
   8) REGIONS
   =========================================================== */

SELECT region_id, COUNT(*)
FROM TXT_regions
GROUP BY region_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_regions
WHERE region_id IS NOT NULL
  AND CAST(region_id AS INTEGER) IS NULL;

DELETE FROM TMP_regions;

INSERT INTO TMP_regions(region_id, region_description)
SELECT
  CAST(region_id AS INTEGER),
  region_description
FROM TXT_regions;


/* ===========================================================
   9) SHIPPERS
   =========================================================== */

SELECT shipper_id, COUNT(*)
FROM TXT_shippers
GROUP BY shipper_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_shippers
WHERE CAST(shipper_id AS INTEGER) IS NULL;

DELETE FROM TMP_shippers;

INSERT INTO TMP_shippers
SELECT
  CAST(shipper_id AS INTEGER),
  company_name,
  phone
FROM TXT_shippers;


/* ===========================================================
   10) SUPPLIERS
   =========================================================== */

SELECT supplier_id, COUNT(*)
FROM TXT_suppliers
GROUP BY supplier_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_suppliers
WHERE supplier_id IS NOT NULL
  AND CAST(supplier_id AS INTEGER) IS NULL;

DELETE FROM TMP_suppliers;

INSERT INTO TMP_suppliers
SELECT
  CAST(supplier_id AS INTEGER),
  company_name,
  contact_name,
  contact_title,
  address,
  city,
  region,
  postalCode,
  country,
  phone,
  fax,
  home_page
FROM TXT_suppliers;


/* ===========================================================
   11) TERRITORIES
   =========================================================== */

SELECT territory_id, COUNT(*)
FROM TXT_territories
GROUP BY territory_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_territories
WHERE region_id IS NOT NULL
  AND CAST(region_id AS INTEGER) IS NULL;

DELETE FROM TMP_territories;

INSERT INTO TMP_territories(territory_id, territory_description, region_id)
SELECT
  territory_id,
  territory_description,
  CAST(region_id AS INTEGER)
FROM TXT_territories;

SELECT t.*
FROM TMP_territories t
LEFT JOIN TMP_regions r ON t.region_id = r.region_id
WHERE r.region_id IS NULL;


PRAGMA foreign_keys = ON;