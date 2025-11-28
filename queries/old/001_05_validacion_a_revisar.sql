/* Scripts para: 
1. Validaciones en TXT (tipos de datos, PK, campos obligatorios)
2. Carga TXT → TMP (haciendo CAST con seguridad)
3. Validación de integridad referencial en TMP (FK, orphans)

Están organizados por tabla, en tres bloques por cada una*/ 

problemas que observé: cuando cargué los csv a las tablas txt, me cargó los nombres de las columnas como el primer registro
así que primero borré esos registros, ejemplo:

select * from TXT_territories where territory_id='territoryid'
delete from TXT_territories where territory_id='territoryid'

hice esto con todas las tablas y recién ahí empecé a validar

******* REGIONS *******
-- 1) VALIDACIONES EN TXT_regions
-- PK duplicados
SELECT region_id, COUNT(*)
FROM TXT_regions
GROUP BY region_id
HAVING COUNT(*) > 1;

-- region_id debe ser entero
SELECT *
FROM TXT_regions
WHERE region_id IS NOT NULL
  AND CAST(region_id AS INTEGER) IS NULL;

-- 2) CARGA TXT → TMP
INSERT INTO TMP_regions(region_id, region_description)
SELECT
  CAST(region_id AS INTEGER),
  region_description
FROM TXT_regions;

-- 3) VALIDACIÓN REFERENCIAL
-- (No tiene FKs)
******* fin regions *******

******* TERRITORIES ******* 
-- 1) VALIDACIONES EN TXT_territories
-- PK duplicados
SELECT territory_id, COUNT(*)
FROM TXT_territories
GROUP BY territory_id
HAVING COUNT(*) > 1;

-- region_id entero
SELECT *
FROM TXT_territories
WHERE region_id IS NOT NULL
  AND CAST(region_id AS INTEGER) IS NULL;

-- 2) CARGA TXT → TMP
INSERT INTO TMP_territories(territory_id, territory_description, region_id)
SELECT
  territory_id,
  territory_description,
  CAST(region_id AS INTEGER)
FROM TXT_territories;

select * from TMP_territories

-- 3) VALIDACIÓN REFERENCIAL
SELECT t.*
FROM TMP_territories t
LEFT JOIN TMP_regions r ON t.region_id = r.region_id
WHERE r.region_id IS NULL;

******* fin territories *******

******* CATEGORIES *******
-- 1) VALIDACIONES EN TXT_categories
-- PK duplicados
SELECT category_id, COUNT(*)
FROM TXT_categories
GROUP BY category_id
HAVING COUNT(*) > 1;

-- category_id entero
SELECT *
FROM TXT_categories
WHERE category_id IS NOT NULL
  AND CAST(category_id AS INTEGER) IS NULL;

-- 2) CARGA TXT → TMP
INSERT INTO TMP_categories(category_id, category_name, description, picture)
SELECT
  CAST(category_id AS INTEGER),
  category_name,
  description,
  picture  -- podría ser TEXT, SQLite lo permite
FROM TXT_categories;

select * from TMP_categories
-- 3) VALIDACIÓN REFERENCIAL
-- (No tiene FKs)
******* fin categories *******


******* SUPPLIERS *******
-- 1) VALIDACIONES EN TXT_suppliers
-- PK duplicados
SELECT supplier_id, COUNT(*)
FROM TXT_suppliers
GROUP BY supplier_id
HAVING COUNT(*) > 1;

-- supplier_id entero
SELECT *
FROM TXT_suppliers
WHERE supplier_id IS NOT NULL
  AND CAST(supplier_id AS INTEGER) IS NULL;

-- 2) CARGA TXT → TMP
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

-- 3) VALIDACIÓN REFERENCIAL
-- (No tiene FKs)
******* fin suppliers *******

******* SHIPPERS *******

-- 1) VALIDACIONES EN TXT_shippers
SELECT shipper_id, COUNT(*)
FROM TXT_shippers
GROUP BY shipper_id
HAVING COUNT(*) > 1;

SELECT *
FROM TXT_shippers
WHERE CAST(shipper_id AS INTEGER) IS NULL;

-- 2) CARGA TXT → TMP
INSERT INTO TMP_shippers
SELECT
  CAST(shipper_id AS INTEGER),
  company_name,
  phone
FROM TXT_shippers;

select * from TMP_shippers

-- 3) VALIDACIÓN REFERENCIAL
-- (No tiene FKs)
******* fin shippers *******

******* EMPLOYEES *******
-- 1) VALIDACIONES EN TXT_employees
-- PK duplicados
SELECT employee_id, COUNT(*)
FROM TXT_employees
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- employee_id entero
SELECT *
FROM TXT_employees
WHERE CAST(employee_id AS INTEGER) IS NULL;

-- reports_to debe ser entero o null
SELECT *
FROM TXT_employees
WHERE reports_to IS NOT NULL
  AND reports_to <> ''
  AND CAST(reports_to AS INTEGER) IS NULL;

-- Validación de fechas YYYY-MM-DD
SELECT *
FROM TXT_employees
WHERE birth_date NOT GLOB '????-??-?? ??:??:??.???'
  AND birth_date IS NOT NULL;
  
SELECT *
FROM TXT_employees
WHERE hire_date NOT GLOB '????-??-?? ??:??:??.???'
  AND hire_date IS NOT NULL;

-- 2) CARGA TXT → TMP

PRAGMA foreign_keys = OFF; -- deshabilito FK para que puedan insertarse todos los registros en el orden sin que molesten las fk

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
  CAST(reports_to AS INTEGER),
  photo_path
