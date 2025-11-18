/*
======================================================================
 SCRIPT: nr_script_registro_logs.sql (Plantilla de Uso)
======================================================================
Este script contiene los bloques de código para:
1. Poblar el inventario (se ejecuta una sola vez).
2. Registrar el INICIO y FIN de una ejecución de script.
*/

-- =====================================================================
-- BLOQUE 1: POBLAR EL INVENTARIO (Ejecutar 1 sola vez)
-- =====================================================================
-- Asegúrate de que tus scripts estén registrados en el inventario.
-- 'INSERT OR IGNORE' evita errores si ya existen.

INSERT OR IGNORE INTO SCRIPT_INVENTORY (ScriptName, Description)
VALUES ('script_metadata', 'creación de las tablas de metadata y logs');

INSERT OR IGNORE INTO SCRIPT_INVENTORY (ScriptName, Description)
VALUES ('script_registro_logs', 'guardar cada transacción');

INSERT OR IGNORE INTO SCRIPT_INVENTORY (ScriptName, Description)
VALUES ('S-001_Create_TXT_Tables', 'creación del conjunto de tablas TXT');


-- =====================================================================
-- BLOQUE 2: PLANTILLA DE EJECUCIÓN DE LOG
-- (Para loguear la ejecución de 'S-001_Create_TXT_Tables')
-- =====================================================================

-- (Asumimos que el ScriptID de 'S-001_Create_TXT_Tables' es 3)

-- PASO 1: ANTES de ejecutar tu script principal, corre esto:
-- (Esto crea el registro 'Running')
INSERT INTO SCRIPT_LOG (ScriptID, StartTime, Result)
VALUES (3, CURRENT_TIMESTAMP, 'Running');


-- PASO 2: (...)
--     AQUÍ EJECUTAS TU SCRIPT PRINCIPAL
--     (Ej: corres el archivo S-001_Create_TXT_Tables.sql)
-- (...)


-- PASO 3: DESPUÉS de ejecutar, corre UNO de los siguientes bloques
-- (Nunca ambos)

-- OPCIÓN A: Si el PASO 2 fue EXITOSO, corre este bloque:
UPDATE SCRIPT_LOG
SET EndTime = CURRENT_TIMESTAMP,
    Result = 'Success',
    RowsAffected = 100 -- (Opcional: N° de filas)
WHERE 
    LogID = (SELECT MAX(LogID) FROM SCRIPT_LOG WHERE ScriptID = 3);


-- OPCIÓN B: Si el PASO 2 FALLÓ, corre este bloque:
UPDATE SCRIPT_LOG
SET EndTime = CURRENT_TIMESTAMP,
    Result = 'Failure',
    ErrorMessage = 'Error: la tabla TXT_categories ya existe' -- (El error real)
WHERE 
    LogID = (SELECT MAX(LogID) FROM SCRIPT_LOG WHERE ScriptID = 3);