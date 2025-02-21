@echo off
chcp 65001 > nul 2>&1
setlocal enabledelayedexpansion


:: Obtener la ruta base del script
set "BASE_PATH=%~dp0"
set "PGSQL_PATH=%BASE_PATH%\pgsql"
set "WEB_PATH=%BASE_PATH%\proyecto"


:: Agregar Python al PATH si no está configurado globalmente
set "PYTHON_EXEC=%BASE_PATH%\python\python-3.12.4.amd64\python.exe"


:: Configurar entorno virtual
set "VENV_PATH=%WEB_PATH%\entorno\Scripts\activate"
if not exist "%VENV_PATH%" (
    echo Creando entorno virtual...
    "%PYTHON_EXEC%" -m venv "%WEB_PATH%\entorno"
    
    if exist "%VENV_PATH%" (
        echo Instalando dependencias...
        call "%VENV_PATH%"
        pip install -r "%WEB_PATH%\requirements.txt"
        deactivate
    ) else (
        echo Error: No se pudo crear el entorno virtual.
        pause
        exit /b
    )
)


:: Activar entorno virtual
call "%VENV_PATH%"


:: Verificar existencia del archivo de configuración del cluster
set "CLUSTER_FILE=%PGSQL_PATH%\cluster_name.txt"


if not exist "%CLUSTER_FILE%" (
    echo Error: No se encontró 'cluster_name.txt'.
    pause
    exit /b
)


:: Leer nombre del cluster
set /P "NombreCluster=" < "%CLUSTER_FILE%"
set "NombreCluster=!NombreCluster: =!"
set "RutaCluster=%PGSQL_PATH%\%NombreCluster%"


if not exist "%RutaCluster%" (
    echo Error: No se encontró el directorio del cluster '%NombreCluster%'.
    pause
    exit /b
)


:: Verificar si pg_ctl existe
set "PG_CTL=%PGSQL_PATH%\bin\pg_ctl.exe"


:: Iniciar PostgreSQL
echo Iniciando PostgreSQL...
"%PG_CTL%" start -D "%RutaCluster%"


:: Iniciar aplicación Flask
echo Iniciando aplicación Flask...
if exist "%WEB_PATH%\app.py" (
    start cmd /c python "%WEB_PATH%\app.py"
) else (
    echo Error: No se encontró 'app.py'.
    pause
    exit /b
)

:: Esperar a que la aplicación termine
echo Esperando a que la aplicación termine...
pause

:: Detener PostgreSQL
echo Deteniendo PostgreSQL...
"%PG_CTL%" stop -D "%RutaCluster%" -m fast

echo.
echo Proceso finalizado. Presiona cualquier tecla para salir...
pause
