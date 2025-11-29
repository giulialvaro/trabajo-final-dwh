INSERT INTO DQM_Processes (process_name, process_date, layer, status, observations)
VALUES ('Validación DWA (integración)', DATE('now'), 'DWA', 'PENDING', NULL);

SELECT last_insert_rowid() AS process_id;


INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT (SELECT MAX(process_id) FROM DQM_Processes), 'DWA_DimEmployee', COUNT(*), 'PENDING' FROM DWA_DimEmployee;

INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT (SELECT MAX(process_id) FROM DQM_Processes), 'DWA_DimCustomer', COUNT(*), 'PENDING' FROM DWA_DimCustomer;

INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT (SELECT MAX(process_id) FROM DQM_Processes), 'DWA_DimProduct', COUNT(*), 'PENDING' FROM DWA_DimProduct;

INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT (SELECT MAX(process_id) FROM DQM_Processes), 'DWA_DimCategory', COUNT(*), 'PENDING' FROM DWA_DimCategory;

INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT (SELECT MAX(process_id) FROM DQM_Processes), 'DWA_DimSupplier', COUNT(*), 'PENDING' FROM DWA_DimSupplier;

INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT (SELECT MAX(process_id) FROM DQM_Processes), 'DWA_DimShipper', COUNT(*), 'PENDING' FROM DWA_DimShipper;

INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT (SELECT MAX(process_id) FROM DQM_Processes), 'DWA_DimDate', COUNT(*), 'PENDING' FROM DWA_DimDate;

INSERT INTO DQM_Entities (process_id, table_name, record_count, status)
SELECT (SELECT MAX(process_id) FROM DQM_Processes), 'DWA_FactOrderDetails', COUNT(*), 'PENDING' FROM DWA_FactOrderDetails;

/*
======================================================================
 PK DUPLICADAS
======================================================================
*/

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT 
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimEmployee'),
    'PK duplicada (employee_key)',
    (SELECT COUNT(*) FROM (
        SELECT employee_key, COUNT(*) AS c 
        FROM DWA_DimEmployee 
        GROUP BY employee_key 
        HAVING c > 1
    )),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT employee_key, COUNT(*) AS c 
        FROM DWA_DimEmployee 
        GROUP BY employee_key 
        HAVING c > 1
    )) = 0 THEN 1 ELSE 0 END;

-- customers
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT 
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimCustomer'),
    'PK duplicada (customer_key)',
    (SELECT COUNT(*) FROM (
        SELECT customer_key, COUNT(*) AS c 
        FROM DWA_DimCustomer 
        GROUP BY customer_key 
        HAVING c > 1
    )),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT customer_key, COUNT(*) AS c 
        FROM DWA_DimCustomer 
        GROUP BY customer_key 
        HAVING c > 1
    )) = 0 THEN 1 ELSE 0 END;

-- products
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT 
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimProduct'),
    'PK duplicada (product_key)',
    (SELECT COUNT(*) FROM (
        SELECT product_key, COUNT(*) AS c 
        FROM DWA_DimProduct 
        GROUP BY product_key 
        HAVING c > 1
    )),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT product_key, COUNT(*) AS c 
        FROM DWA_DimProduct 
        GROUP BY product_key 
        HAVING c > 1
    )) = 0 THEN 1 ELSE 0 END;

-- category
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT 
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimCategory'),
    'PK duplicada (category_key)',
    (SELECT COUNT(*) FROM (
        SELECT category_key, COUNT(*) AS c 
        FROM DWA_DimCategory 
        GROUP BY category_key 
        HAVING c > 1
    )),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT category_key, COUNT(*) AS c 
        FROM DWA_DimCategory 
        GROUP BY category_key 
        HAVING c > 1
    )) = 0 THEN 1 ELSE 0 END;

-- supplier
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT 
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimSupplier'),
    'PK duplicada (supplier_key)',
    (SELECT COUNT(*) FROM (
        SELECT supplier_key, COUNT(*) AS c 
        FROM DWA_DimSupplier 
        GROUP BY supplier_key 
        HAVING c > 1
    )),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT supplier_key, COUNT(*) AS c 
        FROM DWA_DimSupplier 
        GROUP BY supplier_key 
        HAVING c > 1
    )) = 0 THEN 1 ELSE 0 END;

