-- ==========================================================
-- 002_01_validaciones_ingesta.sql
-- Etapa 1 - Validaciones sobre TXT y carga en DQM
-- Requiere:
--   - DQM_* creadas (001_01_create_txt_tables.sql)
--   - TXT_* cargadas con los CSV de Ingesta1
-- ==========================================================

PRAGMA foreign_keys = ON;

-- ==========================================================
-- PASO 1: VALIDACIONES DE CAST (CAST_NUMERIC / CAST_DATE)
--   -> DQM_cast_issues
-- ==========================================================

-- ---------- NUMÉRICOS EN TXT_order_details ----------

-- unit_price debería ser numérico
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_order_details'           AS table_name,
  'unit_price'                  AS column_name,
  'CAST_NUMERIC'                AS check_code,
  COUNT(*)                      AS invalid_count,
  MIN(unit_price)               AS sample_value
FROM TXT_order_details
WHERE TRIM(unit_price) <> ''
  AND unit_price NOT GLOB '[0-9]*';

-- quantity debería ser numérico
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_order_details',
  'quantity',
  'CAST_NUMERIC',
  COUNT(*),
  MIN(quantity)
FROM TXT_order_details
WHERE TRIM(quantity) <> ''
  AND quantity NOT GLOB '[0-9]*';

-- discount debería ser numérico (0-9, sin decimales en esta primera pasada)
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_order_details',
  'discount',
  'CAST_NUMERIC',
  COUNT(*),
  MIN(discount)
FROM TXT_order_details
WHERE TRIM(discount) <> ''
  AND discount NOT GLOB '[0-9]*';


-- ---------- NUMÉRICOS EN TXT_products ----------

-- unit_price numérico
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_products',
  'unit_price',
  'CAST_NUMERIC',
  COUNT(*),
  MIN(unit_price)
FROM TXT_products
WHERE TRIM(unit_price) <> ''
  AND unit_price NOT GLOB '[0-9]*';

-- units_in_stock numérico
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_products',
  'units_in_stock',
  'CAST_NUMERIC',
  COUNT(*),
  MIN(units_in_stock)
FROM TXT_products
WHERE TRIM(units_in_stock) <> ''
  AND units_in_stock NOT GLOB '[0-9]*';

-- units_on_order numérico
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_products',
  'units_on_order',
  'CAST_NUMERIC',
  COUNT(*),
  MIN(units_on_order)
FROM TXT_products
WHERE TRIM(units_on_order) <> ''
  AND units_on_order NOT GLOB '[0-9]*';

-- reorder_level numérico
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_products',
  'reorder_level',
  'CAST_NUMERIC',
  COUNT(*),
  MIN(reorder_level)
FROM TXT_products
WHERE TRIM(reorder_level) <> ''
  AND reorder_level NOT GLOB '[0-9]*';


-- ---------- NUMÉRICOS EN TXT_orders ----------

-- freight numérico
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_orders',
  'freight',
  'CAST_NUMERIC',
  COUNT(*),
  MIN(freight)
FROM TXT_orders
WHERE TRIM(freight) <> ''
  AND freight NOT GLOB '[0-9]*';


-- ---------- FECHAS EN TXT_orders (formato YYYY-MM-DD) ----------

-- order_date
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_orders',
  'order_date',
  'CAST_DATE',
  COUNT(*),
  MIN(order_date)
FROM TXT_orders
WHERE TRIM(order_date) <> ''
  AND order_date NOT GLOB '____-__-__';

-- required_date
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_orders',
  'required_date',
  'CAST_DATE',
  COUNT(*),
  MIN(required_date)
FROM TXT_orders
WHERE TRIM(required_date) <> ''
  AND required_date NOT GLOB '____-__-__';

-- shipped_date
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT
  'TXT_orders',
  'shipped_date',
  'CAST_DATE',
  COUNT(*),
  MIN(shipped_date)
FROM TXT_orders
WHERE TRIM(shipped_date) <> ''
  AND shipped_date NOT GLOB '____-__-__';


-- ==========================================================
-- PASO 2: VALIDACIÓN DE PK (PK_DUPLICATES)
--   -> DQM_pk_issues
-- ==========================================================

