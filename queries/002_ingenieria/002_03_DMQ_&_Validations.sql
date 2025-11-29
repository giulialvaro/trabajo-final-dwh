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
-- VALIDACIÓN POR TABLA
---------------------------------------------------------------
-- EMPLOYEES
-- PK duplicada (employee_id)
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Employees'),
    'PK duplicada (employee_id)',
    IFNULL((
        SELECT COUNT(*) 
        FROM TMP_Employees
        GROUP BY employee_id
        HAVING COUNT(*) > 1
    ),0),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Employees GROUP BY employee_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- FK inexistente reports_to
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
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
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
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


-- CUSTOMERS
-- PK duplicada customer_id
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Customers'),
    'PK duplicada (customer_id)',
    IFNULL((
        SELECT COUNT(*) FROM TMP_Customers GROUP BY customer_id HAVING COUNT(*) > 1
    ),0),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Customers GROUP BY customer_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- company_name nulo
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Customers'),
    '% nulos company_name',
    (
        SELECT COUNT(*) * 1.0 / (SELECT COUNT(*) FROM TMP_Customers)
        FROM TMP_Customers WHERE company_name IS NULL
    ),
    0,0.1,
    CASE WHEN (
        SELECT COUNT(*) * 1.0 / (SELECT COUNT(*) FROM TMP_Customers)
        FROM TMP_Customers WHERE company_name IS NULL
    ) <= 0.1 THEN 1 ELSE 0 END;

-- PRODUCTS
-- PK duplicada product_id
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Products'),
    'PK duplicada (product_id)',
    IFNULL((
        SELECT COUNT(*) FROM TMP_Products GROUP BY product_id HAVING COUNT(*) > 1
    ),0),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Products GROUP BY product_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- FK category inexistente
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Products'),
    'FK category_id inexistente',
    (
        SELECT COUNT(*) FROM TMP_Products p
        LEFT JOIN TMP_Categories c ON p.category_id=c.category_id
        WHERE c.category_id IS NULL
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(*) FROM TMP_Products p
        LEFT JOIN TMP_Categories c ON p.category_id=c.category_id
        WHERE c.category_id IS NULL
    )=0 THEN 1 ELSE 0 END;

-- unit_price <= 0
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Products'),
    'unit_price <= 0',
    (
        SELECT COUNT(*) FROM TMP_Products WHERE unit_price <= 0
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(*) FROM TMP_Products WHERE unit_price <= 0
    )=0 THEN 1 ELSE 0 END;

-- CATEGORIES
-- PK duplicada category_id
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Categories'),
    'PK duplicada (category_id)',
    IFNULL((
        SELECT COUNT(*) FROM TMP_Categories GROUP BY category_id HAVING COUNT(*) > 1
    ),0),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Categories GROUP BY category_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- PK duplicada supplier_id
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Suppliers'),
    'PK duplicada (supplier_id)',
    IFNULL((
        SELECT COUNT(*) FROM TMP_Suppliers GROUP BY supplier_id HAVING COUNT(*) > 1
    ),0),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Suppliers GROUP BY supplier_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- SHIPPERS
-- PK duplicada shipper_id
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Shippers'),
    'PK duplicada (shipper_id)',
    IFNULL((
        SELECT COUNT(*) FROM TMP_Shippers GROUP BY shipper_id HAVING COUNT(*) > 1
    ),0),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Shippers GROUP BY shipper_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- ORDERS
-- PK duplicada order_id
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Orders'),
    'PK duplicada (order_id)',
    IFNULL((
        SELECT COUNT(*) FROM TMP_Orders GROUP BY order_id HAVING COUNT(*) > 1
    ),0),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Orders GROUP BY order_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- Fechas inválidas
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Orders'),
    'Fechas inválidas',
    (
        SELECT COUNT(*) FROM TMP_Orders
        WHERE order_date NOT LIKE '____-__-__%'
           OR (shipped_date IS NOT NULL AND shipped_date NOT LIKE '____-__-__%')
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(*) FROM TMP_Orders
        WHERE order_date NOT LIKE '____-__-__%'
           OR (shipped_date IS NOT NULL AND shipped_date NOT LIKE '____-__-__%')
    )=0 THEN 1 ELSE 0 END;

-- FK employee inexistente
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Orders'),
    'FK employee_id inexistente',
    (
        SELECT COUNT(*) FROM TMP_Orders o
        LEFT JOIN TMP_Employees e ON o.employee_id=e.employee_id
        WHERE e.employee_id IS NULL
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(*) FROM TMP_Orders o
        LEFT JOIN TMP_Employees e ON o.employee_id=e.employee_id
        WHERE e.employee_id IS NULL
    )=0 THEN 1 ELSE 0 END;

-- ORDER DETAILS
-- PK compuesta duplicada (order_id, product_id)
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name = 'TMP_order_details'),
    'PK compuesta duplicada (order_id, product_id)',
    IFNULL((
        SELECT COUNT(*) 
        FROM TMP_order_details
        GROUP BY order_id, product_id
        HAVING COUNT(*) > 1
    ),0),
    0, 0,
    CASE WHEN EXISTS (
        SELECT 1 
        FROM TMP_order_details
        GROUP BY order_id, product_id
        HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- FK order_id inexistente en TMP_Orders
---------------------------------------------------------------
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name = 'TMP_order_details'),
    'FK order_id inexistente',
    (
        SELECT COUNT(*)
        FROM TMP_order_details od
        LEFT JOIN TMP_Orders o ON od.order_id = o.order_id
        WHERE o.order_id IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM TMP_order_details od
        LEFT JOIN TMP_Orders o ON od.order_id = o.order_id
        WHERE o.order_id IS NULL
    ) = 0 THEN 1 ELSE 0 END;

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name = 'TMP_order_details'),
    'quantity <= 0 o discount fuera de rango',
    (
        SELECT COUNT(*)
        FROM TMP_order_details
        WHERE quantity <= 0 OR discount < 0 OR discount > 1
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM TMP_order_details
        WHERE quantity <= 0 OR discount < 0 OR discount > 1
    ) = 0 THEN 1 ELSE 0 END;


-- REGIONS
-- PK duplicada region_id
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Regions'),
    'PK duplicada (region_id)',
    IFNULL((
        SELECT COUNT(*) FROM TMP_Regions GROUP BY region_id HAVING COUNT(*) > 1
    ),0),
    0,0,
    CASE WHEN EXISTS(
        SELECT 1 FROM TMP_Regions GROUP BY region_id HAVING COUNT(*) > 1
    ) THEN 0 ELSE 1 END;

-- TERRITORIES 
-- FK region inexistente
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value, threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='TMP_Territories'),
    'FK region_id inexistente',
    (
        SELECT COUNT(*) FROM TMP_Territories t
        LEFT JOIN TMP_Regions r ON t.region_id=r.region_id
        WHERE r.region_id IS NULL
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(*) FROM TMP_Territories t
        LEFT JOIN TMP_Regions r ON t.region_id=r.region_id
        WHERE r.region_id IS NULL
    )=0 THEN 1 ELSE 0 END;

