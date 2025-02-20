// Proyecto CocaCola
// rev: 1.0
// Fecha: 10-02-2025
// Autor: Mr.Tico89
// Contacto: matinico71@gmail.com, @mati_rojasv (IG)
// Respositorio: https://github.com/Mr-Tico89/CocaCola.git

// Para el futuro practicante:  
    //  
    // Si estás leyendo esto, es probable que te hayan enviado a revisar el código.  
    // Seré honesto: este es mi primer proyecto de página web, así que seguro está lleno  
    // de bugs y vulnerabilidades.  
    //  
    // Tu misión es continuar con este legado. Si es posible, me encantaría saber cómo 
    // evoluciona mi "primer hijo" (le tengo cariño, jeje). No dudes en hacer preguntas 
    // si necesitas ayuda. Mucho éxito en tu camino.  
    //  
    // "El universo dijo que tú eres el universo probándose a sí mismo, hablándose a sí mismo, 
    //  leyendo su propio código. Y el universo dijo Te amo, porque tú eres el amor." 
    //  -Minecraft  
    //  
    // Se despide el primer practicante Ing. civil en computacion de mantenimiento (hasta donde sé).  
//
//     ⠀⠀⠀⠀⢸⠓⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠀⠀⢸⠀⠀⠑⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠀⠀⢸⡆⠀⠀⠀⠙⢤⡷⣤⣦⣀⠤⠖⠚⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⣠⡿⠢⢄⡀⠀⡇⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠸⠷⣶⠂⠀⠀⠀⣀⣀⠀⠀⠀
//    ⢸⣃⠀⠀⠉⠳⣷⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⢉⡭⠋
//    ⠀⠘⣆⠀⠀⠀⠁⠀⢀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀
//    ⠀⠀⠘⣦⠆⠀⠀⢀⡎⢹⡀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⡀⣠⠔⠋⠀⠀⠀⠀
//    ⠀⠀⠀⡏⠀⠀⣆⠘⣄⠸⢧⠀⠀⠀⠀⢀⣠⠖⢻⠀⠀⠀⣿⢥⣄⣀⣀⣀⠀⠀
//    ⠀⠀⢸⠁⠀⠀⡏⢣⣌⠙⠚⠀⠀⠠⣖⡛⠀⣠⠏⠀⠀⠀⠇⠀⠀⠀⠀⢙⣣⠄
//    ⠀⠀⢸⡀⠀⠀⠳⡞⠈⢻⠶⠤⣄⣀⣈⣉⣉⣡⡔⠀⠀⢀⠀⠀⣀⡤⠖⠚⠀⠀
//    ⠀⠀⡼⣇⠀⠀⠀⠙⠦⣞⡀⠀⢀⡏⠀⢸⣣⠞⠀⠀⠀⡼⠚⠋⠁⠀⠀⠀⠀⠀
//    ⠀⢰⡇⠙⠀⠀⠀⠀⠀⠀⠉⠙⠚⠒⠚⠉⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⢧⡀⠀⢠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠙⣶⣶⣿⠢⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠀⠀⠉⠀⠀⠀⠙⢿⣳⠞⠳⡄⠀⠀⠀⢀⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠹⣄⣀⡤⠋⠀


document.addEventListener('DOMContentLoaded', function () {
    // Llamar a loadTableOptions cuando la página se carga
    loadTableOptions();

    // Agregar eventos a los filtros
    document.querySelectorAll('.filter-select').forEach(select => {
        console.log("hola toi en uso")
        select.addEventListener('change', (event) => {
            const selectId = event.target.id.replace('filter-', ''); // ID del select
            const value = Array.from(event.target.selectedOptions).map(option => option.value); // Valores seleccionados
            updateSelectedFilters(selectId, value);
        });
    });


    // Agregar eventos a los botones de pestañas
    document.querySelectorAll('.tablinks').forEach(button => {
        button.addEventListener('click', (event) => {
            const tabId = event.target.getAttribute('onclick').match(/'(.*?)'/)[1]; // Extrae el ID de la pestaña
            clearGlobalActiveFilters(globalActiveFilters)
            clearGlobalActiveFilters(selectedFilters)
            // Definir las acciones para cada pestaña
            switch (tabId) {
                case 'Tab2':
                    loadTableData('editable-container-tab2', 'Tab2', 'db_averias_consolidado', true)
                    break;

                case 'Tab3':
                    loadTableData('editable-container-tab3', 'Tab3', 'hpr_oee', true);
                    break;

                case 'Tab4':
                    loadTableData('Indicador-container', 'Tab4', 'INDICADOR_SEMANAL', true);
                    loadAndPopulateFilters()
                    break;
            }
        });
    });

    document.getElementById('Gen-button').addEventListener('click', async function (event) {
        try {
            const tableContainer = document.getElementById('Indicador-container');
    
            // Mostrar un mensaje de carga
            tableContainer.innerHTML = '<p>Actualizando datos...</p>';
    
            // Ejecutar los filtros y cálculos
            const data = await applyFiltersAndCalculate(); //ver q ondis pq falla
            // Guardar los datos procesados
            await saveData(data);

            // Llamada a la función
            // Verificar si selectedFilters.año y selectedFilters.semana tienen longitud 1
            if (globalActiveFilters.año.size >= 1 && globalActiveFilters.mes.size >= 1 && 
                globalActiveFilters.semana.size >= 1 && globalActiveFilters.areas.size >= 2
            ) {
                const result = CreateJsonInd(data, globalActiveFilters.areas.has("Paros Menores")); //ver q ondis pqq falla
                await saveData(result);
            }

            // Cargar la tabla actualizada
            await loadTableData('Indicador-container', 'Tab4', 'indicador_semanal', true);
            console.log('Tabla actualizada correctamente.');

        } catch (error) {
            console.error('Error durante el proceso:', error);
    
            const tableContainer = document.getElementById('Indicador-container');
            tableContainer.innerHTML = '<p>Error al actualizar los datos.</p>';
        }
    });
    
    // Para el botón de subir
    document.getElementById('upload-form').addEventListener('submit', function (event) {
        event.preventDefault();  // Previene el comportamiento por defecto del formulario
        var formData = new FormData(this);

        // Enviar el formulario a la ruta '/upload' usando fetch
        fetch('/uploads', {
            method: 'POST',
            body: formData
        })
            .then(response => response.json())
            .then(data => document.getElementById('upload-status').innerText = data.message)
            .catch(error => console.error('Error al subir el archivo:', error));
    });



});


