@echo off
echo Iniciando PostgreSQL...

:: Obtener la ruta base del script (independiente de la letra de unidad)
set "BASE_PATH=%~dp0"
set "PGSQL_PATH=%BASE_PATH%..\pgsql"

:: Ejecutar el script para iniciar PostgreSQL
call "%PGSQL_PATH%\PostgreSQL-Start.bat"


echo Iniciando la aplicación web...
:: Verificar si el entorno virtual existe
if not exist "entorno\Scripts\activate" (
    echo Creando entorno virtual...
    python -m venv entorno
    echo Instalando dependencias...
    call entorno\Scripts\activate
    pip install -r requirements.txt
    deactivate
)

:: Activar entorno virtual e iniciar la aplicación
echo Activando entorno virtual...
call entorno\Scripts\activate


:: Iniciar la aplicación Flask
echo Iniciando la app...
python app.py


:: Al cerrar la aplicación Flask, detener el clúster de PostgreSQL
echo Cerrando el clúster de PostgreSQL...
call "%PGSQL_PATH%\PostgreSQL-Stop.bat"

:: Mantener la consola abierta en caso de error
echo.
echo Presiona cualquier tecla para salir...
pause











