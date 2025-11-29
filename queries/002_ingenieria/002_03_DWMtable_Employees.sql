CREATE TABLE IF NOT EXISTS DWM_Employee (
    employee_scd_key INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER,              -- natural key

    first_name TEXT,
    last_name TEXT,
    title TEXT,
    reports_to INTEGER,
    hire_date TEXT,
    birth_date TEXT,
    seniority_years INTEGER,
    age INTEGER,

    valid_from TEXT,
    valid_to TEXT,
    is_current INTEGER                -- 1 = activo, 0 = histórico
);

INSERT INTO DWM_Employee (
    employee_id,
    first_name,
    last_name,
    title,
    reports_to,
    hire_date,
    birth_date,
    seniority_years,
    age,
    valid_from,
    valid_to,
    is_current
)
SELECT 
    employee_id,
    first_name,
    last_name,
    title,
    reports_to,
    hire_date,
    birth_date,
    seniority_years,
    age,
    DATE('now') AS valid_from,
    NULL AS valid_to,
    1 AS is_current
FROM DWA_DimEmployee;

/* ------------------------------------------------------------
   ACTUALIZACIÓN (INGESTA 2)
   ------------------------------------------------------------ */

/* ------------------------------------------------------------
   1) Detectar cambios entre DWA y la versión actual de DWM
   ------------------------------------------------------------ */

WITH changes AS (
    SELECT 
        d.employee_id AS emp_id,
        d.first_name,
        d.last_name,
        d.title,
        d.reports_to,
        d.hire_date,
        d.birth_date,
        d.seniority_years,
        d.age
    FROM DWA_DimEmployee d
    JOIN DWM_Employee dwm
        ON d.employee_id = dwm.employee_id
       AND dwm.is_current = 1
    WHERE 
         (d.first_name        <> dwm.first_name OR (d.first_name IS NULL AND dwm.first_name IS NOT NULL))
      OR (d.last_name         <> dwm.last_name  OR (d.last_name IS NULL AND dwm.last_name IS NOT NULL))
      OR (d.title             <> dwm.title      OR (d.title IS NULL AND dwm.title IS NOT NULL))
      OR (d.reports_to        <> dwm.reports_to)
      OR (d.hire_date         <> dwm.hire_date)
      OR (d.birth_date        <> dwm.birth_date)
      OR (d.seniority_years   <> dwm.seniority_years)
      OR (d.age               <> dwm.age)
)

/* ------------------------------------------------------------
   2) Cerrar versión actual en DWM (is_current=0)
   ------------------------------------------------------------ */
UPDATE DWM_Employee
SET 
    valid_to = DATE('now'),
    is_current = 0
WHERE employee_id IN (SELECT emp_id FROM changes)
  AND is_current = 1;

/* ------------------------------------------------------------
   3) Insertar la nueva versión corregida/actualizada
   ------------------------------------------------------------ */
INSERT INTO DWM_Employee (
    employee_id,
    first_name,
    last_name,
    title,
    reports_to,
    hire_date,
    birth_date,
    seniority_years,
    age,
    valid_from,
    valid_to,
    is_current
)
SELECT
    emp_id,
    first_name,
    last_name,
    title,
    reports_to,
    hire_date,
    birth_date,
    seniority_years,
    age,
    DATE('now') AS valid_from,
    NULL AS valid_to,
    1 AS is_current
FROM changes;






