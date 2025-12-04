DROP TABLE IF EXISTS SPM_FactSales;
CREATE TABLE SPM_FactSales AS
SELECT 
    /* --- KEYS --- */
    f.orderdetail_key,
    f.order_id,
    f.product_id,
    f.customer_id,
    f.employee_id,
    f.shipper_id,
    f.order_date_key,
    f.shipped_date_key,

    /* --- METRICAS BASE --- */
    f.quantity,
    f.unit_price,
    f.discount,
    f.revenue,

    /* --- PRODUCTO & CATEGORIA --- */
    p.product_name,
    c.category_name,
    p.unit_price AS list_price,
    p.supplier_id,
    s.company_name AS supplier_name,
    s.country AS supplier_country,

    /* --- CUSTOMERS --- */
    cust.company_name AS customer_name,
    cust.region AS customer_region,
    cust.country AS customer_country,

    /* --- PAISES (WORLD DATA) --- */
    co.latitude,
    co.longitude,

    /* --- DATES (ORDER & SHIPPED) --- */
    od.date AS order_date,
    od.year AS order_year,
    od.month AS order_month,
    od.quarter AS order_quarter,
    od.weekday AS order_weekday,

    sd.date AS shipped_date,
    sd.year AS shipped_year,
    sd.month AS shipped_month,
    sd.quarter AS shipped_quarter,
    sd.weekday AS shipped_weekday,

    /* --- SHIPPING DELAY (en días) --- */
    CASE 
        WHEN f.shipped_date_key IS NOT NULL 
        THEN (f.shipped_date_key - f.order_date_key)
        ELSE NULL
    END AS ship_delay_days

FROM DWA_FactOrderDetails f

LEFT JOIN DWA_DimProduct p
    ON p.product_id = f.product_id

LEFT JOIN DWA_DimCategory c
    ON c.category_id = p.category_id

LEFT JOIN DWA_DimSupplier s
    ON s.supplier_id = p.supplier_id

LEFT JOIN DWA_DimCustomer cust
    ON cust.customer_key = f.customer_id

LEFT JOIN DWA_DimCountry co
    ON LOWER(TRIM(cust.country)) = LOWER(TRIM(co.country))

LEFT JOIN DWA_DimDate od
    ON od.date_key = f.order_date_key

LEFT JOIN DWA_DimDate sd
    ON sd.date_key = f.shipped_date_key

LEFT JOIN DWA_DimShipper sh
    ON sh.shipper_id = f.shipper_id;