/*
======================================================================
 CREACIÓN DE TABLAS TMP
======================================================================
Descripción: Crea las tablas TMP (staging tipado).
Correcciones aplicadas:
- Estandarización a snake_case.
- Corregida sintaxis de FOREIGN KEY para SQLite.
- Corregidos tipos de datos (REAL, TEXT, INTEGER) según análisis.
- Corregidas Primary Keys (simples y compuestas).
*/
-- Las primeras 4 tablas TMP no dependen de nadie 
-- 1. TMP_regions
DROP TABLE IF EXISTS TMP_regions;
CREATE TABLE TMP_regions(
  region_id INTEGER PRIMARY KEY,
  region_description TEXT
);

-- 2. TMP_countries (SE AGREGA TMP PAISES)
DROP TABLE IF EXISTS TMP_countries;
CREATE TABLE TMP_countries(
  country_id INTEGER PRIMARY KEY AUTOINCREMENT,
  country_name TEXT NOT NULL UNIQUE
);

-- 3. TMP_categories
DROP TABLE IF EXISTS TMP_categories;
CREATE TABLE TMP_categories(
  category_id INTEGER PRIMARY KEY,
  category_name TEXT,
  description TEXT,
  picture BLOB -- 'picture' en Northwind es un objeto OLE (BLOB), no texto
);

-- 4. TMP_shippers
DROP TABLE IF EXISTS TMP_shippers;
CREATE TABLE TMP_shippers(
  shipper_id INTEGER PRIMARY KEY,
  company_name TEXT,
  phone TEXT
);


-- 5. TMP_employees 
--Dependencia self-referencial
DROP TABLE IF EXISTS TMP_employees;
CREATE TABLE TMP_employees(
  employee_id INTEGER PRIMARY KEY,
  last_name TEXT,
  first_name TEXT,
  title TEXT,
  title_of_courtesy TEXT,
  birth_date TEXT, -- Se mantiene como TEXT para la carga inicial
  hire_date TEXT,  -- Se mantiene como TEXT para la carga inicial
  address TEXT,
  city TEXT, 
  region TEXT,
  postal_code TEXT,
 -- country TEXT,              -- << ELIMINADA >>
  country_id INTEGER,           -- << AGREGADA >>
  home_phone TEXT,
  extension TEXT,
  photo BLOB,
  notes TEXT,
  reports_to INTEGER, -- FK a sí mismo (jefe)
  photo_path TEXT,
  FOREIGN KEY(reports_to) REFERENCES TMP_employees(employee_id)
);


-- 6. TMP_territories
DROP TABLE IF EXISTS TMP_territories;
CREATE TABLE TMP_territories(
  territory_id TEXT PRIMARY KEY,
  territory_description TEXT,
  region_id INTEGER,
  FOREIGN KEY(region_id) REFERENCES TMP_regions(region_id)
);



--7. TMP_suppliers (MODIFICADA-Depende de: TMP_countries)
DROP TABLE IF EXISTS TMP_suppliers;
CREATE TABLE TMP_suppliers(
  supplier_id INTEGER PRIMARY KEY,
  company_name TEXT,
  contact_name TEXT,
  contact_title TEXT,
  address TEXT,
  city TEXT,
  region TEXT,
  postal_code TEXT,
  -- country TEXT,              -- << ELIMINADA >>
  country_id INTEGER,           -- << AGREGADA >>
  phone TEXT,
  fax TEXT,
  home_page TEXT,
  FOREIGN KEY(country_id) REFERENCES TMP_countries(country_id) -- NUEVA FK
);

-- 8. TMP_customers (MODIFICADA-Depende de: TMP_countries)
DROP TABLE IF EXISTS TMP_customers;
CREATE TABLE TMP_customers(
  customer_id TEXT PRIMARY KEY,
  company_name TEXT,
  contact_name TEXT,
  contact_title TEXT,
  address TEXT,
  city TEXT,
  region TEXT,
  postal_code TEXT,
  -- country TEXT,              -- << ELIMINADA >>
  country_id INTEGER,           -- << AGREGADA >>
  phone TEXT,
  fax TEXT,
  FOREIGN KEY(country_id) REFERENCES TMP_countries(country_id) -- NUEVA FK
);




-- 9. TMP_employee_territories  (Depende de: TMP_employees, TMP_territories)
DROP TABLE IF EXISTS TMP_employee_territories;
CREATE TABLE TMP_employee_territories(
  employee_id INTEGER,
  territory_id TEXT,
  PRIMARY KEY(employee_id, territory_id),
  FOREIGN KEY(employee_id) REFERENCES TMP_employees(employee_id),
  FOREIGN KEY(territory_id) REFERENCES TMP_territories(territory_id)
);



-- 10. TMP_products  (Depende de: TMP_suppliers, TMP_categories)
DROP TABLE IF EXISTS TMP_products;
CREATE TABLE TMP_products(
  product_id INTEGER PRIMARY KEY,
  product_name TEXT,
  supplier_id INTEGER,
  category_id INTEGER,
  quantity_per_unit TEXT, -- Correcto: '24 - 12 oz bottles' es TEXT
  unit_price REAL,        -- Correcto: Es un decimal
  units_in_stock INTEGER,
  units_on_order INTEGER,
  reorder_level INTEGER,  -- Corregido: Es un número
  discontinued INTEGER,   -- Corregido: Es un booleano (0 o 1)
  FOREIGN KEY(supplier_id) REFERENCES TMP_suppliers(supplier_id),
  FOREIGN KEY(category_id) REFERENCES TMP_categories(category_id)
);



-- 11. TMP_orders (MODIFICADA-Depende de: TMP_customers, TMP_employees, TMP_shippers, TMP_countries)
DROP TABLE IF EXISTS TMP_orders;
CREATE TABLE TMP_orders(
  order_id INTEGER PRIMARY KEY,
  customer_id TEXT,
  employee_id INTEGER,
  order_date TEXT,
  required_date TEXT,
  shipped_date TEXT,
  ship_via INTEGER,
  freight REAL,
  ship_name TEXT,
  ship_address TEXT,
  ship_city TEXT,
  ship_region TEXT,
  ship_postal_code TEXT,
  -- ship_country TEXT,            -- << ELIMINADA >>
  ship_country_id INTEGER,         -- << AGREGADA >>
  FOREIGN KEY(customer_id) REFERENCES TMP_customers(customer_id),
  FOREIGN KEY(employee_id) REFERENCES TMP_employees(employee_id),
  FOREIGN KEY(ship_via) REFERENCES TMP_shippers(shipper_id),
  FOREIGN KEY(ship_country_id) REFERENCES TMP_countries(country_id) -- NUEVA FK
);

-- 12. TMP_order_details (Depende de: TMP_orders, TMP_products)
DROP TABLE IF EXISTS TMP_order_details;
CREATE TABLE TMP_order_details(
  order_id INTEGER,
  product_id INTEGER,
  unit_price REAL,    -- Correcto: Es un decimal
  quantity INTEGER,
  discount REAL,      -- Correcto: Es un decimal (porcentaje)
  PRIMARY KEY(order_id, product_id),
  FOREIGN KEY(order_id) REFERENCES TMP_orders(order_id),
  FOREIGN KEY(product_id) REFERENCES TMP_products(product_id)

);

