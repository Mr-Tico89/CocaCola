# Proyecto CocaCola

Este proyecto tiene como objetivo **optimizar y agilizar** el trabajo de los planificadores
en el **taller de mantención de Coca-Cola Embonor**, ofreciendo una **solución integral para la gestión y visualización de datos**, lo que permite una administración más eficiente y precisa.


## Requisitos 
El proyecto utiliza los siguientes lenguajes: 
- Python 3.12 +
- PostgreSQL 16.1 +

El disco externo ya viene con postgreSQL y python. Ademas existe un archivo nombrado 
requirements.txt, el cual contiene todas las librerias utilizadas, no tiene que instalarlas,
ya se encuentran instaladas en el entorno virtual.

> [!WARNING]
> La Base de datos no viene incluida, consulte para mas detalle

> [!NOTE]
> El backend y el archivo de Power BI están configurados para operar con la base de datos 
> alojada en el mismo host, utilizando el puerto predeterminado localhost:5432.


## Instrucciones para iniciar la pagina
Sigue estos pasos para iniciar el proyecto:

1. Dentro de la carpeta paginaWeb existe el archivo llamado iniciar.bat, abralo y se abrira una terminal.

2. Si es la primera vez que lo iniciar, comenzara a descargar las librerias e instalarlas en 
el entorno virtual.

> [!NOTE]
> Puede tardar un par de minutos

3. Una vez ya instalado todo comenzara la aplicacion, se abrira La aplicacion web junto a un terminal en el cual aparece algo del estilo:

    ```bash
    Iniciando aplicación Flask...
    Aplicacion iniciada en: http://localhost:8000
    ```

4. Si llega a cerrar la aplicacion web en el navegador puede seleccionar y copiar ese link con `Ctrl + C`(**Cuidado** que con `Ctrl + C` tambien puede cerrar la app si no lo seleciona), luego peguelo en el su navegador preferido. Asi podra usar la aplicacion nuevamente, si gusta puede guardar un acceso directo en el escritorio.

5. Para cerrar la aplicacion debe apretar `Ctrl + C` en la terminal si llega a cerrar mediante el boton X es posible que la aplicacion no cierre bien lo cual puede causar problemas a futuro


## Instrucciones para usar la pagina
La pagina esta compuesta por varias pestañas las cuales tienen su propia utilidad

1. **"Ver tablas"**: Como su nombre indica sirve para visualizar las tablas de la base de datos ademas se podran descargar en formato CSV (Al menos que esten bloqueadas las descargas por la empresa). 

2. **"Averías Consolidadas"**: Esta pestaña permite al usuario modificar manualmente los datos, permitiendo cambiar la columna observaciones, areas y sintoma. Además se pueden eliminar los datos inncesarios o duplicados, usando el boton X que se encuentra en la columna Quitar

3. **"HPR OEE"**: Esta pestaña permite al usuario modificar manualmente los datos de esta, permitiendo cambiar el OEE. Además se pueden eliminar los datos inncesarios o duplicados, usando 
el boton X que se encuentra en la columna Quitar

4. **"Indicador Semanal"**: Como su nombre indica sirve para crear el indicador semanal, según 
los parametros otorgados año, mes, semana y areas. La tabla se generara al momento de darle al 
boton de generar tabla, esta nueva tabla quedara guardada en indicadores semanales historicos si 
no ha estado con estos parametros antes ademas se guarda el ultimo indicador semanal creado en 
la tabla

5. **"Subir Datos"**: Como su nombre indica sirve para subir los archivos CSV de shoplogix a
la base de datos.

6. **"Graficos"**: Esta pestaña permite abrir el archivo planilla.pbix para usarlo en 
powerBI, (Recuerde que cada vez que lo abre tendra que actualizar los datos) este archivo ya 
posee algunos graficos por defecto, si desea modificarlos puede hacerlo directamente en ese 
archivo.

7. **"Avisos Turno"**: Estamos trabajando para usted ᕙ(⇀‸↼‶)ᕗ


## Bugs encontrados
- **Filtro para observaciones**: Este filtro se sale del margen de la pagina, ademas se limito 
el texto de este. Esto ocurre para patallas de menor tamaño.

- **Cambio de orden**: Cuando se actualiza una fila esta posiblemente cambia de ubicacion 
subiendo o bajando en la tabla cuando se recarga la pagina.


## Advertencias
- **Paginacion**: es posible que existan algunos bugs respecto a la paginacion cuando existen 
filtros o se clikea rapido el boton, ya no ocurre con frecuencia pero pueden ocurrir. 

- **Agregar Datos**: Para añadir los datos solo se puede con el csv original, si quiere agregar 
datos ya procesados lo puede hacer directamente usando consultas SQL en la base de datos.

- **Optimizacion**: Se podria mejorar la optimizacion del codigo.

- **Orden de filtros**: Los filtros de fecha no tienen orden (ex. el orden 2024-02-24, 2023-10-02,
2023-06-24)

- **Ciberseguridad**: En temas de ciberseguridad, no se le brindó la atención necesaria debido 
a la poca experiencia en el área.

- **letra de unidad**: Este programa funciona cuando el disco duro esta asignado a la letra E: si llega a estar en otra letra por ejemplo la D: tiene 2 opcines:

1. Sacar el disco, colocar un pendrive o otra unidad de almacenamiento para que ocupe la letra D:la letra y luego colocar el disco.


2. Si por alguna razón no posee un pendrive debe cambiar la configuración del entorno a la letra correspondiente (paginaWeb\proyecto\entorno\pyvenv.cfg), abra el archivo con block de notas y ahi saldra algo del estilo:

    ```bash
    home = E:\paginaWeb\python\python-3.12.4.amd64
    include-system-site-packages = false
    version = 3.12.4
    executable = E:\paginaWeb\python\python-3.12.4.amd64\python.exe
    command = E:\paginaWeb\python\python-3.12.4.amd64\python.exe -m venv D:\paginaWeb\proyecto\entorno
    ```

    Aqui debe cambiar la letra E: del principio de cada directorio a la letra correspondiente de la unidad por ejemplo si el disco ahora esta en la unidad D: debe cambiarlo para que quede asi:

        ```bash
        home = D:\paginaWeb\python\python-3.12.4.amd64
        include-system-site-packages = false
        version = 3.12.4
        executable = D:\paginaWeb\python\python-3.12.4.amd64\python.exe
        command = D:\paginaWeb\python\python-3.12.4.amd64\python.exe -m venv D:\paginaWeb\proyecto\entorno
        ```




## Contribuciones
Si deseas contribuir al proyecto, por favor sigue los siguientes pasos:

1. Haz un fork de este repositorio.

2. Crea una nueva rama (`git checkout -b feature/nueva-funcionalidad`).

3. Realiza tus cambios y haz commit (`git commit -m 'Añadir nueva funcionalidad'`).

4. Push a la rama (`git push origin feature/nueva-funcionalidad`).

5. Crea un pull request.