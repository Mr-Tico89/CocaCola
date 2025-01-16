from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import psycopg2
import codecs
import subprocess
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

        print(f"Archivo sobrescrito a UTF-8 sin BOM: {input_file}")
    
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
def load_data_to_db(filename):
    # Construye la ruta del archivo usando las barras correctas
    file_path = os.path.normpath(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    # Establecer la contraseña en la variable de entorno PGPASSWORD
    os.environ['PGPASSWORD'] = '1234'

    # Comando \copy para cargar datos en la tabla temporal
    command = f'psql -U postgres -d cocacola -c "\\copy datos_maquinaria.temp_datasheet_fallas_semanales FROM \'{file_path}\' WITH DELIMITER \',\' CSV HEADER ENCODING \'UTF8\'"'

    try:
        copy = "\copy temp_datasheet_fallas_semanales FROM '{file_path}' WITH DELIMITER ',' CSV HEADER ENCODING 'UTF8';"       
        # Insertar los datos en la tabla final
        insert_query = """
        INSERT INTO datos_maquinaria.DATASHEEET_FALLAS_SEMANALES
        SELECT * FROM datos_maquinaria.temp_datasheet_fallas_semanales;
        """
        # Conectar a la base de datos para ejecutar el INSERT
        conn = psycopg2.connect(
            dbname="cocacola",
            user="postgres",
            password="1234",
            host="localhost",
            port="5432"
        )
        cursor = conn.cursor()
        cursor.execute("SHOW client_encoding;")
        encoding = cursor.fetchone()
        print(encoding)
        cursor.execute(insert_query)
        conn.commit()
        print("Datos transferidos exitosamente a la tabla final.")
        
        # Vaciar la tabla temporal
        cursor.execute("TRUNCATE TABLE temp_datasheet_fallas_semanales;")
        conn.commit()

    except subprocess.CalledProcessError as e:
        print(f"Error al cargar datos con \copy: {e}")
    except Exception as e:
        print(f"Error al insertar o procesar los datos: {e}")
    finally:
        # Cerrar conexión de base de datos
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
            # Llamar a la función para convertir el archivo a UTF-8 sin BOM
            convert_to_utf8_without_bom(file_path)
            
            load_data_to_db(filename)  # Llama a la función para procesar el archivo y cargarlo
            return jsonify({'message': 'File successfully uploaded and data loaded to DB', 'filename': filename}), 200
        except Exception as e:
            return jsonify({'message': f'Error while loading data to DB: {str(e)}'}), 500
    else:
        return jsonify({'message': 'Invalid file type, only .csv files are allowed'}), 400

@app.route('/save', methods=['PUT'])
def save():
    # Intentamos obtener el JSON enviado por el cliente
    data = request.get_json()
    if data is None or not isinstance(data, list):
        return jsonify({'error': 'El cuerpo debe ser un array JSON válido'}), 400

    # Validación adicional del JSON
    if not all(isinstance(item, dict) for item in data):
        return jsonify({'error': 'Cada elemento del array debe ser un objeto JSON'}), 400

    # Intentamos insertar los datos en la base de datos
    try:
        conn = psycopg2.connect(
            dbname="cocacola",
            user="postgres",
            password="1234",
            host="localhost",
            port="5432"
        )
        cur = conn.cursor()

        # Insertamos cada elemento del JSON
        for item in data:
            columns = item.keys()
            values = [item[column] for column in columns]
            set_clause = ', '.join([f"{column} = %s" for column in columns])
            update_statement = f'UPDATE datos_maquinaria.DB_AVERIAS_CONSOLIDADO SET {set_clause}'
            cur.execute(update_statement, values + [item['id']])

        # Confirmamos los cambios
        conn.commit()

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