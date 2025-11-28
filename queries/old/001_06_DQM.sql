/* ===========================================================
   006_DQM.sql
   PERSISTENCIA COMPLETA DE DATA QUALITY (DQM)
   =========================================================== */


----------------------------------------------------------------
-- 0) LIMPIAR DQM (opcional si estás re-ejecutando)
----------------------------------------------------------------
DELETE FROM DQM_cast_issues;
DELETE FROM DQM_pk_issues;
DELETE FROM DQM_fk_issues;
DELETE FROM DQM_table_profile;
DELETE FROM DQM_field_profile;


/* ===========================================================
   1) CAST ISSUES (TXT)
   =========================================================== */

------------------------
-- CATEGORIES
------------------------
INSERT INTO DQM_cast_issues(table_name, column_name, check_code, invalid_count, sample_value)
SELECT 'TXT_categories','category_id','CAST_NUMERIC', COUNT(*), category_id
FROM TXT_categories
WHERE category_id IS NOT NULL AND CAST(category_id AS INTEGER) IS NULL;



------------------------
-- CUSTOMERS (no numeric keys)
------------------------
-- No cast issues relevantes aquí


------------------------
-- EMPLOYEES
------------------------
INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_employees','employee_id','CAST_NUMERIC', COUNT(*), employee_id
FROM TXT_employees
WHERE CAST(employee_id AS INTEGER) IS NULL;

INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_employees','reports_to','CAST_NUMERIC', COUNT(*), reports_to
FROM TXT_employees
WHERE reports_to <> '' AND reports_to IS NOT NULL AND CAST(reports_to AS INTEGER) IS NULL;

------------------------
-- ORDER_DETAILS
------------------------
INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_order_details','order_id','CAST_NUMERIC',COUNT(*),order_id
FROM TXT_order_details
WHERE CAST(order_id AS INTEGER) IS NULL;

INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_order_details','product_id','CAST_NUMERIC',COUNT(*),product_id
FROM TXT_order_details
WHERE CAST(product_id AS INTEGER) IS NULL;


------------------------
-- ORDERS
------------------------
INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_orders','employee_id','CAST_NUMERIC',COUNT(*),employee_id
FROM TXT_orders
WHERE employee_id <> '' AND CAST(employee_id AS INTEGER) IS NULL;

INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_orders','ship_via','CAST_NUMERIC',COUNT(*),ship_via
FROM TXT_orders
WHERE ship_via <> '' AND CAST(ship_via AS INTEGER) IS NULL;



------------------------
-- PRODUCTS
------------------------
INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_products','supplier_id','CAST_NUMERIC',COUNT(*),supplier_id
FROM TXT_products
WHERE supplier_id <> '' AND CAST(supplier_id AS INTEGER) IS NULL;

INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_products','category_id','CAST_NUMERIC',COUNT(*),category_id
FROM TXT_products
WHERE category_id <> '' AND CAST(category_id AS INTEGER) IS NULL;



------------------------
-- REGIONS / SHIPPERS / SUPPLIERS / TERRITORIES
------------------------
INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_regions','region_id','CAST_NUMERIC',COUNT(*),region_id
FROM TXT_regions
WHERE CAST(region_id AS INTEGER) IS NULL;

INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_shippers','shipper_id','CAST_NUMERIC',COUNT(*),shipper_id
FROM TXT_shippers
WHERE CAST(shipper_id AS INTEGER) IS NULL;

INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_suppliers','supplier_id','CAST_NUMERIC',COUNT(*),supplier_id
FROM TXT_suppliers
WHERE CAST(supplier_id AS INTEGER) IS NULL;

INSERT INTO DQM_cast_issues(table_name,column_name,check_code,invalid_count,sample_value)
SELECT 'TXT_territories','region_id','CAST_NUMERIC',COUNT(*),region_id
FROM TXT_territories
WHERE region_id <> '' AND CAST(region_id AS INTEGER) IS NULL;




/* ===========================================================
   2) PK ISSUES (TXT)
   =========================================================== */

INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT 'TXT_categories','PK_DUPLICATES', COUNT(*) - COUNT(DISTINCT category_id)
FROM TXT_categories;

INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT 'TXT_customers','PK_DUPLICATES', COUNT(*) - COUNT(DISTINCT customer_id)
FROM TXT_customers;

INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT 'TXT_employees','PK_DUPLICATES', COUNT(*) - COUNT(DISTINCT employee_id)
FROM TXT_employees;

INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT 'TXT_order_details','PK_DUPLICATES',
       COUNT(*) - COUNT(DISTINCT order_id || '-' || product_id)
FROM TXT_order_details;

INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT 'TXT_orders','PK_DUPLICATES', COUNT(*) - COUNT(DISTINCT order_id)
FROM TXT_orders;

INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT 'TXT_products','PK_DUPLICATES', COUNT(*) - COUNT(DISTINCT product_id)
FROM TXT_products;

INSERT INTO DQM_pk_issues(table_name, check_code, duplicates_count)
SELECT 'TXT_regions','PK_DUPLICATES', COUNT(*) - COUNT(DISTINCT region_id)
FROM TXT_regions;




/* ===========================================================
   3) FK ISSUES (sobre TMP)
   =========================================================== */

------------------------
-- ORDERS → CUSTOMERS
------------------------
INSERT INTO DQM_fk_issues(table_name, fk_name, check_code, orphan_count)
SELECT 'TMP_orders','FK_customer','FK_ORPHANS', COUNT(*)
FROM TMP_orders o
LEFT JOIN TMP_customers c USING(customer_id)
WHERE c.customer_id IS NULL;


