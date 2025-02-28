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
    LINEA VARCHAR(255),
    FECHA DATE,
    A±O INT,
    MES VARCHAR(255),
    SEMANA INT,
    MIN FLOAT,
    OEE FLOAT
);
--TRUNCATE TABLE HPR_OEE;

CREATE INDEX idx_hpr ON HPR_OEE (A±O, MES, SEMANA);


CREATE TABLE temp_OEEYDISPONIBILIDAD AS
SELECT * FROM OEEYDISPONIBILIDAD LIMIT 0;


CREATE TABLE temp_HPR_OEE AS
SELECT * FROM HPR_OEE LIMIT 0;

CREATE INDEX idx_temp_hpr ON temp_HPR_OEE (A±O, MES, SEMANA);


--trabajar datos OEE
CREATE OR REPLACE FUNCTION insert_into_hpr_oee()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO datos_maquinaria.temp_HPR_OEE (LINEA, FECHA, AñO, MES, SEMANA, MIN, OEE)
    SELECT 
        CASE 
            WHEN TRIM(NEW.Machine_Name) LIKE '%Ref Pet (Llenadora)%' THEN 'L3'
            WHEN TRIM(NEW.Machine_Name) LIKE '%RGB%' THEN 'L4'
            WHEN TRIM(NEW.Machine_Name) LIKE '%One Way V2%' THEN 'L1'
            ELSE NEW.Machine_Name
        END AS LINEA,
        NEW.Days_in_Calendar_DateTime AS FECHA,
        EXTRACT(YEAR FROM NEW.Days_in_Calendar_DateTime) AS AñO,
        LOWER(REPLACE(TO_CHAR(NEW.Days_in_Calendar_DateTime, 'TMMon'), '.', '')) AS MES,
        EXTRACT(WEEK FROM NEW.Days_in_Calendar_DateTime) AS SEMANA,
        round(CAST((NEW.Horas_planificadas::FLOAT * 60) AS NUMERIC), 2) AS MIN,
        NEW.OEE AS OEE
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


--insertar datos que no estan 
INSERT INTO hpr_oee (LINEA, FECHA, AñO, MES, SEMANA, MIN, OEE)
SELECT LINEA, FECHA, AñO, MES, SEMANA, MIN, OEE
FROM temp_hpr_oee t
WHERE NOT EXISTS (
    SELECT 1 
    FROM hpr_oee h
    WHERE h.AñO = t.AñO 
    AND h.MES = t.MES 
    AND h.SEMANA = t.SEMANA
);