FROM TXT_employees;

PRAGMA foreign_keys = ON; -- vuelvo a habilitar fk

-- 3) VALIDACIÓN REFERENCIAL (self-FK)
SELECT e.*
FROM TMP_employees e
LEFT JOIN TMP_employees b ON e.reports_to = b.employee_id
WHERE e.reports_to IS NOT NULL AND b.employee_id IS NULL;

******* fin employees *******

******* EMPLOYEE_TERRITORIES *******
-- 1) VALIDACIONES EN TXT_employee_territories
-- Duplicados de PK compuesta
SELECT employee_id, territory_id, COUNT(*)
FROM TXT_employee_territories
GROUP BY employee_id, territory_id
HAVING COUNT(*) > 1;

-- employee_id entero
SELECT *
FROM TXT_employee_territories
WHERE CAST(employee_id AS INTEGER) IS NULL;

-- 2) CARGA TXT → TMP
INSERT INTO TMP_employee_territories
SELECT
  CAST(employee_id AS INTEGER),
  territory_id
FROM TXT_employee_territories;

select * from TMP_employee_territories order by 1,2

-- 3) VALIDACIÓN REFERENCIAL
-- employee_id → employees
SELECT et.*
FROM TMP_employee_territories et
LEFT JOIN TMP_employees e ON et.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
-- territory_id → territories
SELECT et.*
FROM TMP_employee_territories et
LEFT JOIN TMP_territories t ON et.territory_id = t.territory_id
WHERE t.territory_id IS NULL;

******* fin employee territories *******

******* CUSTOMERS *******
-- 1) VALIDACIONES EN TXT_customers
SELECT customer_id, COUNT(*)
FROM TXT_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 2) CARGA TXT → TMP
INSERT INTO TMP_customers
SELECT *
FROM TXT_customers;

-- 3) VALIDACIÓN REFERENCIAL
-- (No tiene FKs)
******* fin customers *******

******* PRODUCTS *******
-- 1) VALIDACIONES EN TXT_products
-- PK duplicados
SELECT product_id, COUNT(*)
FROM TXT_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- FK supplier_id entero
SELECT *
FROM TXT_products
WHERE supplier_id <> '' AND CAST(supplier_id AS INTEGER) IS NULL;

-- FK category_id entero
SELECT *
FROM TXT_products
WHERE category_id <> '' AND CAST(category_id AS INTEGER) IS NULL;

-- unit_price decimal
SELECT *
FROM TXT_products
WHERE unit_price NOT GLOB '[0-9]*.[0-9]*'
  AND unit_price NOT GLOB '[0-9]*';

-- 2) CARGA TXT → TMP
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

-- 3) VALIDACIÓN REFERENCIAL
-- supplier_id
SELECT p.*
FROM TMP_products p
LEFT JOIN TMP_suppliers s ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;
-- category_id
SELECT p.*
FROM TMP_products p
LEFT JOIN TMP_categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL;

******* fin products *******

******* ORDERS *******
-- 1) VALIDACIONES EN TXT_orders
-- PK duplicados
SELECT order_id, COUNT(*)
FROM TXT_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- customer_id no vacío
SELECT *
FROM TXT_orders
WHERE customer_id IS NULL OR customer_id = '';

-- employee_id entero
SELECT *
FROM TXT_orders
WHERE employee_id <> '' AND CAST(employee_id AS INTEGER) IS NULL;

-- ship_via entero
SELECT *
FROM TXT_orders
WHERE ship_via <> '' AND CAST(ship_via AS INTEGER) IS NULL;

-- fechas válidas
SELECT *
FROM TXT_orders
WHERE order_date NOT GLOB '????-??-?? ??:??:??.???'
  AND order_date IS NOT NULL;

-- 2) CARGA TXT → TMP
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

-- 3) VALIDACIÓN REFERENCIAL
--customer_id
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_customers c USING(customer_id)
WHERE c.customer_id IS NULL;
--employee_id
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_employees e ON o.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
--ship_via
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_shippers s ON o.ship_via = s.shipper_id
WHERE s.shipper_id IS NULL;

******* fin orders *******

******* ORDER_DETAILS *******
-- 1) VALIDACIONES EN TXT_order_details
-- Duplicados PK compuesta
SELECT order_id, product_id, COUNT(*)
FROM TXT_order_details
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- order_id entero
SELECT *
FROM TXT_order_details
WHERE CAST(order_id AS INTEGER) IS NULL;

-- product_id entero
SELECT *
FROM TXT_order_details
WHERE CAST(product_id AS INTEGER) IS NULL;

-- unit_price decimal
SELECT *
FROM TXT_order_details
WHERE unit_price NOT GLOB '[0-9]*.[0-9]*'
  AND unit_price NOT GLOB '[0-9]*';

-- 2) CARGA TXT → TMP
INSERT INTO TMP_order_details
SELECT
  CAST(order_id AS INTEGER),
  CAST(product_id AS INTEGER),
  CAST(unit_price AS REAL),
  CAST(quantity AS INTEGER),
  CAST(discount AS REAL)
FROM TXT_order_details;

-- 3) VALIDACIÓN REFERENCIAL
-- order_id
SELECT od.*
FROM TMP_order_details od
LEFT JOIN TMP_orders o ON od.order_id = o.order_id
WHERE o.order_id IS NULL;
-- product_id
SELECT od.*
FROM TMP_order_details od
LEFT JOIN TMP_products p ON od.product_id = p.product_id
WHERE p.product_id IS NULL;

******* fin order_details *******