// Objeto global para almacenar filtros activos por columna
const globalActiveFilters  = {};


// Objeto para almacenar los filtros seleccionados
const selectedFilters = {};


// funcion para limpiar filtros, se usa cada vez que cambia de pestaña
function clearGlobalActiveFilters(filters) {
    Object.keys(filters).forEach(key => delete filters[key]);
}


// Muestra el botón cuando se baja más de 200px
window.onscroll = function() {
    let button = document.getElementById("scrollToTopBtn");
    if (document.body.scrollTop > 200 || document.documentElement.scrollTop > 200) {
      button.style.display = "block";
    } else {
      button.style.display = "none";
    }
};
  

// Función para subir al inicio
function scrollToTop() {
    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
}
  

// Función para mostrar la pestaña seleccionada
function openTab(evt, tabName) {
    var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tabcontent");
    tablinks = document.getElementsByClassName("tablinks");
  
    // Ocultar todas las pestañas
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
    }
  
    // Quitar la clase 'active' de todos los botones
    for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active", "");
    }
  
    // Mostrar la pestaña seleccionada
    document.getElementById(tabName).style.display = "block";
  
    // Añadir la clase 'active' al botón de la pestaña
    evt.currentTarget.className += " active";
  
    // Guardar el índice de la pestaña seleccionada en localStorage
    localStorage.setItem("activeTab", tabName);

}


//funcion para cargar los nombres de las tablas en las opciones tab1
async function loadTableOptions() {
    try {
        const response = await fetch('/tables');
        const tables = await response.json();
        const tableSelect = document.getElementById('table-select');
        tables.forEach(table => {
            const option = document.createElement('option');
            
            option.value = table;
            option.textContent = table.replace(/_/g, ' ').charAt(0).toUpperCase() + table.replace(/_/g, ' ').slice(1);
            tableSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error fetching tables:', error);
    }
}


//funcion para cargar los datos del backtend al front
async function loadTableData(containerId, tabName,  tableName = null, render) {
    const table = tableName || document.getElementById('table-select').value;
    if (!table) return;

    try {
        const response = await fetch(`/tables/${table}/filtered_data`);
        const data = await response.json();
        if (render) {
            renderEditableTable(data, containerId);
            return data;
        }
        return data;
    } catch (error) {
        console.error(`Error fetching data for table ${table}:`, error);
    }
}


// crea el menu desplegable
function createDropdownFilter(filterName, column) {
    // Crear el contenedor principal del filtro
    const container = document.createElement('div');
    container.classList.add(`${filterName}-container`);
    
    // Crear el botón desplegable
    const dropdownButton = document.createElement('button');
    if (filterName === "dropdown") {
        dropdownButton.textContent = '▼';  // Mejor icono visual
    } else {
        dropdownButton.textContent = column;
    }
    
    dropdownButton.classList.add(`${filterName}-button`);
    dropdownButton.setAttribute('aria-expanded', 'false'); // Accesibilidad

    // Crear el menú desplegable
    const dropdownMenu = document.createElement('div');
    dropdownMenu.classList.add(`${filterName}-menu`);
    dropdownMenu.setAttribute('role', 'menu');

    let closeTimeout; // Variable para manejar el tiempo de cierre

    // Manejar la apertura y cierre del menú
    function toggleDropdown(event) {
        event.stopPropagation();
        const isOpen = dropdownMenu.classList.toggle('show');
        dropdownButton.setAttribute('aria-expanded', isOpen.toString());
    }

    function closeDropdown() {
        dropdownMenu.classList.remove('show');
        dropdownButton.setAttribute('aria-expanded', 'false');
    }

    dropdownButton.addEventListener('click', toggleDropdown);

    // Cerrar el menú al hacer clic fuera de él
    document.addEventListener('click', (event) => {
        if (!container.contains(event.target)) {
            closeDropdown();
        }
    });

    // Cerrar el menú con la tecla Esc
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            closeDropdown();
        }
    });

    // Ajustar la posición si el menú se desborda
    dropdownMenu.addEventListener('mouseover', () => {
        const rect = dropdownMenu.getBoundingClientRect();
        if (rect.right > window.innerWidth) {
            dropdownMenu.classList.add('adjust-left');
        } else {
            dropdownMenu.classList.remove('adjust-left');
        }
    });

    // Cerrar el menú si el mouse sale del contenedor después de 300ms
    dropdownMenu.addEventListener('mouseleave', () => {
        closeTimeout = setTimeout(closeDropdown, 200);
    });

    // Si el usuario vuelve a entrar, cancelar el cierre
    dropdownMenu.addEventListener('mouseenter', () => {
        clearTimeout(closeTimeout);
    });

    // Añadir los elementos al contenedor
    container.appendChild(dropdownButton);
    container.appendChild(dropdownMenu);

    // Retornar el contenedor y el menú para su manipulación posterior
    return { container, dropdownMenu };
}


