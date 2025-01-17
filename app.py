from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
import json
import os


app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # Aumenta el límite a 16 MB
CORS(app)  # Habilitar CORS para todas las rutas

# Configuración de la carpeta de subida
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'csv'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])


def query_db(query, args=(), one=False):
    conn = psycopg2.connect(
        dbname="cocacola",
        user="postgres",
        password="1234",
        host="localhost",
        port="5432"
    )
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    column_names = [desc[0] for desc in cur.description]
    conn.close()
    return (rv, column_names) if not one else (rv[0], column_names)


# Función para cambiar la codificacion del archivo a utf8
def convert_to_utf8_without_bom(input_file):
    try:
        # Intentar leer el archivo con ISO-8859-1 (latin1) para manejar caracteres no válidos en UTF-8
        with open(input_file, 'r', encoding='iso-8859-1') as f:
            content = f.read()

        # Sobrescribir el archivo en UTF-8 sin BOM
        with open(input_file, 'w', encoding='utf-8') as f:
            f.write(content)

    except Exception as e:
        print(f"Error al procesar el archivo: {e}")


# Función para verificar si el archivo tiene una extensión permitida
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/tables', methods=['GET'])
def get_tables():
    query = "SELECT table_name FROM tabla_nombres;"
    tables, _ = query_db(query)
    table_names = [table[0] for table in tables]
    return jsonify(table_names)


@app.route('/tables/<table_name>', methods=['GET'])
def get_table_data(table_name):
    # Crear lista de columnas en orden físico
    query_columns = f"""
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'datos_maquinaria' AND table_name = '{table_name}'
    ORDER BY ordinal_position;
    """
    columns, _ = query_db(query_columns) 
    column_names = [col[0] for col in columns]  # Extraer nombres de columnas
    if (table_name == 'db_averias_consolidado'):
        query = f"SELECT row_to_json(t) FROM {table_name} t ORDER BY t.fecha;"
    else:
        query = f"SELECT row_to_json(t) FROM {table_name} t;"
    # Ejecutar consulta para obtener los datos
    rows, _ = query_db(query)
    flattened_rows = [item for sublist in rows for item in sublist]

    # Crear un objeto JSON que incluya columnas y datos
    response = {
        "columns": column_names,
        "data": flattened_rows
    }

    # Enviar el JSON al frontend
    return jsonify(response)


# Función para cargar los datos en la base de datos después de subir el archivo
def load_data_to_db(file_path, filename):
    try:
        # Conectar a la base de datos
        conn = psycopg2.connect(
            dbname="cocacola",
            user="postgres",
            password="1234",
            host="localhost",
            port="5432",
            options="-c client_encoding=WIN1252"
        )
        cursor = conn.cursor()


        # Verificar si el nombre del archivo es DATASHEEET_FALLAS_SEMANALES
        if 'DATASHEEETFALLASSEMANALES' in filename:
            # Copiar datos del archivo CSV a la tabla temporal
            with open(file_path, 'r', encoding='utf-8') as f:
                cursor.copy_expert(
                    """
                    COPY datos_maquinaria.temp_datasheet_fallas_semanales 
                    FROM STDIN 
                    WITH CSV HEADER DELIMITER ',' ENCODING 'UTF8';
                    """,
                    f
                )
            conn.commit()

            # Insertar datos en la tabla final
            insert_query = """
            INSERT INTO datos_maquinaria.DATASHEEET_FALLAS_SEMANALES
            SELECT * FROM datos_maquinaria.temp_datasheet_fallas_semanales;
            TRUNCATE TABLE datos_maquinaria.temp_datasheet_fallas_semanales;
            """
            cursor.execute(insert_query)
            conn.commit()

         # Verificar si el nombre del archivo es OEEYDISPONIBILIDAD
        if 'OEEYDISPONIBILIDAD' in filename:
             # Copiar datos del archivo CSV a la tabla temporal
            with open(file_path, 'r', encoding='utf-8') as f:
                cursor.copy_expert(
                    """
                    COPY datos_maquinaria.temp_OEEYDISPONIBILIDAD 
                    FROM STDIN 
                    WITH CSV HEADER DELIMITER ',' ENCODING 'UTF8';
                    """,
                    f
                )
            conn.commit()

            # Insertar datos en la tabla final
            insert_query = """
            INSERT INTO OEEYDISPONIBILIDAD
            SELECT * FROM temp_OEEYDISPONIBILIDAD;
            TRUNCATE TABLE datos_maquinaria.temp_OEEYDISPONIBILIDAD;
            """
            cursor.execute(insert_query)
            conn.commit()

    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Cerrar la conexión
        if conn:
            cursor.close()
            conn.close()


