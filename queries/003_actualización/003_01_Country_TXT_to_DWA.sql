/* ============================
   WORLD DATA TXT
   ============================ */

CREATE TABLE IF NOT EXISTS TXT_WorldData (
    COUNTRY TEXT,
    DENSITY TEXT,
    Abbreviation TEXT, 
    Agricultural_land TEXT,
    "Land Area(Km2)" TEXT,
    "Armed Forces size" TEXT,
    "Birth Rate" TEXT,
    "Calling Code" TEXT,
    "Capital/Major City" TEXT,
    "Co2-Emissions" TEXT,
    CPI TEXT,
    "CPI Change (%)" TEXT,
    "Currency-Code" TEXT,
    "Fertility Rate" TEXT,
    "Forested Area (%)" TEXT,
    "Gasoline Price" TEXT,
    GDP TEXT,
    "Gross primary education enrollment (%)" TEXT,
    "Gross tertiary education enrollment (%)" TEXT,
    "Infant mortality" TEXT,
    "Largest city" TEXT,
    "Life expectancy" TEXT,
    "Maternal mortality ratio" TEXT,
    "Minimum wage" TEXT,
    "Official language" TEXT,
    "Out of pocket health expenditure" TEXT,
    "Physicians per thousand" TEXT,
    Population TEXT,
    "Population: Labor force participation (%)" TEXT,
    "Tax revenue (%)" TEXT,
    "Total tax rate" TEXT,
    "Unemployment rate" TEXT,
    Urban_population TEXT,
    Latitude TEXT,
    Longitude TEXT
);


/* ============================
   TMP_WorldData – tipada
   ============================ */

CREATE TABLE IF NOT EXISTS TMP_WorldData (
    country TEXT PRIMARY KEY,
    density REAL,
    land_area_km2 INTEGER,
    armed_forces_size INTEGER,
    birth_rate REAL,
    calling_code TEXT,
    capital TEXT,
    co2_emissions REAL,
    cpi REAL,
    cpi_change_pct REAL,
    currency_code TEXT,
    fertility_rate REAL,
    forested_area_pct REAL,
    gasoline_price REAL,
    gdp REAL,
    gross_primary_enrollment_pct REAL,
    gross_tertiary_enrollment_pct REAL,
    infant_mortality REAL,
    largest_city TEXT,
    life_expectancy REAL,
    maternal_mortality_ratio REAL,
    minimum_wage REAL,
    official_language TEXT,
    oop_health_expenditure REAL,
    physicians_per_thousand REAL,
    population INTEGER,
    labor_force_participation_pct REAL,
    tax_revenue_pct REAL,
    total_tax_rate REAL,
    unemployment_rate REAL,
    urban_population REAL,
    latitude REAL,
    longitude REAL
);

/* ============================
   INGESTA DE DATOS
   ============================ */
INSERT INTO TMP_WorldData (
    country,
    density,
    land_area_km2,
    armed_forces_size,
    birth_rate,
    calling_code,
    capital,
    co2_emissions,
    cpi,
    cpi_change_pct,
    currency_code,
    fertility_rate,
    forested_area_pct,
    gasoline_price,
    gdp,
    gross_primary_enrollment_pct,
    gross_tertiary_enrollment_pct,
    infant_mortality,
    largest_city,
    life_expectancy,
    maternal_mortality_ratio,
    minimum_wage,
    official_language,
    oop_health_expenditure,
    physicians_per_thousand,
    population,
    labor_force_participation_pct,
    tax_revenue_pct,
    total_tax_rate,
    unemployment_rate,
    urban_population,
    latitude,
    longitude
)
SELECT
    COUNTRY,
    CAST(DENSITY AS REAL),
    CAST("Land Area(Km2)" AS INTEGER),
    CAST("Armed Forces size" AS INTEGER),
    CAST("Birth Rate" AS REAL),
    "Calling Code",
    "Capital/Major City",
    CAST("Co2-Emissions" AS REAL),
    CAST(CPI AS REAL),
    CAST("CPI Change (%)" AS REAL),
    "Currency-Code",
    CAST("Fertility Rate" AS REAL),
    CAST("Forested Area (%)" AS REAL),
    CAST("Gasoline Price" AS REAL),
    CAST(GDP AS REAL),
    CAST("Gross primary education enrollment (%)" AS REAL),
    CAST("Gross tertiary education enrollment (%)" AS REAL),
    CAST("Infant mortality" AS REAL),
    "Largest city",
    CAST("Life expectancy" AS REAL),
    CAST("Maternal mortality ratio" AS REAL),
    CAST("Minimum wage" AS REAL),
    "Official language",
    CAST("Out of pocket health expenditure" AS REAL),
    CAST("Physicians per thousand" AS REAL),
    CAST(Population AS INTEGER),
    CAST("Population: Labor force participation (%)" AS REAL),
    CAST("Tax revenue (%)" AS REAL),
    CAST("Total tax rate" AS REAL),
    CAST("Unemployment rate" AS REAL),
    CAST(Urban_population AS REAL),
    CAST(Latitude AS REAL),
    CAST(Longitude AS REAL)
FROM TXT_WorldData;

/* ============================
   DWA_DimCountry
   ============================ */

CREATE TABLE IF NOT EXISTS DWA_DimCountry (
    country_key INTEGER PRIMARY KEY AUTOINCREMENT,
    country TEXT UNIQUE,
    density REAL,
    land_area_km2 INTEGER,
    capital TEXT,
    currency_code TEXT,
    population INTEGER,
    gdp REAL,
    life_expectancy REAL,
    urban_population REAL,
    latitude REAL,
    longitude REAL
    -- Podés agregar más campos si querés
);

INSERT INTO DWA_DimCountry (
    country,
    density,
    land_area_km2,
    capital,
    currency_code,
    population,
    gdp,
    life_expectancy,
    urban_population,
    latitude,
    longitude
)
SELECT
    country,
    density,
    land_area_km2,
    capital,
    currency_code,
    population,
    gdp,
    life_expectancy,
    urban_population,
    latitude,
    longitude
FROM TMP_WorldData;