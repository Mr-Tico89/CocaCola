--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: datos_maquinaria; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA datos_maquinaria;


ALTER SCHEMA datos_maquinaria OWNER TO postgres;

--
-- Name: insert_into_hpr_oee(); Type: FUNCTION; Schema: datos_maquinaria; Owner: postgres
--

CREATE FUNCTION datos_maquinaria.insert_into_hpr_oee() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO datos_maquinaria.HPR_OEE (LINEA, FECHA, AñO, MIN, OEE, MES, SEMANA)
    SELECT 
        CASE 
            WHEN TRIM(NEW.Machine_Name) LIKE '%Ref Pet (Llenadora)%' THEN 'L3'
            WHEN TRIM(NEW.Machine_Name) LIKE '%RGB%' THEN 'L4'
            WHEN TRIM(NEW.Machine_Name) LIKE '%One Way V2%' THEN 'L1'
            ELSE NEW.Machine_Name
        END AS LINEA,
        NEW.Days_in_Calendar_DateTime AS FECHA,
        EXTRACT(YEAR FROM NEW.Days_in_Calendar_DateTime) AS AñO,
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
$$;


ALTER FUNCTION datos_maquinaria.insert_into_hpr_oee() OWNER TO postgres;

--
-- Name: update_db_averias_consolidado(); Type: FUNCTION; Schema: datos_maquinaria; Owner: postgres
--

CREATE FUNCTION datos_maquinaria.update_db_averias_consolidado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insertar un nuevo registro en DB_AVERIAS_CONSOLIDADO
    INSERT INTO datos_maquinaria.DB_AVERIAS_CONSOLIDADO (
        ID, MES, SEMANA, FECHA, AñO, TURNO, MAQUINA, MINUTOS, SINTOMA, AREAS, OBSERVACIONES
    )
    VALUES (
        -- Determinar el valor de ID basado en Machine_Name
        CASE 
            WHEN TRIM(NEW.Machine_Name) LIKE '%Ref Pet (Llenadora)%' THEN 'L3'
            WHEN TRIM(NEW.Machine_Name) LIKE '%RGB%' THEN 'L4'
            WHEN TRIM(NEW.Machine_Name) LIKE '%One Way V2%' THEN 'L1'
            ELSE NEW.Machine_Name
        END,
        -- Obtener el mes en formato abreviado
        TO_CHAR(NEW.Days_in_Calendar_DateTime, 'Mon'),
        -- Calcular la semana del a¤o
        EXTRACT(WEEK FROM NEW.Days_in_Calendar_DateTime),
        -- Usar la fecha original
        NEW.Days_in_Calendar_DateTime,
        -- Extraer el a¤o de la fecha
        EXTRACT(YEAR FROM NEW.Days_in_Calendar_DateTime),
        -- Determinar el turno basado en Shift_Name
        CASE 
            WHEN TRIM(NEW.Shift_Name) LIKE '% No%' THEN 'Turno Noche'
            WHEN TRIM(NEW.Shift_Name) LIKE '%Tarde' THEN 'Turno Tarde'
            ELSE E'Turno D\u00eda' 
        END,
        -- Nombre de la m quina
        NEW.ReasonState_Group2,
        -- Calcular los minutos redondeados
        ROUND(CAST(NEW.Scheduled_Hours AS NUMERIC) * 60, 3),
        -- Nombre del estado de la raz¢n
        NEW.ReasonState_Name,
        -- Determinar  reas basadas en minutos
        CASE 
            WHEN ROUND(CAST((NEW.Scheduled_Hours::FLOAT * 60) AS NUMERIC), 2) < 5 THEN 'Paros Menores'
            ELSE ''
        END,
        -- Observaciones vac¡as
        ''
    );

    RETURN NEW;
END;
$$;


ALTER FUNCTION datos_maquinaria.update_db_averias_consolidado() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: datasheeet_fallas_semanales; Type: TABLE; Schema: datos_maquinaria; Owner: postgres
--

CREATE TABLE datos_maquinaria.datasheeet_fallas_semanales (
    machine_name character varying(255),
    days_in_calendar_datetime date,
    shift_name character varying,
    reasonstate_group1 character varying,
    reasonstate_group2 character varying,
    reasonstate_name character varying(255),
    reason_occurrences character varying(20),
    scheduled_hours character varying(255)
);


ALTER TABLE datos_maquinaria.datasheeet_fallas_semanales OWNER TO postgres;

--
-- Name: db_averias_consolidado; Type: TABLE; Schema: datos_maquinaria; Owner: postgres
--

CREATE TABLE datos_maquinaria.db_averias_consolidado (
    id character varying(255),
    mes character varying(255),
    semana integer,
    fecha date,
    "año" integer,
    turno character varying(255),
    maquina character varying(255),
    sintoma character varying(255),
    areas character varying(255),
    minutos double precision,
    observaciones character varying(255)
);


ALTER TABLE datos_maquinaria.db_averias_consolidado OWNER TO postgres;

--
-- Name: hpr_oee; Type: TABLE; Schema: datos_maquinaria; Owner: postgres
--

CREATE TABLE datos_maquinaria.hpr_oee (
    linea character varying(255),
    fecha date,
    "año" integer,
    min double precision,
    oee double precision,
    mes character varying(255),
    semana integer
);


ALTER TABLE datos_maquinaria.hpr_oee OWNER TO postgres;

--
-- Name: indicador_semanal; Type: TABLE; Schema: datos_maquinaria; Owner: postgres
--

CREATE TABLE datos_maquinaria.indicador_semanal (
    total_general character varying(255),
    hpr double precision,
    disp integer,
    meta double precision,
    mtbf double precision,
    mttr double precision,
    averias integer,
    minutos double precision,
    oee character varying(255)
);


ALTER TABLE datos_maquinaria.indicador_semanal OWNER TO postgres;

--
-- Name: oeeydisponibilidad; Type: TABLE; Schema: datos_maquinaria; Owner: postgres
--

CREATE TABLE datos_maquinaria.oeeydisponibilidad (
    machine_name character varying(255),
    days_in_calendar_datetime date,
    shift_name character varying(255),
    horas_produciendo double precision,
    horas_planificadas double precision,
    oee numeric(5,3)
);


ALTER TABLE datos_maquinaria.oeeydisponibilidad OWNER TO postgres;

--
-- Name: tabla_nombres; Type: TABLE; Schema: datos_maquinaria; Owner: postgres
--

CREATE TABLE datos_maquinaria.tabla_nombres (
    id integer NOT NULL,
    table_name character varying(255) NOT NULL
);


ALTER TABLE datos_maquinaria.tabla_nombres OWNER TO postgres;

--
-- Name: tabla_nombres_id_seq; Type: SEQUENCE; Schema: datos_maquinaria; Owner: postgres
--

CREATE SEQUENCE datos_maquinaria.tabla_nombres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE datos_maquinaria.tabla_nombres_id_seq OWNER TO postgres;

--
-- Name: tabla_nombres_id_seq; Type: SEQUENCE OWNED BY; Schema: datos_maquinaria; Owner: postgres
--

ALTER SEQUENCE datos_maquinaria.tabla_nombres_id_seq OWNED BY datos_maquinaria.tabla_nombres.id;


--
-- Name: temp_datasheet_fallas_semanales; Type: TABLE; Schema: datos_maquinaria; Owner: postgres
--

CREATE TABLE datos_maquinaria.temp_datasheet_fallas_semanales (
    machine_name character varying(255),
    days_in_calendar_datetime date,
    shift_name character varying,
    reasonstate_group1 character varying,
    reasonstate_group2 character varying,
    reasonstate_name character varying(255),
    reason_occurrences character varying(20),
    scheduled_hours character varying(255)
);


ALTER TABLE datos_maquinaria.temp_datasheet_fallas_semanales OWNER TO postgres;

--
-- Name: temp_oeeydisponibilidad; Type: TABLE; Schema: datos_maquinaria; Owner: postgres
--

CREATE TABLE datos_maquinaria.temp_oeeydisponibilidad (
    machine_name character varying(255),
    days_in_calendar_datetime date,
    shift_name character varying(255),
    horas_produciendo double precision,
    horas_planificadas double precision,
    oee numeric(5,2)
);


ALTER TABLE datos_maquinaria.temp_oeeydisponibilidad OWNER TO postgres;

--
-- Name: tabla_nombres id; Type: DEFAULT; Schema: datos_maquinaria; Owner: postgres
--

ALTER TABLE ONLY datos_maquinaria.tabla_nombres ALTER COLUMN id SET DEFAULT nextval('datos_maquinaria.tabla_nombres_id_seq'::regclass);


--
-- Data for Name: datasheeet_fallas_semanales; Type: TABLE DATA; Schema: datos_maquinaria; Owner: postgres
--

