@echo off
echo Iniciando PostgreSQL...

:: Obtener la ruta base del script (independiente de la letra de unidad)
set "WEB_PATH=%~dp0"

:: Establecer PGSQL_PATH apuntando a la carpeta pgsql al mismo nivel que CocaCola
set "PGSQL_PATH=%WEB_PATH:CocaCola=pgsql%"



echo Iniciando la aplicación web...
:: Verificar si el entorno virtual existe
if not exist "%WEB_PATH%\entorno\Scripts\activate" (
    echo Creando entorno virtual...
    python -m venv entorno
    echo Instalando dependencias...
    call entorno\Scripts\activate
    pip install -r requirements.txt
    deactivate
)

:: Activar entorno virtual e iniciar la aplicación
echo Activando entorno virtual...
call "%WEB_PATH%\entorno\Scripts\activate


:: Ejecutar el script para iniciar PostgreSQL en una nueva ventana
START "Iniciando PostgreSQL" cmd /c "%PGSQL_PATH%\PostgreSQL-Start.bat"


:: Iniciar la aplicación Flask
call cmd /c "python %WEB_PATH%\app.py"

:: Al cerrar la aplicación Flask, detener el clúster de PostgreSQL
echo Esperando a que la app termine...
pause

echo Cerrando postgreSQL...
START "Cerrando PostgreSQL" cmd /c "%PGSQL_PATH%\PostgreSQL-Stop.bat"

:: Mantener la consola abierta en caso de error
echo.
echo Presiona cualquier tecla para salir...
pause