------------------------
-- ORDERS → EMPLOYEES
------------------------
INSERT INTO DQM_fk_issues(table_name, fk_name, check_code, orphan_count)
SELECT 'TMP_orders','FK_employee','FK_ORPHANS', COUNT(*)
FROM TMP_orders o
LEFT JOIN TMP_employees e ON o.employee_id = e.employee_id
WHERE e.employee_id IS NULL;


------------------------
-- PRODUCTS → SUPPLIERS
------------------------
INSERT INTO DQM_fk_issues(table_name, fk_name, check_code, orphan_count)
SELECT 'TMP_products','FK_supplier','FK_ORPHANS', COUNT(*)
FROM TMP_products p
LEFT JOIN TMP_suppliers s ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;


------------------------
-- PRODUCTS → CATEGORIES
------------------------
INSERT INTO DQM_fk_issues(table_name, fk_name, check_code, orphan_count)
SELECT 'TMP_products','FK_category','FK_ORPHANS', COUNT(*)
FROM TMP_products p
LEFT JOIN TMP_categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL;


------------------------
-- TERRITORIES → REGIONS
------------------------
INSERT INTO DQM_fk_issues(table_name, fk_name, check_code, orphan_count)
SELECT 'TMP_territories','FK_region','FK_ORPHANS', COUNT(*)
FROM TMP_territories t
LEFT JOIN TMP_regions r ON t.region_id = r.region_id
WHERE r.region_id IS NULL;




/* ===========================================================
   4) TABLE PROFILE
   =========================================================== */

INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_categories', COUNT(*) FROM TXT_categories;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_customers', COUNT(*) FROM TXT_customers;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_employees', COUNT(*) FROM TXT_employees;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_order_details', COUNT(*) FROM TXT_order_details;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_orders', COUNT(*) FROM TXT_orders;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_products', COUNT(*) FROM TXT_products;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_regions', COUNT(*) FROM TXT_regions;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_shippers', COUNT(*) FROM TXT_shippers;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_suppliers', COUNT(*) FROM TXT_suppliers;
INSERT INTO DQM_table_profile(table_name,row_count) SELECT 'TXT_territories', COUNT(*) FROM TXT_territories;




/* ===========================================================
   5) FIELD PROFILE
   (null_count + distinct_count) – por columna importante
   =========================================================== */

-- Helper inline: NULL ('' or NULL)

------------------------
-- TXT_categories
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_categories','category_id',
       SUM(category_id IS NULL OR TRIM(category_id)=''),
       COUNT(DISTINCT category_id)
FROM TXT_categories;

INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_categories','category_name',
       SUM(category_name IS NULL OR TRIM(category_name)=''),
       COUNT(DISTINCT category_name)
FROM TXT_categories;


------------------------
-- TXT_customers
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_customers','customer_id',
       SUM(customer_id IS NULL OR TRIM(customer_id)=''),
       COUNT(DISTINCT customer_id)
FROM TXT_customers;

INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_customers','company_name',
       SUM(company_name IS NULL OR TRIM(company_name)=''),
       COUNT(DISTINCT company_name)
FROM TXT_customers;


------------------------
-- TXT_employees
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_employees','employee_id',
       SUM(employee_id IS NULL OR TRIM(employee_id)=''),
       COUNT(DISTINCT employee_id)
FROM TXT_employees;

INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_employees','last_name',
       SUM(last_name IS NULL OR TRIM(last_name)=''),
       COUNT(DISTINCT last_name)
FROM TXT_employees;


------------------------
-- TXT_order_details
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_order_details','order_id',
       SUM(order_id IS NULL OR TRIM(order_id)=''),
       COUNT(DISTINCT order_id)
FROM TXT_order_details;

INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_order_details','product_id',
       SUM(product_id IS NULL OR TRIM(product_id)=''),
       COUNT(DISTINCT product_id)
FROM TXT_order_details;


------------------------
-- TXT_orders
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_orders','order_id',
       SUM(order_id IS NULL OR TRIM(order_id)=''),
       COUNT(DISTINCT order_id)
FROM TXT_orders;

INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_orders','customer_id',
       SUM(customer_id IS NULL OR TRIM(customer_id)=''),
       COUNT(DISTINCT customer_id)
FROM TXT_orders;


------------------------
-- TXT_products
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_products','product_id',
       SUM(product_id IS NULL OR TRIM(product_id)=''),
       COUNT(DISTINCT product_id)
FROM TXT_products;

INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_products','product_name',
       SUM(product_name IS NULL OR TRIM(product_name)=''),
       COUNT(DISTINCT product_name)
FROM TXT_products;


------------------------
-- TXT_regions
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_regions','region_id',
       SUM(region_id IS NULL OR TRIM(region_id)=''),
       COUNT(DISTINCT region_id)
FROM TXT_regions;


------------------------
-- TXT_suppliers
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_suppliers','supplier_id',
       SUM(supplier_id IS NULL OR TRIM(supplier_id)=''),
       COUNT(DISTINCT supplier_id)
FROM TXT_suppliers;

INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_suppliers','company_name',
       SUM(company_name IS NULL OR TRIM(company_name)=''),
       COUNT(DISTINCT company_name)
FROM TXT_suppliers;


------------------------
-- TXT_territories
------------------------
INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_territories','territory_id',
       SUM(territory_id IS NULL OR TRIM(territory_id)=''),
       COUNT(DISTINCT territory_id)
FROM TXT_territories;

INSERT INTO DQM_field_profile(table_name,column_name,null_count,distinct_count)
SELECT 'TXT_territories','region_id',
       SUM(region_id IS NULL OR TRIM(region_id)=''),
       COUNT(DISTINCT region_id)
FROM TXT_territories;