-- shipper
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT 
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimShipper'),
    'PK duplicada (shipper_key)',
    (SELECT COUNT(*) FROM (
        SELECT shipper_key, COUNT(*) AS c 
        FROM DWA_DimShipper 
        GROUP BY shipper_key 
        HAVING c > 1
    )),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT shipper_key, COUNT(*) AS c 
        FROM DWA_DimShipper 
        GROUP BY shipper_key 
        HAVING c > 1
    )) = 0 THEN 1 ELSE 0 END;

-- date
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT 
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimDate'),
    'PK duplicada (date_key)',
    (SELECT COUNT(*) FROM (
        SELECT date_key, COUNT(*) AS c 
        FROM DWA_DimDate 
        GROUP BY date_key 
        HAVING c > 1
    )),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT date_key, COUNT(*) AS c 
        FROM DWA_DimDate 
        GROUP BY date_key 
        HAVING c > 1
    )) = 0 THEN 1 ELSE 0 END;

/*
=============================================
VALIDACION FACTS
=============================================
*/
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name='DWA_FactOrderDetails'),
    'FK product_id inexistente en DimProduct',
    (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimProduct p ON f.product_id = p.product_key
        WHERE p.product_key IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimProduct p ON f.product_id = p.product_key
        WHERE p.product_key IS NULL
    ) = 0 THEN 1 ELSE 0 END;

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name='DWA_FactOrderDetails'),
    'FK customer_id inexistente en DimCustomer',
    (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimCustomer c ON f.customer_id = c.customer_key
        WHERE c.customer_key IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimCustomer c ON f.customer_id = c.customer_key
        WHERE c.customer_key IS NULL
    ) = 0 THEN 1 ELSE 0 END;

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name='DWA_FactOrderDetails'),
    'FK employee_id inexistente en DimEmployee',
    (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimEmployee e ON f.employee_id = e.employee_key
        WHERE e.employee_key IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimEmployee e ON f.employee_id = e.employee_key
        WHERE e.employee_key IS NULL
    ) = 0 THEN 1 ELSE 0 END;

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name='DWA_FactOrderDetails'),
    'FK shipper_id inexistente en DimShipper',
    (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimShipper s ON f.shipper_id = s.shipper_key
        WHERE s.shipper_key IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimShipper s ON f.shipper_id = s.shipper_key
        WHERE s.shipper_key IS NULL
    ) = 0 THEN 1 ELSE 0 END;

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name='DWA_FactOrderDetails'),
    'FK order_date_key inexistente en DimDate',
    (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimDate d ON f.order_date_key = d.date_key
        WHERE d.date_key IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimDate d ON f.order_date_key = d.date_key
        WHERE d.date_key IS NULL
    ) = 0 THEN 1 ELSE 0 END;

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name='DWA_FactOrderDetails'),
    'FK shipped_date_key inexistente en DimDate (NULL permitido)',
    (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimDate d ON f.shipped_date_key = d.date_key
        WHERE f.shipped_date_key IS NOT NULL
          AND d.date_key IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(*)
        FROM DWA_FactOrderDetails f
        LEFT JOIN DWA_DimDate d ON f.shipped_date_key = d.date_key
        WHERE f.shipped_date_key IS NOT NULL
          AND d.date_key IS NULL
    ) = 0 THEN 1 ELSE 0 END;

-- INDICADORES DE RANGO
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_FactOrderDetails'),
    'quantity <= 0',
    (SELECT COUNT(*) FROM DWA_FactOrderDetails WHERE quantity <= 0),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM DWA_FactOrderDetails WHERE quantity <= 0) = 0 THEN 1 ELSE 0 END;

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_FactOrderDetails'),
    'discount fuera de rango',
    (SELECT COUNT(*) FROM DWA_FactOrderDetails WHERE discount < 0 OR discount > 1),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM DWA_FactOrderDetails WHERE discount < 0 OR discount > 1) = 0 THEN 1 ELSE 0 END;

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_FactOrderDetails'),
    'revenue negativo',
    (SELECT COUNT(*) FROM DWA_FactOrderDetails WHERE revenue < 0),
    0, 0,
    CASE WHEN (SELECT COUNT(*) FROM DWA_FactOrderDetails WHERE revenue < 0) = 0 THEN 1 ELSE 0 END;

