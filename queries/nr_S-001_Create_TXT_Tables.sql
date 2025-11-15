/*
SCRIPT-ID: S-001
Nombre: S-001_Create_TXT_Tables
Descripción: Crea el conjunto de tablas de staging (prefijo TXT_) con todos los campos como TEXT para la ingesta inicial de CSV.
*/

-- 1. TXT_categories
DROP TABLE IF EXISTS TXT_categories;
CREATE TABLE TXT_categories (
    categoryID TEXT,
    categoryName TEXT,
    description TEXT,
    picture TEXT
);

-- 2. TXT_customers
DROP TABLE IF EXISTS TXT_customers;
CREATE TABLE TXT_customers (
    customerID TEXT,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    phone TEXT,
    fax TEXT
);

-- 3. TXT_employee_territories
DROP TABLE IF EXISTS TXT_employee_territories;
CREATE TABLE TXT_employee_territories (
    employeeid TEXT,
    territoryid TEXT
);

-- 4. TXT_employees
DROP TABLE IF EXISTS TXT_employees;
CREATE TABLE TXT_employees (
    employeeID TEXT,
    lastName TEXT,
    firstName TEXT,
    title TEXT,
    titleOfCourtesy TEXT,
    birthDate TEXT,
    hireDate TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    homePhone TEXT,
    extension TEXT,
    photo TEXT,
    notes TEXT,
    reportsTo TEXT,
    photoPath TEXT
);

-- 5. TXT_order_details
DROP TABLE IF EXISTS TXT_order_details;
CREATE TABLE TXT_order_details (
    orderID TEXT,
    productID TEXT,
    unitPrice TEXT,
    quantity TEXT,
    discount TEXT
);

-- 6. TXT_orders
DROP TABLE IF EXISTS TXT_orders;
CREATE TABLE TXT_orders (
    orderID TEXT,
    customerID TEXT,
    employeeID TEXT,
    orderDate TEXT,
    requiredDate TEXT,
    shippedDate TEXT,
    shipVia TEXT,
    freight TEXT,
    shipName TEXT,
    shipAddress TEXT,
    shipCity TEXT,
    shipRegion TEXT,
    shipPostalCode TEXT,
    shipCountry TEXT
);

-- 7. TXT_products
DROP TABLE IF EXISTS TXT_products;
CREATE TABLE TXT_products (
    productID TEXT,
    productName TEXT,
    supplierID TEXT,
    categoryID TEXT,
    quantityPerUnit TEXT,
    unitPrice TEXT,
    unitsInStock TEXT,
    unitsOnOrder TEXT,
    reorderLevel TEXT,
    discontinued TEXT
);

-- 8. TXT_regions
DROP TABLE IF EXISTS TXT_regions;
CREATE TABLE TXT_regions (
    regionid TEXT,
    regiondescription TEXT
);

-- 9. TXT_shippers
DROP TABLE IF EXISTS TXT_shippers;
CREATE TABLE TXT_shippers (
    shipperid TEXT,
    companyname TEXT,
    phone TEXT
);

-- 10. TXT_suppliers
DROP TABLE IF EXISTS TXT_suppliers;
CREATE TABLE TXT_suppliers (
    supplierID TEXT,
    companyName TEXT,
    contactName TEXT,
    contactTitle TEXT,
    address TEXT,
    city TEXT,
    region TEXT,
    postalCode TEXT,
    country TEXT,
    phone TEXT,
    fax TEXT,
    homePage TEXT
);

-- 11. TXT_territories
DROP TABLE IF EXISTS TXT_territories;
CREATE TABLE TXT_territories (
    territoryid TEXT,
    territorydescription TEXT,
    regionid TEXT
);