# Proyecto CocaCola


## Resumen
Este proyecto tiene como objetivo **optimizar y agilizar** el trabajo de los planificadores
en el **taller de mantención de Coca-Cola Embonor**, ofreciendo una **solución integral para la gestión y visualización de datos**, lo que permite una administración más eficiente y precisa.


## Requisitos 
Antes de iniciar el proyecto, asegúrate de tener instalados los siguientes lenguajes:
- Python 3.12 +
- PostgreSQL 16.1 +

Ademas existe un archivo nombrado requirements.txt, el cual contiene todas las librerias 
utilizadas, no tiene que instalarlas, el iniciar.bat se encargara de instalarlas si no las tiene. 

> [!WARNING]
> La Base de datos no viene incluida, consulte para mas detalle

> [!NOTE]
> El backend y el archivo de Power BI están configurados para operar con la base de datos 
> alojada en el mismo host, utilizando el puerto predeterminado localhost:5432.


## Instrucciones
Sigue estos pasos para iniciar el proyecto:

1. Dentro de la carpeta del proyecto existe el archivo iniciar.bat, abralo y se abrira un terminal.

2. Si es la primera vez que lo iniciar, comenzara a descargar las librerias e instalarlas en 
el entorno virtual.

> [!NOTE]
> Puede tardar un par de minutos


3. Una vez ya instalado todo comenzara la aplicacion, debiese salir algo del estilo

    ```bash
    Running on http://XXX.XXX.XXXX:8000
    ```

4. Copie ese link con `Ctrl + Shift + C`, luego peguelo en el su navegador preferido. Asi podra 
usar la aplicacion si gusta puede guardar un acceso directo.

5. Para cerrar la aplicacion puede salir de la terminal o puede apretar `Ctrl + C` para luego 
confirmar si quiere cerrar.


## Advertencias
- **Paginacion**: es posible que existan algunos bugs respecto a la paginacion cuando existen 
filtros o se clikea rapido el boton, ya no ocurre con frecuencia pero pueden ocurrir. 

- **Agregar Datos**: Para añadir los datos solo se puede con csv sin procesar, si quiere agregar 
datos ya procesados lo puede hacer mediantes consultas SQL en la base de datos.

- **Filtros Indicadores**: Los filtros de indicadores semanales no son dinamicos


## Bugs encontrados
- **Filtro para observaciones**: este filtro se sale del margen de la pagina, ademas se limito 
el texto de este. Esto ocurre para patallas de menor tamaño.

- **Cambio de orden**: cuando se actualiza una fila esta generalmete cambia de ubicacion 
subiendo o bajando en la tabla cuando se recarga la pagina.


## Contribuciones
Si deseas contribuir al proyecto, por favor sigue los siguientes pasos:

1. Haz un fork de este repositorio.

2. Crea una nueva rama (`git checkout -b feature/nueva-funcionalidad`).

3. Realiza tus cambios y haz commit (`git commit -m 'Añadir nueva funcionalidad'`).

4. Push a la rama (`git push origin feature/nueva-funcionalidad`).

5. Crea un pull request.


