/* ============================
   WORLD DATA VALIDATIONS DQM
   ============================ */

INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimCustomer'),
    'Country inexistente en DWA_DimCountry (Customer)',
    (
        SELECT COUNT(DISTINCT c.country)
        FROM DWA_DimCustomer c
        LEFT JOIN DWA_DimCountry d ON c.country = d.country
        WHERE d.country IS NULL
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(DISTINCT c.country)
        FROM DWA_DimCustomer c
        LEFT JOIN DWA_DimCountry d ON c.country = d.country
        WHERE d.country IS NULL
    ) = 0 THEN 1 ELSE 0 END;


-- ENCONTRAMOS 3 PAISES INEXISTENTES
SELECT DISTINCT c.country
FROM DWA_DimCustomer c
LEFT JOIN DWA_DimCountry d ON c.country = d.country
WHERE d.country IS NULL;

-- TABLA MAPPING
CREATE TABLE IF NOT EXISTS DIM_CountryMapping (
    source_country TEXT PRIMARY KEY,
    standardized_country TEXT
);

INSERT INTO DIM_CountryMapping (source_country, standardized_country)
VALUES 
    ('UK', 'United Kingdom'),
    ('USA', 'United States'),
    ('Ireland', 'Republic of Ireland');

-- ACTUALIZAMOS CUSTOMERS PARA Q LOS PAISES ESTÉN BIEN
UPDATE DWA_DimCustomer
SET country = (
    SELECT standardized_country
    FROM DIM_CountryMapping m
    WHERE m.source_country = DWA_DimCustomer.country
)
WHERE country IN (SELECT source_country FROM DIM_CountryMapping);

-- CHEQUEAMOS DENUEVO
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id FROM DQM_Entities WHERE table_name='DWA_DimCustomer'),
    'Country inexistente en DWA_DimCountry (Customer)',
    (
        SELECT COUNT(DISTINCT c.country)
        FROM DWA_DimCustomer c
        LEFT JOIN DWA_DimCountry d ON c.country = d.country
        WHERE d.country IS NULL
    ),
    0,0,
    CASE WHEN (
        SELECT COUNT(DISTINCT c.country)
        FROM DWA_DimCustomer c
        LEFT JOIN DWA_DimCountry d ON c.country = d.country
        WHERE d.country IS NULL
    ) = 0 THEN 1 ELSE 0 END;



/* ============================
    SUPPLIERS
   ============================ */
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name='DWA_DimSupplier'),
    'Country inexistente en DWA_DimCountry (Supplier)',
    (
        SELECT COUNT(DISTINCT s.country)
        FROM DWA_DimSupplier s
        LEFT JOIN DWA_DimCountry c ON s.country = c.country
        WHERE c.country IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(DISTINCT s.country)
        FROM DWA_DimSupplier s
        LEFT JOIN DWA_DimCountry c ON s.country = c.country
        WHERE c.country IS NULL
    ) = 0 THEN 1 ELSE 0 END;



-- ENCONTRAMOS W PAISES INEXISTENTES
SELECT DISTINCT s.country
FROM DWA_DimSupplier s
LEFT JOIN DWA_DimCountry d ON s.country = d.country
WHERE d.country IS NULL;

-- UPDATE
UPDATE DWA_DimSupplier
SET country = (
    SELECT standardized_country
    FROM DIM_CountryMapping m
    WHERE m.source_country = DWA_DimSupplier.country
)
WHERE country IN (SELECT source_country FROM DIM_CountryMapping);

-- CHEQUEAMOS DENUEVO
INSERT INTO DQM_Indicators (
    dqm_entity_id, indicator_name, indicator_value,
    threshold_min, threshold_max, passed
)
SELECT
    (SELECT dqm_entity_id 
     FROM DQM_Entities 
     WHERE table_name='DWA_DimSupplier'),
    'Country inexistente en DWA_DimCountry (Supplier)',
    (
        SELECT COUNT(DISTINCT s.country)
        FROM DWA_DimSupplier s
        LEFT JOIN DWA_DimCountry c ON s.country = c.country
        WHERE c.country IS NULL
    ),
    0, 0,
    CASE WHEN (
        SELECT COUNT(DISTINCT s.country)
        FROM DWA_DimSupplier s
        LEFT JOIN DWA_DimCountry c ON s.country = c.country
        WHERE c.country IS NULL
    ) = 0 THEN 1 ELSE 0 END;