COPY datos_maquinaria.datasheeet_fallas_semanales (machine_name, days_in_calendar_datetime, shift_name, reasonstate_group1, reasonstate_group2, reasonstate_name, reason_occurrences, scheduled_hours) FROM stdin;
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	Mantenimiento	Omnivision	Falla Servomotor	1	0.999428571444445
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	Mantenimiento	Omnivision	Falla Servomotor	7	0.859902184
TAL - Línea One Way V2	2025-01-19	Día Tarde	Mantenimiento	Túnel	Ajuste de rodillo ( Balanza)	1	0.776051666666667
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	Mantenimiento	Omnivision	Falla Servomotor	0	0.567880793666667
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	8	0.456824444444444
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	Mantenimiento	Omnivision	Falla Servomotor	6	0.421187183777778
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Reparación - Coronador	9	0.412829722222222
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno  Tarde	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	3	0.376418651388889
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Túnel	Ajuste de rodillo ( Balanza)	7	0.37122722225
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	Mantenimiento	Lavadora de Cajas	Reparación guia de cajas	3	0.359854207361111
TAL - Línea RGB	2025-01-18	Turno Dia	Mantenimiento	Codificador	cabezal sucio	1	0.353434722222222
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Cambio o reparación - Coronador	8	0.347221111111111
TAL - Línea One Way V2	2025-01-13	Turno Día	Mantenimiento	Capsuladora	Cambio de cabezal	1	0.345777341277778
TAL - Línea One Way V2	2025-01-19	Día Tarde	Mantenimiento	Túnel	Producto desplazado salida recubrimiento - Mantenimiento	1	0.320923888888889
TAL - Línea One Way V2	2025-01-19	Día Tarde	Mantenimiento	Túnel	Ajuste de rodillo ( Balanza)	3	0.270079444444444
TAL - Línea One Way V2	2025-01-19	Día Tarde	Mantenimiento	Sopladora	Problema compresor de alta	3	0.265093333388889
TAL - Línea One Way V2	2025-01-19	Día Tarde	Mantenimiento	Sopladora	Problema compresor de alta	1	0.260904722222222
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	3	0.257161388888889
TAL - Línea One Way V2	2025-01-16	Día Tarde	Mantenimiento	Robopac	Problema en Soldadora	6	0.242744004444444
TAL - Línea One Way V2	2025-01-19	Día Tarde	Mantenimiento	Túnel	Producto desplazado salida recubrimiento - Mantenimiento	4	0.239515555555556
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	8	0.236320555555556
TAL - Línea Ref Pet (Llenadora)	2025-01-15	Turno Día	Mantenimiento	Decapsuladora	Ajustes por falla	2	0.227094182305556
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	4	0.2196525
TAL - Línea One Way V2	2025-01-17	Turno Noche	Mantenimiento	Capsuladora	Tapas giradas en cabezal	11	0.201122419027778
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno  Tarde	Mantenimiento	Capsuladora	Falla sensor	4	0.196726667222222
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	4	0.181934444444444
TAL - Línea One Way V2	2025-01-16	Turno Día	Mantenimiento	Capsuladora	Cambio de cabezal	0	0.178680555555556
TAL - Línea RGB	2025-01-18	Turno Noche	Mantenimiento	Paletizadora	Caída de automático - Paletizadora	1	0.170037777777778
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Codificador	cabezal sucio	1	0.166728333333333
TAL - Línea One Way V2	2025-01-15	Día Tarde	Mantenimiento	Paletizadora	Trabamiento de paletas	1	0.153012682083333
TAL - Línea One Way V2	2025-01-14	Turno Día	Mantenimiento	Mixer	Falla en bomba de Jarabes	1	0.1460968255
TAL - Línea One Way V2	2025-01-16	Turno Noche	Mantenimiento	Capsuladora	Tapa girada cabezal N° 12	3	0.146084311861111
TAL - Línea RGB	2025-01-16	Turno Dia	Mantenimiento	Despaletizadora	Falla motor transporte - Despaletizadora	2	0.141723888888889
TAL - Línea One Way V2	2025-01-16	Turno Día	Mantenimiento	Capsuladora	Cambio de cabezal	1	0.140334710555556
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	23	0.127983333333333
TAL - Línea One Way V2	2025-01-19	Turno Noche	Mantenimiento	Llenadora	Cambio o reparación de pinzas - Llenadora	1	0.1191925
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno  Tarde	Mantenimiento	Capsuladora	Falla sensor	24	0.119140240111111
TAL - Línea One Way V2	2025-01-16	Día Tarde	Mantenimiento	Túnel	Caída de botellas, ajuste de traspasos	3	0.113110964222222
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Cambio o reparación - Coronador	2	0.1079575
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno  Tarde	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	27	0.101906591111111
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	15	0.0979627777777778
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	13	0.0938180555555556
TAL - Línea One Way V2	2025-01-19	Día Tarde	Mantenimiento	Túnel	Producto desplazado salida recubrimiento - Mantenimiento	2	0.0883858333611111
TAL - Línea One Way V2	2025-01-13	Día Tarde	Mantenimiento	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	6	0.0856352384166667
TAL - Línea One Way V2	2025-01-19	Turno Noche	Mantenimiento	Llenadora	Cambio o reparación de pinzas - Llenadora	1	0.0841975
TAL - Línea One Way V2	2025-01-15	Turno Día	Mantenimiento	Capsuladora	Cambio de cabezal	1	0.081239331
TAL - Línea One Way V2	2025-01-15	Día Tarde	Mantenimiento	Túnel	Falla en motor	3	0.0796986596666667
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	3	0.0779511111111111
TAL - Línea One Way V2	2025-01-15	Día Tarde	Mantenimiento	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	4	0.0776035761666667
TAL - Línea Ref Pet (Llenadora)	2025-01-13	Turno Día	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.07653111125
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	3	0.074195
TAL - Línea One Way V2	2025-01-13	Turno Día	Mantenimiento	Capsuladora	Cambio de cabezal	0	0.0726313888888889
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	17	0.0704588888888889
TAL - Línea One Way V2	2025-01-14	Turno Noche	Mantenimiento	Robopac	Corte de Film en Robopack	3	0.0684771033611111
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Túnel	Caída de botellas, ajuste de traspasos	1	0.0683480555555556
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Unscheduled	Mantenimiento	Omnivision	Falla Servomotor	1	0
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Túnel	Producto desplazado salida recubrimiento - Mantenimiento	2	0.0683419444444444
TAL - Línea One Way V2	2025-01-14	Día Tarde	Mantenimiento	Sopladora	Problema en el Chiller	2	0.0662224209444444
TAL - Línea One Way V2	2025-01-13	Turno Día	Mantenimiento	Mixer	Presión de Co2 - Mantenimiento	1	0.0657303968333333
TAL - Línea One Way V2	2025-01-15	Turno Día	Mantenimiento	Capsuladora	Cambio de cabezal	0	0.0650097222222222
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0647426195833333
TAL - Línea RGB	2025-01-18	Turno Dia	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	2	0.0647241666666667
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	3	0.0631502777777778
TAL - Línea One Way V2	2025-01-15	Día Tarde	Mantenimiento	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	3	0.0622652432777778
TAL - Línea One Way V2	2025-01-14	Día Tarde	Mantenimiento	Sopladora	Problema en el Chiller	1	0.0620401984166667
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Llenadora	Caída de guía de seguridad por problema en pinza - Botella mal tapada	5	0.0608594444444444
TAL - Línea One Way V2	2025-01-14	Turno Día	Mantenimiento	Mixer	Falla en bomba de Jarabes	1	0.0603832540833333
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	11	0.0583702777777778
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Capsuladora	Tapa girada cabezal N° 1	2	0.0583519444444444
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Cambio o reparación - Coronador	12	0.0579441666666667
TAL - Línea RGB	2025-01-18	Turno Dia	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	1	0.0578247222222222
TAL - Línea One Way V2	2025-01-13	Turno Día	Mantenimiento	Mixer	Presión de Co2 - Mantenimiento	1	0.0558552778611111
TAL - Línea One Way V2	2025-01-13	Turno Día	Mantenimiento	Mixer	Presión de Co2 - Mantenimiento	2	0.0526468255833333
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Mixer	Error de Mezcla	1	0.05252
TAL - Línea One Way V2	2025-01-15	Turno Día	Mantenimiento	Llenadora	Espumado al inicio de proceso	2	0.0524087820277778
TAL - Línea One Way V2	2025-01-14	Día Tarde	Mantenimiento	Robopac	Corte de Film en Robopack	1	0.0509704366388889
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Mixer	Error de Mezcla	1	0.0508491666666667
TAL - Línea One Way V2	2025-01-14	Turno Noche	Mantenimiento	Robopac	Corte de Film en Robopack	4	0.0496823021111111
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Llenadora	Caída de guía de seguridad por problema en pinza - Botella mal tapada	2	0.0489044444444444
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno  Tarde	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	2	0.0484169848611111
TAL - Línea One Way V2	2025-01-18	Turno Noche	Mantenimiento	Túnel	Rectificación de dientes de cuchillo	1	0.0482555555555556
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.0464766666666667
TAL - Línea One Way V2	2025-01-16	Día Tarde	Mantenimiento	Sopladora	Presión de soplado insuficiente	2	0.0461474513611111
TAL - Línea One Way V2	2025-01-15	Turno Noche	Mantenimiento	Sopladora	Cambio de Lamparas	1	0.0428263888888889
TAL - Línea Ref Pet (Llenadora)	2025-01-14	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	2	0.0393898413333333
TAL - Línea One Way V2	2025-01-14	Turno Noche	Mantenimiento	Robopac	Corte de Film en Robopack	1	0.0388200793888889
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Llenadora	Caída de guía de seguridad por problema en pinza - Botella mal tapada	1	0.0380716666944444
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Túnel	Falla en motor	1	0.0377891666666667
TAL - Línea One Way V2	2025-01-19	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	1	0.0355677777777778
TAL - Línea One Way V2	2025-01-17	Día Tarde	Mantenimiento	Paletizadora	Sensor entrada divisor	2	0.0355661111111111
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	6	0.0346247222222222
TAL - Línea RGB	2025-01-13	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.0325119444444444
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	Mantenimiento	Omnivision	Falla Servomotor	0	0.0323026592222222
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0291639684722222
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno  Tarde	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	11	0.0285917083333333
TAL - Línea RGB	2025-01-13	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	1	0.0275077777777778
TAL - Línea Ref Pet (Llenadora)	2025-01-15	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0270441822777778
TAL - Línea Ref Pet (Llenadora)	2025-01-15	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.026885738
TAL - Línea RGB	2025-01-13	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.0266822222222222
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	5	0.0266794444444444
TAL - Línea One Way V2	2025-01-17	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	2	0.026175131
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	3	0.02543
TAL - Línea Ref Pet (Llenadora)	2025-01-15	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0249200312222222
TAL - Línea One Way V2	2025-01-19	Turno Noche	Mantenimiento	Etiquetadora	Empalme defectuoso - Etiquetadora	1	0.0244569444444444
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0238436113888889
TAL - Línea RGB	2025-01-17	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0225066666666667
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	9	0.0200205555555556
TAL - Línea Ref Pet (Llenadora)	2025-01-13	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0196976984722222
TAL - Línea One Way V2	2025-01-15	Turno Noche	Mantenimiento	Robopac	Corte de Film en Robopack	1	0.0196339054444444
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	4	0.0191827777777778
TAL - Línea Ref Pet (Llenadora)	2025-01-13	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0189178177777778
TAL - Línea Ref Pet (Llenadora)	2025-01-13	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0189105955555556
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	1	0.0187616666666667
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0187541666666667
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0184856356944444
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Mixer	Error de Mezcla	2	0.0183394444444444
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0177469847222222
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno Mañana	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0174153175555556
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	Mantenimiento	Lavadora de Cajas	Reparación guia de cajas	3	0.0174092065277778
TAL - Línea One Way V2	2025-01-14	Día Tarde	Mantenimiento	Transporte	Divisor de paquetes	1	0.0162029763333333
TAL - Línea RGB	2025-01-17	Turno Dia	Mantenimiento	Transporte	Trabamiento curva salida pulmón	2	0.0150072222222222
TAL - Línea RGB	2025-01-16	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0150008333333333
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	Mantenimiento	Omnivision	Falla Servomotor	2	0.0143184131111111
TAL - Línea One Way V2	2025-01-19	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	1	0.0141772222222222
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	Mantenimiento	Omnivision	Falla Servomotor	3	0.0141498018888889
TAL - Línea Ref Pet (Llenadora)	2025-01-13	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0140005556944444
TAL - Línea One Way V2	2025-01-14	Turno Noche	Mantenimiento	Transporte	Divisor de paquetes	1	0.0139346826666667
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Cambio o reparación - Coronador	1	0.0137666666666667
TAL - Línea One Way V2	2025-01-19	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	3	0.0136175
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno Mañana	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	0	0.0127494444444444
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Reparación - Coronador	3	0.0125077777777778
TAL - Línea RGB	2025-01-13	Turno Dia	Mantenimiento	Mixer	Problema presión bomba de agua	2	0.0116836111111111
TAL - Línea RGB	2025-01-17	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	2	0.0116769444444444
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Mixer	Error de Mezcla	4	0.0116736111111111
TAL - Línea RGB	2025-01-16	Turno Dia	Mantenimiento	Codificador	Ajuste por cambio de formato - Codificador	1	0.0116705555555556
TAL - Línea One Way V2	2025-01-14	Día Tarde	Mantenimiento	Sopladora	Trabamiento de Preformas	3	0.0103718653055556
TAL - Línea RGB	2025-01-18	Turno Dia	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	1	0.0100069444444444
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	6	0.00959638888888889
TAL - Línea One Way V2	2025-01-15	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	2	0.00850117672222222
TAL - Línea One Way V2	2025-01-16	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	3	0.00824663072222222
TAL - Línea One Way V2	2025-01-14	Turno Noche	Mantenimiento	Codificador	Regulación de Altura - Mantenimiento	1	0.00727551605555556
TAL - Línea RGB	2025-01-16	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.00708694444444444
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno Mañana	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.00580789688888889
TAL - Línea RGB	2025-01-15	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.00541916666666667
TAL - Línea RGB	2025-01-16	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.00500138888888889
TAL - Línea One Way V2	2025-01-15	Turno Noche	Mantenimiento	Robopac	Corte de Film en Robopack	1	0.00448406977777778
TAL - Línea One Way V2	2025-01-16	Día Tarde	Mantenimiento	Túnel	Caída de botellas, ajuste de traspasos	0	0.00419527777777778
TAL - Línea RGB	2025-01-13	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.00417027777777778
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Cambio o reparación - Coronador	2	0.00416861111111111
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.00333388888888889
TAL - Línea RGB	2025-01-13	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	1	0.00251416666666667
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.00250888888888889
TAL - Línea RGB	2025-01-13	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	1	0.0025
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Mixer	Problema presión bomba de agua	1	0.00249916666666667
TAL - Línea Ref Pet (Llenadora)	2025-01-14	Turno Día	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.00245182544444444
TAL - Línea RGB	2025-01-13	Turno Dia	Mantenimiento	Mixer	Problema presión bomba de agua	1	0.00166861111111111
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.00166861111111111
TAL - Línea RGB	2025-01-16	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.00166777777777778
TAL - Línea RGB	2025-01-14	Turno Dia	Mantenimiento	Mixer	Problema presión bomba de agua	1	0.00166638888888889
TAL - Línea RGB	2025-01-15	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.000836111111111111
TAL - Línea RGB	2025-01-16	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.000419166666666667
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Unscheduled	Mantenimiento	Omnivision	Falla Servomotor	1	0
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Unscheduled	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Unscheduled	Mantenimiento	Omnivision	Falla Servomotor	0	0
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Unscheduled	Mantenimiento	Omnivision	Falla Servomotor	0	0
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Unscheduled	Mantenimiento	Omnivision	Falla Servomotor	5	0
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Unscheduled	Mantenimiento	Omnivision	Falla Servomotor	1	0
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Noche	Mantenimiento	Lavadora de Botellas	Ajuste o cambio de encoder - Lavadora de Botellas	1	0.926314722222222
TAL - Línea One Way V2	2024-12-24	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	1	0.878014206444444
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Noche	Mantenimiento	Lavadora de Botellas	Ajuste o cambio de encoder - Lavadora de Botellas	1	0.813906388888889
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	5	0.76496
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	Mantenimiento	Encajonadora	Ajuste o cambio - Encajonadora	4	0.762608810833333
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	4	0.751616666666667
TAL - Línea One Way V2	2024-12-23	Turno Día	Mantenimiento	Etiquetadora	Falla Etiquetadora	1	0.674805797416667
TAL - Línea One Way V2	2024-12-28	Turno Noche	Mantenimiento	Robopac	Problema en Soldadora	7	0.628775595583333
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	5	0.582511111111111
TAL - Línea RGB	2024-12-23	Turno Dia	Mantenimiento	Etiquetadora	Falla Etiquetadora	4	0.453454166666667
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Día	Mantenimiento	Etiquetadora	Ajuste o cambio de cuchillo	1	0.393921571333333
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Codificador	Problema en encoder	2	0.393597386583333
TAL - Línea One Way V2	2024-12-26	Turno Noche	Mantenimiento	Sopladora	Presión de soplado insuficiente	4	0.390664166666667
TAL - Línea One Way V2	2024-12-23	Turno Día	Mantenimiento	Etiquetadora	Falla Etiquetadora	1	0.331537777777778
TAL - Línea One Way V2	2024-12-26	Día Tarde	Mantenimiento	Túnel	Ajuste de rodillo ( Balanza)	1	0.328481111111111
TAL - Línea One Way V2	2024-12-26	Turno Noche	Mantenimiento	Sopladora	Molde con problemas	4	0.325085555555556
TAL - Línea One Way V2	2024-12-27	Turno Día	Mantenimiento	Robopac	Problema en Soldadora	11	0.308440237305556
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Día	Mantenimiento	Decapsuladora	Ajustes por falla	3	0.30180107825
TAL - Línea One Way V2	2024-12-26	Día Tarde	Mantenimiento	Paletizadora	Araña toma cartón en falla	2	0.290224082166667
TAL - Línea RGB	2024-12-23	Turno Noche	Mantenimiento	Llenadora	Espumado al inicio de proceso	0	0.270320833333333
TAL - Línea One Way V2	2024-12-23	Turno Día	Mantenimiento	Sopladora	Pruebas por mantención	2	0.264349434444444
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Día	Mantenimiento	Paletizadora	Caída de automático - Paletizadora	1	0.24704627
TAL - Línea One Way V2	2024-12-26	Turno Día	Mantenimiento	Paletizadora	Araña toma cartón en falla	1	0.239476111111111
TAL - Línea One Way V2	2024-12-26	Día Tarde	Mantenimiento	Túnel	Ajuste de rodillo ( Balanza)	1	0.233089315083333
TAL - Línea One Way V2	2024-12-26	Turno Noche	Mantenimiento	Codificador	Regulación de Altura - Mantenimiento	4	0.229793333361111
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Transporte	Ajuste o reparacion de barandas	2	0.224115952555556
TAL - Línea One Way V2	2024-12-24	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	1	0.220212103305556
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	2	0.207531111111111
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Mixer	Brix jarabe bajo	3	0.206738888888889
TAL - Línea One Way V2	2024-12-23	Turno Día	Mantenimiento	Paletizadora	Paletizadora problema con receta	4	0.197828974444444
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Decapsuladora	Ajuste o cambio de sensor - Decapsuladora	1	0.196738333333333
TAL - Línea Ref Pet (Llenadora)	2024-12-23	Turno Día	Mantenimiento	Transporte	Transporte lleno reparación cadena	0	0.191875555555556
TAL - Línea One Way V2	2024-12-26	Turno Día	Mantenimiento	Sopladora	Mantención Horno	12	0.18007722225
TAL - Línea One Way V2	2024-12-23	Turno Día	Mantenimiento	Túnel	Falla en motor	2	0.174811013666667
TAL - Línea One Way V2	2024-12-27	Día Tarde	Mantenimiento	Paletizadora	Trabamiento de paletas	1	0.170944166722222
TAL - Línea One Way V2	2024-12-23	Turno Noche	Mantenimiento	Paletizadora	Pérdida de ciclo	1	0.167860484138889
TAL - Línea One Way V2	2024-12-26	Día Tarde	Mantenimiento	Paletizadora	Araña toma cartón en falla	2	0.157818106444444
TAL - Línea One Way V2	2024-12-24	Turno Noche	Mantenimiento	Sopladora	Pruebas por mantención	1	0.155764008027778
TAL - Línea One Way V2	2024-12-26	Turno Día	Mantenimiento	Paletizadora	Ajuste o cambio de sensor - Paletizadora	3	0.155611388888889
TAL - Línea Ref Pet (Llenadora)	2024-12-23	Turno Día	Mantenimiento	Transporte	Transporte lleno reparación cadena	1	0.155423533194444
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Mixer	Error de Mezcla	2	0.146722777777778
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Transporte	Ajuste o reparación de guías	2	0.145398254277778
TAL - Línea One Way V2	2024-12-24	Día Tarde	Mantenimiento	Robopac	Problema carga de batería	4	0.143826309666667
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	4	0.138376944444444
TAL - Línea One Way V2	2024-12-29	Día Tarde	Mantenimiento	Túnel	Falla en motor	2	0.134815516166667
TAL - Línea One Way V2	2024-12-26	Turno Noche	Mantenimiento	Sopladora	Bloqueo molde	3	0.132277222222222
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Mixer	Error de Mezcla	3	0.131014166666667
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	1	0.1300275
TAL - Línea RGB	2024-12-23	Turno Noche	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	5	0.126735
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Transporte	Cambio o reparación de sensor - Transporte	2	0.12194198425
TAL - Línea One Way V2	2024-12-26	Turno Noche	Mantenimiento	Sopladora	Problema en el Chiller	3	0.121710277777778
TAL - Línea One Way V2	2024-12-27	Turno Día	Mantenimiento	Llenadora	Defectos Nudos PLC	7	0.121585674833333
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	Mantenimiento	Codificador	Ajuste por cambio de fecha	3	0.121535000833333
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.120213055555556
TAL - Línea One Way V2	2024-12-26	Día Tarde	Mantenimiento	Paletizadora	Araña toma cartón en falla	6	0.116915639916667
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.115711388888889
TAL - Línea One Way V2	2024-12-26	Turno Noche	Mantenimiento	Sopladora	Molde con problemas	13	0.110593888916667
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Robopac	Problema carga de batería	3	0.108965793888889
TAL - Línea One Way V2	2024-12-24	Turno Día	Mantenimiento	Paletizadora	Cambio o reparación de sensor - Paletizadora	3	0.103794365166667
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Noche	Mantenimiento	Despaletizadora	Ajuste o cambio - Despaletizadora	1	0.0992758730555556
TAL - Línea One Way V2	2024-12-26	Día Tarde	Mantenimiento	Capsuladora	Tapa girada cabezal N° 12	4	0.0986486111111111
TAL - Línea One Way V2	2024-12-23	Turno Noche	Mantenimiento	Llenadora	Sensor de Tapa Humedo	7	0.0971325378333333
TAL - Línea One Way V2	2024-12-27	Día Tarde	Mantenimiento	Sopladora	Temperatura sobre los cuerpos de los moldes fuera	2	0.0970574207222222
TAL - Línea One Way V2	2024-12-26	Turno Día	Mantenimiento	Paletizadora	Reparación mesa paletizadora	3	0.0961530555555556
TAL - Línea RGB	2024-12-23	Turno Noche	Mantenimiento	Codificador	Ajuste por cambio de formato - Codificador	2	0.0950322222222222
TAL - Línea One Way V2	2024-12-24	Turno Día	Mantenimiento	Llenadora	Espumado al inicio de proceso	3	0.0896873019722222
TAL - Línea One Way V2	2024-12-27	Turno Día	Mantenimiento	Robopac	Problema en Soldadora	0	0.0888594444444444
TAL - Línea One Way V2	2024-12-27	Día Tarde	Mantenimiento	Sopladora	Problema en el Chiller	2	0.0861036509722222
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	6	0.0847821829722222
TAL - Línea RGB	2024-12-23	Turno Noche	Mantenimiento	Llenadora	Espumado al inicio de proceso	1	0.0833333333333333
TAL - Línea One Way V2	2024-12-26	Día Tarde	Mantenimiento	Capsuladora	Tapa girada cabezal N° 9	2	0.08253722225
TAL - Línea One Way V2	2024-12-23	Turno Noche	Mantenimiento	Llenadora	Sensor de Tapa Humedo	2	0.0813647479166667
TAL - Línea RGB	2024-12-23	Turno Dia	Mantenimiento	Etiquetadora	Falla Etiquetadora	2	0.0792008333333333
TAL - Línea RGB	2024-12-23	Turno Noche	Mantenimiento	Omnivision	Ajuste eléctrico o mecánico	9	0.0791930555555556
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	4	0.0771122231944444
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Mixer	Brix jarabe bajo	17	0.0758730555555555
TAL - Línea One Way V2	2024-12-29	Turno Noche	Mantenimiento	Capsuladora	Tapa girada cabezal N° 10	7	0.0743032143611111
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.0731041666666667
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	1	0.0696075
TAL - Línea One Way V2	2024-12-24	Turno Noche	Mantenimiento	Transporte	Divisor de paquetes	3	0.0678846431944445
TAL - Línea One Way V2	2024-12-23	Turno Día	Mantenimiento	Etiquetadora	Falla Etiquetadora	1	0.0651755555555556
TAL - Línea One Way V2	2024-12-26	Día Tarde	Mantenimiento	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	4	0.0630852778055555
TAL - Línea One Way V2	2024-12-23	Turno Día	Mantenimiento	Etiquetadora	Falla Etiquetadora	0	0.0621655555555556
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Robopac	Cambio o reparación de sensor - Robopac	2	0.0590681746944444
TAL - Línea RGB	2024-12-23	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0550202777777778
TAL - Línea RGB	2024-12-29	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0550169444444444
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Día	Mantenimiento	Decapsuladora	Ajustes por falla	15	0.0536852918611111
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Mixer	Brix jarabe bajo	1	0.0525305555555556
TAL - Línea One Way V2	2024-12-29	Día Tarde	Mantenimiento	Sopladora	Problema en el Chiller	3	0.0513250793888889
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	3	0.0502628175277778
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0491772222222222
TAL - Línea One Way V2	2024-12-29	Día Tarde	Mantenimiento	Prime	Trabamiento de producto	4	0.0457265081388889
TAL - Línea RGB	2024-12-28	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	1	0.0454297222222222
TAL - Línea One Way V2	2024-12-26	Turno Noche	Mantenimiento	Capsuladora	Tapa girada cabezal N° 10	1	0.045015
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	2	0.0450108340277778
TAL - Línea One Way V2	2024-12-29	Día Tarde	Mantenimiento	Prime	Trabamiento de producto	1	0.0444158730277778
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	2	0.0443310629722222
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Mixer	Brix jarabe bajo	7	0.0441916666666667
TAL - Línea One Way V2	2024-12-28	Turno Día	Mantenimiento	Sopladora	Cambio o reparación de sensor - Sopladora	4	0.0433533336944444
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.0426816666666667
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0425208333333333
TAL - Línea Ref Pet (Llenadora)	2024-12-23	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0408051593333333
TAL - Línea RGB	2024-12-28	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0400075
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	2	0.0397744048611111
TAL - Línea RGB	2024-12-29	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	2	0.0387580555555556
TAL - Línea RGB	2024-12-27	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	9	0.0379347222222222
TAL - Línea RGB	2024-12-29	Turno Noche	Mantenimiento	Codificador	Ajuste por cambio de formato - Codificador	1	0.0379263888888889
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0374482943055556
TAL - Línea RGB	2024-12-28	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	8	0.0358466666666667
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0358408333333333
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.0350472222222222
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Noche	Mantenimiento	Transporte	Cambio o reparación de sensor - Transporte	1	0.0345069444444444
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de botellas salida de la lavadora	1	0.03419
TAL - Línea RGB	2024-12-23	Turno Dia	Mantenimiento	Etiquetadora	Falla Etiquetadora	5	0.0341880555555556
TAL - Línea One Way V2	2024-12-24	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	3	0.0340570637222222
TAL - Línea One Way V2	2024-12-27	Día Tarde	Mantenimiento	Transporte	Trabamiento entrada curva encausador	2	0.0335914288055556
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	3	0.0333594444444444
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Noche	Mantenimiento	Lavadora de Botellas	Ajuste o cambio de encoder - Lavadora de Botellas	1	0.0294613888888889
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	5	0.0293998427777778
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	3	0.0291572222222222
TAL - Línea RGB	2024-12-29	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0287594444444444
TAL - Línea RGB	2024-12-29	Turno Noche	Mantenimiento	Lavadora de Botellas	trabamiento de botella en entrada	1	0.0279458333333333
TAL - Línea RGB	2024-12-28	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	6	0.0279327777777778
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Mixer	Brix jarabe bajo	7	0.0266805555555556
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	1	0.0252808333333333
TAL - Línea RGB	2024-12-28	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	4	0.0250108333333333
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Día	Mantenimiento	Etiquetadora	Ajuste o cambio de cuchillo	0	0.0247291666666667
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	1	0.0241758333333333
TAL - Línea RGB	2024-12-28	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	3	0.0237644444444444
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Mixer	Brix jarabe bajo	6	0.0233502777777778
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	Mantenimiento	Codificador	Ajuste por cambio de fecha	3	0.0226287708333333
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0225041666666667
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	2	0.0222738494722222
TAL - Línea One Way V2	2024-12-24	Turno Noche	Mantenimiento	Transporte	Divisor de paquetes	1	0.0221586906388889
TAL - Línea One Way V2	2024-12-29	Turno Día	Mantenimiento	Llenadora	Espumado al inicio de proceso	2	0.0221528574444444
TAL - Línea RGB	2024-12-29	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.0220894444444444
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	1	0.0220869444444444
TAL - Línea RGB	2024-12-29	Turno Noche	Mantenimiento	Lavadora de Botellas	trabamiento de botella en entrada	1	0.0216825
TAL - Línea RGB	2024-12-29	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.0208425
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Lavadora de Botellas	trabamiento de botella en entrada	4	0.0208386111111111
TAL - Línea RGB	2024-12-29	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	4	0.0208375
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.0204333333333333
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.0204211111111111
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0200733730555556
TAL - Línea RGB	2024-12-29	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.0191922222222222
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Mixer	Brix jarabe bajo	1	0.0191713888888889
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	3	0.0183563888888889
TAL - Línea Ref Pet (Llenadora)	2024-12-27	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0183186907777778
TAL - Línea RGB	2024-12-28	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	4	0.0179369444444444
TAL - Línea One Way V2	2024-12-24	Turno Noche	Mantenimiento	Transporte	Divisor de paquetes	1	0.0177519842222222
TAL - Línea Ref Pet (Llenadora)	2024-12-27	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.0177497622222222
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	5	0.0170919444444444
TAL - Línea One Way V2	2024-12-23	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	2	0.0170239388611111
TAL - Línea One Way V2	2024-12-23	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	3	0.0156886606111111
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	Mantenimiento	Encajonadora	Ajuste o cambio - Encajonadora	3	0.0151417461111111
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	9	0.0133477777777778
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	3	0.0133444444444444
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	1	0.0133430555555556
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	1	0.0133377777777778
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	3	0.0129277777777778
TAL - Línea RGB	2024-12-28	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	5	0.0112558333333333
TAL - Línea RGB	2024-12-27	Turno Noche	Mantenimiento	Llenadora	Lubricación de pedestales - Llenadora	2	0.0112541666666667
TAL - Línea One Way V2	2024-12-28	Turno Día	Mantenimiento	Sopladora	Cambio o reparación de sensor - Sopladora	3	0.0112021431388889
TAL - Línea One Way V2	2024-12-29	Día Tarde	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.0100047223055556
TAL - Línea RGB	2024-12-27	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	4	0.00959055555555556
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	3	0.00958916666666667
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	3	0.00917277777777778
TAL - Línea RGB	2024-12-27	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.00834333333333333
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	4	0.00709111111111111
TAL - Línea One Way V2	2024-12-23	Día Tarde	Mantenimiento	Robopac	Problema carga de batería	2	0.00703186522222222
TAL - Línea RGB	2024-12-27	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	5	0.00667166666666667
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	3	0.00667083333333333
TAL - Línea RGB	2024-12-27	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.00625472222222222
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.00625361111111111
TAL - Línea One Way V2	2024-12-28	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	1	0.00595321430555556
TAL - Línea RGB	2024-12-24	Turno Noche	Mantenimiento	Mixer	Error de Mezcla	2	0.00583583333333333
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.00500472222222222
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.00458333333333333
TAL - Línea One Way V2	2024-12-27	Día Tarde	Mantenimiento	Sopladora	Problema en el Chiller	1	0.00452269844444444
TAL - Línea One Way V2	2024-12-26	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	2	0.00417444447222222
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	3	0.0037575
TAL - Línea One Way V2	2024-12-24	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	1	0.00369853188888889
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.00340503972222222
TAL - Línea RGB	2024-12-27	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	2	0.00333805555555556
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Mixer	Error de Mezcla	2	0.00333611111111111
TAL - Línea One Way V2	2024-12-29	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	2	0.00309579372222222
TAL - Línea One Way V2	2024-12-23	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	1	0.00288181280555556
TAL - Línea One Way V2	2024-12-29	Turno Noche	Mantenimiento	Sopladora	Trabamiento de Preformas	1	0.00274142858333333
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Mixer	Error de Mezcla	1	0.0025025
TAL - Línea RGB	2024-12-29	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	1	0.00250083333333333
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.00250055555555556
TAL - Línea RGB	2024-12-24	Turno Dia	Mantenimiento	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	1	0.00166833333333333
TAL - Línea RGB	2024-12-27	Turno Dia	Mantenimiento	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	1	0.00166722222222222
TAL - Línea RGB	2024-12-28	Turno Noche	Mantenimiento	Lavadora de Botellas	Caída de botellas salida de la lavadora	1	0.00166722222222222
TAL - Línea RGB	2024-12-26	Turno Dia	Mantenimiento	Mixer	Brix jarabe bajo	1	0.000835
TAL - Línea RGB	2024-12-27	Turno Noche	Mantenimiento	Coronador	Trancónes reiterados pista de bajada	1	0.000833888888888889
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Día	Mantenimiento	Paletizadora	Caída de automático - Paletizadora	1	0.000358531944444444
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Reseteo tablero eléctrico	1	0
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Error de Mezcla	1	0
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Error de Mezcla	0	0
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Error de Mezcla	1	0
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Reseteo tablero eléctrico	1	0
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Error de Mezcla	3	0
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Error de Mezcla	1	0
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Error de Mezcla	3	0
TAL - Línea RGB	2024-12-26	Unscheduled	Mantenimiento	Mixer	Error de Mezcla	4	0
\.


