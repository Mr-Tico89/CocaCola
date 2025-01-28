import requests
from flask import Flask, request, jsonify, render_template, send_file
from flask_cors import CORS
import tempfile
import psycopg2
import os


app = Flask(__name__, static_folder='static')

app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # Aumenta el límite a 16 MB

CORS(app)  # Permitir solo tu dominio



# Configuración de la carpeta de subida
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'csv'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

# Configuración de la conexión a PostgreSQL, para nada seguro (investigar q ondis)
config = {
    "dbname": "cocacola",
    "user": "webuser",
    "password": "cocacola9041",
    "host": "localhost",  # Cambia si es un servidor remoto
    "port": 5432,         # Puerto de PostgreSQL
    "options":"-c client_encoding=WIN1252"        
}

def query_db(query, args=(), one=False):
    conn = psycopg2.connect(**config)
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



@app.route('/')
def index():
    return render_template('interface.html')  # Sirve tu archivo HTML desde la carpeta 'templates'



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
        "table_name": table_name,
        "columns": column_names,
        "data": flattened_rows
    }

    # Enviar el JSON al frontend
    return jsonify(response)


# Función para cargar los datos en la base de datos después de subir el archivo
def load_data_to_db(file_path, filename):
    try:
        # Conectar a la base de datos
        conn = psycopg2.connect(**config)
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


#funcion para cargar archivos a postgreSQL
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
    # Obtener el JSON enviado por el cliente
    data = request.get_json()

    table_name = data.get('table_name')  # Nombre de la tabla
    columns = data.get('columns')  # Orden de las columnas
    rows = data.get('data')  # Filas de datos

    # Validaciones iniciales
    if not table_name or not columns or not rows:
        return jsonify({'error': 'El JSON debe incluir table_name, columns y data'}), 400
    if not isinstance(columns, list) or not isinstance(rows, list):
        return jsonify({'error': 'Columns debe ser una lista y data debe ser una lista de objetos JSON'}), 400

    try:
        # Sanitizar nombres de columnas (reemplazar caracteres especiales)
        sanitized_columns = [f'"{col}"' if any(c in col for c in '()% ') else col for col in columns]

        # Conexión a la base de datos
        conn = psycopg2.connect(**config)
        cur = conn.cursor()

        # TRUNCATE para limpiar la tabla antes de actualizar
        cur.execute(f"TRUNCATE TABLE {table_name} RESTART IDENTITY")

        # Preparar la consulta de inserción dinámica
        column_names = ', '.join(sanitized_columns)
        value_placeholders = ', '.join(['%s'] * len(columns))
        insert_query = f"INSERT INTO {table_name} ({column_names}) VALUES ({value_placeholders})"

        # Insertar las filas
        for row in rows:
            # Mapear claves de data a columnas en caso de desajuste
            values = tuple(row.get(col.replace('"', ''), None) for col in sanitized_columns)
            cur.execute(insert_query, values)

        # Confirmar los cambios
        conn.commit()
        return jsonify({'status': 'success'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    finally:
        cur.close()
        conn.close()


@app.route('/cargar-powerbi', methods=['POST'])
def cargar_powerbi():
    try:
        # URL del archivo en Google Drive
        file_url = "https://drive.google.com/uc?id=1bmG0gtAx3TXUtpD2sT5errQ_kIhbNaZC&export=download"

        # Descargar el archivo desde Google Drive
        response = requests.get(file_url, stream=True)
        if response.status_code != 200:
            return jsonify({"mensaje": "No se pudo descargar el archivo", "error": f"HTTP {response.status_code}"}), 500

        # Guardar el archivo temporalmente
        temp_dir = tempfile.gettempdir()
        temp_file_path = os.path.join(temp_dir, "planilla.pbix")
        with open(temp_file_path, 'wb') as temp_file:
            for chunk in response.iter_content(chunk_size=8192):
                temp_file.write(chunk)

        print(f"Archivo descargado y guardado temporalmente en {temp_file_path}")

        # Enviar el archivo al cliente para que el navegador lo descargue
        return send_file(temp_file_path, as_attachment=True, download_name="planilla.pbix")

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"mensaje": "Ocurrió un error", "error": str(e)}), 500


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000, debug=False)