-- 5) Crear el soporte para la Metadata y describir las entidades
-- La metadata debe responder: qué tablas existen, qué campos tiene cada una, tipos de datos, longitudes, en qué capa, relaciones entre tablas

-- Diseño del paquete METADATA (MET_)
-- A) Diccionario de entidades: Qué tablas existen, en qué capa están (TXT, TMP, ING, DWA, etc.), Para qué sirven
-- B) Diccionario de campos: Nombre, Tipo, Si es PK o FK, Si puede ser nulo, A qué tabla pertenece
-- C) Procesos: Nombre del proceso, Tipo (ingesta, validación, carga, etc.)
-- D) Logs de ejecución de procesos: Inicio, fin, Resultado, Filas procesadas, filas rechazadas, mensaje --> esto lo tenemos en parte en las tablas _LOG

-- Crear tabla MET_Entity
CREATE TABLE IF NOT EXISTS MET_Entity (
    entity_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    entity_name    TEXT NOT NULL,            -- nombre lógico: customers, products, etc
    entity_layer   TEXT NOT NULL,            -- TXT, TMP, ING, DWA, DQM, etc
    business_desc  TEXT,                     -- descripción funcional
    is_active      INTEGER DEFAULT 1,        -- 1=activa, 0=baja lógica
    created_at     TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla MET_Field
CREATE TABLE IF NOT EXISTS MET_Field (
    field_id           INTEGER PRIMARY KEY AUTOINCREMENT,
    entity_id          INTEGER NOT NULL,
    field_name         TEXT NOT NULL,
    data_type          TEXT NOT NULL,        -- TEXT, INTEGER, REAL, DATE, etc
    nullable_flag      INTEGER DEFAULT 1,    -- 0 = NOT NULL
    is_pk              INTEGER DEFAULT 0,    
    is_fk              INTEGER DEFAULT 0,
    fk_reference_table TEXT,                -- si aplica
    field_desc         TEXT,
    created_at         TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(entity_id) REFERENCES MET_Entity(entity_id)
);

-- Crear tabla MET_Process
CREATE TABLE IF NOT EXISTS MET_Process (
    process_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    process_name    TEXT NOT NULL,        -- VALIDATE_TXT_CUSTOMERS
    process_type    TEXT NOT NULL,        -- VALIDATION, LOAD, PROFILE, DQM, etc.
    description     TEXT,
    created_at      TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla MET_Process_Run (LOG de ejecución)
CREATE TABLE IF NOT EXISTS MET_Process_Run (
    run_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    process_id      INTEGER NOT NULL,
    start_time      TEXT DEFAULT CURRENT_TIMESTAMP,
    end_time        TEXT,
    status          TEXT,                 -- OK / ERROR
    rows_processed  INTEGER,
    rows_rejected   INTEGER,
    detail_message  TEXT,
    FOREIGN KEY(process_id) REFERENCES MET_Process(process_id)
);

-- INSERTS para todas las entidades (TXT y TMP)
-- ======================
-- METADATA: ENTIDADES
-- ======================
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_categories', 'TXT', 'Raw categories data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_customers', 'TXT', 'Raw customers data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_employee_territories', 'TXT', 'Raw employee territories data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_employees', 'TXT', 'Raw employees data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_order_details', 'TXT', 'Raw order details data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_orders', 'TXT', 'Raw orders data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_products', 'TXT', 'Raw products data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_regions', 'TXT', 'Raw regions data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_shippers', 'TXT', 'Raw shippers data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_supliers', 'TXT', 'Raw suppliers data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TXT_territories', 'TXT', 'Raw territories data');

INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_categories', 'TMP', 'Clean categories data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_customers', 'TMP', 'Clean customers data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_employee_territories', 'TMP', 'Clean employee territories data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_employees', 'TMP', 'Clean employees data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_order_details', 'TMP', 'Clean order details data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_orders', 'TMP', 'Clean orders data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_products', 'TMP', 'Clean products data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_regions', 'TMP', 'Clean regions data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_shippers', 'TMP', 'Clean shippers data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_supliers', 'TMP', 'Clean suppliers data');
INSERT INTO MET_Entity (entity_name, entity_layer, business_desc) VALUES ('TMP_territories', 'TMP', 'Clean territories data');

select * from MET_Entity

