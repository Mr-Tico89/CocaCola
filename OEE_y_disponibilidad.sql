--crear tabla 
CREATE TABLE datos_maquinaria.OEEYDISPONIBILIDAD (
    Machine_Name VARCHAR (255),
    Days_in_Calendar_DateTime DATE,
    Shift_Name VARCHAR (255),
    Horas_produciendo FLOAT,
    Horas_planificadas FLOAT,
    OEE NUMERIC(5, 3)
);
--TRUNCATE TABLE OEEYDISPONIBILIDAD;

--crear tabla 
CREATE TABLE datos_maquinaria.HPR_OEE (
    LINEA VARCHAR (255),
    FECHA DATE,
    A±O INT,
    MIN FLOAT,
    OEE FLOAT,
    MES VARCHAR (255),
    SEMANA INT
);
--TRUNCATE TABLE HPR_OEE;

CREATE TABLE temp_OEEYDISPONIBILIDAD AS
SELECT * FROM OEEYDISPONIBILIDAD LIMIT 0;


--cargar datos OEE
\copy temp_OEEYDISPONIBILIDAD FROM 'C:\Users\matias\Desktop\CocaCola\tablas\OEEYDISPONIBILIDAD (13).csv' WITH DELIMITER ',' CSV HEADER ENCODING 'UTF8';

INSERT INTO OEEYDISPONIBILIDAD
SELECT * FROM temp_OEEYDISPONIBILIDAD;


--trabajar datos OEE
CREATE OR REPLACE FUNCTION insert_into_hpr_oee()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO datos_maquinaria.HPR_OEE (LINEA, FECHA, A±O, MIN, OEE, MES, SEMANA)
    SELECT 
        CASE 
            WHEN TRIM(NEW.Machine_Name) LIKE '%Ref Pet (Llenadora)%' THEN 'L3'
            WHEN TRIM(NEW.Machine_Name) LIKE '%RGB%' THEN 'L4'
            WHEN TRIM(NEW.Machine_Name) LIKE '%One Way V2%' THEN 'L1'
            ELSE NEW.Machine_Name
        END AS LINEA,
        NEW.Days_in_Calendar_DateTime AS FECHA,
        EXTRACT(YEAR FROM NEW.Days_in_Calendar_DateTime) AS A±O,
        round(CAST((NEW.Horas_planificadas::FLOAT * 60) as NUMERIC), 2) AS MIN,
        NEW.OEE AS OEE,
        TO_CHAR(NEW.Days_in_Calendar_DateTime, 'Mon') AS MES,
        EXTRACT(WEEK FROM NEW.Days_in_Calendar_DateTime) AS SEMANA
    FROM datos_maquinaria.OEEYDISPONIBILIDAD
    WHERE NEW.Machine_Name = Machine_Name
      AND NEW.Days_in_Calendar_DateTime = Days_in_Calendar_DateTime
    LIMIT 1;  -- Agregar LIMIT para asegurar que solo se inserte una fila

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER after_insert_oee_y_disponibilidad
AFTER INSERT ON datos_maquinaria.OEEYDISPONIBILIDAD
FOR EACH ROW
EXECUTE FUNCTION insert_into_hpr_oee();