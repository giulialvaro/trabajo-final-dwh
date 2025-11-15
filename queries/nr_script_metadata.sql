/* Script de Creación de Tablas de Metadata
Este script crea la tabla SCRIPT_INVENTORY para rastrear los scripts y SCRIPT_LOG para registrar cada ejecución. */

-- 1. Tabla para el inventario de scripts
CREATE TABLE IF NOT EXISTS SCRIPT_INVENTORY (
    ScriptID INTEGER PRIMARY KEY AUTOINCREMENT,
    ScriptName TEXT NOT NULL UNIQUE,
    Description TEXT,
    DateCreated DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabla para el log de ejecuciones
CREATE TABLE IF NOT EXISTS SCRIPT_LOG (
    LogID INTEGER PRIMARY KEY AUTOINCREMENT,
    ScriptID INTEGER,
    StartTime DATETIME,
    EndTime DATETIME,
    Result TEXT, -- Ej: 'Success', 'Failure', 'Running'
    ErrorMessage TEXT, -- Mensaje de error si Result = 'Failure'
    RowsAffected INTEGER DEFAULT 0,
    FOREIGN KEY (ScriptID) REFERENCES SCRIPT_INVENTORY(ScriptID)
);