// funcion para crear los valores unicos, para los filtros de columnas 
async function fetchUniqueValues(column, tableName) {
    const filters = {};

    // Convertir los filtros de globalActiveFilters a un formato adecuado
    Object.keys(globalActiveFilters).forEach(column => {
        // Si el Set no está vacío, lo convertimos a array
        if (globalActiveFilters[column].size > 0) {
            filters[column] = Array.from(globalActiveFilters[column]).join(',');
        }
    });
    // Construir la cadena de parámetros de consulta con los filtros
    const queryString = new URLSearchParams(filters).toString();

    // Hacer la solicitud al backend, incluyendo los filtros en la URL
    const url = `/tables/${tableName}/unique_values?column=${column}&${queryString}`;
    
    try {
        const response = await fetch(url);
        const uniqueData = await response.json();
        return uniqueData[column] || [];  // Retorna los valores únicos de la columna solicitada
    } catch (error) {
        console.error("Error obteniendo valores únicos:", error);
        return [];
    }
}


// Función madre para crear el boton de filtros y menu desplegable
async function createFilterSelect(filterName, column, tableName, containerId) {
    // Crear el contenedor para el filtro
    
    const { container, dropdownMenu } = createDropdownFilter(filterName, column);

    if (!(containerId == "Indicador-container")){
        // Obtener valores únicos desde el backend
        const uniqueValues = await fetchUniqueValues(column, tableName);  

        // Agregar los checkboxes y los valores únicos obtenidos al dropdownMenu
        addCheckboxesToDropdown(filterName, uniqueValues, column, dropdownMenu, tableName, containerId);
    }
    return container;
}


// Función auxiliar para agregar los checkboxes al menú desplegable, cada vez que se activa uno activa fetchFilteredData
function addCheckboxesToDropdown(filterName, uniqueValues, column, dropdownMenu, tableName, containerId) {
    createClearFiltersButton(dropdownMenu, column, containerId, tableName);

    uniqueValues.forEach(value => {
        const checkboxContainer = document.createElement('label');
        checkboxContainer.classList.add(`${filterName}-item`);

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.value = value;

        const label = document.createElement('span');
        label.textContent = value;

        
        // Asegurar que globalActiveFilters esté inicializado
        if (!globalActiveFilters[column]) {
            globalActiveFilters[column] = new Set();  // Inicializar como un conjunto vacío
        }
        
        
        // Verificar si el valor está en globalActiveFilters y marcar el checkbox
        if (globalActiveFilters[column].has(String(value))) {
            checkbox.checked = true;  // Si está en globalActiveFilters, marcar el checkbox
        }

        // Manejar cambio en el estado del checkbox
        checkbox.addEventListener('change', () => {

            // Actualizamos el filtro según si el checkbox está marcado o no
            if (checkbox.checked) {
                globalActiveFilters[column].add(String(value));
            } else {
                globalActiveFilters[column].delete(String(value));
            }

            // Si el containerId no contiene "filter", obtenemos los datos filtrados
            if (!containerId.includes("filter")) {
                fetchFilteredData(tableName, containerId);
            } else {
                // Si el containerId contiene "filter", mostramos el mensaje en consola
                const columms = ['año', 'mes', 'semana']
                columms.forEach(colummn => {
                    if (!(column == colummn)) {
                        addFilterToTable(colummn)
                    }   
                });
            }
        });

        checkboxContainer.appendChild(checkbox);
        checkboxContainer.appendChild(label);
        dropdownMenu.appendChild(checkboxContainer);
    });
}


