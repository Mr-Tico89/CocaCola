from flask import Flask, request, jsonify
from flask_cors import CORS
from collections import OrderedDict
import psycopg2
import os

app = Flask(__name__)
CORS(app)  # Habilitar CORS para todas las rutas

# Configuración de la carpeta de subida
UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Asegúrate de que la carpeta de subida exista
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


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



@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'message': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'message': 'No selected file'}), 400
    if file and file.filename.endswith('.csv'):
        filename = file.filename
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        return jsonify({'message': 'File successfully uploaded'}), 200
    else:
        return jsonify({'message': 'Invalid file type, only .csv files are allowed'}), 400



if __name__ == "__main__":
    app.run(debug=True)