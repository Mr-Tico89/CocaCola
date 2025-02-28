--tabla con los nombres de tablas 
CREATE TABLE tabla_nombres (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL
);

INSERT INTO tabla_nombres (table_name)
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'datos_maquinaria';



CREATE OR REPLACE FUNCTION tabla_nombres()
RETURNS event_trigger AS $$
BEGIN
    INSERT INTO tabla_nombres (table_name)
    SELECT objid::regclass::text FROM pg_event_trigger_ddl_commands();
END;
$$ LANGUAGE plpgsql;


CREATE EVENT TRIGGER trigger_registro_tabla
ON ddl_command_end
WHEN TAG IN ('CREATE TABLE')
EXECUTE FUNCTION tabla_nombres();


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
CREATE TABLE datos_maquinaria.DB_AVERIAS_CONSOLIDADO_new (
    ID VARCHAR (255),
    FECHA DATE,
    A±O INT,
    MES VARCHAR (255),
    SEMANA INT,
    TURNO VARCHAR (255),
    MAQUINA VARCHAR (255),
    SINTOMA VARCHAR (255),
    AREAS VARCHAR(255),
    MINUTOS FLOAT,
    OBSERVACIONES VARCHAR (255)
);

CREATE INDEX idx_db_averias ON db_averias_consolidado (A±O, MES, SEMANA);


--tabla temporal para datos en brutos
CREATE TABLE temp_datasheet_fallas_semanales AS
SELECT * FROM DATASHEEET_FALLAS_SEMANALES LIMIT 0;


CREATE TABLE temp_db_averias_consolidado AS
SELECT * FROM db_averias_consolidado LIMIT 0;

CREATE INDEX idx_temp_db_averias_consolidado ON datos_maquinaria.temp_db_averias_consolidado (A±O, MES, SEMANA);


-- La función que actualizará temp_db_averias_consolidado cuando se inserten datos a datasheet_averias
CREATE OR REPLACE FUNCTION update_db_averias_consolidado()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar un nuevo registro en temp_db_averias_consolidado
    INSERT INTO datos_maquinaria.temp_db_averias_consolidado (
        ID, FECHA, AñO, MES, SEMANA, TURNO, MAQUINA, SINTOMA, AREAS, MINUTOS, OBSERVACIONES
    )
    VALUES (
        -- Determinar el valor de ID basado en Machine_Name
        CASE 
            WHEN TRIM(NEW.Machine_Name) LIKE '%Ref Pet (Llenadora)%' THEN 'L3'
            WHEN TRIM(NEW.Machine_Name) LIKE '%RGB%' THEN 'L4'
            WHEN TRIM(NEW.Machine_Name) LIKE '%One Way V2%' THEN 'L1'
            ELSE NEW.Machine_Name
        END,
        
        -- Usar la fecha original
        NEW.Days_in_Calendar_DateTime,

        -- Extraer el año de la fecha
        EXTRACT(YEAR FROM NEW.Days_in_Calendar_DateTime),

        -- Obtener el mes en formato abreviado
        LOWER(REPLACE(TO_CHAR(NEW.Days_in_Calendar_DateTime, 'TMMon'), '.', '')),
        
        -- Calcular la semana del año
        EXTRACT(WEEK FROM NEW.Days_in_Calendar_DateTime),
        
        -- Determinar el turno basado en Shift_Name
        CASE 
            WHEN TRIM(NEW.Shift_Name) LIKE '% No%' THEN 'Turno Noche'
            WHEN TRIM(NEW.Shift_Name) LIKE '%Tarde' THEN 'Turno Tarde'
            ELSE E'Turno D\u00eda' 
        END,
        
        -- Nombre de la máquina
        NEW.ReasonState_Group2,
        
        -- Nombre del estado de la razón
        NEW.ReasonState_Name,
        
        -- Determinar áreas basadas en minutos
        CASE 
            WHEN ROUND(CAST((NEW.Scheduled_Hours::FLOAT * 60) AS NUMERIC), 2) < 5 THEN 'Paros Menores'
            ELSE ''
        END,
        
        -- Calcular los minutos redondeados
        ROUND(CAST(NEW.Scheduled_Hours AS NUMERIC) * 60, 3),

        -- Agregar el valor de OBSERVACIONES (aunque sea vacío)
        ''
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Crear el trigger que llama a la función update_db_averias_consolidado
CREATE TRIGGER after_insert_datasheet_fallas_semanales
AFTER INSERT ON datos_maquinaria.DATASHEEET_FALLAS_SEMANALES
FOR EACH STATEMENT
EXECUTE FUNCTION update_db_averias_consolidado();


--insertar datos que no estan 
INSERT INTO db_averias_consolidado (ID, FECHA, A±O, MES, SEMANA, TURNO, MAQUINA, SINTOMA, AREAS, MINUTOS, OBSERVACIONES)
SELECT ID, FECHA, A±O, MES, SEMANA, TURNO, MAQUINA, SINTOMA, AREAS, MINUTOS, OBSERVACIONES
FROM temp_db_averias_consolidado t
WHERE NOT EXISTS (
    SELECT 1 
    FROM db_averias_consolidado d
    WHERE d.AñO = t.AñO 
    AND d.MES = t.MES 
    AND d.SEMANA = t.SEMANA
);