-- actualizacion desde tmp2_ a dwa_

-- 1) dwa_dimcustomer
insert into dwa_dimcustomer (customer_id, company_name, country, region, segment)
SELECT
    customer_id,
    company_name,
    country,
    region,
    CASE WHEN country = 'USA' THEN 'Local' ELSE 'International' END AS segment
from tmp2_customers

-- 2) dwa_factorderdetails
INSERT INTO dwa_factorderdetails (
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
FROM tmp2_Order_Details od
JOIN tmp2_orders o ON od.order_id = o.order_id;

-- 3) dwa_dimproduct
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
FROM tmp2_products;

-- identificamos que en la inserción de los nuevos datos, aparecen customer_id con codigo erroneo, entonces procedemos a eliminarlos del dwa
select * from dwa_factorderdetails where order_id = 11078
delete from dwa_factorderdetails where order_id = 11078

