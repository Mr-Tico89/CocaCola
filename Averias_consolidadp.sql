--tabla con los nombres de tablas 
CREATE TABLE tabla_nombres (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL
);

INSERT INTO tabla_nombres (table_name)
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'datos_maquinaria';


SELECT table_name FROM information_schema.tables
    WHERE table_schema = 'datos_maquinaria';

--tabla datos en bruto
CREATE TABLE datos_maquinaria.DATASHEEET_FALLAS_SEMANALES (
    Machine_Name VARCHAR (255),
    Days_in_Calendar_DateTime DATE,
    Shift_Name VARCHAR,
    ReasonState_Group1 VARCHAR,
    ReasonState_Group2 VARCHAR,
    ReasonState_Name VARCHAR (255),
    Reason_Occurrences VARCHAR (20),
    Scheduled_Hours VARCHAR (255)
);
--TRUNCATE TABLE DATASHEEET_FALLAS_SEMANALES;

--tabla con datos ya trabajados
CREATE TABLE datos_maquinaria.DB_AVERIAS_CONSOLIDADO (
    ID VARCHAR (255),
    MES VARCHAR (255),
    SEMANA INT,
    FECHA DATE,
    A±O INT,
    TURNO VARCHAR (255),
    MAQUINA VARCHAR (255),
    SINTOMA VARCHAR (255),
    AREAS VARCHAR(255),
    MINUTOS FLOAT,
    OBSERVACIONES VARCHAR (255)
);

--tabla temporal para datos en brutos
CREATE TABLE temp_datasheet_fallas_semanales AS
SELECT * FROM DATASHEEET_FALLAS_SEMANALES LIMIT 0;

ALTER TABLE DB_AVERIAS_CONSOLIDADO
RENAME COLUMN "A¤O" TO "AÑO";


-- La función que actualizará DB_AVERIAS_CONSOLIDADO cuando se inserten datos a datasheet_averias
CREATE OR REPLACE FUNCTION update_db_averias_consolidado()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO datos_maquinaria.DB_AVERIAS_CONSOLIDADO (ID, MES, SEMANA, FECHA, A±O, TURNO, MAQUINA, MINUTOS, SINTOMA, AREAS, OBSERVACIONES)
    SELECT 
        CASE 
            WHEN TRIM(NEW.Machine_Name) LIKE '%Ref Pet (Llenadora)%' THEN 'L3'
            WHEN TRIM(NEW.Machine_Name) LIKE '%RGB%' THEN 'L4'
            WHEN TRIM(NEW.Machine_Name) LIKE '%One Way V2%' THEN 'L1'
            ELSE NEW.Machine_Name
        END AS ID,
        TO_CHAR(NEW.Days_in_Calendar_DateTime, 'Mon') AS MES,
        EXTRACT(WEEK FROM NEW.Days_in_Calendar_DateTime) AS SEMANA,
        NEW.Days_in_Calendar_DateTime AS FECHA,
        EXTRACT(YEAR FROM NEW.Days_in_Calendar_DateTime) AS AñO,
        CASE 
            WHEN TRIM(NEW.Shift_Name) LIKE '% No%' THEN 'Turno Noche'
            WHEN TRIM(NEW.Shift_Name) LIKE '%Tarde' THEN 'Turno Tarde'
            ELSE E'Turno   D\u00EDa'
        END AS TURNO,
        NEW.ReasonState_Group2 AS MAQUINA,
        round(CAST((NEW.Scheduled_Hours::FLOAT * 60) as NUMERIC), 2) AS MINUTOS,
        NEW.ReasonState_Name AS SINTOMA,
        CASE 
            WHEN (CAST((NEW.Scheduled_Hours::FLOAT * 60) as NUMERIC)) < 5 THEN 'Paros Menores'
            ELSE ''
        END AS AREAS,
        '' AS OBSERVACIONES;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Crear el trigger que llama a la función update_db_averias_consolidado
CREATE TRIGGER after_insert_datasheet_fallas_semanales
AFTER INSERT ON datos_maquinaria.DATASHEEET_FALLAS_SEMANALES
FOR EACH ROW
EXECUTE FUNCTION update_db_averias_consolidado();

--cargar datos en la base 
\copy temp_datasheet_fallas_semanales FROM 'C:\Users\matias\Desktop\cocacola\tablas\DATASHEEETFALLASSEMANALES (10).csv' WITH DELIMITER ',' CSV HEADER ENCODING 'UTF8';

-- Insertar datos en DATASHEEET_FALLAS_SEMANALES desde temp_datasheet_fallas_semanales
INSERT INTO DATASHEEET_FALLAS_SEMANALES
SELECT * FROM temp_datasheet_fallas_semanales;

-- Vaciar la tabla temp_datasheet_fallas_semanales después de la inserción
TRUNCATE TABLE temp_datasheet_fallas_semanales;



--ver triggers 
SELECT 
    tgname AS trigger_name,
    relname AS table_name,
    nspname AS schema_name
FROM 
    pg_trigger
JOIN 
    pg_class ON pg_trigger.tgrelid = pg_class.oid
JOIN 
    pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE 
    NOT tgisinternal;

--eliminar triggers 
DROP TRIGGER IF EXISTS after_insert_datasheet_fallas_semanales ON DATASHEEET_FALLAS_SEMANALES;

--ver funciones 
SELECT 
    proname AS function_name,
    nspname AS schema_name
FROM 
    pg_proc
JOIN 
    pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
WHERE 
    nspname NOT IN ('pg_catalog', 'information_schema');

--eliminar funciones
DROP FUNCTION IF EXISTS update_db_averias_consolidado();
DROP TRIGGER IF EXISTS 


-- hacer joins con tabla de area con hpr_oee y hacer input del filtro para sacar los calculos de la tabla 


-- esto lo debe hacer al cargar los archivos desde la pagina mas o menos
    --cargar datos en la base 
    \copy temp_datasheet_fallas_semanales FROM 'uploads\{archivo.csv}' WITH DELIMITER ',' CSV HEADER ENCODING 'UTF8';

    -- Insertar datos en DATASHEEET_FALLAS_SEMANALES desde temp_datasheet_fallas_semanales
    INSERT INTO DATASHEEET_FALLAS_SEMANALES
    SELECT * FROM temp_datasheet_fallas_semanales;

    -- Vaciar la tabla temp_datasheet_fallas_semanales después de la inserción
    TRUNCATE TABLE temp_datasheet_fallas_semanales;
--


SELECT datname, pg_encoding_to_char(encoding) AS encoding
FROM pg_database
WHERE datname = 'cocacola';