-- Duplicados de order_id en TXT_orders
INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT
  'TXT_orders'    AS table_name,
  'PK_DUPLICATES' AS check_code,
  COUNT(*)        AS duplicates_count
FROM (
  SELECT order_id
  FROM TXT_orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
) t;


-- Duplicados de product_id en TXT_products
INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT
  'TXT_products',
  'PK_DUPLICATES',
  COUNT(*)
FROM (
  SELECT product_id
  FROM TXT_products
  GROUP BY product_id
  HAVING COUNT(*) > 1
) t;


-- Duplicados de PK compuesta (order_id, product_id) en TXT_order_details
INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT
  'TXT_order_details',
  'PK_DUPLICATES',
  COUNT(*)
FROM (
  SELECT order_id, product_id
  FROM TXT_order_details
  GROUP BY order_id, product_id
  HAVING COUNT(*) > 1
) t;


-- (Opcional) Duplicados de otras PK: customers, employees, etc.
INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT
  'TXT_customers',
  'PK_DUPLICATES',
  COUNT(*)
FROM (
  SELECT customer_id
  FROM TXT_customers
  GROUP BY customer_id
  HAVING COUNT(*) > 1
) t;

INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT
  'TXT_employees',
  'PK_DUPLICATES',
  COUNT(*)
FROM (
  SELECT employee_id
  FROM TXT_employees
  GROUP BY employee_id
  HAVING COUNT(*) > 1
) t;


-- ==========================================================
-- PASO 3: PERFILADO BÁSICO
--   -> DQM_table_profile, DQM_field_profile
-- ==========================================================

-- ---------- Perfilado por tabla (row_count) ----------

INSERT INTO DQM_table_profile(table_name, row_count)
SELECT 'TXT_orders', COUNT(*) FROM TXT_orders;

INSERT INTO DQM_table_profile(table_name, row_count)
SELECT 'TXT_products', COUNT(*) FROM TXT_products;

INSERT INTO DQM_table_profile(table_name, row_count)
SELECT 'TXT_customers', COUNT(*) FROM TXT_customers;

INSERT INTO DQM_table_profile(table_name, row_count)
SELECT 'TXT_order_details', COUNT(*) FROM TXT_order_details;


-- ---------- Perfilado por campo (ejemplos) ----------

-- TXT_orders.order_id
INSERT INTO DQM_field_profile(
    table_name,
    column_name,
    null_count,
    distinct_count,
    min_val,
    max_val,
    example_value
)
SELECT
  'TXT_orders'                                                        AS table_name,
  'order_id'                                                          AS column_name,
  SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = '' THEN 1 ELSE 0 END) AS null_count,
  COUNT(DISTINCT order_id)                                            AS distinct_count,
  MIN(order_id)                                                       AS min_val,
  MAX(order_id)                                                       AS max_val,
  MAX(order_id)                                                       AS example_value
FROM TXT_orders;


-- TXT_orders.customer_id
INSERT INTO DQM_field_profile(
    table_name,
    column_name,
    null_count,
    distinct_count,
    min_val,
    max_val,
    example_value
)
SELECT
  'TXT_orders',
  'customer_id',
  SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id) = '' THEN 1 ELSE 0 END),
  COUNT(DISTINCT customer_id),
  MIN(customer_id),
  MAX(customer_id),
  MAX(customer_id)
FROM TXT_orders;


-- TXT_products.product_id
INSERT INTO DQM_field_profile(
    table_name,
    column_name,
    null_count,
    distinct_count,
    min_val,
    max_val,
    example_value
)
SELECT
  'TXT_products',
  'product_id',
  SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END),
  COUNT(DISTINCT product_id),
  MIN(product_id),
  MAX(product_id),
  MAX(product_id)
FROM TXT_products;


-- TXT_products.unit_price
INSERT INTO DQM_field_profile(
    table_name,
    column_name,
    null_count,
    distinct_count,
    min_val,
    max_val,
    example_value
)
SELECT
  'TXT_products',
  'unit_price',
  SUM(CASE WHEN unit_price IS NULL OR TRIM(unit_price) = '' THEN 1 ELSE 0 END),
  COUNT(DISTINCT unit_price),
  MIN(unit_price),
  MAX(unit_price),
  MAX(unit_price)
FROM TXT_products;

-- (podés seguir agregando campos según lo que quieras resumir)