--
-- Data for Name: db_averias_consolidado; Type: TABLE DATA; Schema: datos_maquinaria; Owner: postgres
--

COPY datos_maquinaria.db_averias_consolidado (id, mes, semana, fecha, "año", turno, maquina, sintoma, areas, minutos, observaciones) FROM stdin;
L1	Dec	52	2024-12-23	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.941	HOLA
L1	Dec	52	2024-12-23	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	1.021	HOLA2
L1	Dec	52	2024-12-23	2024	Turno Tarde	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	Paros Menores	1.336	COCACOLA ESPUMAA
L4	Dec	52	2024-12-23	2024	Turno Día	Etiquetadora	Falla Etiquetadora	Paros Menores	2.051	SPRITE
L3	Dec	52	2024-12-23	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	2.448	EL CAMPEONNN
L1	Dec	52	2024-12-23	2024	Turno Tarde	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	2.66	ALKJDHALKJDHDLKJA
L1	Dec	52	2024-12-23	2024	Turno Tarde	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	Paros Menores	3.016	GSDFHDS
L4	Dec	52	2024-12-23	2024	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	3.301	WECO
L1	Dec	52	2024-12-23	2024	Turno Tarde	Robopac	Cambio o reparación de sensor - Robopac	Paros Menores	3.544	ZAPALLO KL
L1	Dec	52	2024-12-23	2024	Turno Día	Etiquetadora	Falla Etiquetadora	Paros Menores	3.73	
L1	Dec	52	2024-12-23	2024	Turno Día	Etiquetadora	Falla Etiquetadora	Paros Menores	3.911	
L1	Dec	52	2024-12-23	2024	Turno Tarde	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	Paros Menores	4.627	
L4	Dec	52	2024-12-23	2024	Turno Noche	Omnivision	Ajuste eléctrico o mecánico	Paros Menores	4.752	
L4	Dec	52	2024-12-23	2024	Turno Día	Etiquetadora	Falla Etiquetadora	Paros Menores	4.752	
L1	Dec	52	2024-12-23	2024	Turno Noche	Llenadora	Sensor de Tapa Humedo	Paros Menores	4.882	
L4	Dec	52	2024-12-23	2024	Turno Noche	Llenadora	Espumado al inicio de proceso	Mecánico	5	
L1	Dec	52	2024-12-23	2024	Turno Tarde	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento		5.087	
L4	Dec	52	2024-12-23	2024	Turno Noche	Codificador	Ajuste por cambio de formato - Codificador		5.702	
L1	Dec	52	2024-12-23	2024	Turno Noche	Llenadora	Sensor de Tapa Humedo		5.828	
L1	Dec	52	2024-12-23	2024	Turno Tarde	Robopac	Problema carga de batería		6.538	
L1	Dec	52	2024-12-23	2024	Turno Tarde	Transporte	Cambio o reparación de sensor - Transporte		7.317	
L4	Dec	52	2024-12-23	2024	Turno Noche	Omnivision	Ajuste eléctrico o mecánico		7.604	
L1	Dec	52	2024-12-23	2024	Turno Tarde	Transporte	Ajuste o reparación de guías		8.724	
L3	Dec	52	2024-12-23	2024	Turno Día	Transporte	Transporte lleno reparación cadena		9.325	
L1	Dec	52	2024-12-23	2024	Turno Noche	Paletizadora	Pérdida de ciclo		10.072	
L1	Dec	52	2024-12-23	2024	Turno Día	Túnel	Falla en motor		10.489	
L1	Dec	52	2024-12-23	2024	Turno Tarde	Robopac	Problema carga de batería	Paros Menores	0.422	
L3	Dec	52	2024-12-23	2024	Turno Día	Transporte	Transporte lleno reparación cadena	Eléctrico	11.513	
L1	Dec	52	2024-12-23	2024	Turno Día	Paletizadora	Paletizadora problema con receta		11.87	
L1	Dec	52	2024-12-23	2024	Turno Tarde	Transporte	Ajuste o reparacion de barandas		13.447	
L1	Dec	52	2024-12-23	2024	Turno Día	Sopladora	Pruebas por mantención		15.861	
L4	Dec	52	2024-12-23	2024	Turno Noche	Llenadora	Espumado al inicio de proceso		16.219	
L1	Dec	52	2024-12-23	2024	Turno Día	Etiquetadora	Falla Etiquetadora		19.892	
L1	Dec	52	2024-12-23	2024	Turno Tarde	Codificador	Problema en encoder		23.616	
L4	Dec	52	2024-12-23	2024	Turno Día	Etiquetadora	Falla Etiquetadora		27.207	
L1	Dec	52	2024-12-23	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.173	
L3	Dec	52	2024-12-24	2024	Turno Día	Paletizadora	Caída de automático - Paletizadora	Paros Menores	0.022	
L4	Dec	52	2024-12-24	2024	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	0.1	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla	Paros Menores	0.8	
L3	Dec	52	2024-12-24	2024	Turno Noche	Lavadora de Botellas	Ajuste o cambio de encoder - Lavadora de Botellas		55.579	
L1	Dec	52	2024-12-24	2024	Turno Noche	Sopladora	Trabamiento de Preformas		52.681	
L3	Dec	52	2024-12-24	2024	Turno Noche	Lavadora de Botellas	Ajuste o cambio de encoder - Lavadora de Botellas		48.834	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla		45.898	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla		45.097	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla		34.951	
L3	Dec	52	2024-12-24	2024	Turno Día	Paletizadora	Caída de automático - Paletizadora		14.823	
L1	Dec	52	2024-12-24	2024	Turno Noche	Sopladora	Trabamiento de Preformas		13.213	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla		12.452	
L4	Dec	52	2024-12-24	2024	Turno Día	Decapsuladora	Ajuste o cambio de sensor - Decapsuladora		11.804	
L1	Dec	52	2024-12-24	2024	Turno Noche	Sopladora	Pruebas por mantención		9.346	
L4	Dec	52	2024-12-24	2024	Turno Día	Mixer	Error de Mezcla		8.803	
L1	Dec	52	2024-12-24	2024	Turno Tarde	Robopac	Problema carga de batería		8.63	
L4	Dec	52	2024-12-24	2024	Turno Día	Mixer	Error de Mezcla		7.861	
L4	Dec	52	2024-12-24	2024	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento		7.802	
L3	Dec	52	2024-12-24	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento		7.213	
L1	Dec	52	2024-12-24	2024	Turno Día	Paletizadora	Cambio o reparación de sensor - Paletizadora		6.228	
L1	Dec	52	2024-12-24	2024	Turno Día	Llenadora	Espumado al inicio de proceso		5.381	
L1	Dec	52	2024-12-24	2024	Turno Noche	Transporte	Divisor de paquetes	Paros Menores	4.073	
L4	Dec	52	2024-12-24	2024	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	2.951	
L4	Dec	52	2024-12-24	2024	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	2.551	
L3	Dec	52	2024-12-24	2024	Turno Noche	Transporte	Cambio o reparación de sensor - Transporte	Paros Menores	2.07	
L1	Dec	52	2024-12-24	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	2.043	
L3	Dec	52	2024-12-24	2024	Turno Noche	Lavadora de Botellas	Ajuste o cambio de encoder - Lavadora de Botellas	Paros Menores	1.768	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla	Paros Menores	1.451	
L1	Dec	52	2024-12-24	2024	Turno Noche	Transporte	Divisor de paquetes	Paros Menores	1.33	
L4	Dec	52	2024-12-24	2024	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	1.101	
L1	Dec	52	2024-12-24	2024	Turno Noche	Transporte	Divisor de paquetes	Paros Menores	1.065	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla	Paros Menores	0.801	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla	Paros Menores	0.801	
L4	Dec	52	2024-12-24	2024	Turno Noche	Mixer	Error de Mezcla	Paros Menores	0.35	
L1	Dec	52	2024-12-24	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.222	
L4	Dec	52	2024-12-24	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0.2	
L4	Dec	52	2024-12-24	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0.15	
L3	Dec	52	2024-12-26	2024	Turno Día	Decapsuladora	Ajustes por falla		18.108	
L3	Dec	52	2024-12-26	2024	Turno Día	Etiquetadora	Ajuste o cambio de cuchillo		23.635	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Reseteo tablero eléctrico	Paros Menores	0	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Brix jarabe bajo	Paros Menores	1.15	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Brix jarabe bajo	Paros Menores	0.05	
L4	Dec	52	2024-12-26	2024	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	1.35	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Brix jarabe bajo	Paros Menores	1.401	
L3	Dec	52	2024-12-26	2024	Turno Día	Etiquetadora	Ajuste o cambio de cuchillo	Paros Menores	1.484	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Brix jarabe bajo	Paros Menores	1.601	
L3	Dec	52	2024-12-26	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.764	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Brix jarabe bajo	Paros Menores	2.652	
L3	Dec	52	2024-12-26	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	2.701	
L1	Dec	52	2024-12-26	2024	Turno Noche	Capsuladora	Tapa girada cabezal N° 10	Paros Menores	2.701	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Brix jarabe bajo	Paros Menores	3.152	
L3	Dec	52	2024-12-26	2024	Turno Día	Decapsuladora	Ajustes por falla	Paros Menores	3.221	
L1	Dec	52	2024-12-26	2024	Turno Tarde	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	Paros Menores	3.785	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Brix jarabe bajo	Paros Menores	4.552	
L1	Dec	52	2024-12-26	2024	Turno Tarde	Capsuladora	Tapa girada cabezal N° 9	Paros Menores	4.952	
L1	Dec	52	2024-12-26	2024	Turno Día	Paletizadora	Reparación mesa paletizadora		5.769	
L1	Dec	52	2024-12-26	2024	Turno Tarde	Capsuladora	Tapa girada cabezal N° 12		5.919	
L3	Dec	52	2024-12-26	2024	Turno Noche	Despaletizadora	Ajuste o cambio - Despaletizadora		5.957	
L1	Dec	52	2024-12-26	2024	Turno Noche	Sopladora	Molde con problemas		6.636	
L1	Dec	52	2024-12-26	2024	Turno Tarde	Paletizadora	Araña toma cartón en falla		7.015	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0	
L1	Dec	52	2024-12-26	2024	Turno Noche	Sopladora	Problema en el Chiller		7.303	
L1	Dec	52	2024-12-26	2024	Turno Noche	Sopladora	Bloqueo molde		7.937	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Reseteo tablero eléctrico	Paros Menores	0	
L1	Dec	52	2024-12-26	2024	Turno Día	Paletizadora	Ajuste o cambio de sensor - Paletizadora		9.337	
L1	Dec	52	2024-12-26	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.25	
L1	Dec	52	2024-12-26	2024	Turno Tarde	Paletizadora	Araña toma cartón en falla		9.469	
L1	Dec	52	2024-12-26	2024	Turno Día	Sopladora	Mantención Horno		10.805	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Brix jarabe bajo		12.404	
L1	Dec	52	2024-12-26	2024	Turno Noche	Codificador	Regulación de Altura - Mantenimiento		13.788	
L1	Dec	52	2024-12-26	2024	Turno Tarde	Túnel	Ajuste de rodillo ( Balanza)		13.985	
L1	Dec	52	2024-12-26	2024	Turno Día	Paletizadora	Araña toma cartón en falla		14.369	
L4	Dec	52	2024-12-26	2024	Turno Día	Mixer	Error de Mezcla	Paros Menores	0	
L1	Dec	52	2024-12-26	2024	Turno Tarde	Paletizadora	Araña toma cartón en falla		17.413	
L1	Dec	52	2024-12-26	2024	Turno Noche	Sopladora	Molde con problemas		19.505	
L1	Dec	52	2024-12-26	2024	Turno Tarde	Túnel	Ajuste de rodillo ( Balanza)		19.709	
L1	Dec	52	2024-12-26	2024	Turno Noche	Sopladora	Presión de soplado insuficiente		23.44	
L4	Dec	52	2024-12-27	2024	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	Paros Menores	4.176	
L4	Dec	52	2024-12-27	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.501	
L4	Dec	52	2024-12-27	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.4	
L4	Dec	52	2024-12-27	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.375	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.375	
L1	Dec	52	2024-12-27	2024	Turno Día	Robopac	Problema en Soldadora		18.506	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.3	
L1	Dec	52	2024-12-27	2024	Turno Tarde	Sopladora	Problema en el Chiller	Paros Menores	0.271	
L1	Dec	52	2024-12-27	2024	Turno Tarde	Paletizadora	Trabamiento de paletas		10.257	
L4	Dec	52	2024-12-27	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.2	
L1	Dec	52	2024-12-27	2024	Turno Día	Llenadora	Defectos Nudos PLC		7.295	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada		6.943	
L1	Dec	52	2024-12-27	2024	Turno Tarde	Sopladora	Temperatura sobre los cuerpos de los moldes fuera		5.823	
L1	Dec	52	2024-12-27	2024	Turno Día	Robopac	Problema en Soldadora		5.332	
L1	Dec	52	2024-12-27	2024	Turno Tarde	Sopladora	Problema en el Chiller		5.166	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	4.386	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	2.561	
L4	Dec	52	2024-12-27	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	2.276	
L4	Dec	52	2024-12-27	2024	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	2.15	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	2.103	
L1	Dec	52	2024-12-27	2024	Turno Tarde	Transporte	Trabamiento entrada curva encausador	Paros Menores	2.015	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	2.002	
L4	Dec	52	2024-12-27	2024	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	Paros Menores	0.1	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.749	
L4	Dec	52	2024-12-27	2024	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	Paros Menores	1.517	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.226	
L4	Dec	52	2024-12-27	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.05	
L3	Dec	52	2024-12-27	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.099	
L3	Dec	52	2024-12-27	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.065	
L4	Dec	52	2024-12-27	2024	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	Paros Menores	1.026	
L4	Dec	52	2024-12-27	2024	Turno Noche	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	0.675	
L4	Dec	52	2024-12-27	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.575	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.575	
L4	Dec	52	2024-12-27	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.55	
L4	Dec	52	2024-12-28	2024	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	2.4	
L3	Dec	52	2024-12-28	2024	Turno Noche	Encajonadora	Ajuste o cambio - Encajonadora		45.757	
L4	Dec	52	2024-12-28	2024	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	Paros Menores	2.726	
L1	Dec	52	2024-12-28	2024	Turno Día	Sopladora	Cambio o reparación de sensor - Sopladora	Paros Menores	0.672	
L4	Dec	52	2024-12-28	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.675	
L1	Dec	52	2024-12-28	2024	Turno Noche	Robopac	Problema en Soldadora		37.727	
L1	Dec	52	2024-12-28	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.357	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.776	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.225	
L4	Dec	52	2024-12-28	2024	Turno Noche	Lavadora de Botellas	trabamiento de botella en entrada	Paros Menores	1.25	
L4	Dec	52	2024-12-28	2024	Turno Noche	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	1.325	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.801	
L3	Dec	52	2024-12-28	2024	Turno Noche	Encajonadora	Ajuste o cambio - Encajonadora	Paros Menores	0.909	
L3	Dec	52	2024-12-28	2024	Turno Noche	Codificador	Ajuste por cambio de fecha	Paros Menores	1.358	
L4	Dec	52	2024-12-28	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.426	
L3	Dec	52	2024-12-28	2024	Turno Noche	Codificador	Ajuste por cambio de fecha		7.292	
L4	Dec	52	2024-12-28	2024	Turno Noche	Lavadora de Botellas	Caída de botellas salida de la lavadora	Paros Menores	0.1	
L4	Dec	52	2024-12-28	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.501	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.275	
L4	Dec	52	2024-12-28	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.676	
L4	Dec	52	2024-12-28	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.076	
L3	Dec	52	2024-12-28	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.204	
L4	Dec	52	2024-12-28	2024	Turno Noche	Lavadora de Botellas	Caída de botellas salida de la lavadora	Paros Menores	2.051	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.15	
L4	Dec	52	2024-12-28	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	2.151	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.225	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.425	
L3	Dec	52	2024-12-28	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	2.247	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada		8.303	
L3	Dec	52	2024-12-28	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	0.204	
L4	Dec	52	2024-12-28	2024	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.4	
L1	Dec	52	2024-12-28	2024	Turno Día	Sopladora	Cambio o reparación de sensor - Sopladora	Paros Menores	2.601	
L3	Dec	52	2024-12-28	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	2.386	
L4	Dec	52	2024-12-29	2024	Turno Noche	Codificador	Ajuste por cambio de formato - Codificador	Paros Menores	2.276	
L1	Dec	52	2024-12-29	2024	Turno Tarde	Túnel	Falla en motor		8.089	
L4	Dec	52	2024-12-29	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	2.325	
L1	Dec	52	2024-12-29	2024	Turno Tarde	Prime	Trabamiento de producto	Paros Menores	2.665	
L1	Dec	52	2024-12-29	2024	Turno Tarde	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	0.6	
L1	Dec	52	2024-12-29	2024	Turno Tarde	Prime	Trabamiento de producto	Paros Menores	2.744	
L4	Dec	52	2024-12-29	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	0.15	
L1	Dec	52	2024-12-29	2024	Turno Tarde	Sopladora	Problema en el Chiller	Paros Menores	3.08	
L4	Dec	52	2024-12-29	2024	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	3.301	
L1	Dec	52	2024-12-29	2024	Turno Noche	Capsuladora	Tapa girada cabezal N° 10	Paros Menores	4.458	
L1	Dec	52	2024-12-29	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.164	
L4	Dec	52	2024-12-29	2024	Turno Noche	Lavadora de Botellas	trabamiento de botella en entrada	Paros Menores	1.677	
L1	Dec	52	2024-12-29	2024	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.186	
L4	Dec	52	2024-12-29	2024	Turno Noche	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.726	
L4	Dec	52	2024-12-29	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.25	
L4	Dec	52	2024-12-29	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.152	
L4	Dec	52	2024-12-29	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.251	
L4	Dec	52	2024-12-29	2024	Turno Noche	Lavadora de Botellas	trabamiento de botella en entrada	Paros Menores	1.301	
L4	Dec	52	2024-12-29	2024	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.325	
L1	Dec	52	2024-12-29	2024	Turno Día	Llenadora	Espumado al inicio de proceso	Paros Menores	1.329	
L3	Jan	3	2025-01-13	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	4.592	
L1	Jan	3	2025-01-13	2025	Turno Día	Mixer	Presión de Co2 - Mantenimiento	Paros Menores	3.159	
L1	Jan	3	2025-01-13	2025	Turno Tarde	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	Mecánico	5.138	
L3	Jan	3	2025-01-13	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.182	
L3	Jan	3	2025-01-13	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.135	
L3	Jan	3	2025-01-13	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	0.84	
L1	Jan	3	2025-01-13	2025	Turno Día	Capsuladora	Cambio de cabezal	Paros Menores	4.358	
L1	Jan	3	2025-01-13	2025	Turno Día	Capsuladora	Cambio de cabezal	Eléctrico	20.747	
L1	Jan	3	2025-01-13	2025	Turno Día	Mixer	Presión de Co2 - Mantenimiento	Paros Menores	3.944	
L4	Jan	3	2025-01-13	2025	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	Paros Menores	0.15	
L3	Jan	3	2025-01-13	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.135	
L4	Jan	3	2025-01-13	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	1.601	
L1	Jan	3	2025-01-13	2025	Turno Día	Mixer	Presión de Co2 - Mantenimiento	Paros Menores	3.351	
L4	Jan	3	2025-01-13	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	1.951	
L4	Jan	3	2025-01-13	2025	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	Paros Menores	1.65	
L4	Jan	3	2025-01-13	2025	Turno Día	Mixer	Problema presión bomba de agua	Paros Menores	0.701	
L4	Jan	3	2025-01-13	2025	Turno Día	Mixer	Problema presión bomba de agua	Paros Menores	0.1	
L4	Jan	3	2025-01-13	2025	Turno Día	Lavadora de Botellas	Trabamiento de botellas en la salida - Mantenimiento	Paros Menores	0.151	
L4	Jan	3	2025-01-13	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	0.25	
L4	Jan	3	2025-01-14	2025	Turno Día	Mixer	Error de Mezcla	Paros Menores	3.051	
L1	Jan	3	2025-01-14	2025	Turno Noche	Robopac	Corte de Film en Robopack	Paros Menores	4.109	
L1	Jan	3	2025-01-14	2025	Turno Tarde	Sopladora	Trabamiento de Preformas	Paros Menores	0.622	
L1	Jan	3	2025-01-14	2025	Turno Noche	Robopac	Corte de Film en Robopack	Paros Menores	2.981	
L1	Jan	3	2025-01-14	2025	Turno Tarde	Sopladora	Problema en el Chiller	Paros Menores	3.973	
L1	Jan	3	2025-01-14	2025	Turno Noche	Codificador	Regulación de Altura - Mantenimiento	Paros Menores	0.437	
L4	Jan	3	2025-01-14	2025	Turno Día	Mixer	Error de Mezcla	Paros Menores	3.151	
L1	Jan	3	2025-01-14	2025	Turno Tarde	Robopac	Corte de Film en Robopack	Paros Menores	3.058	
L4	Jan	3	2025-01-14	2025	Turno Día	Mixer	Problema presión bomba de agua	Paros Menores	0.1	
L4	Jan	3	2025-01-14	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	1.151	
L4	Jan	3	2025-01-14	2025	Turno Día	Codificador	cabezal sucio	Eléctrico	10.004	
L4	Jan	3	2025-01-14	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	0.2	
L4	Jan	3	2025-01-14	2025	Turno Día	Mixer	Error de Mezcla	Paros Menores	0.7	
L4	Jan	3	2025-01-14	2025	Turno Día	Mixer	Problema presión bomba de agua	Paros Menores	0.15	
L1	Jan	3	2025-01-14	2025	Turno Noche	Robopac	Corte de Film en Robopack	Paros Menores	2.329	
L4	Jan	3	2025-01-14	2025	Turno Día	Mixer	Error de Mezcla	Paros Menores	1.1	
L4	Jan	3	2025-01-14	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	0.151	
L1	Jan	3	2025-01-14	2025	Turno Noche	Transporte	Divisor de paquetes	Paros Menores	0.836	
L1	Jan	3	2025-01-14	2025	Turno Tarde	Transporte	Divisor de paquetes	Paros Menores	0.972	
L3	Jan	3	2025-01-14	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	0.147	
L1	Jan	3	2025-01-14	2025	Turno Día	Mixer	Falla en bomba de Jarabes	Eléctrico	8.766	
L3	Jan	3	2025-01-14	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	2.363	
L1	Jan	3	2025-01-14	2025	Turno Día	Mixer	Falla en bomba de Jarabes	Paros Menores	3.623	
L1	Jan	3	2025-01-14	2025	Turno Tarde	Sopladora	Problema en el Chiller	Paros Menores	3.722	
L4	Jan	3	2025-01-14	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	0.1	
L3	Jan	3	2025-01-15	2025	Turno Día	Decapsuladora	Ajustes por falla		13.626	
L1	Jan	3	2025-01-15	2025	Turno Tarde	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	Paros Menores	4.656	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador		5.878	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	1.126	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador		14.179	
L1	Jan	3	2025-01-15	2025	Turno Día	Llenadora	Espumado al inicio de proceso	Paros Menores	3.145	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador		15.43	
L3	Jan	3	2025-01-15	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.623	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador		5.629	
L1	Jan	3	2025-01-15	2025	Turno Noche	Sopladora	Cambio de Lamparas	Paros Menores	2.57	
L1	Jan	3	2025-01-15	2025	Turno Día	Capsuladora	Cambio de cabezal	Paros Menores	4.874	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	1.601	
L1	Jan	3	2025-01-15	2025	Turno Tarde	Túnel	Falla en motor	Paros Menores	4.782	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	4.452	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Cambio o reparación - Coronador	Mecánico	20.833	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	4.228	
L1	Jan	3	2025-01-15	2025	Turno Noche	Robopac	Corte de Film en Robopack	Paros Menores	0.269	
L1	Jan	3	2025-01-15	2025	Turno Día	Capsuladora	Cambio de cabezal	Paros Menores	3.901	
L1	Jan	3	2025-01-15	2025	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.51	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	4.677	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.576	
L1	Jan	3	2025-01-15	2025	Turno Tarde	Paletizadora	Trabamiento de paletas		9.181	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Cambio o reparación - Coronador	Paros Menores	3.477	
L3	Jan	3	2025-01-15	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.613	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	2.077	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	1.526	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	2.789	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.325	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Reparación - Coronador	Eléctrico	24.77	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador		27.409	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Reparación - Coronador	Paros Menores	0.75	
L4	Jan	3	2025-01-15	2025	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	1.125	
L3	Jan	3	2025-01-15	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.495	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada		10.916	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Cambio o reparación - Coronador	Paros Menores	0.826	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Mecánico	7.679	
L1	Jan	3	2025-01-15	2025	Turno Noche	Robopac	Corte de Film en Robopack	Paros Menores	1.178	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador		13.179	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	3.789	
L4	Jan	3	2025-01-15	2025	Turno Día	Coronador	Cambio o reparación - Coronador		6.477	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	1.201	
L1	Jan	3	2025-01-15	2025	Turno Tarde	Llenadora	Salida llenadora, caída guía seguridad - Mantenimiento	Paros Menores	3.736	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	3.502	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.05	
L4	Jan	3	2025-01-15	2025	Turno Noche	Coronador	Cambio o reparación - Coronador	Paros Menores	0.25	
L3	Jan	3	2025-01-16	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.065	
L1	Jan	3	2025-01-16	2025	Turno Tarde	Túnel	Caída de botellas, ajuste de traspasos		6.787	
L4	Jan	3	2025-01-16	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.3	
L4	Jan	3	2025-01-16	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.425	
L1	Jan	3	2025-01-16	2025	Turno Día	Capsuladora	Cambio de cabezal		8.42	
L4	Jan	3	2025-01-16	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.025	
L3	Jan	3	2025-01-16	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.431	
L1	Jan	3	2025-01-16	2025	Turno Tarde	Sopladora	Presión de soplado insuficiente	Paros Menores	2.769	
L4	Jan	3	2025-01-16	2025	Turno Día	Coronador	Trancónes reiterados pista de bajada	Paros Menores	0.1	
L4	Jan	3	2025-01-16	2025	Turno Día	Despaletizadora	Falla motor transporte - Despaletizadora		8.503	
L4	Jan	3	2025-01-16	2025	Turno Día	Codificador	Ajuste por cambio de formato - Codificador	Paros Menores	0.7	
L1	Jan	3	2025-01-16	2025	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.495	
L3	Jan	3	2025-01-16	2025	Turno Día	Lavadora de Cajas	Reparación guia de cajas		21.591	
L1	Jan	3	2025-01-16	2025	Turno Tarde	Robopac	Problema en Soldadora		14.565	
L3	Jan	3	2025-01-16	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.109	
L1	Jan	3	2025-01-16	2025	Turno Tarde	Túnel	Caída de botellas, ajuste de traspasos	Paros Menores	0.252	
L3	Jan	3	2025-01-16	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.75	
L4	Jan	3	2025-01-16	2025	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	0.9	
L3	Jan	3	2025-01-16	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	3.885	
L1	Jan	3	2025-01-16	2025	Turno Noche	Capsuladora	Tapa girada cabezal N° 12		8.765	
L1	Jan	3	2025-01-16	2025	Turno Día	Capsuladora	Cambio de cabezal		10.721	
L3	Jan	3	2025-01-16	2025	Turno Día	Lavadora de Cajas	Reparación guia de cajas	Paros Menores	1.045	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Llenadora	Caída de guía de seguridad por problema en pinza - Botella mal tapada	Paros Menores	3.652	
L3	Jan	3	2025-01-17	2025	Turno Día	Omnivision	Falla Servomotor	Paros Menores	0	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Túnel	Producto desplazado salida recubrimiento - Mantenimiento	Paros Menores	4.101	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Túnel	Caída de botellas, ajuste de traspasos	Paros Menores	4.101	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Llenadora	Caída de guía de seguridad por problema en pinza - Botella mal tapada	Paros Menores	2.934	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Paletizadora	Sensor entrada divisor	Paros Menores	2.134	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Llenadora	Caída de guía de seguridad por problema en pinza - Botella mal tapada	Paros Menores	2.284	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Túnel	Falla en motor	Paros Menores	2.267	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Capsuladora	Tapa girada cabezal N° 1	Paros Menores	3.501	
L3	Jan	3	2025-01-17	2025	Turno Noche	Omnivision	Falla Servomotor	Paros Menores	1.938	
L1	Jan	3	2025-01-17	2025	Turno Tarde	Túnel	Ajuste de rodillo ( Balanza)		22.274	
L3	Jan	3	2025-01-17	2025	Turno Noche	Omnivision	Falla Servomotor		25.271	
L1	Jan	3	2025-01-17	2025	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	1.571	
L3	Jan	3	2025-01-17	2025	Turno Noche	Omnivision	Falla Servomotor		34.073	
L4	Jan	3	2025-01-17	2025	Turno Día	Llenadora	Lubricación de pedestales - Llenadora	Paros Menores	1.35	
L3	Jan	3	2025-01-17	2025	Turno Noche	Omnivision	Falla Servomotor		51.594	
L3	Jan	3	2025-01-17	2025	Turno Día	Omnivision	Falla Servomotor	Paros Menores	0	
L4	Jan	3	2025-01-17	2025	Turno Día	Transporte	Trabamiento curva salida pulmón	Paros Menores	0.9	
L3	Jan	3	2025-01-17	2025	Turno Noche	Omnivision	Falla Servomotor	Paros Menores	0.859	
L3	Jan	3	2025-01-17	2025	Turno Noche	Omnivision	Falla Servomotor	Paros Menores	0.849	
L1	Jan	3	2025-01-17	2025	Turno Noche	Capsuladora	Tapas giradas en cabezal		12.067	
L3	Jan	3	2025-01-17	2025	Turno Noche	Omnivision	Falla Servomotor		59.966	
L3	Jan	3	2025-01-17	2025	Turno Día	Omnivision	Falla Servomotor	Paros Menores	0	
L4	Jan	3	2025-01-17	2025	Turno Día	Capsuladora	Trancón de tapas en pista de bajada - Mantenimiento	Paros Menores	0.701	
L3	Jan	3	2025-01-17	2025	Turno Día	Omnivision	Falla Servomotor	Paros Menores	0	
L3	Jan	3	2025-01-17	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	0	
L3	Jan	3	2025-01-17	2025	Turno Día	Omnivision	Falla Servomotor	Paros Menores	0	
L3	Jan	3	2025-01-17	2025	Turno Día	Omnivision	Falla Servomotor	Paros Menores	0	
L4	Jan	3	2025-01-18	2025	Turno Día	Omnivision	Ajuste eléctrico o mecánico	Paros Menores	0.6	
L1	Jan	3	2025-01-18	2025	Turno Noche	Túnel	Rectificación de dientes de cuchillo	Paros Menores	2.895	
L4	Jan	3	2025-01-18	2025	Turno Día	Omnivision	Ajuste eléctrico o mecánico	Paros Menores	3.883	
L4	Jan	3	2025-01-18	2025	Turno Día	Omnivision	Ajuste eléctrico o mecánico	Paros Menores	3.469	
L4	Jan	3	2025-01-18	2025	Turno Noche	Paletizadora	Caída de automático - Paletizadora		10.202	
L4	Jan	3	2025-01-18	2025	Turno Día	Codificador	cabezal sucio		21.206	
L1	Jan	3	2025-01-19	2025	Turno Noche	Llenadora	Cambio o reparación de pinzas - Llenadora		5.052	
L1	Jan	3	2025-01-19	2025	Turno Tarde	Túnel	Ajuste de rodillo ( Balanza)		16.205	
L3	Jan	3	2025-01-19	2025	Turno Tarde	Capsuladora	Falla sensor		11.804	
L3	Jan	3	2025-01-19	2025	Turno Tarde	Omnivision	Ajuste eléctrico o mecánico	Paros Menores	1.716	
L1	Jan	3	2025-01-19	2025	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.817	
L3	Jan	3	2025-01-19	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	0.765	
L1	Jan	3	2025-01-19	2025	Turno Tarde	Túnel	Producto desplazado salida recubrimiento - Mantenimiento		19.255	
L1	Jan	3	2025-01-19	2025	Turno Tarde	Túnel	Ajuste de rodillo ( Balanza)		46.563	
L3	Jan	3	2025-01-19	2025	Turno Tarde	Omnivision	Ajuste eléctrico o mecánico		22.585	
L3	Jan	3	2025-01-19	2025	Turno Tarde	Omnivision	Ajuste eléctrico o mecánico		6.114	
L1	Jan	3	2025-01-19	2025	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	0.851	
L3	Jan	3	2025-01-19	2025	Turno Tarde	Capsuladora	Falla sensor		7.148	
L1	Jan	3	2025-01-19	2025	Turno Noche	Sopladora	Trabamiento de Preformas	Paros Menores	2.134	
L1	Jan	3	2025-01-19	2025	Turno Tarde	Sopladora	Problema compresor de alta		15.654	
L3	Jan	3	2025-01-19	2025	Turno Tarde	Omnivision	Ajuste eléctrico o mecánico	Paros Menores	2.905	
L3	Jan	3	2025-01-19	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	1.045	
L1	Jan	3	2025-01-19	2025	Turno Tarde	Túnel	Producto desplazado salida recubrimiento - Mantenimiento		5.303	
L1	Jan	3	2025-01-19	2025	Turno Tarde	Sopladora	Problema compresor de alta		15.906	
L1	Jan	3	2025-01-19	2025	Turno Noche	Llenadora	Cambio o reparación de pinzas - Llenadora		7.152	
L1	Jan	3	2025-01-19	2025	Turno Noche	Etiquetadora	Empalme defectuoso - Etiquetadora	Paros Menores	1.467	
L3	Jan	3	2025-01-19	2025	Turno Día	Lavadora de Botellas	Caída de envase en descarga - Mantenimiento	Paros Menores	0.348	
L1	Jan	3	2025-01-19	2025	Turno Tarde	Túnel	Producto desplazado salida recubrimiento - Mantenimiento		14.371	
\.


