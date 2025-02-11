@echo off
echo Iniciando la aplicacion web...

:: Verificar si el entorno virtual existe
if not exist "entorno\Scripts\activate" (
    echo Creando entorno virtual...
    python -m venv entorno

    echo Instalando dependencias desde requirements.txt...
    call entorno\Scripts\activate.bat
    pip install --no-cache-dir -r requirements.txt || (
        echo Error: Falló la instalación de requirements.txt
        exit /b 1
    )
)

:: Activar entorno virtual
echo Activando entorno virtual...
call entorno\Scripts\activate.bat

:: Iniciar la aplicación Flask
echo Iniciando la app...
python app.py

:: Mantener la consola abierta en caso de error
echo.
echo Presiona cualquier tecla para salir...
pause











