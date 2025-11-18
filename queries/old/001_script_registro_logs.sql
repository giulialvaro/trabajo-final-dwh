-- ====================================
-- TP Intro a Datawarehouring 
-- Etapa 1 - Adquisición
-- ====================================

/* Registro de metadata y logs
este script permite tener un listado de todos los scripts ejecutados en el proceso en INVENTORY
y guardar cada paso en LOG
 */
-- select * from SCRIPT_INVENTORY

INSERT INTO SCRIPT_INVENTORY (ScriptName, Description)
VALUES ('script_metadata', 'creación de las tablas de metadata y logs'); -- id = 1

INSERT INTO SCRIPT_INVENTORY (ScriptName, Description)
VALUES ('script_registro_logs', 'guardar cada transacción');

INSERT INTO SCRIPT_INVENTORY (ScriptName, Description)
VALUES ('S-001_Create_TXT_Tables', 'creación del conjunto de tablas TXT');

------------------------------------------

-- LOG de creación de tablas TXT
SELECT * FROM SCRIPT_LOG
-- 1) fijarse cual es el ID del script, en este caso 3
-- 2) Antes de ejecutar el script S-001_Create_TXT_Tables, correr el log:

INSERT INTO SCRIPT_LOG (ScriptID, StartTime, Result)
VALUES (3, CURRENT_TIMESTAMP, 'Running');

-- 3) EJECUTAR EL SCRIPT

-- 4a) DESPUÉS de una ejecución EXITOSA:
UPDATE SCRIPT_LOG
SET EndTime = CURRENT_TIMESTAMP,
    Result = 'Success'
WHERE LogID = 1; -- Usas el ID que guardaste


-- 4b) DESPUÉS de una ejecución FALLIDA:
UPDATE SCRIPT_LOG
SET EndTime = CURRENT_TIMESTAMP,
    Result = 'Failure',
    ErrorMessage = 'Error: la tabla TXT_categories ya existe' -- (ejemplo de error)
WHERE LogID = 101;