--
-- Data for Name: hpr_oee; Type: TABLE DATA; Schema: datos_maquinaria; Owner: postgres
--

COPY datos_maquinaria.hpr_oee (linea, fecha, "año", min, oee, mes, semana) FROM stdin;
L1	2025-01-13	2025	540	0.72	Jan	3
L1	2025-01-13	2025	450	0.64	Jan	3
L1	2025-01-14	2025	540	0.77	Jan	3
L1	2025-01-14	2025	450	0.66	Jan	3
L1	2025-01-14	2025	450	0.78	Jan	3
L1	2025-01-15	2025	540	0.72	Jan	3
L1	2025-01-15	2025	450	0.67	Jan	3
L1	2025-01-15	2025	450	0.64	Jan	3
L1	2025-01-16	2025	540	0.62	Jan	3
L1	2025-01-16	2025	450	0.65	Jan	3
L1	2025-01-16	2025	450	0.78	Jan	3
L1	2025-01-17	2025	480	0.72	Jan	3
L1	2025-01-17	2025	450	0.73	Jan	3
L1	2025-01-17	2025	450	0.69	Jan	3
L1	2025-01-18	2025	390	0.53	Jan	3
L1	2025-01-18	2025	450	0.82	Jan	3
L1	2025-01-19	2025	540	0.51	Jan	3
L1	2025-01-19	2025	450	0.75	Jan	3
L1	2025-01-19	2025	450	0.7	Jan	3
L3	2025-01-13	2025	450	0.58	Jan	3
L3	2025-01-14	2025	450	0.61	Jan	3
L3	2025-01-14	2025	450	0.64	Jan	3
L3	2025-01-15	2025	450	0.62	Jan	3
L3	2025-01-16	2025	450	0.63	Jan	3
L3	2025-01-16	2025	450	0.58	Jan	3
L3	2025-01-17	2025	450	0.24	Jan	3
L3	2025-01-19	2025	540	0.49	Jan	3
L3	2025-01-19	2025	450	0.59	Jan	3
L4	2025-01-13	2025	450	0.58	Jan	3
L4	2025-01-14	2025	330	0.57	Jan	3
L4	2025-01-15	2025	450	0.61	Jan	3
L4	2025-01-15	2025	450	0.31	Jan	3
L4	2025-01-16	2025	450	0.54	Jan	3
L4	2025-01-17	2025	450	0.73	Jan	3
L4	2025-01-18	2025	390	0.64	Jan	3
L4	2025-01-18	2025	450	0.64	Jan	3
L1	2025-01-13	2025	540	0.72	Jan	3
L1	2025-01-13	2025	450	0.64	Jan	3
L1	2025-01-14	2025	540	0.77	Jan	3
L1	2025-01-14	2025	450	0.66	Jan	3
L1	2025-01-14	2025	450	0.78	Jan	3
L1	2025-01-15	2025	540	0.72	Jan	3
L1	2025-01-15	2025	450	0.67	Jan	3
L1	2025-01-15	2025	450	0.64	Jan	3
L1	2025-01-16	2025	540	0.62	Jan	3
L1	2025-01-16	2025	450	0.65	Jan	3
L1	2025-01-16	2025	450	0.78	Jan	3
L1	2025-01-17	2025	480	0.72	Jan	3
L1	2025-01-17	2025	450	0.73	Jan	3
L1	2025-01-17	2025	450	0.69	Jan	3
L1	2025-01-18	2025	390	0.53	Jan	3
L1	2025-01-18	2025	450	0.82	Jan	3
L1	2025-01-19	2025	540	0.51	Jan	3
L1	2025-01-19	2025	450	0.75	Jan	3
L1	2025-01-19	2025	450	0.7	Jan	3
L3	2025-01-13	2025	450	0.58	Jan	3
L3	2025-01-14	2025	450	0.61	Jan	3
L3	2025-01-14	2025	450	0.64	Jan	3
L3	2025-01-15	2025	450	0.62	Jan	3
L3	2025-01-16	2025	450	0.63	Jan	3
L3	2025-01-16	2025	450	0.58	Jan	3
L3	2025-01-17	2025	450	0.24	Jan	3
L3	2025-01-19	2025	540	0.49	Jan	3
L3	2025-01-19	2025	450	0.59	Jan	3
L4	2025-01-13	2025	450	0.58	Jan	3
L4	2025-01-14	2025	330	0.57	Jan	3
L4	2025-01-15	2025	450	0.61	Jan	3
L4	2025-01-15	2025	450	0.31	Jan	3
L4	2025-01-16	2025	450	0.54	Jan	3
L4	2025-01-17	2025	450	0.73	Jan	3
L4	2025-01-18	2025	390	0.64	Jan	3
L4	2025-01-18	2025	450	0.64	Jan	3
L1	2024-12-23	2024	540	0.54	Dec	52
L1	2024-12-23	2024	450	0.3	Dec	52
L1	2024-12-23	2024	390	0.57	Dec	52
L1	2024-12-24	2024	180	0.32	Dec	52
L1	2024-12-24	2024	450	0.62	Dec	52
L1	2024-12-24	2024	450	0.58	Dec	52
L1	2024-12-26	2024	540	0.46	Dec	52
L1	2024-12-26	2024	450	0.62	Dec	52
L1	2024-12-26	2024	450	0.49	Dec	52
L1	2024-12-27	2024	480	0.68	Dec	52
L1	2024-12-27	2024	450	0.63	Dec	52
L1	2024-12-27	2024	450	0.68	Dec	52
L1	2024-12-28	2024	300	0.81	Dec	52
L1	2024-12-28	2024	450	0.64	Dec	52
L1	2024-12-29	2024	540	0.87	Dec	52
L1	2024-12-29	2024	450	0.82	Dec	52
L1	2024-12-29	2024	450	0.82	Dec	52
L3	2024-12-23	2024	450	0.58	Dec	52
L3	2024-12-23	2024	390	0.61	Dec	52
L3	2024-12-24	2024	450	0.46	Dec	52
L3	2024-12-24	2024	450	0.32	Dec	52
L3	2024-12-26	2024	450	0.67	Dec	52
L3	2024-12-26	2024	330	0.52	Dec	52
L3	2024-12-27	2024	450	0.64	Dec	52
L3	2024-12-27	2024	450	0.51	Dec	52
L3	2024-12-28	2024	180	0.74	Dec	52
L3	2024-12-28	2024	450	0.5	Dec	52
L4	2024-12-23	2024	450	0.65	Dec	52
L4	2024-12-23	2024	390	0.37	Dec	52
L4	2024-12-24	2024	450	0.52	Dec	52
L4	2024-12-24	2024	450	0.27	Dec	52
L4	2024-12-26	2024	450	0.57	Dec	52
L4	2024-12-27	2024	450	0.6	Dec	52
L4	2024-12-27	2024	450	0.48	Dec	52
L4	2024-12-28	2024	300	0.67	Dec	52
L4	2024-12-28	2024	450	0.59	Dec	52
L4	2024-12-29	2024	420	0.64	Dec	52
L4	2024-12-29	2024	450	0.6	Dec	52
\.


