/* ============================================================
   002_01_create_DWA_model.sql
   MODELO DIMENSIONAL DEL DATA WAREHOUSE
   Capa: DWA_
   Basado en Northwind (versión SQLite) provista en la ingesta.
   ============================================================ */

/* ============================================================
   DIMENSION DE TIEMPO
   ============================================================ */

CREATE TABLE DWA_DimDate (
    date_key INTEGER PRIMARY KEY,     -- YYYYMMDD
    date TEXT,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    week INTEGER,
    day INTEGER,
    weekday INTEGER
);

/* ============================================================
   DIMENSION DE PRODUCTOS
   ============================================================ */

CREATE TABLE DWA_DimProduct (
    product_key INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER,
    product_name TEXT,
    category_id INTEGER,
    supplier_id INTEGER,
    unit_price REAL
);

-- !!!!! BORRAMOS PRICE BAND

/* ============================================================
   DIMENSION DE CLIENTES
   ============================================================ */

CREATE TABLE DWA_DimCustomer (
    customer_key INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id TEXT,
    company_name TEXT,
    country TEXT,
    region TEXT,
    segment TEXT      -- derivado: local, international, etc. BORRAR!!!!1
);

/* ============================================================
   DIMENSION DE EMPLEADOS
   ============================================================ */

CREATE TABLE DWA_DimEmployee (
    employee_key INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    title TEXT,
    reports_to INTEGER,         -- puede ser NULL (top-level)
    hire_date TEXT,
    birth_date TEXT,
    seniority_years INTEGER,    -- derivado
    age INTEGER                 -- derivado
);

/* ============================================================
   DIMENSION DE TRANSPORTISTAS
   ============================================================ */

CREATE TABLE DWA_DimShipper (
    shipper_key INTEGER PRIMARY KEY AUTOINCREMENT,
    shipper_id INTEGER,
    company_name TEXT
);

/* ============================================================
   DIMENSION DE CATEGORIAS
   ============================================================ */

CREATE TABLE DWA_DimCategory (
    category_key INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER,
    category_name TEXT
);

/* ============================================================
   DIMENSION DE PROVEEDORES
   ============================================================ */

CREATE TABLE DWA_DimSupplier (
    supplier_key INTEGER PRIMARY KEY AUTOINCREMENT,
    supplier_id INTEGER,
    company_name TEXT,
    country TEXT
);

/* ============================================================
   TABLA DE HECHOS: ORDER DETAILS
   ============================================================ */

CREATE TABLE DWA_FactOrderDetails (
    orderdetail_key INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER,
    product_id INTEGER,
    customer_id TEXT,
    employee_id INTEGER,
    shipper_id INTEGER,

    order_date_key INTEGER,       -- FK hacia DWA_DimDate
    shipped_date_key INTEGER,     -- FK hacia DWA_DimDate

    quantity INTEGER,
    unit_price REAL,
    discount REAL,
    
    revenue REAL                  -- derivado: quantity*unit_price*(1-discount)
);