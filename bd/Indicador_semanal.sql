--crear tabla 
CREATE TABLE datos_maquinaria.INDICADOR_SEMANAL (
    TOTAL_GENERAL VARCHAR (255),
    HPR FLOAT,
    DISP VARCHAR (255),
    META FLOAT,
    MTBF FLOAT,
    MTTR FLOAT,
    AVERIAS INT,
    MINUTOS FLOAT,
    OEE VARCHAR (255)
);
--TRUNCATE TABLE INDICADOR_SEMANAL; 

DELETE FROM INDICADOR_SEMANAL WHERE total_general IS NULL;

INSERT INTO datos_maquinaria.INDICADOR_SEMANAL (TOTAL_GENERAL, META)
SELECT DISTINCT LINEA AS TOTAL_GENERAL, 0.95 AS META
FROM datos_maquinaria.HPR_OEE
UNION
SELECT 'L2' AS TOTAL_GENERAL, 0.95 AS META
UNION
SELECT 'PLANTA' AS TOTAL_GENERAL, 0.95 AS META
ORDER BY TOTAL_GENERAL;




CREATE OR REPLACE FUNCTION limit_rows()
RETURNS TRIGGER AS $$
BEGIN
    -- Contar cuántas filas existen en la tabla
    IF (SELECT COUNT(*) FROM INDICADOR_SEMANAL) >= 5 THEN
        RAISE EXCEPTION 'No se pueden agregar más de 4 filas en esta tabla.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_row_limit
BEFORE INSERT ON INDICADOR_SEMANAL
FOR EACH ROW
EXECUTE FUNCTION limit_rows();








CREATE TABLE datos_maquinaria.INDICADOR_SEMANAL_HISTORICO (
    ID VARCHAR(255),
    A±O INT,
    SEMANA INT,
    DISP FLOAT,
    META FLOAT,
    MTBF FLOAT,
    MTTR FLOAT,
    AVERIAS INT,
    MINUTOS FLOAT,
    OEE FLOAT,
    PAROSMENORES BOOLEAN,
    UNIQUE (ID, A±O, SEMANA, PAROSMENORES)
);

CREATE INDEX idx_indicador_ID_año_semana ON INDICADOR_SEMANAL_HISTORICO (ID, A±O, SEMANA);



\COPY INDICADOR_SEMANAL_HISTORICO FROM 'C:\Users\matias\Desktop\CocaCola\tablas muestras\INDICADORES SEMANA.csv' with DELIMITER ',' CSV HEADER ENCODING 'UTF8';


UPDATE INDICADOR_SEMANAL_HISTORICO
SET PAROSMENORES = FALSE;
