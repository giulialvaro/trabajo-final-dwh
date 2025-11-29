/* ============================================================
   Capa DQM – Data Quality Mart
   ============================================================ */

---------------------------------------------------------------
-- PROCESOS EJECUTADOS (FECHAS, TABLAS, RESULTADO)
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DQM_Processes (
    process_id INTEGER PRIMARY KEY AUTOINCREMENT,
    process_name TEXT,
    process_date TEXT,
    layer TEXT,
    status TEXT,         -- OK / PARTIAL / REJECTED
    observations TEXT
);

---------------------------------------------------------------
-- ENTIDADES VALIDADAS EN CADA PROCESO
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DQM_Entities (
    dqm_entity_id INTEGER PRIMARY KEY AUTOINCREMENT,
    process_id INTEGER,
    table_name TEXT,
    record_count INTEGER,
    status TEXT,         -- OK / PARTIAL / REJECTED
    observations TEXT
);

---------------------------------------------------------------
-- INDICADORES DE CALIDAD POR ENTIDAD
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DQM_Indicators (
    indicator_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dqm_entity_id INTEGER,

    indicator_name TEXT,
    indicator_value REAL,
    threshold_min REAL,
    threshold_max REAL,
    passed INTEGER         -- 1 = OK, 0 = FAIL
);



---------------------------------------------------------------
-- CREAMOS EL PROCESO
---------------------------------------------------------------
INSERT INTO DQM_Processes (process_name, process_date, layer, status, observations)
VALUES ('Validacion TMP -> DWA', DATE('now'), 'TMP', 'PENDING', NULL);

SELECT last_insert_rowid() AS process_id;

---------------------------------------------------------------
-- MÉTRICAS POR ENTIDAD employees 
---------------------------------------------------------------
/* ============================================================
   Cargar ENTIDADES del proceso 1 en DQM_Entities
   ============================================================ */

---------------------------------------------------------------
-- TMP_Employees
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1 AS process_id,
    'TMP_Employees',
    COUNT(*) AS record_count,
    'PENDING'
FROM TMP_Employees;

---------------------------------------------------------------
-- TMP_Customers
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Customers',
    COUNT(*),
    'PENDING'
FROM TMP_Customers;

---------------------------------------------------------------
-- TMP_Products
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Products',
    COUNT(*),
    'PENDING'
FROM TMP_Products;

---------------------------------------------------------------
-- TMP_Categories
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Categories',
    COUNT(*),
    'PENDING'
FROM TMP_Categories;

---------------------------------------------------------------
-- TMP_Suppliers
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Suppliers',
    COUNT(*),
    'PENDING'
FROM TMP_Suppliers;

---------------------------------------------------------------
-- TMP_Shippers
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Shippers',
    COUNT(*),
    'PENDING'
FROM TMP_Shippers;

---------------------------------------------------------------
-- TMP_Orders
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Orders',
    COUNT(*),
    'PENDING'
FROM TMP_Orders;

---------------------------------------------------------------
-- TMP_OrderDetails
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_OrderDetails',
    COUNT(*),
    'PENDING'
FROM TMP_order_details;

---------------------------------------------------------------
-- TMP_Regions
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Regions',
    COUNT(*),
    'PENDING'
FROM TMP_Regions;

---------------------------------------------------------------
-- TMP_Territories
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Territories',
    COUNT(*),
    'PENDING'
FROM TMP_Territories;

---------------------------------------------------------------
-- TMP_Employee_Territories
---------------------------------------------------------------
INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT 
    1,
    'TMP_Employee_Territories',
    COUNT(*),
    'PENDING'
FROM TMP_Employee_Territories;


---------------------------------------------------------------
-- INDICADORES X TABLA
---------------------------------------------------------------
-- PK duplicada (employee_id)
INSERT INTO DQM_Indicators
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Employees'),
    'PK duplicada (employee_id)',
    (
        SELECT COUNT(*) 
        FROM TMP_Employees
        GROUP BY employee_id
        HAVING COUNT(*) > 1
    ),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Employees GROUP BY employee_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- FK inexistente reports_to
INSERT INTO DQM_Indicators
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Employees'),
    'FK reports_to inexistente',
    (
        SELECT COUNT(*)
        FROM TMP_Employees e
        LEFT JOIN TMP_Employees b ON e.reports_to=b.employee_id
        WHERE e.reports_to IS NOT NULL AND b.employee_id IS NULL
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM TMP_Employees e
        LEFT JOIN TMP_Employees b ON e.reports_to=b.employee_id
        WHERE e.reports_to IS NOT NULL AND b.employee_id IS NULL
    )=0 THEN 1 ELSE 0 END;

-- Fechas inválidas
INSERT INTO DQM_Indicators
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Employees'),
    'Fechas inválidas (birth/hire)',
    (
        SELECT COUNT(*)
        FROM TMP_Employees
        WHERE hire_date NOT LIKE '____-__-__%'
           OR birth_date NOT LIKE '____-__-__%'
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM TMP_Employees
        WHERE hire_date NOT LIKE '____-__-__%'
           OR birth_date NOT LIKE '____-__-__%'
    )=0 THEN 1 ELSE 0 END;

