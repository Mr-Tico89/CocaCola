@echo off
echo Iniciando la aplicacion web...

:: Activar entorno virtual (si lo tienes)
call entorno\Scripts\activate 

:: Iniciar la aplicación Flask
python app.py

pause