function createClearFiltersButton(dropdownMenu, column, containerId, tableName) {
    const clearButton = document.createElement('button');
    clearButton.textContent = 'Borrar filtros';
    clearButton.classList.add('clear-filters-button');
    
    clearButton.addEventListener('click', (event) => {
        event.stopPropagation();
        
        // Desmarcar todos los checkboxes dentro del menú desplegable
        dropdownMenu.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
            checkbox.checked = false;
        });
        
        // Limpiar los filtros activos de la columna si existen
        if (globalActiveFilters[column]) {
            globalActiveFilters[column].clear();
        }
        
        // Verificar si el containerId no contiene "filter"
        if (!containerId.includes("filter")) {
            fetchFilteredData(tableName, containerId);
        } else {
            // Si el containerId contiene "filter", mostramos el mensaje en consola
            const columms = ['año', 'mes', 'semana']
            columms.forEach(colummn => {
                if (!(column == colummn)) {
                    addFilterToTable(colummn)
                }
            });  
        }
    });
    
    dropdownMenu.appendChild(clearButton);
}



//funcion para actualizar la tabla con los valores unicos (filtros dinamicos), implementarlos a ind_sem WIP
async function fetchFilteredData(tableName, containerId) {
    if (!tableName) {
        console.error("El nombre de la tabla es requerido.");
        return;
    }

    const filters = {};

    // Construir filtros activos
    for (const column in globalActiveFilters) {
        if (globalActiveFilters[column]?.size > 0) {
            filters[column] = [...globalActiveFilters[column]].join(',');
        }
    }

    // Construir URL con parámetros de filtros
    const queryString = new URLSearchParams(filters).toString();
    const url = `/tables/${encodeURIComponent(tableName)}/filtered_data?${queryString}`;

    try {
        const response = await fetch(url);

        if (!response.ok) {
            throw new Error(`Error en la solicitud: ${response.status} ${response.statusText}`);
        }

        const filteredData = await response.json();
        //quizas hacer un if para implementarlo en ind_sem no se
        
        renderEditableTable(filteredData, containerId)
        
    } catch (error) {
        console.error("Error obteniendo datos filtrados:", error);
    }
}


//para actualizar la paginacion (por una extraña razon a veces se bugea cuando se clickea rapido o cuando hay filtros)
function updatePagination(data, tableName, containerId) {
    const { current_page, total_pages } = data;


    // Usar expresión regular para obtener el número final
    const match = containerId.match(/tab(\d+)$/);
    const tabNumber = match[1];  // El número estará en la primera captura

    // Acceso a los elementos de paginación
    const prevButton = document.getElementById(`prevPage${tabNumber}`);
    const nextButton = document.getElementById(`nextPage${tabNumber}`);
    const pageInfo = document.getElementById(`pageInfo${tabNumber}`);

    // Verificar que los elementos de paginación existen
    if (!prevButton || !nextButton || !pageInfo) {
        console.error("Error: Elementos de paginación faltantes en el DOM.");
        if (!prevButton) console.error("No se encontró el botón 'prevPage'.");
        if (!nextButton) console.error("No se encontró el botón 'nextPage'.");
        if (!pageInfo) console.error("No se encontró el elemento 'pageInfo'.");
        return;
    }

    // Actualizar información de la página
    pageInfo.textContent = `Página ${current_page} de ${total_pages}`;

    // Habilitar o deshabilitar los botones según la página actual
    prevButton.disabled = current_page <= 1;
    nextButton.disabled = current_page >= total_pages;

    // Solo actualizar eventos si los botones no están deshabilitados
    if (!prevButton.disabled) {
        prevButton.onclick = () => changePage(current_page, total_pages, tableName, -1 , containerId);
    }

    if (!nextButton.disabled) {
        nextButton.onclick = () => changePage(current_page, total_pages, tableName, 1, containerId);
    }
}


let currentPage = 1;  // Página inicial


//funcion auxiliar para cambiar pagina
function changePage(current_page, total_pages, tableName, direction, containerId) {
    current_page += direction; // Calcula la nueva página

    // Limita el rango entre 1 y totalPages
    if (current_page >= 1 && current_page <= total_pages) {
        fetchTablePage(tableName, current_page, containerId);
    }
    else {
        console.error("Error: La página está fuera de rango:", newPage);
    }
}


//funcion auxiliar para generar nueva pagina
function fetchTablePage(tableName, page, containerId) {
    const filters = {};
    
    // Construir filtros activos
    for (const column in globalActiveFilters) {
        if (globalActiveFilters[column]?.size > 0) {
            filters[column] = [...globalActiveFilters[column]].join(',');
        }
    }

    // Construir URL con parámetros de filtros
    const queryString = new URLSearchParams(filters).toString();

    fetch(`/tables/${tableName}/filtered_data?page=${page}&${queryString}`)
        .then(response => response.json())
        .then(data => {
            renderEditableTable(data, containerId)
            
        })
        .catch(error => console.error("Error al obtener los datos:", error));
}


