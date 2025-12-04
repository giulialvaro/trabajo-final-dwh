/* ============================================================
    002_00_validaciones_TMP.sql
    Validaciones completas sobre tablas TMP
    Objetivo: asegurar consistencia antes de etapa modelo.
   ============================================================ */


/* ============================================================
   TMP_CATEGORIES
   ============================================================ */

-- PK duplicada (no deberia existir)
SELECT category_id, COUNT(*)
FROM TMP_categories
GROUP BY category_id
HAVING COUNT(*) > 1;

-- PK nula
SELECT *
FROM TMP_categories
WHERE category_id IS NULL;

-- Campos obligatorios nulos
SELECT *
FROM TMP_categories
WHERE category_name IS NULL;



/* ============================================================
   TMP_CUSTOMERS
   ============================================================ */

-- PK duplicada
SELECT customer_id, COUNT(*)
FROM TMP_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- PK nula
SELECT *
FROM TMP_customers
WHERE customer_id IS NULL;

-- Campos obligatorios nulos
SELECT *
FROM TMP_customers
WHERE company_name IS NULL;

-- NUEVA: FK country inexistente
SELECT c.*
FROM TMP_customers c
LEFT JOIN TMP_countries t ON c.country_id = t.country_id
WHERE t.country_id IS NULL;



/* ============================================================
   TMP_EMPLOYEES
   ============================================================ */

-- PK duplicada
SELECT employee_id, COUNT(*)
FROM TMP_employees
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- PK nula
SELECT *
FROM TMP_employees
WHERE employee_id IS NULL;

-- Fechas mal parseadas (CUANDO YA ESTÁN TIPADAS)
SELECT *
FROM TMP_employees
WHERE hire_date IS NOT NULL
  AND hire_date < '1900-01-01';   -- outlier típico

SELECT *
FROM TMP_employees
WHERE birth_date IS NOT NULL
  AND birth_date > DATE('now');   -- imposible

-- FK: reports_to huérfanos
SELECT e.*
FROM TMP_employees e
LEFT JOIN TMP_employees boss ON e.reports_to = boss.employee_id
WHERE e.reports_to IS NOT NULL
  AND boss.employee_id IS NULL;

-- NUEVA: FK country inexistente
SELECT e.*
FROM TMP_employees e
LEFT JOIN TMP_countries t ON e.country_id = t.country_id
WHERE t.country_id IS NULL;



/* ============================================================
   TMP_PRODUCTS
   ============================================================ */

-- PK duplicada
SELECT product_id, COUNT(*)
FROM TMP_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- PK nula
SELECT *
FROM TMP_products
WHERE product_id IS NULL;

-- FK: supplier inexistente
SELECT p.*
FROM TMP_products p
LEFT JOIN TMP_suppliers s ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;

-- FK: category inexistente
SELECT p.*
FROM TMP_products p
LEFT JOIN TMP_categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL;

-- Valores fuera de rango
SELECT *
FROM TMP_products
WHERE unit_price <= 0;



/* ============================================================
   TMP_ORDERS
   ============================================================ */

-- PK duplicada
SELECT order_id, COUNT(*)
FROM TMP_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- PK nula
SELECT *
FROM TMP_orders
WHERE order_id IS NULL;

-- FK customer inexistente
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- FK employee inexistente
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_employees e ON o.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

-- FK shipper inexistente
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_shippers s ON o.ship_via = s.shipper_id
WHERE s.shipper_id IS NULL;

-- NUEVA: FK ship_country inexistente
SELECT o.*
FROM TMP_orders o
LEFT JOIN TMP_countries t ON o.ship_country_id = t.country_id
WHERE t.country_id IS NULL;

-- Fechas inválidas
SELECT *
FROM TMP_orders
WHERE order_date > DATE('now');

SELECT *
FROM TMP_orders
WHERE shipped_date IS NOT NULL
  AND shipped_date < order_date;



/* ============================================================
   TMP_ORDER_DETAILS
   ============================================================ */

-- PK compuesta duplicada
SELECT order_id, product_id, COUNT(*)
FROM TMP_order_details
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- PK incompleta
SELECT *
FROM TMP_order_details
WHERE order_id IS NULL
   OR product_id IS NULL;

-- FK order inexistente
SELECT od.*
FROM TMP_order_details od
LEFT JOIN TMP_orders o ON od.order_id = o.order_id
WHERE o.order_id IS NULL;

-- FK product inexistente
SELECT od.*
FROM TMP_order_details od
LEFT JOIN TMP_products p ON od.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Outliers típicos
SELECT *
FROM TMP_order_details
WHERE unit_price <= 0
   OR quantity <= 0
   OR discount < 0
   OR discount > 1;



/* ============================================================
   TMP_SHIPPERS
   ============================================================ */

-- PK duplicada
SELECT shipper_id, COUNT(*)
FROM TMP_shippers
GROUP BY shipper_id
HAVING COUNT(*) > 1;

-- Campos nulos
SELECT *
FROM TMP_shippers
WHERE company_name IS NULL;



/* ============================================================
   TMP_SUPPLIERS
   ============================================================ */

-- PK duplicada
SELECT supplier_id, COUNT(*)
FROM TMP_suppliers
GROUP BY supplier_id
HAVING COUNT(*) > 1;

-- Campos relevantes nulos
SELECT *
FROM TMP_suppliers
WHERE company_name IS NULL;


-- NUEVA: FK country inexistente
SELECT s.*
FROM TMP_suppliers s
LEFT JOIN TMP_countries t ON s.country_id = t.country_id
WHERE t.country_id IS NULL;

/* ============================================================
   TMP_REGIONS / TMP_TERRITORIES
   ============================================================ */

-- Regions PK duplicada
SELECT region_id, COUNT(*)
FROM TMP_regions
GROUP BY region_id
HAVING COUNT(*) > 1;

-- Territories PK duplicada
SELECT territory_id, COUNT(*)
FROM TMP_territories
GROUP BY territory_id
HAVING COUNT(*) > 1;

-- FK region inexistente
SELECT t.*
FROM TMP_territories t
LEFT JOIN TMP_regions r ON t.region_id = r.region_id
WHERE r.region_id IS NULL;



/* ============================================================
   TMP_EMPLOYEE_TERRITORIES
   ============================================================ */

-- PK compuesta duplicada
SELECT employee_id, territory_id, COUNT(*)
FROM TMP_employee_territories
GROUP BY employee_id, territory_id
HAVING COUNT(*) > 1;

-- FK employee inexistente
SELECT et.*
FROM TMP_employee_territories et
LEFT JOIN TMP_employees e ON et.employee_id = e.employee_id
WHERE e.employee_id IS NULL;

-- FK territory inexistente
SELECT et.*
FROM TMP_employee_territories et
LEFT JOIN TMP_territories t ON et.territory_id = t.territory_id
WHERE t.territory_id IS NULL;









