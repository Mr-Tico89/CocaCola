
document.addEventListener('DOMContentLoaded', function () {
    // Llamar a loadTableOptions cuando la página se carga
    loadTableOptions();

    // Agregar eventos a los filtros
    document.querySelectorAll('.filter-select').forEach(select => {
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

            // Definir las acciones para cada pestaña
            switch (tabId) {
                case 'Tab2':
                    loadTableData('editable-container-tab2', 'Tab2', 'db_averias_consolidado', true)
                    break;

                case 'Tab3':
                    break;

                case 'Tab4':
                    loadTableData('Indicador-container', 'Tab4', 'INDICADOR_SEMANAL', true);
                    loadTableData('Indicador-container', 'Tab4', 'db_averias_consolidado', false)
                        .then(data => loadAndPopulateFilters(data))
                        .catch(error => console.error('Error al cargar los datos:', error));
                    break;

                case 'Tab6':
                    loadTableData('editable-container-tab6', 'Tab6', 'hpr_oee', true);
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
            const data = await applyFiltersAndCalculate();
    
            // Guardar los datos procesados
            await saveData(data);

            // Llamada a la función
            // Verificar si selectedFilters.año y selectedFilters.semana tienen longitud 1
            if (selectedFilters.año.length === 1 && selectedFilters.semana.length === 1 && selectedFilters.areas.length >= 2 ) {
                const result = splitJsonByTotalGeneral(data, selectedFilters.areas.includes("Paros Menores"));
                result.forEach(item => {
                    saveData(item); // Llama a saveData con cada valor de result
                });

                
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


function createDropdownFilter(column, tableName, containerId) {
    // Crear el contenedor principal del filtro
    const container = document.createElement('div');
    container.classList.add('filter-container');

    // Crear el botón desplegable
    const dropdownButton = document.createElement('button');
    dropdownButton.textContent = 'V';
    dropdownButton.classList.add('dropdown-button');

    // Crear el menú desplegable
    const dropdownMenu = document.createElement('div');
    dropdownMenu.classList.add('dropdown-menu');

    // Botón para borrar filtros
    const clearButton = document.createElement('button');
    clearButton.textContent = 'Borrar filtros';
    clearButton.classList.add('clear-filters-button');
    clearButton.addEventListener('click', (event) => {
        event.stopPropagation();
        
        dropdownMenu.querySelectorAll('input:checked').forEach(checkbox => {
            checkbox.checked = false;
        });
        
        if (globalActiveFilters[column]) {
            globalActiveFilters[column].clear();
        }
        fetchFilteredData(tableName, containerId);
    });

    dropdownMenu.appendChild(clearButton);

    // Manejar eventos para mostrar/ocultar el menú
    dropdownButton.addEventListener('click', (event) => {
        event.stopPropagation();
        dropdownMenu.classList.toggle('show');
    });

    let closeTimeout;
    dropdownMenu.addEventListener('mouseleave', () => {
        closeTimeout = setTimeout(() => dropdownMenu.classList.remove('show'), 100);
    });
    dropdownMenu.addEventListener('mouseenter', () => clearTimeout(closeTimeout));

    // Añadir el botón y el menú al contenedor
    container.appendChild(dropdownButton);
    container.appendChild(dropdownMenu);

    // Retornar un objeto con los elementos clave
    return { container, dropdownMenu };
}


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


// Función madre para crear filtros dinámicos
async function createFilterSelect(column, tableName, containerId) {
    // Crear el contenedor para el filtro
    const { container, dropdownMenu } = createDropdownFilter(column, tableName, containerId);

    // Obtener valores únicos desde el backend
    const uniqueValues = await fetchUniqueValues(column, tableName);  

    // Agregar los checkboxes para los valores únicos obtenidos
    addCheckboxesToDropdown(uniqueValues, column, dropdownMenu, tableName, containerId);

    return { container, activeFilters: globalActiveFilters };
}


// Función auxiliar para agregar los checkboxes al menú desplegable
function addCheckboxesToDropdown(uniqueValues, column, dropdownMenu, tableName, containerId) {
    uniqueValues.forEach(value => {
        const checkboxContainer = document.createElement('label');
        checkboxContainer.classList.add('dropdown-item');

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
            if (checkbox.checked) {
                globalActiveFilters[column].add(String(value));
            } else {
                globalActiveFilters[column].delete(String(value));
            }
            fetchFilteredData(tableName, containerId);
        });

        checkboxContainer.appendChild(checkbox);
        checkboxContainer.appendChild(label);
        dropdownMenu.appendChild(checkboxContainer);
    });
}




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
        renderEditableTable(filteredData, containerId)
        


    } catch (error) {
        console.error("Error obteniendo datos filtrados:", error);
    }
}


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
        prevButton.onclick = () => changePage(tableName, -1, containerId);
    }

    if (!nextButton.disabled) {
        nextButton.onclick = () => changePage(tableName, 1, containerId);
    }
}


