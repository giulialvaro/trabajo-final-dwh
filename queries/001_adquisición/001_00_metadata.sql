/* Script de Creación de Tablas de Metadata
Este script crea la tabla SCRIPT_INVENTORY para rastrear los scripts 
y SCRIPT_LOG para registrar cada ejecución.

Modificaciones:
- Se añade un CHECK constraint a SCRIPT_LOG.Result para estandarizar los estados.
- Se añade un índice en SCRIPT_LOG(ScriptID, StartTime) para optimizar consultas.
*/

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
    
    -- Se añade el CHECK para estandarizar los estados permitidos
    Result TEXT CHECK(Result IN ('Running', 'Success', 'Failure')), 
    
    ErrorMessage TEXT, -- Mensaje de error si Result = 'Failure'
    RowsAffected INTEGER DEFAULT 0,
    FOREIGN KEY (ScriptID) REFERENCES SCRIPT_INVENTORY(ScriptID)
);

-- 3. Índice para consultas rápidas en SCRIPT_LOG
-- Añadido según la recomendación para optimizar búsquedas por script y fecha
CREATE INDEX IF NOT EXISTS idx_script_log_script_time
ON SCRIPT_LOG (ScriptID, StartTime);