//para modificar filas de la tabla en la base de datos
async function updateRow(table_name, rowData, newData) {
    try {
        const response = await fetch('/update_row', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ table_name, row_data: rowData, newData }),
        });

        if (!response.ok) {
            throw new Error(`Error HTTP: ${response.status}`);
        }

        const result = await response.json();
        console.log(result.message || result.error);
    } catch (error) {
        console.error("Error actualizando la fila:", error);
    }
}


//para eliminar filas de la tabla en la base de datos
async function deleteRow(jsonData, table_name) {
    try {
        const response = await fetch('/delete_row', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ table_name, row_data: jsonData }),
        });

        if (!response.ok) {
            throw new Error(`Error HTTP: ${response.status}`);
        }

        return await response.json(); // Devolver el resultado del servidor
    } catch (error) {
        console.error('Error en deleteRow:', error);
        return { success: false, error: error.message };
    }
}


//renderizar tabla
function renderEditableTable(response, containerId) {
    const {table_name, columns, data } = response;
    const container = document.getElementById(containerId);
    // Limpiar la tabla existente
    if (!container) {
        console.error(`Error: El contenedor con id '${containerId}' no existe en el DOM.`);
        return;
    }
     
    container.innerHTML = ''

    // Crear y configurar la tabla
    const table = createTableElement('editable-table');


    // Crear encabezados con filtros
    const thead = createTableHeader(columns, containerId, table_name);


    // Crear cuerpo de la tabla
    const tbody = createTableBody(columns, data, containerId, table_name);

    if (containerId !== 'Indicador-container') {
        updatePagination(response, table_name, containerId);
    }

    // Ensamblar la tabla
    table.appendChild(thead);
    table.appendChild(tbody);
    container.appendChild(table);
}


function createTableElement(className) {
    const table = document.createElement('table');
    table.classList.add(className);
    return table;
}


//crear el encabezado de la tabla
function createTableHeader(columns, containerId, tableName) {
    const thead = document.createElement('thead');
    thead.classList.add('editable-table-header');
    const headerRow = thead.insertRow();

    const buttonHeader = createHeaderCell('Quitar');
    if (!containerId.includes('editable-container'))  { 
        // ocultar la columna quitar para que filten bien los datos en la tab ver tablas
        buttonHeader.classList.add('hidden-column');
    }

    headerRow.appendChild(buttonHeader);

    columns.forEach(column => {
        const th = createHeaderCell(
            column.replace(/_/g, ' ').charAt(0).toUpperCase() + column.replace(/_/g, ' ').slice(1) //deja bonito el titulo de la columna
        );

        // Crear filtro para cada columna
        createFilterSelect('dropdown', column, tableName, containerId)
        .then(container => {
            th.appendChild(container);  // Añadir el contenedor del filtro al encabezado de la columna
        });

        headerRow.appendChild(th);
    });

    return thead;
}


//celdas para el encabezado
function createHeaderCell(textContent, additionalClass = '') {
    const th = document.createElement('th');
    th.textContent = textContent;
    if (additionalClass) {
        th.classList.add(additionalClass);
    }
    return th;
}


//crear el cuerpo de la tabla
function createTableBody(columns, data, containerId, table_name) {
    const tbody = document.createElement('tbody');
    tbody.classList.add('editable-table-body');

    data.forEach((row, rowIndex) => {
        const tr = tbody.insertRow();

        const buttonCell = createButtonCell(tr, tbody, data, table_name);
        if (!containerId.includes('editable-container')) { // ocultar la columna quitar para que filten bien los datos
            buttonCell.classList.add('hidden-column');
        }
        tr.appendChild(buttonCell);
        
        columns.forEach(column => {
            const td = containerId.includes('editable-container')
                ? createEditableCell(row, column, data, rowIndex, table_name)
                : createTextCell(row[column]);
            tr.appendChild(td);
        });
    });

    return tbody;
}


//crear celdas editables
function createEditableCell(row, column, data, rowIndex, table_name) {
    let counter = 1;  // Contador para IDs únicos
    const td = document.createElement('td');
    td.id = `bodyCell${counter}`;
    const cellValue = row[column] !== null && row[column] !== undefined ? row[column] : '';
    

    // Manejar la columna 'areas' con un <select>
    if (column === 'areas' && cellValue !== 'Paros Menores') {
        const select = document.createElement('select');
        select.id = `selectCell${counter}`;
        const options = ['', 'Mecánico', 'Eléctrico'];

        options.forEach(optionValue => {
            const option = document.createElement('option');
            option.value = optionValue;
            option.textContent = optionValue;

            if (cellValue === optionValue) {
                option.selected = true;
            }

            select.appendChild(option);
        });

        // Agregar evento de cambio para actualizar el valor en los datos
        select.addEventListener('change', (e) => {
            data[rowIndex][column] = e.target.value;
            let new_data = {
                [column]: data[rowIndex][column]
            }
            
            updateRow(table_name, data[rowIndex], new_data)
        });

        td.appendChild(select);
    } 

    // Manejar columnas 'sintoma', 'observaciones', o 'OEE' con <input>
    else if (['sintoma', 'observaciones', 'oee'].includes(column)) {
        const input = document.createElement('input');
        input.id =  `textCell${counter}`;
        input.type = 'text';
        input.placeholder = 'Editar';
        input.value = cellValue;

        // Forzar mayúsculas en 'observaciones'
        if (column === 'observaciones') {
            input.addEventListener('input', () => {
                input.value = input.value.toUpperCase();
            });
        }

        // Actualizar los datos al perder el foco
        input.addEventListener('blur', () => {
            data[rowIndex][column] = input.value;
            let new_datas = {
                [column]: data[rowIndex][column]
            }
            updateRow(table_name, data[rowIndex], new_datas)
        });

        td.appendChild(input);
    } 

    // Manejar celdas normales sin edición
    else {
        td.textContent = cellValue;
    }

    counter++; //para crear id's de celdas

    return td;
}