let currentPage = 1;  // Página inicial
function changePage(tableName, direction, containerId) {
    currentPage += direction;  // Sumar o restar 1 a la página
    fetchTablePage(tableName, currentPage, containerId);
}


function fetchTablePage(tableName, page, containerId) {
    fetch(`/tables/${tableName}/filtered_data?page=${page}`)
        .then(response => response.json())
        .then(data => {
            renderEditableTable(data, containerId)
            
        })
        .catch(error => console.error("Error al obtener los datos:", error));
}






async function updateRow(rowData) {
    try {
        const response = await fetch('/update_row', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(rowData)
        });

        const result = await response.json();
        console.log(result.message || result.error);
    } catch (error) {
        console.error("Error actualizando la fila:", error);
    }
}




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




function renderEditableTable(response, containerId) {

    const {table_name, columns, data } = response;
    const container = document.getElementById(containerId);
    // Limpiar la tabla existente
    container.innerHTML = '';

    updatePagination(response, table_name, containerId);

    // Crear y configurar la tabla
    const table = createTableElement('editable-table');

    // Contenedor para los filtros activos globales
    const globalActiveFilters = {};


    // Crear encabezados con filtros
    const thead = createTableHeader(columns, containerId, globalActiveFilters, table_name);

    // Crear cuerpo de la tabla
    const tbody = createTableBody(columns, data, containerId, globalActiveFilters, table, table_name);

    

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


function createTableHeader(columns, containerId, globalActiveFilters, tableName) {
    const thead = document.createElement('thead');
    thead.classList.add('editable-table-header');
    const headerRow = thead.insertRow();

    const buttonHeader = createHeaderCell('Quitar');
    if (!containerId.includes('editable-container'))  { // ocultar la columna quitar para que filten bien los datos
        buttonHeader.classList.add('hidden-column');
    }
    headerRow.appendChild(buttonHeader);

    columns.forEach(column => {
        const th = createHeaderCell(
            column.replace(/_/g, ' ').charAt(0).toUpperCase() + column.replace(/_/g, ' ').slice(1)
        );

        // Crear filtro para cada columna
        createFilterSelect(column, tableName, containerId).then(({ container, activeFilters }) => {
            globalActiveFilters[column] = activeFilters; // Guardar referencia a filtros activos
            th.appendChild(container);  // Añadir el contenedor del filtro al encabezado de la columna
        });

        headerRow.appendChild(th);
    });

    return thead;
}


function createHeaderCell(textContent, additionalClass = '') {
    const th = document.createElement('th');
    th.textContent = textContent;
    if (additionalClass) {
        th.classList.add(additionalClass);
    }
    return th;
}


function createTableBody(columns, data, containerId, globalActiveFilters, table, table_name) {
    const tbody = document.createElement('tbody');
    tbody.classList.add('editable-table-body');

    data.forEach((row, rowIndex) => {
        const tr = tbody.insertRow();

        const buttonCell = createButtonCell(tr, tbody, data, columns, table_name);
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

let counter = 1;  // Contador para IDs únicos

function createEditableCell(row, column, data, rowIndex, table_name) {
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
            console.log(data[rowIndex])
            //updateTableJson(table_name, data)
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
            //updateTableJson(table_name, data)
        });

        td.appendChild(input);
    } 
    // Manejar celdas normales sin edición
    else {
        td.textContent = cellValue;
    }
    counter++;

    return td;
}


function createButtonCell(rowElement, tbody, data, columns, table_name) {
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





















function populateUniqueSelect(json, property, selectId) {
    const select = document.getElementById(selectId);

    // Verificar si el select existe
    if (!select) {
        console.error(`No se encontró el elemento con ID: ${selectId}`);
        return;
    }

    // Verificar que json.data exista y sea un array
    if (!json || !json.data || !Array.isArray(json.data)) {
        console.error("La estructura del JSON no es válida o no contiene 'data'. Verifica la entrada:", json);
        return;
    }

    // Verificar que la propiedad esté en los objetos de "data"
    if (!json.data[0].hasOwnProperty(property)) {
        console.error(`La propiedad '${property}' no existe en los objetos de 'data'.`);
        return;
    }

    // Extraer valores únicos de la propiedad
    const uniqueValues = [...new Set(json.data.map(item => item[property]))];
    
    // Limpiar las opciones previas antes de agregar nuevas
    select.innerHTML = '';

    // Agregar el atributo multiple si no existe
    select.setAttribute('multiple', 'true');

    // Agregar las nuevas opciones al select
    uniqueValues.forEach(value => {
        //if (value !== '') { // Verificar que el valor no sea ''
            const option = document.createElement('option');
            option.value = value;
            option.textContent = value;
            select.appendChild(option);
        //}
    });
}


// Función para actualizar los filtros seleccionados
function updateSelectedFilters(selectId, value) {
    if (value.length > 0) {
        selectedFilters[selectId] = value; // Actualiza el valor seleccionado
    } else {
        delete selectedFilters[selectId]; // Elimina el filtro si no hay selección
    }
}


async function loadAndPopulateFilters(data) {
    // Llenar los filtros con los datos obtenidos
    populateUniqueSelect(data, 'año', 'filter-año'); // Filtro Año
    populateUniqueSelect(data, 'mes', 'filter-mes'); // Filtro Mes
    populateUniqueSelect(data, 'semana', 'filter-semana'); // Filtro Semana
    populateUniqueSelect(data, 'areas', 'filter-areas'); // Filtro Semana
}


function applyFiltersAndCalculate() {
    return Promise.all([
        loadTableData('Indicador-container', 'Tab4', 'db_averias_consolidado', false),
        loadTableData('Indicador-container', 'Tab4', 'hpr_oee', false),
        loadTableData('Indicador-container', 'Tab4', 'indicador_semanal', false)
    ])
    .then(([averiasData, oeeData, indData]) => {
        if (!averiasData || !averiasData.data || !oeeData || !oeeData.data) {
            throw new Error("Los datos de las tablas no son válidos.");
        }

        // Filtrar los datos según los filtros seleccionados
        const filteredAverias = averiasData.data.filter(row => {
            return Object.entries(selectedFilters).every(([key, values]) => {
                const rowValue = String(row[key] || ""); // Asegurarse de que el valor sea una cadena
                return values.includes(rowValue);
            });
        });

        const filteredOEE = oeeData.data.filter(row => {
            return Object.entries(selectedFilters).every(([key, values]) => {
                // Ignorar el filtro de "area" para esta tabla
                if (key === 'areas') return true;
                const rowValue = String(row[key] || ""); // Asegurarse de que el valor sea una cadena
                return values.includes(rowValue);
            });
        });

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

        let metrics = { 
            mttr: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 },
            mtbf: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 },
            disp: { L1: 0, L2: 0, L3: 0, L4: 0, PLANTA: 0 }
        };
        // Calcular minutos para ambas tablas usando la función auxiliar con los campos específicos
        minutosAverias = calculateTotalMinutesById(filteredAverias, minutosAverias, 'id', 'minutos');
        minutosOEE = calculateTotalMinutesById(filteredOEE, minutosOEE, 'linea', 'min');
        metrics = calculateMetrics(minutosAverias, minutosOEE, metrics);
        const avg = calculateOEEAverage(filteredOEE)

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
    filteredData.forEach(row => {
        const id = row[idField]; // Campo usado como clave (ej. "id" o "linea")
        const value = parseFloat(row[valueField]); // Campo usado para sumar (ej. "minutos" o "min")

        if (!id || isNaN(value)) {
            console.warn(`Fila ignorada: ${idField}="${id}", ${valueField}="${row[valueField]}"`);
            return; // Ignorar filas sin clave o sin valor válido
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


function splitJsonByTotalGeneral(jsonData, boolean) {
    const newColumns = ["año", "semana", "hpr", "disp", "meta", "mtbf", "mttr", "averias", "minutos", "oee", "parosmenores"];
    const ParosMenores = boolean
    const año = selectedFilters.año[0]; // Obtener el año desde selectedFilters
    const semana = selectedFilters.semana[0]; // Obtener la semana desde selectedFilters
    
    return jsonData.data
    .filter(item => item.total_general !== "PLANTA") // Filtrar elementos que no son "PLANTA"
    .map(item => ({
        columns: newColumns,
        data: [
            {
                ...item,
                año: año,  // Usar solo el primer valor de año
                semana: semana,  // Usar solo el primer valor de semana
                parosmenores: ParosMenores,
                disp: parseFloat(item.disp.replace('%', '')) / 100 || 0,  // Eliminar '%' y convertir a float
                oee: parseFloat(item.oee.replace('%', '')) / 100 || 0    // Eliminar '%' y convertir a float
            }
        ],
        table_name: `indicador_semanal_historico_${item.total_general}`
    }));
}