-- VALIDACIONES TMP2 CUSTOMERS
-- PK duplicadas
SELECT customer_id, COUNT(*) AS repeticiones
FROM TMP2_Customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- nulls
SELECT *
FROM TMP2_Customers
WHERE customer_id IS NULL
   OR company_name IS NULL;

-- paises
SELECT c.country
FROM TMP2_Customers c
LEFT JOIN DWA_DimCountry d ON d.country = c.country
WHERE d.country IS NULL AND c.country IS NOT NULL
GROUP BY c.country;

-- VALIDACIONES TPM2 PRODUCTS
-- pk duplicadas
SELECT product_id, COUNT(*)
FROM TMP2_Products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- nulls
SELECT *
FROM TMP2_Products
WHERE product_name IS NULL
   OR unit_price IS NULL;

-- fk cat inexistente
SELECT p.category_id
FROM TMP2_Products p
LEFT JOIN DWA_DimCategory c ON c.category_id = p.category_id
WHERE c.category_id IS NULL;

-- fk supplier inexistente
SELECT p.supplier_id
FROM TMP2_Products p
LEFT JOIN DWA_DimSupplier s ON s.supplier_id = p.supplier_id
WHERE s.supplier_id IS NULL;

-- unit price fuera de rango
SELECT *
FROM TMP2_Products
WHERE unit_price <= 0;

-- VALIDACIONES TMP2 ORDERS
-- pk duplicadas
SELECT order_id, COUNT(*)
FROM TMP2_Orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- fechasinvalidas
SELECT *
FROM TMP2_Orders
WHERE order_date NOT LIKE '____-__-__'
   OR required_date NOT LIKE '____-__-__'
   OR (shipped_date IS NOT NULL AND shipped_date NOT LIKE '____-__-__');

-- (update de 6 fechas)
UPDATE TMP2_Orders
SET order_date = substr(order_date, 1, 10)
WHERE order_date IS NOT NULL;

UPDATE TMP2_Orders
SET required_date = substr(required_date, 1, 10)
WHERE required_date IS NOT NULL;

UPDATE TMP2_Orders
SET shipped_date = substr(shipped_date, 1, 10)
WHERE shipped_date IS NOT NULL AND shipped_date <> '';

-- fk customer inexistente
SELECT o.customer_id
FROM TMP2_Orders o
LEFT JOIN DWA_DimCustomer c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

--(HAY 1 CUSTOMER ID ERRONEO, ELIMINAMOS EN EL CSV)

-- fk employee inexistente
SELECT o.employee_id
FROM TMP2_Orders o
LEFT JOIN DWA_DimEmployee e ON e.employee_id = o.employee_id
WHERE e.employee_id IS NULL;

-- fk shipper inexistente
SELECT o.ship_via
FROM TMP2_Orders o
LEFT JOIN DWA_DimShipper s ON s.shipper_id = o.ship_via
WHERE s.shipper_id IS NULL;

-- VALIDACIONES TMP2 ORDER DETAILS
-- pk duplicadas
SELECT order_id, product_id, COUNT(*)
FROM TMP2_order_details
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- fk prod inex
SELECT d.product_id
FROM TMP2_order_details d
LEFT JOIN DWA_DimProduct p ON p.product_id = d.product_id
WHERE p.product_id IS NULL;

-- FK ORDER INEX
SELECT d.order_id
FROM TMP2_order_details d
LEFT JOIN TMP2_Orders o ON o.order_id = d.order_id
WHERE o.order_id IS NULL;

-- discount en rango
SELECT *
FROM TMP2_order_details
WHERE discount < 0 OR discount > 1;









