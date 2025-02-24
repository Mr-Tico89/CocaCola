@echo off
chcp 65001 > nul 2>&1
setlocal enabledelayedexpansion


:: Obtener la ruta base del script
set "BASE_PATH=%~dp0"
set "PGSQL_PATH=%BASE_PATH%\pgsql"
set "WEB_PATH=%BASE_PATH%proyecto"


:: Verificar existencia del archivo de configuración del cluster
set "CLUSTER_FILE=%PGSQL_PATH%\cluster_name.txt"



:: Leer nombre del cluster
set /P "NombreCluster=" < "%CLUSTER_FILE%"
set "NombreCluster=!NombreCluster: =!"
set "RutaCluster=%PGSQL_PATH%\%NombreCluster%"



:: Verificar si pg_ctl existe
set "PG_CTL=%PGSQL_PATH%\bin\pg_ctl"


:: Iniciar PostgreSQL
echo Iniciando PostgreSQL...
"%PG_CTL%" start -D "%RutaCluster%"


:: Configurar entorno virtual
set "VENV_PATH=%WEB_PATH%\entorno\Scripts\activate"


:: Activar entorno virtual
echo activando entorno virtual...
set "PYTHON_EVNC=%WEB_PATH%\entorno\Scripts\python.exe"

call "%VENV_PATH%"

    
:: Agregar WEB_PATH al PYTHONPATH
:: set PYTHONPATH=%WEB_PATH%

:: Iniciar aplicación Flask
echo Iniciando aplicación Flask...

start http://localhost:8000	
start /wait "" "%PYTHON_EVNC%" -m waitress --port=8000 --call proyecto.app:create_app 


:: Detener PostgreSQL
echo Deteniendo PostgreSQL...
"%PG_CTL%" stop -D "%RutaCluster%" -m fast


:: Cerrar la ventana automáticamente
exit