//crear el boton de la columna quitar
function createButtonCell(rowElement, tbody, data, table_name) {
    const buttonCell = document.createElement('td');
    const button = document.createElement('button');
    button.classList.add('delete-button');
    button.textContent = 'x';
    

    button.addEventListener('click', () => {
        const rowIndex = rowElement.rowIndex - 1; // Restar 1 si hay un encabezado en la tabla
        if (confirm('¿Seguro que quieres eliminar esta fila?')) {
            deleteRow(data[rowIndex], table_name)
                .then(response => {
                    if (response.success) {
                        tbody.removeChild(rowElement); // Eliminar fila del DOM

                        alert('Fila eliminada con éxito.');
                    } else {
                        alert(`Error al eliminar fila: ${response.error}`);
                    }
                })
                .catch(error => {
                    console.error('Error en la solicitud:', error);
                    alert('Ocurrió un error al eliminar la fila.');
                });
        }
    });

    buttonCell.appendChild(button);
    return buttonCell;
}


function createTextCell(content) {
    const td = document.createElement('td');
    td.textContent = content !== null && content !== undefined ? content : '0';
    return td;
}


//para guardar la tabla en indicardor semanal historico
async function saveData(data) {
    try {
        const response = await fetch('/save', {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });

        // Verificar si la respuesta fue exitosa
        if (!response.ok) {
            throw new Error(`Error en la solicitud: ${response.status} - ${response.statusText}`);
        }

        const result = await response.json();
        console.log('Datos guardados:', result);
        return result; // Devolver los datos guardados
    } catch (error) {
        console.error('Error al guardar los datos:', error);
        throw error; // Lanzar el error para que sea manejado en el nivel superior
    }
}


// Función para actualizar los filtros seleccionados en indicador semanal
function updateSelectedFilters(selectId, value) {
    if (value.length > 0) {
        selectedFilters[selectId] = value; // Actualiza el valor seleccionado
    } else {
        delete selectedFilters[selectId]; // Elimina el filtro si no hay selección
    }
}



async function addFilterToTable(filter) {
    const thead = document.createElement('thead');
    thead.classList.add('editable-filter-header'); //cambiarlo para personalizarlo CSS
    const headerRow = thead.insertRow();
    const th = createHeaderCell();

    await createFilterSelect('filter', filter, 'db_averias_consolidado', `filter-${filter}`)
    .then(container => {
        th.appendChild(container);

        // Agregarlo también al div con id="filter-año"

        const filterDiv = document.getElementById(`filter-${filter}`);
        filterDiv.innerHTML = '';
        if (filterDiv) {
            filterDiv.appendChild(container);
        }   
    });

    headerRow.appendChild(th);
}

//func main para rellenar los 4 fitros 
async function loadAndPopulateFilters() {
    addFilterToTable('año')
    addFilterToTable('mes')
    addFilterToTable('semana')
    addFilterToTable('areas')

}


//funcion para cargar todos los datos del backtend al front, no usar para renderizar la tabla (LAG!!)
async function loadFullTableData(tableName = null) {
    const table = tableName || document.getElementById('table-select').value;
    if (!table) return;

    const filters = {};
    // Construir filtros activos
    for (const column in globalActiveFilters) {
        if (globalActiveFilters[column]?.size > 0) {
            filters[column] = [...globalActiveFilters[column]].join(',');
        }
    }

    // Construir URL con parámetros de filtros
    const queryString = new URLSearchParams(filters).toString();
    try {
        const url = `/tables/${table}/data?${queryString}`;
        const response = await fetch(url)
        const data = await response.json();
        return data;
    } catch (error) {
        console.error(`Error fetching data for table ${table}:`, error);
    }
}