--
-- Data for Name: indicador_semanal; Type: TABLE DATA; Schema: datos_maquinaria; Owner: postgres
--

COPY datos_maquinaria.indicador_semanal (total_general, hpr, disp, meta, mtbf, mttr, averias, minutos, oee) FROM stdin;
L1	17940	100	0.95	299	5.14	1	5.14	68.95%
L2	0	0	0.95	0	0	0	0	0
L3	8280	100	0.95	0	0	0	0	55.33%
L4	6840	100	0.95	57	14.26	2	28.51	57.75%
PLANTA	33060	100	0.95	183.67	11.22	3	33.65	63.06%
\.


--
-- Data for Name: oeeydisponibilidad; Type: TABLE DATA; Schema: datos_maquinaria; Owner: postgres
--

COPY datos_maquinaria.oeeydisponibilidad (machine_name, days_in_calendar_datetime, shift_name, horas_produciendo, horas_planificadas, oee) FROM stdin;
TAL - Línea One Way V2	2025-01-13	Día Tarde	7.20128836852778	8.99999984130556	0.720
TAL - Línea One Way V2	2025-01-13	Turno Día	5.52769555302778	7.49999984127778	0.640
TAL - Línea One Way V2	2025-01-14	Día Tarde	7.39757231569444	8.99999984133333	0.770
TAL - Línea One Way V2	2025-01-14	Turno Día	5.59573995661111	7.5	0.660
TAL - Línea One Way V2	2025-01-14	Turno Noche	6.33672563258333	7.49999972241667	0.780
TAL - Línea One Way V2	2025-01-15	Día Tarde	7.85186614877778	9	0.720
TAL - Línea One Way V2	2025-01-15	Turno Día	6.27099877619444	7.49999954655556	0.670
TAL - Línea One Way V2	2025-01-15	Turno Noche	6.28105836661111	7.49999978877778	0.640
TAL - Línea One Way V2	2025-01-16	Día Tarde	6.29399853813889	8.99999960836111	0.620
TAL - Línea One Way V2	2025-01-16	Turno Día	5.97775374322222	7.49999998833333	0.650
TAL - Línea One Way V2	2025-01-16	Turno Noche	6.796796689	7.5	0.780
TAL - Línea One Way V2	2025-01-17	Día Tarde	6.37887249980556	8	0.720
TAL - Línea One Way V2	2025-01-17	Turno Día	6.00301499986111	7.5	0.730
TAL - Línea One Way V2	2025-01-17	Turno Noche	5.67474037461111	7.49999982047222	0.690
TAL - Línea One Way V2	2025-01-18	Turno Día	3.75555111105556	6.5	0.530
TAL - Línea One Way V2	2025-01-18	Turno Noche	6.52111499994444	7.5	0.820
TAL - Línea One Way V2	2025-01-19	Día Tarde	5.11019579269444	9	0.510
TAL - Línea One Way V2	2025-01-19	Turno Día	6.20760777769444	7.5	0.750
TAL - Línea One Way V2	2025-01-19	Turno Noche	5.76699472208333	7.5	0.700
TAL - Línea Ref Pet (Llenadora)	2025-01-13	Turno Día	5.58353858527778	7.5	0.580
TAL - Línea Ref Pet (Llenadora)	2025-01-14	Turno Día	5.44352518833333	7.5	0.610
TAL - Línea Ref Pet (Llenadora)	2025-01-14	Turno Noche	5.75916866902778	7.5	0.640
TAL - Línea Ref Pet (Llenadora)	2025-01-15	Turno Día	5.70632547166667	7.5	0.620
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	6.00696969347222	7.5	0.630
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Noche	5.44819219638889	7.5	0.580
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	2.59590816466667	7.5	0.240
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno  Tarde	6.28790422294445	9	0.490
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno Mañana	6.28872378877778	7.5	0.590
TAL - Línea RGB	2025-01-13	Turno Dia	5.68072416666667	7.5	0.580
TAL - Línea RGB	2025-01-14	Turno Dia	4.32120861111111	5.5	0.570
TAL - Línea RGB	2025-01-15	Turno Dia	6.32411944444444	7.5	0.610
TAL - Línea RGB	2025-01-15	Turno Noche	4.75152166666667	7.5	0.310
TAL - Línea RGB	2025-01-16	Turno Dia	6.03964055555556	7.5	0.540
TAL - Línea RGB	2025-01-17	Turno Dia	6.66223555555556	7.5	0.730
TAL - Línea RGB	2025-01-18	Turno Dia	5.26458472222222	6.5	0.640
TAL - Línea RGB	2025-01-18	Turno Noche	6.02181388888889	7.5	0.640
TAL - Línea One Way V2	2025-01-13	Día Tarde	7.20128836852778	8.99999984130556	0.720
TAL - Línea One Way V2	2025-01-13	Turno Día	5.52769555302778	7.49999984127778	0.640
TAL - Línea One Way V2	2025-01-14	Día Tarde	7.39757231569444	8.99999984133333	0.770
TAL - Línea One Way V2	2025-01-14	Turno Día	5.59573995661111	7.5	0.660
TAL - Línea One Way V2	2025-01-14	Turno Noche	6.33672563258333	7.49999972241667	0.780
TAL - Línea One Way V2	2025-01-15	Día Tarde	7.85186614877778	9	0.720
TAL - Línea One Way V2	2025-01-15	Turno Día	6.27099877619444	7.49999954655556	0.670
TAL - Línea One Way V2	2025-01-15	Turno Noche	6.28105836661111	7.49999978877778	0.640
TAL - Línea One Way V2	2025-01-16	Día Tarde	6.29399853813889	8.99999960836111	0.620
TAL - Línea One Way V2	2025-01-16	Turno Día	5.97775374322222	7.49999998833333	0.650
TAL - Línea One Way V2	2025-01-16	Turno Noche	6.796796689	7.5	0.780
TAL - Línea One Way V2	2025-01-17	Día Tarde	6.37887249980556	8	0.720
TAL - Línea One Way V2	2025-01-17	Turno Día	6.00301499986111	7.5	0.730
TAL - Línea One Way V2	2025-01-17	Turno Noche	5.67474037461111	7.49999982047222	0.690
TAL - Línea One Way V2	2025-01-18	Turno Día	3.75555111105556	6.5	0.530
TAL - Línea One Way V2	2025-01-18	Turno Noche	6.52111499994444	7.5	0.820
TAL - Línea One Way V2	2025-01-19	Día Tarde	5.11019579269444	9	0.510
TAL - Línea One Way V2	2025-01-19	Turno Día	6.20760777769444	7.5	0.750
TAL - Línea One Way V2	2025-01-19	Turno Noche	5.76699472208333	7.5	0.700
TAL - Línea Ref Pet (Llenadora)	2025-01-13	Turno Día	5.58353858527778	7.5	0.580
TAL - Línea Ref Pet (Llenadora)	2025-01-14	Turno Día	5.44352518833333	7.5	0.610
TAL - Línea Ref Pet (Llenadora)	2025-01-14	Turno Noche	5.75916866902778	7.5	0.640
TAL - Línea Ref Pet (Llenadora)	2025-01-15	Turno Día	5.70632547166667	7.5	0.620
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Día	6.00696969347222	7.5	0.630
TAL - Línea Ref Pet (Llenadora)	2025-01-16	Turno Noche	5.44819219638889	7.5	0.580
TAL - Línea Ref Pet (Llenadora)	2025-01-17	Turno Noche	2.59590816466667	7.5	0.240
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno  Tarde	6.28790422294445	9	0.490
TAL - Línea Ref Pet (Llenadora)	2025-01-19	Turno Mañana	6.28872378877778	7.5	0.590
TAL - Línea RGB	2025-01-13	Turno Dia	5.68072416666667	7.5	0.580
TAL - Línea RGB	2025-01-14	Turno Dia	4.32120861111111	5.5	0.570
TAL - Línea RGB	2025-01-15	Turno Dia	6.32411944444444	7.5	0.610
TAL - Línea RGB	2025-01-15	Turno Noche	4.75152166666667	7.5	0.310
TAL - Línea RGB	2025-01-16	Turno Dia	6.03964055555556	7.5	0.540
TAL - Línea RGB	2025-01-17	Turno Dia	6.66223555555556	7.5	0.730
TAL - Línea RGB	2025-01-18	Turno Dia	5.26458472222222	6.5	0.640
TAL - Línea RGB	2025-01-18	Turno Noche	6.02181388888889	7.5	0.640
TAL - Línea One Way V2	2024-12-23	Día Tarde	6.08012626658333	8.99999988597223	0.540
TAL - Línea One Way V2	2024-12-23	Turno Día	3.03063337136111	7.49999923425	0.300
TAL - Línea One Way V2	2024-12-23	Turno Noche	4.61438087355555	6.5	0.570
TAL - Línea One Way V2	2024-12-24	Día Tarde	1.18555936394444	3	0.320
TAL - Línea One Way V2	2024-12-24	Turno Día	5.17968757625	7.49999996038889	0.620
TAL - Línea One Way V2	2024-12-24	Turno Noche	4.96596832911111	7.5	0.580
TAL - Línea One Way V2	2024-12-26	Día Tarde	4.88902118338889	8.99999998408333	0.460
TAL - Línea One Way V2	2024-12-26	Turno Día	5.39018027761111	7.5	0.620
TAL - Línea One Way V2	2024-12-26	Turno Noche	4.17714472208333	7.5	0.490
TAL - Línea One Way V2	2024-12-27	Día Tarde	5.84105880711111	7.99999996044444	0.680
TAL - Línea One Way V2	2024-12-27	Turno Día	5.84536045336111	7.49999995194444	0.630
TAL - Línea One Way V2	2024-12-27	Turno Noche	6.06832069011111	7.5	0.680
TAL - Línea One Way V2	2024-12-28	Turno Día	4.44256595038889	5	0.810
TAL - Línea One Way V2	2024-12-28	Turno Noche	5.22798031463889	7.5	0.640
TAL - Línea One Way V2	2024-12-29	Día Tarde	8.19265293436111	9	0.870
TAL - Línea One Way V2	2024-12-29	Turno Día	6.62558567194444	7.5	0.820
TAL - Línea One Way V2	2024-12-29	Turno Noche	6.56323416494444	7.49999976205556	0.820
TAL - Línea Ref Pet (Llenadora)	2024-12-23	Turno Día	5.65439505013889	7.5	0.580
TAL - Línea Ref Pet (Llenadora)	2024-12-23	Turno Noche	4.65347657930556	6.5	0.610
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Día	4.87894271111111	7.5	0.460
TAL - Línea Ref Pet (Llenadora)	2024-12-24	Turno Noche	3.68700416666667	7.5	0.320
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Día	5.84619315311111	7.5	0.670
TAL - Línea Ref Pet (Llenadora)	2024-12-26	Turno Noche	3.86703168522222	5.5	0.520
TAL - Línea Ref Pet (Llenadora)	2024-12-27	Turno Día	6.35051545597222	7.5	0.640
TAL - Línea Ref Pet (Llenadora)	2024-12-27	Turno Noche	4.79929931163889	7.5	0.510
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Día	2.77474919958333	3	0.740
TAL - Línea Ref Pet (Llenadora)	2024-12-28	Turno Noche	4.98439977555556	7.5	0.500
TAL - Línea RGB	2024-12-23	Turno Dia	5.8858175	7.5	0.650
TAL - Línea RGB	2024-12-23	Turno Noche	3.55002416666667	6.5	0.370
TAL - Línea RGB	2024-12-24	Turno Dia	5.19921055555556	7.5	0.520
TAL - Línea RGB	2024-12-24	Turno Noche	3.09043055555556	7.5	0.270
TAL - Línea RGB	2024-12-26	Turno Dia	5.99823277777778	7.5	0.570
TAL - Línea RGB	2024-12-27	Turno Dia	6.43514027777778	7.5	0.600
TAL - Línea RGB	2024-12-27	Turno Noche	5.21421	7.5	0.480
TAL - Línea RGB	2024-12-28	Turno Dia	4.5704475	5	0.670
TAL - Línea RGB	2024-12-28	Turno Noche	6.06081444444444	7.5	0.590
TAL - Línea RGB	2024-12-29	Turno Dia	6.22067055555555	7	0.640
TAL - Línea RGB	2024-12-29	Turno Noche	6.37230222222222	7.5	0.600
\.


