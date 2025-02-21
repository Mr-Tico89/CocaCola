--tabla datos en bruto
CREATE TABLE datos_maquinaria.FORMS_MTTO (
    ID INT PRIMARY KEY,
    Start_time DATE,
    Completion_time DATE,
    Email VARCHAR (255),
    Nombre VARCHAR (255),
    FECHA DATE,
    TURNO VARCHAR (225),
    AREAS VARCHAR (255),
    Equipo VARCHAR (255),
    Tenico VARCHAR (255),
    Tipo_de_mantencion VARCHAR (20),
    Evidencia VARCHAR (255),
    Tiempo  INT,
    Estado VARCHAR (255),
    Equipo_L2 VARCHAR (255),
    Equipo_L3 VARCHAR (255),
    Equipo_L4 VARCHAR (20),
    Equipo_L5 VARCHAR (255),
    Equipo_L6  VARCHAR (255),
    Sala_de_agua VARCHAR (255)
    Sala_Jarabe VARCHAR (255),
    Riles VARCHAR (255),
    Servicios VARCHAR (255),
    Actividad_modo_de_falla VARCHAR (255),
    ¿Qué probabilidades_hay_de_que_nos_recomiende? VARCHAR (255),
    Evidencia VARCHAR (255),
    Tableros_de_área_de_servicio VARCHAR (255),
    Área_técnico VARCHAR (255),
    nombre_de_responsable VARCHAR (255),
    Nombre_de_responsable_1 VARCHAR (255),
    nombre_de_empresa VARCHAR (255),
    El_mantenimiento_correctivo VARCHAR (255),
    Tipo_de_mantenimiento_correctivo VARCHAR (255),
    Nombre_del_que_recibe_el_trabajo VARCHAR (255),
    Se_necesitó_una_evaluación_de_riesgos VARCHAR (255),
    Se_necesitó_un_permiso_de_trabajo VARCHAR (255),
    Causa VARCHAR (255),
    La_actividad VARCHAR (255),
    Solución/observación VARCHAR (255)
);


CREATE TABLE datos_maquinaria.Novedades_Turno (
    ID INT,
    FECHA DATE,
    MES VARCHAR (255),
    A±O INT,
    SEMANA INT,
    TURNO VARCHAR (255),
    LINEA VARCHAR (255),
    MAQUINA VARCHAR (255),
    RESPONSABLE_1 VARCHAR (255),
    RESPONSABLE_2 VARCHAR (255),
    RESPONSABLE_3 VARCHAR (255),
    RESPONSABLE_4 VARCHAR (20),
    MODE_DE_FALLA VARCHAR (255),
    CAUSA  INT,
    SOLUCION/OBSERVACION CHAR (255),
    TIPO_MTTO VARCHAR (255),
    ESPECIALIDAD VARCHAR (255),
    TIEMPO_(MIN) INT,
    HR FLOAT,
    DETIENE_LINEA  VARCHAR (255),
    CONSTRAINT fk_id FOREIGN KEY (ID) REFERENCES FORMS_MTTO(id)
);


CREATE OR REPLACE FUNCTION trg_insert_novedades_turno()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO NOVEDADES_TURNO (
        id,
        minutos, 
        maquina,
        
    ) VALUES (
        NEW.id,  -- Inserta la ID de FORMS_MTTO
        EXTRACT(EPOCH FROM (NEW.completion_time - NEW.start_time)) / 60, -- Diferencia en minutos
        CONCAT_WS(' | ', 
            NEW.Equipo_L2, NEW.Equipo_L3, NEW.Equipo_L4, 
            NEW.Equipo_L5, NEW.Equipo_L6, NEW.Sala_de_agua, 
            NEW.Sala_Jarabe, NEW.Riles
        )  -- Fusiona los campos en "maquina"
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER insert_into_novedades_turno
AFTER INSERT ON FORMS_MTTO
FOR EACH ROW
EXECUTE FUNCTION trg_insert_novedades_turno();






--TRUNCATE TABLE DATASHEEET_FALLAS_SEMANALES;


--tabla con datos ya trabajados
CREATE TABLE datos_maquinaria.REPORTE_MTTO (
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