//funcion para rellenar la tabla ind semanal realizando todos los calculos y recopilacion de datos en la tabla
function applyFiltersAndCalculate() {
    return Promise.all([
        loadFullTableData('db_averias_consolidado'),
        loadFullTableData('hpr_oee'),
        loadFullTableData('indicador_semanal')
    ])
    .then(([averiasData, oeeData, indData]) => {
        if (!averiasData || !averiasData.data || !oeeData || !oeeData.data) {
            throw new Error("Los datos de las tablas no son válidos.");
        }
        // Inicializar objetos de minutos para cada tabla
        let minutosAverias = { 
            minutos: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 },
            countMin: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 }
        };


        let minutosOEE = { 
            minutos: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 },
            countMin: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 },
            oee: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 }
        };

        //aqui van los calculos de los datos
        let metrics = { 
            mttr: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 },
            mtbf: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 },
            disp: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 }
        };

        // Calcular minutos para ambas tablas usando la función auxiliar con los campos específicos
        minutosAverias = calculateTotalMinutesById(averiasData, minutosAverias, 'id', 'minutos');
        minutosOEE = calculateTotalMinutesById(oeeData, minutosOEE, 'linea', 'min');
        metrics = calculateMetrics(minutosAverias, minutosOEE, metrics);
        const avg = calculateOEEAverage(oeeData.data)
        updateIndData(indData, minutosAverias, minutosOEE, metrics, avg);
        // Devolver los datos procesados
        return indData;
    })
    .catch(error => {
        console.error("Error al cargar los datos:", error);
        throw error; // Propagar el error para que sea manejado en el nivel superior
    });
}


// Función auxiliar para calcular los minutos por ID o Línea
function calculateTotalMinutesById(filteredData, minutosAverias, idField, valueField) {
    filteredData.data.forEach(row => {
        const id = row[idField]; // Campo usado como clave (ej. "id" o "linea")
        const value = parseFloat(row[valueField]); // Campo usado para sumar (ej. "minutos" o "min")

        if (!id || isNaN(value)) {
            console.warn(`Fila ignorada: ${idField}="${id}", ${valueField}="${row[valueField]}"`);
            return; // Ignorar filas sin clave o sin valor válido
        }

        // Inicializar si no existe la clave
        if (!minutosAverias.minutos[id]) {
            minutosAverias.minutos[id] = 0;
            minutosAverias.countMin[id] = 0;
        }

        // Sumar los valores del campo especificado
        minutosAverias.minutos[id] += value;
        minutosAverias.countMin[id] += 1;  // Contar la cantidad de registros por ID
    });

    // Calcular el total global y aproximar a la centésima
    minutosAverias.minutos.PLANTA = calculateTotal(minutosAverias.minutos);
    minutosAverias.countMin.PLANTA = calculateTotal(minutosAverias.countMin);

    // Aproximar los valores individuales a la centésima
    for (const key in minutosAverias.minutos) {
        if (key !== 'PLANTA') {
            minutosAverias.minutos[key] = parseFloat(minutosAverias.minutos[key].toFixed(2));
        }
    }

    return minutosAverias;
}


// Función para calcular el total global y aproximar a la centésima
function calculateTotal(obj) {
    return parseFloat(
        Object.values(obj)
            .filter(value => typeof value === 'number')
            .reduce((sum, value) => sum + value, 0)
            .toFixed(2)
    );
}


// Función para calcular MTTR, MTBF y Disponibilidad
function calculateMetrics(minutosAverias, minutosOEE, metrics) {
    for (const id in minutosAverias.minutos) {
        if (minutosAverias.minutos.hasOwnProperty(id) && minutosAverias.countMin.hasOwnProperty(id)) {
            const totalMinutosDetencion = minutosAverias.minutos[id];
            const numeroAverias = minutosAverias.countMin[id];
            const totalMinutosProduccion = minutosOEE.minutos[id];

            // Calcular MTTR
            metrics.mttr[id] = numeroAverias > 0 ? parseFloat((totalMinutosDetencion / numeroAverias).toFixed(2)) : 0;

            // Calcular MTBF (convertido a horas)
            metrics.mtbf[id] = numeroAverias > 0 ? parseFloat((totalMinutosProduccion / numeroAverias / 60).toFixed(2)) : 0;

            // Calcular Disponibilidad (en porcentaje)
            const disponibilidad = totalMinutosProduccion + totalMinutosDetencion;
            metrics.disp[id] = disponibilidad > 0
                ? parseFloat((totalMinutosProduccion / disponibilidad).toFixed(4) ): 0;
        }
    }

    return metrics;
}