--
-- Data for Name: tabla_nombres; Type: TABLE DATA; Schema: datos_maquinaria; Owner: postgres
--

COPY datos_maquinaria.tabla_nombres (id, table_name) FROM stdin;
1	tabla_nombres
2	db_averias_consolidado
3	datasheeet_fallas_semanales
4	oeeydisponibilidad
5	hpr_oee
6	indicador_semanal
\.


--
-- Data for Name: temp_datasheet_fallas_semanales; Type: TABLE DATA; Schema: datos_maquinaria; Owner: postgres
--

COPY datos_maquinaria.temp_datasheet_fallas_semanales (machine_name, days_in_calendar_datetime, shift_name, reasonstate_group1, reasonstate_group2, reasonstate_name, reason_occurrences, scheduled_hours) FROM stdin;
\.


--
-- Data for Name: temp_oeeydisponibilidad; Type: TABLE DATA; Schema: datos_maquinaria; Owner: postgres
--

COPY datos_maquinaria.temp_oeeydisponibilidad (machine_name, days_in_calendar_datetime, shift_name, horas_produciendo, horas_planificadas, oee) FROM stdin;
\.


--
-- Name: tabla_nombres_id_seq; Type: SEQUENCE SET; Schema: datos_maquinaria; Owner: postgres
--

