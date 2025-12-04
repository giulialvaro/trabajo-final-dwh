/* ===========================================================
   001_05_validacion_txt_tmp.sql
   VALIDACIONES TXT → CARGA TMP → VALIDACIÓN FK
   ORDEN ALFABÉTICO
   =========================================================== */

PRAGMA foreign_keys = OFF;   -- evitamos errores durante inserts

--El DELETE es una práctica estándar en la capa de Staging para garantizar la idempotencia de la ejecución del script.


/* ===========================================================
   0) PAISES (CATÁLOGO - NUEVA SECCIÓN)
   =========================================================== */

-- Validaciones de la capa TXT (Opcional, pero recomendado)
SELECT country, COUNT(*) FROM (
    SELECT country FROM TXT_customers UNION ALL
    SELECT country FROM TXT_suppliers UNION ALL
    SELECT country FROM TXT_employees UNION ALL
    SELECT ship_country FROM TXT_orders
)
WHERE country IS NOT NULL AND TRIM(country) <> ''
GROUP BY country
HAVING COUNT(*) > 1000; -- Buscar problemas de capitalización/espacios

DELETE FROM TMP_countries;

-- Carga TMP_countries: Extraer todos los valores únicos
INSERT INTO TMP_countries (country_name)
SELECT DISTINCT country FROM TXT_customers WHERE country IS NOT NULL AND TRIM(country) <> ''
UNION
SELECT DISTINCT country FROM TXT_suppliers WHERE country IS NOT NULL AND TRIM(country) <> ''
UNION
SELECT DISTINCT ship_country FROM TXT_orders WHERE ship_country IS NOT NULL AND TRIM(ship_country) <> ''
UNION
SELECT DISTINCT country FROM TXT_employees WHERE country IS NOT NULL AND TRIM(country) <> '';


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



-- Carga TMP_customers (MODIFICADA)
DELETE FROM TMP_customers;

INSERT INTO TMP_customers
SELECT 
  c.customer_id,
  c.company_name,
  c.contact_name,
  c.contact_title,
  c.address,
  c.city,
  c.region,
  c.postalCode,
  t.country_id, -- << AHORA ES ID >>
  c.phone,
  c.fax
FROM TXT_customers c
LEFT JOIN TMP_countries t ON c.country = t.country_name;

-- NUEVA VALIDACIÓN: FK country
SELECT c.*
FROM TMP_customers c
LEFT JOIN TMP_countries t ON c.country_id = t.country_id
WHERE c.country_id IS NOT NULL
  AND t.country_id IS NULL;



/* ===========================================================
   3) EMPLOYEES
   =========================================================== */

-- 0. Validaciones TXT (Verificación de Calidad antes de la Carga)
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


-- 1. RECREAR TMP_employees SIN FK (Necesario para carga estable y evitar errores de FK self-referencial)
-- Nota: Esta estructura temporal debe coincidir con la normalización de country_id.
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
  country_id INTEGER, -- Normalizado a ID
  home_phone TEXT,
  extension TEXT,
  photo BLOB,
  notes TEXT,
  reports_to INTEGER,
  photo_path TEXT
  -- Las FKs (reports_to y country_id) se validan manualmente después de la carga.
);


-- 2. Carga TMP_employees (MODIFICADA: Normalización y CAST)
-- Nota: No se requiere DELETE aquí si la tabla se acaba de recrear.
INSERT INTO TMP_employees
SELECT
  CAST(e.employee_id AS INTEGER),
  e.last_name,
  e.first_name,
  e.title,
  e.title_of_courtesy,
  e.birth_date,
  e.hire_date,
  e.address,
  e.city,
  e.region,
  e.postalCode,
  t.country_id,  -- Normalización: Obtener ID del país
  e.home_phone,
  e.extension,
  e.photo,
  e.notes,
  CAST(NULLIF(TRIM(e.reports_to), '') AS INTEGER),
  e.photo_path
FROM TXT_employees e
LEFT JOIN TMP_countries t ON e.country = t.country_name;


-- 3. Validación self-referential manual (Buscando jefes huérfanos)
SELECT e.*
FROM TMP_employees e
LEFT JOIN TMP_employees b 
    ON e.reports_to = b.employee_id
WHERE e.reports_to IS NOT NULL
  AND b.employee_id IS NULL;


-- 4. NUEVA VALIDACIÓN: FK country (Buscando IDs de país huérfanos)
SELECT e.*
FROM TMP_employees e
LEFT JOIN TMP_countries t ON e.country_id = t.country_id
WHERE e.country_id IS NOT NULL
  AND t.country_id IS NULL;
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

-- Carga TMP_orders (MODIFICADA)
INSERT INTO TMP_orders
SELECT
  CAST(o.order_id AS INTEGER),
  o.customer_id,
  CAST(o.employee_id AS INTEGER),
  o.order_date,
  o.required_date,
  o.shipped_date,
  CAST(o.ship_via AS INTEGER),
  CAST(o.freight AS REAL),
  o.ship_name,
  o.ship_address,
  o.ship_city,
  o.ship_region,
  o.ship_postal_code,
  t.country_id -- << AHORA ES ID (ship_country_id) >>
FROM TXT_orders o
LEFT JOIN TMP_countries t ON o.ship_country = t.country_name;

-- NUEVA VALIDACIÓN: FK ship_country
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_countries t ON o.ship_country_id = t.country_id
WHERE o.ship_country_id IS NOT NULL
  AND t.country_id IS NULL;
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

-- Carga TMP_suppliers (MODIFICADA)
DELETE FROM TMP_suppliers;

INSERT INTO TMP_suppliers
SELECT
  CAST(s.supplier_id AS INTEGER),
  s.company_name,
  s.contact_name,
  s.contact_title,
  s.address,
  s.city,
  s.region,
  s.postalCode,
  t.country_id,  -- << AHORA ES ID >>
  s.phone,
  s.fax,
  s.home_page
FROM TXT_suppliers s
LEFT JOIN TMP_countries t ON s.country = t.country_name;

-- NUEVA VALIDACIÓN: FK country
SELECT s.*
FROM TMP_suppliers s
LEFT JOIN TMP_countries t ON s.country_id = t.country_id
WHERE s.country_id IS NOT NULL
  AND t.country_id IS NULL;

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