@app.route('/uploads', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'message': 'No file part'}), 400
    
    file = request.files['file']

    if file.filename == '':
        return jsonify({'message': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        filename = file.filename
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        
        # Guardar el archivo en la carpeta de subida
        file.save(file_path)

        try:
            convert_to_utf8_without_bom(file_path) # Llamar a la función para convertir el archivo a UTF-8 sin BOM
            load_data_to_db(file_path, filename)  # Llama a la función para procesar el archivo y cargarlo
            os.remove(file_path) # Elimina el archivo una vez usado
            return jsonify({'message': 'File successfully uploaded and data loaded to DB', 'filename': filename}), 200
        
        except Exception as e:
            return jsonify({'message': f'Error while loading data to DB: {str(e)}'}), 500
    else:
        return jsonify({'message': 'Invalid file type, only .csv files are allowed'}), 400


@app.route('/save', methods=['PUT'])
def save():
    # Intentamos obtener el JSON enviado por el cliente
    data = request.get_json()
    columns = data.get('columns', [])
    data = data.get('data', [])
    ordered_data = []
    for record in data:
        ordered_record = {col: record.get(col.lower()) for col in columns}
        ordered_data.append(ordered_record)

    if ordered_data is None or not isinstance(ordered_data, list):
        return jsonify({'error': 'El cuerpo debe ser un array JSON válido'}), 400

    # Validación adicional del JSON
    if not all(isinstance(item, dict) for item in ordered_data):
        return jsonify({'error': 'Cada elemento del array debe ser un objeto JSON'}), 400

    # Intentamos insertar los datos en la base de datos
    try:
        conn = psycopg2.connect(
            dbname="cocacola",
            user="postgres",
            password="1234",
            host="localhost",
            port="5432",
            options="-c client_encoding=WIN1252"
        )
        cur = conn.cursor()

        # 1. Realizar TRUNCATE (vaciar la tabla)
        cur.execute("TRUNCATE TABLE DB_AVERIAS_CONSOLIDADO RESTART IDENTITY")

        # 2. Insertar nuevos datos
        for item in data:
            query = """
                INSERT INTO DB_AVERIAS_CONSOLIDADO (id, mes, semana, fecha, año, turno, maquina, sintoma, areas, minutos, observaciones)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            values = (item['id'], item['mes'], item['semana'], item['fecha'], item['año'], item['turno'], item['maquina'], item['sintoma'], item['areas'], item['minutos'], item['observaciones'])
            cur.execute(query, values)

        # 3. Asegúrate de hacer commit para guardar los cambios
        conn.commit()

        # 4. Ordenar los datos por ID y agrupar si es necesario (ejemplo usando GROUP BY)
        query_select = """
            SELECT id, mes, semana, fecha, año, turno, maquina, sintoma, areas, minutos, observaciones
            FROM DB_AVERIAS_CONSOLIDADO
            ORDER BY id ASC
            -- Si necesitas usar GROUP BY, puedes agregarlo aquí
        """
        cur.execute(query_select)

        # Cerrar la conexión
        cur.close()
        conn.close()

    except Exception as e:
        # Si ocurre un error, revertimos los cambios
        conn.rollback()
        return jsonify({'error': f'Error al guardar los datos: {str(e)}'}), 500

    finally:
        # Cerramos la conexión y el cursor en cualquier caso
        cur.close()
        conn.close()

    # Si todo fue bien
    return jsonify({'message': 'Datos guardados correctamente'}), 200


if __name__ == "__main__":
    app.run(debug=False)