SELECT pg_catalog.setval('datos_maquinaria.tabla_nombres_id_seq', 6, true);


--
-- Name: tabla_nombres tabla_nombres_pkey; Type: CONSTRAINT; Schema: datos_maquinaria; Owner: postgres
--

ALTER TABLE ONLY datos_maquinaria.tabla_nombres
    ADD CONSTRAINT tabla_nombres_pkey PRIMARY KEY (id);


--
-- Name: datasheeet_fallas_semanales after_insert_datasheet_fallas_semanales; Type: TRIGGER; Schema: datos_maquinaria; Owner: postgres
--

CREATE TRIGGER after_insert_datasheet_fallas_semanales AFTER INSERT ON datos_maquinaria.datasheeet_fallas_semanales FOR EACH ROW EXECUTE FUNCTION datos_maquinaria.update_db_averias_consolidado();


--
-- Name: oeeydisponibilidad after_insert_oee_y_disponibilidad; Type: TRIGGER; Schema: datos_maquinaria; Owner: postgres
--

CREATE TRIGGER after_insert_oee_y_disponibilidad AFTER INSERT ON datos_maquinaria.oeeydisponibilidad FOR EACH ROW EXECUTE FUNCTION datos_maquinaria.insert_into_hpr_oee();


--
-- PostgreSQL database dump complete
--

