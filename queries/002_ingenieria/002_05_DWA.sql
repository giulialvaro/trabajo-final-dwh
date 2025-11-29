/* ============================================================
   Capa ING temporal a ingestar
   ============================================================ */

CREATE TABLE IF NOT EXISTS ING_Employees AS
SELECT * FROM TMP_employees;

CREATE TABLE IF NOT EXISTS ING_Products AS
SELECT * FROM TMP_products;

CREATE TABLE IF NOT EXISTS ING_Customers AS
SELECT * FROM TMP_customers;

CREATE TABLE IF NOT EXISTS ING_Shippers AS
SELECT * FROM TMP_shippers;

CREATE TABLE IF NOT EXISTS ING_Categories AS
SELECT * FROM TMP_categories;

CREATE TABLE IF NOT EXISTS ING_Suppliers AS
SELECT * FROM TMP_suppliers;

CREATE TABLE IF NOT EXISTS ING_Orders AS
SELECT * FROM TMP_orders;

CREATE TABLE IF NOT EXISTS ING_OrderDetails AS
SELECT * FROM TMP_order_details;


/* ============================================================
   Población de tablas
   ============================================================ */
INSERT INTO DWA_DimDate (
   date, year, quarter, month, week, day, weekday
)
SELECT
    order_date,
    CAST(strftime('%Y', order_date) AS INTEGER),
    CAST((strftime('%m', order_date)-1)/3 + 1 AS INTEGER),
    CAST(strftime('%m', order_date) AS INTEGER),
    CAST(strftime('%W', order_date) AS INTEGER),
    CAST(strftime('%d', order_date) AS INTEGER),
    CAST(strftime('%w', order_date) AS INTEGER)
FROM ING_Orders
WHERE order_date IS NOT NULL
GROUP BY order_date;


INSERT INTO DWA_DimEmployee (
    employee_id, first_name, last_name, title,
    reports_to, hire_date, birth_date,
    seniority_years, age
)
SELECT
    employee_id,
    first_name,
    last_name,
    title,
    reports_to,
    hire_date,
    birth_date,
    CAST((julianday('now') - julianday(hire_date)) / 365 AS INTEGER) AS seniority_years,
    CAST((julianday('now') - julianday(birth_date)) / 365 AS INTEGER) AS age
FROM ING_Employees;

INSERT INTO DWA_DimCustomer (
    customer_id, company_name, country, region, segment
)
SELECT
    customer_id,
    company_name,
    country,
    region,
    CASE 
        WHEN country = 'USA' THEN 'Local'
        ELSE 'International'
    END AS segment
FROM ING_Customers;


INSERT INTO DWA_DimProduct (
    product_id, product_name, category_id, supplier_id,
    unit_price
)
SELECT
    product_id,
    product_name,
    category_id,
    supplier_id,
    unit_price
FROM ING_Products;

INSERT INTO DWA_DimCategory (category_id, category_name)
SELECT category_id, category_name
FROM ING_Categories;

INSERT INTO DWA_DimSupplier (supplier_id, company_name, country)
SELECT supplier_id, company_name, country
FROM ING_Suppliers;

INSERT INTO DWA_DimShipper (shipper_id, company_name)
SELECT shipper_id, company_name
FROM ING_Shippers;

INSERT INTO DWA_FactOrderDetails (
    order_id, product_id, customer_id, employee_id, shipper_id,
    order_date_key, shipped_date_key,
    quantity, unit_price, discount, revenue
)
SELECT
    od.order_id,
    od.product_id,
    o.customer_id,
    o.employee_id,
    o.ship_via,

    CAST(strftime('%Y%m%d', o.order_date) AS INTEGER),
    CAST(strftime('%Y%m%d', o.shipped_date) AS INTEGER),

    od.quantity,
    od.unit_price,
    od.discount,

    od.quantity * od.unit_price * (1 - od.discount) AS revenue
FROM ING_OrderDetails od
JOIN ING_Orders o ON od.order_id = o.order_id;






