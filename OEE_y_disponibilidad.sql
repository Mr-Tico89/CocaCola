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
    AñO INT,
    MIN FLOAT,
    "OEE_(%)" FLOAT,
    MES VARCHAR (255),
    SEMANA INT
);
--TRUNCATE TABLE HPR_OEE;


--crear tabla 
CREATE TABLE datos_maquinaria.INDICADOR_SEMANAL (
    TOTAL_GENERAL VARCHAR (255),
    HPR FLOAT,
    "DISP_(%)" INT,
    META FLOAT,
    MTBF FLOAT,
    MTTR FLOAT,
    AVERIAS INT,
    MINUTOS FLOAT,
    "OEE_(%)" INT
);
--TRUNCATE TABLE INDICADOR_SEMANAL; 

--cargar datos OEE
\copy OEEYDISPONIBILIDAD FROM 'C:\Users\matias\Desktop\cocacola\OEEYDISPONIBILIDAD (10).csv' WITH DELIMITER ',' CSV HEADER ENCODING 'UTF8';

--trabajar datos OEE
INSERT INTO datos_maquinaria.HPR_OEE (LINEA, FECHA, AñO, MIN, "OEE_(%)", MES, SEMANA)
SELECT 
    CASE 
        WHEN TRIM(Machine_Name) LIKE '%Ref Pet (Llenadora)%' THEN 'L3'
        WHEN TRIM(Machine_Name) LIKE '%RGB%' THEN 'L4'
        WHEN TRIM(Machine_Name) LIKE '%One Way V2%' THEN 'L1'
        ELSE Machine_Name
    END AS LINEA,
    Days_in_Calendar_DateTime AS FECHA,
    EXTRACT(YEAR FROM Days_in_Calendar_DateTime) AS AñO,
    round(CAST((Horas_planificadas::FLOAT * 60) as NUMERIC), 2) AS MIN,
    OEE * 100 AS "OEE_(%)",
    TO_CHAR(Days_in_Calendar_DateTime, 'Mon') AS MES,
    EXTRACT(WEEK FROM Days_in_Calendar_DateTime) AS SEMANA
FROM datos_maquinaria.OEEYDISPONIBILIDAD;





INSERT INTO datos_maquinaria.INDICADOR_SEMANAL (TOTAL_GENERAL, META)
SELECT DISTINCT LINEA AS TOTAL_GENERAL, 0.95 AS META
FROM datos_maquinaria.HPR_OEE
UNION
SELECT 'L2' AS TOTAL_GENERAL, 0.95 AS META
UNION
SELECT 'PLANTA' AS TOTAL_GENERAL, NULL AS META
ORDER BY TOTAL_GENERAL;


 HPR, "DISP (%)", META, MTBF, MTTR, AVERIAS, MINUTOS, "OEE_(%)"
--    AS HPR,
    AS "DISP (%)",
    AS META,
    AS MTBF,
    AS MTTR,
    AS AVERIAS,
    AS MINUTOS,
    AS "OEE_(%)"

SELECT 
    h.LINEA,
    h."OEE_(%)",
    d.AREAS

FROM 
    datos_maquinaria.HPR_OEE h
JOIN 
    datos_maquinaria.DB_AVERIAS_CONSOLIDADO d
ON 
    h.FECHA = d.FECHA;


Select * from HPR_OEE
    where año = '2024',
    and mes = 'dec',
    and semana = '52';