//calcula el OEE promedio simple de cada linea
function calculateOEEAverage(data) {
    const oeeTotals = { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 }; // Suma total de OEE por ID
    const counts = { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 }; // Cantidad de registros por ID
    let totalOEE = 0; // Suma total de OEE para todos los registros
    let totalCount = 0; // Contador total de registros

    // Recorrer los datos y acumular OEE por ID
    data.forEach(row => {
        const id = row.linea; // Suponiendo que cada fila tiene un campo `id` (L1, L2, etc.)
        const oeeValue = parseFloat(row.oee); // Convertir el valor de OEE a número

        if (id && !isNaN(oeeValue)) { // Verificar que el ID y el valor sean válidos
            oeeTotals[id] = (oeeTotals[id] || 0) + oeeValue; // Sumar el OEE al total por ID
            counts[id] = (counts[id] || 0) + 1; // Incrementar el contador por ID

            // Sumar el OEE total
            totalOEE += oeeValue;
            totalCount++;
        }
    });

    // Calcular los promedios por ID
    const oeeAverages = {};
    Object.keys(oeeTotals).forEach(id => {
        if (counts[id] > 0) {
            oeeAverages[id] = parseFloat (( oeeTotals[id] / counts[id]).toFixed(4)); // Promedio por ID
        } else {
            oeeAverages[id] = 0; // Si no hay datos, asignar 0
        }
    });

    // Calcular el promedio total de OEE
    const overallOEE = totalCount > 0 ? totalOEE / totalCount : 0;

    // Asignar el promedio total a PLANTA
    oeeAverages.PLANTA = parseFloat( (overallOEE).toFixed(4) );

    return oeeAverages; // Devolver ambos valores
}


// actualiza la tabla indicador semanal con los valores calculados
function updateIndData(indData, minutosAverias, minutosOEE, metrics, avg) {
    indData.data.forEach(row => {
        const id = row.total_general; // Suponiendo que cada fila tiene un campo 'total_general' que coincide con los IDs de minutosAverias y minutosOEE

        // Actualizar minutosAverias
        if (minutosAverias.minutos.hasOwnProperty(id)) {
            row.minutos = minutosAverias.minutos[id];
        }

        // Actualizar minutosAverias
        if (minutosAverias.countMin.hasOwnProperty(id)) {
            row.averias = minutosAverias.countMin[id];
        }

        // Actualizar minutosOEE
        if (minutosOEE.minutos.hasOwnProperty(id)) {
            row.hpr = minutosOEE.minutos[id];
        }  

        // Actualizar metrics
        if (metrics.mttr.hasOwnProperty(id)) {
            row.mttr = metrics.mttr[id];
        }

        if (metrics.mtbf.hasOwnProperty(id)) {
            row.mtbf = metrics.mtbf[id];
        }

        if (metrics.disp.hasOwnProperty(id)) {
            row.disp = (metrics.disp[id] * 100).toFixed(2) + "%";  // Convertir float a porcentaje (ej. 0.87 -> '87.00%')
        }

        if (avg.hasOwnProperty(id)) {
            row.oee = (avg[id] * 100).toFixed(2) + "%";  // Convertir float a porcentaje (ej. 0.87 -> '87.00%')
        }

    });

    return indData;
}


//descargas el archivo powerBI de google drive
function cargarPowerBI() {
    fetch('/cargar-powerbi', {
        method: 'POST',
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.blob(); // Recibe el archivo como un blob
    })
    .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.style.display = 'none';
        a.href = url;
        a.download = 'planilla.pbix'; // Nombre del archivo descargado
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
    })
    .catch(error => {
        console.error('Error al descargar el archivo:', error);
    });
}


//crea el json para guardarlo en ind_semanal_historico
function CreateJsonInd(jsonData, boolean) {
    const newColumns = ["id", "año", "semana", "disp", "meta", "mtbf", "mttr", "averias", "minutos", "oee", "parosmenores"];
    const ParosMenores = boolean
    const año = selectedFilters.año; // Obtener el año desde selectedFilters
    const semana = selectedFilters.semana; // Obtener la semana desde selectedFilters
    const resultado = {
        columns: newColumns,
        data: jsonData.data
            .filter(item => item.total_general !== "PLANTA") // Filtrar "PLANTA"
            .map(item => ({
                id: item.total_general, // Renombrar total_general a id
                año: año,
                semana: semana,
                disp: item.disp ? parseFloat(item.disp.replace('%', '')) / 100 : 0, // Convertir porcentaje a decimal
                mtbf: item.mtbf ? parseFloat(item.mtbf) : 0,
                mttr: item.mttr ? parseFloat(item.mttr) : 0,
                averias: item.averias ? parseInt(item.averias) : 0,
                minutos: item.minutos ? parseInt(item.minutos) : 0,
                parosmenores: ParosMenores,  
            })),
        table_name: "indicador_semanal_historico"
    };

    return resultado;
}


//funcion para mostrar los botones de descarga y cambiar pagina en la tab 'ver tablas'
function showDownloadButton() {
    document.getElementById("download-btn").style.display = "block";
    document.getElementById("pagination").style.display = "flex"; // Mostrar paginación
}


// para descargar tablas completas
function downloadTable() {
    let tableName = document.getElementById("table-select").value;

    fetch('/download', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ table_name: tableName })
    })

    .then(response => {
        if (!response.ok) {
            return response.json().then(err => { throw new Error(err.error || "Error desconocido"); });
        }
        return response.blob();
    })
    .then(blob => {
        let url = window.URL.createObjectURL(blob);
        let a = document.createElement("a");
        a.href = url;
        a.download = tableName + ".xlsx";
        document.body.appendChild(a);
        a.click();
        a.remove();
    })
    .catch(error => {
        console.error("Error:", error);
        alert("Error al descargar la tabla: " + error.message);
    });
}