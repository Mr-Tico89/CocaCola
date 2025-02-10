@echo off
echo Iniciando la aplicacion web...


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

:: Mantener la consola abierta en caso de error
echo.
echo Presiona cualquier tecla para salir...
pause











