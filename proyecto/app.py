from flask import Flask, request, jsonify, render_template, send_file, send_from_directory
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import pandas as pd
from io import BytesIO
from waitress import serve
import logging



# Comentario importante en script.js


def create_app():
    print("Iniciando aplicación Flask...")
    app = Flask(__name__, static_folder='static')
    print("Aplicacion iniciada en: http://localhost:8000")
    print("Para cerrar la app CTRL + C")

    # Configurar el logger de Waitress para evitar los mensajes INFO
    logging.getLogger('waitress').setLevel(logging.ERROR)  # Configurar Waitress para que no imprima INFO

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

    #para realizar consultas a la base 
    def query_db(query, args=(), commit=False, one=False):
        conn = None
        try:
            conn = psycopg2.connect(**config)
            cur = conn.cursor(cursor_factory=RealDictCursor)

            cur.execute(query, args)

            if commit:  
                conn.commit()  # Confirma cambios para INSERT, UPDATE, DELETE
                return {"success": True}  # DELETE no devuelve datos

            result = cur.fetchall() if not one else cur.fetchone()
            return result

        except Exception as e:
            print(f"Error en query_db: {e}")  # Imprime errores en el servidor
            if conn:
                conn.rollback()  # Revertir cambios si hay un error
            raise e  # Propaga el error para depuración

        finally:
            if conn:
                cur.close()
                conn.close()


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


    @app.route('/favicon.ico')
    def favicon():
        return send_from_directory('static', 'favicon.ico', mimetype='image/icons.icon')

    #Funcion para abrir el front
    @app.route('/')
    def index():
        return render_template('interface.html')  # Sirve tu archivo HTML desde la carpeta 'templates'


    #para obtener los nombres de todas las tablas de la base de datos
    @app.route('/tables', methods=['GET'])
    def get_tables():
        query = "SELECT table_name FROM tabla_nombres;"

        tables = query_db(query)
        # Extraer los nombres correctamente
        if isinstance(tables, list) and tables:
            table_names = [table["table_name"] for table in tables]
        else:
            table_names = []  # Si no hay datos, devolver lista vacía

        return jsonify(table_names)


    #para obtener los valores unicos para el filtro
    @app.route('/tables/<table_name>/unique_values', methods=['GET'])
    def get_unique_values(table_name):
        column = request.args.get('column')  # Obtener el nombre de la columna desde los parámetros de la URL
        
        # Inicializar los filtros
        filters = []
        params = []
        
        # Procesar los filtros que se recibieron
        for filter_column, filter_values in request.args.items():
            if filter_column not in ["column"] and filter_column != column:  # Excluir la columna consultada
                values = filter_values.split(',')
                filters.append(f"{filter_column} IN ({', '.join(['%s'] * len(values))})")
                params.extend(values)
        
        # Construir la consulta con los filtros (si existen)
        filter_query = " AND ".join(filters) if filters else "1=1"  # Si no hay filtros, seleccionar todo


        # Construir la consulta para obtener valores únicos con filtros
        if column == "fecha":
            query = f"SELECT DISTINCT TO_CHAR({column}, 'DD-MM-YYYY') FROM {table_name} WHERE {filter_query};"
        else:
            query = f"SELECT DISTINCT {column} FROM {table_name} WHERE {filter_query};"


        # Ejecutar la consulta
        values = query_db(query, params)
        
        # Obtener los valores únicos correctamente
        if isinstance(values, list) and values:
            # Si devuelve diccionarios, acceder por clave
            if isinstance(values[0], dict):
                column_name = list(values[0].keys())[0]  # Obtener el nombre de la columna
                unique_values = [row[column_name] for row in values]
            else:
                # Si devuelve listas o tuplas
                unique_values = [row[0] for row in values]
        else:
            unique_values = []  # Lista vacía si no hay datos

        # Retornar los valores únicos como un objeto JSON
        return jsonify({column: unique_values})



    #codigo para obtener los datos de las tablas paginada
    @app.route('/tables/<table_name>/filtered_data', methods=['GET'])
    def get_filtered_data(table_name):
        try:
            # Parámetros de paginación
            page = int(request.args.get('page', 1))  # Página actual
            per_page = int(request.args.get('per_page', 500))  # Filas por página
            offset = (page - 1) * per_page  # Calcular desplazamiento
            filters = []
            params = []

            # Obtener los nombres de las columnas
            query_columns = """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'datos_maquinaria' AND table_name = %s
            ORDER BY ordinal_position;
            """
            columns = query_db(query_columns, (table_name,))
            column_names = [col["column_name"] for col in columns]  # Extraer nombres

            # Aplicar filtros dinámicamente
            for column, value in request.args.items():
                if column in column_names:  # Evitar SQL Injection asegurando que la columna existe
                    values = value.split(',')
                    placeholders = ', '.join(['%s'] * len(values))
                    filters.append(f'"{column}" IN ({placeholders})')
                    params.extend(values)

            filter_query = " AND ".join(filters) if filters else "1=1"

            # Comprobar si table_name es igual a 'db_averias_consolidado'
            if table_name in ['db_averias_consolidado', 'hpr_oee']:
                query = f"""
                SELECT row_to_json(t)
                FROM (SELECT * FROM {table_name} WHERE {filter_query} ORDER BY fecha LIMIT %s OFFSET %s) t
                """
            else:
                query = f"""
                SELECT row_to_json(t)
                FROM (SELECT * FROM {table_name} WHERE {filter_query} LIMIT %s OFFSET %s) t
                """

            params.extend([per_page, offset])

            # Obtener datos de la base de datos
            data = query_db(query, params)

            # Extraer los diccionarios JSON de las tuplas
            formatted_data = [row["row_to_json"] for row in data]

            # Obtener cantidad total de registros con filtros (sin paginación)
            count_query = f"SELECT COUNT(*) AS count FROM {table_name} WHERE {filter_query}"
            params_for_count = params[:-2]  # Eliminar LIMIT y OFFSET

            total_count_result = query_db(count_query, params_for_count)
            total_count = total_count_result[0]["count"] if total_count_result else 0

            total_pages = (total_count // per_page) + (1 if total_count % per_page > 0 else 0)

            return jsonify({
                "table_name": table_name,
                "columns": column_names,
                "data": formatted_data,
                "total_count": total_count,
                "total_pages": total_pages,
                "current_page": page,
                "per_page": per_page
            })

        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500


    #codigo para obtener todos los datos de las tablas sin paginar y con filtros
    @app.route('/tables/<table_name>/data', methods=['GET'])
    def get_table_data(table_name):
        try:
            # Obtener nombres de columnas para evitar SQL Injection
            query_columns = """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'datos_maquinaria' AND table_name = %s
            ORDER BY ordinal_position;
            """

            columns = query_db(query_columns, (table_name,))
            column_names = [col["column_name"] for col in columns]


            filters = []
            params = []

            # Aplicar filtros dinámicamente
            for column, value in request.args.items():
                if column in column_names:  # Evitar SQL Injection asegurando que la columna existe
                    values = value.split(',')
                    placeholders = ', '.join(['%s'] * len(values))
                    filters.append(f'"{column}" IN ({placeholders})')
                    params.extend(values)

            filter_query = " AND ".join(filters) if filters else "1=1"

            # Obtener todos los datos sin paginación
            query = f"SELECT row_to_json(t) FROM (SELECT * FROM {table_name} WHERE {filter_query} ) t"
            data = query_db(query, params)

            # Extraer los diccionarios JSON de las tuplas
            formatted_data = [row["row_to_json"] for row in data]

            return jsonify({
                "table_name": table_name,
                "columns": column_names,
                "data": formatted_data,
            })


        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500


    #codigo para actualizar la fila de la tabla 
    @app.route('/update_row', methods=['POST'])
    def update_row():
        try:

            data = request.json
            table_name = data.get("table_name")
            row_data = data.get("row_data")  # Identificación de la fila
            new_data = data.get("newData")  # Contiene { columna: nuevo_valor }

            if not table_name or not row_data or not new_data:
                return jsonify({"success": False, "error": "Datos incompletos."}), 400
            
            # Extraer la única clave y valor de new_data
            update_column, new_value = list(new_data.items())[0]   
            
            # Columnas a omitir en la comparación
            omit_columns = {"oee", "observaciones", "areas", "sintoma"}

            # Construcción de la condición WHERE
            conditions = []
            params = []

            for column, value in row_data.items():
                if column in omit_columns:
                    continue  # Omitir las columnas especificadas

                conditions.append(f"{column} = %s")
                params.append(value)

            # Si no hay condiciones válidas, error
            if not conditions:
                return jsonify({"success": False, "error": "No hay columnas válidas para identificar la fila."}), 400
            where_clause = " AND ".join(conditions)

            # Verificar si la fila existe con COUNT()
            count_query = f"SELECT COUNT(*) FROM {table_name} WHERE {where_clause}"
            count_result = query_db(count_query, params)
            row_count = count_result[0]["count"] if count_result else 0

            if row_count == 0:
                return jsonify({"success": False, "error": "No se encontró ninguna fila para actualizar."}), 404

            # Construir la consulta UPDATE
            query = f"UPDATE {table_name} SET {update_column} = %s WHERE {where_clause}"
            update_params = [new_value] + params  # Agregar el valor a actualizar antes de los filtros


            # Ejecutar la actualización real
            query_db(query, update_params, commit=True)
            
            return jsonify({"success": True, "message": "Fila actualizada con éxito."}), 200

        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500



    #eliminar una fila de la tabla
    @app.route('/delete_row', methods=['POST'])
    def delete_row():
        try:
            data = request.json
            table_name = data.get("table_name")
            row_data = data.get("row_data")
            if not table_name or not row_data:
                return jsonify({"success": False, "error": "Datos incompletos."}), 400

            # Construir condición WHERE para identificar la fila
            conditions = []
            params = []
            
            for column, value in row_data.items():
                if column == "observaciones":
                    # Manejar NULL para la columna "observaciones"
                    conditions.append(f"({column} = %s OR {column} IS NULL)")
                    params.append(value if value != "" else None)
                
                else:
                    # Condición general para otras columnas
                    conditions.append(f"{column} = %s")
                    params.append(value)


            where_clause = " AND ".join(conditions)
            query = f"DELETE FROM {table_name} WHERE {where_clause}"

            # Ejecutar consulta
            query_db(query, params, commit=True)
            

            return jsonify({"success": True, "message": "Fila eliminada con éxito."}), 200
        
        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500


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


    # funcion para guardar los datos en ind semanal (tabla dinamica)
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
            if table_name in ['indicador_semanal', 'indicador_semanal_fecha']:
                # TRUNCATE para limpiar la tabla antes de actualizar
                cur.execute(f"TRUNCATE TABLE {table_name} RESTART IDENTITY")

            # Preparar la consulta de inserción dinámica
            column_names = ', '.join(sanitized_columns)
            value_placeholders = ', '.join(['%s'] * len(columns))
            insert_query = f"""
                INSERT INTO {table_name} ({column_names}) 
                VALUES ({value_placeholders}) 
                ON CONFLICT DO NOTHING
            """
            rows_inserted = 0

            # Insertar las filas
            for row in rows:
                # Mapear claves de data a columnas en caso de desajuste
                values = tuple(row.get(col.replace('"', ''), None) for col in sanitized_columns)
                cur.execute(insert_query, values)
                rows_inserted += cur.rowcount  # Suma las filas insertadas

            # Confirmar los cambios
            conn.commit()

            # Verificar si se insertaron datos o no
            if rows_inserted > 0:
                return jsonify({'status': 'success', 'message': f'{rows_inserted} filas insertadas'}), 200
            else:
                return jsonify({'status': 'no_action', 'message': 'Los datos ya existían, no se insertó nada'}), 200

        except Exception as e:
            return jsonify({'error': str(e)}), 500

        finally:
            cur.close()
            conn.close()


    #funcion para descargar planilla.pbix del drive 
    @app.route('/powerbi', methods=['GET'])
    def cargar_powerbi():
        ruta_archivo = os.path.abspath("proyecto/files/planilla.pbix")  # Ruta completa del archivo
        try:
            os.startfile(ruta_archivo)  # Abre el archivo en la app predeterminada (Power BI)
            return jsonify({"mensaje": "Archivo abierto en Power BI"})

        except Exception as e:
            print(f"Error: {e}")
            return jsonify({"mensaje": "Ocurrió un error", "error": str(e)}), 500


    #funcion para descargar los datos de la tabla a un archivo excel
    @app.route('/download', methods=['POST'])
    def download_table():

        data = request.json
        table_name = data.get("table_name")

        if not table_name:
            return jsonify({"error": "No se especificó la tabla"}), 400

        try:
        # Obtener los datos de la tabla
            query = f"SELECT * FROM {table_name};"
            rows = query_db(query)

            if not rows:
                return jsonify({"error": "La tabla está vacía o no existe"}), 404

            # Convertir a DataFrame
            df = pd.DataFrame(rows)

            # Crear archivo en memoria
            output = BytesIO()
            with pd.ExcelWriter(output, engine="xlsxwriter") as writer:
                df.to_excel(writer, index=False, sheet_name=table_name)

            output.seek(0)  # Regresar al inicio del archivo

            # Enviar archivo como respuesta
            return send_file(output, download_name=f"{table_name}.xlsx", as_attachment=True, mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
        
        except Exception as e:
            return jsonify({"error": str(e)}), 500

    return app


if __name__ == "__main__":
    apps = create_app()  # Llamamos a la función que crea la app)
    serve(apps, host='0.0.0.0', port=8000)  # Usamos Waitress para servir la aplicación