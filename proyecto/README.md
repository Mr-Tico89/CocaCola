# Proyecto CocaCola


## Resumen
Este proyecto tiene como objetivo **optimizar y agilizar** el trabajo de los planificadores
en el **taller de mantención de Coca-Cola Embonor**, ofreciendo una **solución integral para la gestión y visualización de datos**, lo que permite una administración más eficiente y precisa.


## Requisitos 
El proyecto utiliza los siguientes lenguajes: 
- Python 3.12.4 +
- PostgreSQL 16.1 +

El disco duro ya viene con postgreSQL y python. Ademas existe un archivo nombrado requirements.txt, el cual contiene todas las librerias utilizadas, no tiene que instalarlas, el archivo iniciar.bat se encargara de instalarlas si no las tiene. 

> [!WARNING]
> La Base de datos no viene incluida, consulte para mas detalle

> [!NOTE]
> El backend y el archivo de Power BI están configurados para operar con la base de datos 
> alojada en el mismo host, utilizando el puerto predeterminado localhost:5432.


## Instrucciones para iniciar la pagina
Sigue estos pasos para iniciar el proyecto:

1. Dentro de la carpeta paginaWeb existe el archivo iniciar.bat, abralo y se abrira un terminal.

2. Si es la primera vez que lo iniciar, comenzara a descargar las librerias e instalarlas en 
el entorno virtual.

> [!NOTE]
> Puede tardar un par de minutos


3. Una vez ya instalado todo comenzara la aplicacion, se abrirar otra terminal y debiese 
aparece algo del estilo:

    ```bash
    Running on http://XXX.XXX.XXXX:8000
    ```

4. Copie ese link con `Ctrl + C`(**Cuidado** que con `Ctrl + C` tambien puede cerrar la app),
luego peguelo en el su navegador preferido. Asi podra usar la aplicacion si gusta puede guardar
un acceso directo.

5. Para cerrar la aplicacion puede salir de la terminal o puede apretar `Ctrl + C` para luego 
confirmar si quiere cerrar.


## Instrucciones para usar la pagina
La pagina esta compuesta por varias pestañas las cuales tienen su propia utilidad

1. **"Ver tablas"**: Como su nombre indica sirve para visualizar las tablas de la base de datos ademas se podran descargar en formato CSV. 

2. **"Averías Consolidadas"**: Esta pestaña permite al usuario modificar manualmente los datos 
de esta, permitiendo cambiar la columna observaciones, areas y sintoma.

3. **"HPR OEE"**: Esta pestaña permite al usuario modificar manualmente los datos de esta, permitiendo cambiar 

4. **"Indicador Semanal"**: Como su nombre indica sirve para crear el indicador semanal, segun 
los parametros otorgados año, mes, semana y areas. La tabla se generara al momento de darle al 
boton, esta nueva tabla quedara guardada en indicadores semanales historicos si no ha estado 
con estos parametros antes

5. **"Subir Datos"**: Como su nombre indica sirve para subir los archivos CSV de shoplogix a
la base de datos

6. **"Graficos"**: Esta pestaña permite descargar el archivo planilla.pbix para usarlo en 
powerBI, este archivo ya posee algunos graficos por defecto, si desea modificarlos puede 
hacerlo directamente en paginaWeb/cocacola/files

7. **"Avisos Turno"**: WIP


## Advertencias
- **Paginacion**: es posible que existan algunos bugs respecto a la paginacion cuando existen 
filtros o se clikea rapido el boton, ya no ocurre con frecuencia pero pueden ocurrir. 

- **Agregar Datos**: Para añadir los datos solo se puede con el csv original, si quiere agregar 
datos ya procesados lo puede hacer directamente usando consultas SQL en la base de datos.

- **Optimizacion**: Se podria mejorar la optimizacion del codigo.

- **Orden de filtros**: Los filtros no tienen orden (ex. para el filtro semana: 1, 47, 33, 2,
7, 20...).

- **Ciberseguridad**: En temas de ciberseguridad, no se le brindó la atención necesaria debido 
a la poca experiencia en el área.


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


