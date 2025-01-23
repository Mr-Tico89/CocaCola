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
                    resetTab3();
                    break;

                case 'Tab4':
                    loadTableData('Indicador-container', 'Tab4', 'indicador_semanal', true);
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
        fetch('http://127.0.0.1:5000/uploads', {
            method: 'POST',
            body: formData
        })
            .then(response => response.json())
            .then(data => document.getElementById('upload-status').innerText = data.message)
            .catch(error => console.error('Error al subir el archivo:', error));
    });

    // Abrir la primera pestaña por defecto
    document.querySelector('.tablinks').click();
});


// Para el scroll (si es necesario)
window.onscroll = function () {
    scrollFunction();
};



// Objeto global para almacenar filtros activos por columna
const globalActiveFilters  = {};


// Objeto para almacenar los filtros seleccionados
const selectedFilters = {};


// funcion para reiniciar la pestaña Tab3
function resetTab3() {
    const fileInput = document.getElementById('file-input');
    fileInput.value = ''; // Restablecer el contenido de la pestaña
    // Puedes agregar más lógica aquí para recargar datos o restablecer el estado
    
}


// Mostrar el botón cuando el usuario se desplaza hacia abajo 20px desde la parte superior del documento
function scrollFunction() {
    const scrollToTopBtn = document.getElementById("scrollToTopBtn");
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
        scrollToTopBtn.style.display = "block";
    } 
    else {
        scrollToTopBtn.style.display = "none";
    }
}


// Cuando el usuario hace clic en el botón, desplácese hacia arriba hasta la parte superior del documento
function scrollToTop() {
    document.body.scrollTop = 0; // Para Safari
    document.documentElement.scrollTop = 0; // Para Chrome, Firefox, IE y Opera
}


//funcion para las pestañas de la pagina
function openTab(evt, tabName) {
    // Ocultar todas las pestañas
    const tabcontent = document.getElementsByClassName('tabcontent');
    for (let i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = 'none';
    }

    // Eliminar la clase "active" de todos los botones
    const tablinks = document.getElementsByClassName('tablinks');
    for (let i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(' active', '');
    }

    // Mostrar la pestaña actual y marcar el botón como activo
    document.getElementById(tabName).style.display = 'block';
    evt.currentTarget.className += ' active';
}


//funcion para cargar los nombres de las tablas en las opciones tab1
async function loadTableOptions() {
    try {
        const response = await fetch('http://localhost:5000/tables');
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
        const response = await fetch(`http://localhost:5000/tables/${table}`);
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






//funcion para crear el menu del filtro y el boton
function createDropdownFilter() {
    // Crear el contenedor principal del filtro
    const container = document.createElement('div');
    container.classList.add('filter-container');

    // Crear el botón desplegable
    const dropdownButton = document.createElement('button');
    dropdownButton.textContent = '▼';
    dropdownButton.classList.add('dropdown-button');

    // Crear el menú desplegable
    const dropdownMenu = document.createElement('div');
    dropdownMenu.classList.add('dropdown-menu');

    // Manejar eventos para mostrar/ocultar el menú
    dropdownButton.addEventListener('click', (event) => {
        event.stopPropagation();
        dropdownMenu.classList.toggle('show');
    });

    let closeTimeout;
    dropdownMenu.addEventListener('mouseleave', () => {
        closeTimeout = setTimeout(() => dropdownMenu.classList.remove('show'), 75);
    });
    dropdownMenu.addEventListener('mouseenter', () => clearTimeout(closeTimeout));

    // Añadir el botón y el menú al contenedor
    container.appendChild(dropdownButton);
    container.appendChild(dropdownMenu);

    // Retornar un objeto con los elementos clave
    return { container, dropdownButton, dropdownMenu };
}


// Crear el botón para borrar filtros
function createClearButton(column, dropdownMenu, columns, table) {
    const clearButton = document.createElement('button');
    clearButton.textContent = 'Borrar filtros';
    clearButton.classList.add('clear-filters-button');

    clearButton.addEventListener('click', (event) => {
        event.stopPropagation();

        // Desmarcar todas las opciones
        dropdownMenu.querySelectorAll('input:checked').forEach(checkbox => {
            checkbox.checked = false;
        });

        // Limpiar los filtros activos
        globalActiveFilters[column].clear();

        // Aplicar filtros globalmente
        applyFilters(columns, table);
    });

    return clearButton;
}


// Función para crear el selector de filtros
function createFilterSelect(column, data, columns, table) {
    const {container, dropdownButton, dropdownMenu} = createDropdownFilter();

    // Inicializar filtros activos para esta columna si no existen
    globalActiveFilters[column] = globalActiveFilters[column] || new Set();
    // Opciones únicas
    const uniqueValues = [...new Set(data.map(row => row[column]))];
    uniqueValues.forEach(value => {
        const checkboxContainer = document.createElement('label');
        checkboxContainer.classList.add('dropdown-item');

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.value = value;

        const label = document.createElement('span');
        label.textContent = value;
        
        checkbox.addEventListener('change', () => {
            if (checkbox.checked) {
                globalActiveFilters[column].add(String(value));
            } else {
                globalActiveFilters[column].delete(String(value));
            }

            // Aplicar filtros a la tabla
            applyFilters(columns, table);
        });

        checkboxContainer.appendChild(checkbox);
        checkboxContainer.appendChild(label);
        dropdownMenu.appendChild(checkboxContainer);
    });

    // Añadir botón para borrar filtros
    const clearButton = createClearButton(column, dropdownMenu, columns, table);
    dropdownMenu.insertBefore(clearButton, dropdownMenu.firstChild);
 
    // Añadir el botón y el menú desplegable al contenedor principal
    container.appendChild(dropdownButton);
    container.appendChild(dropdownMenu);

    return { container, activeFilters: globalActiveFilters };
}


//funcion de los filtros de las tablas
function applyFilters(columns, table) {
    const rows = table.querySelectorAll('tbody tr');
    rows.forEach(row => {
        let shouldDisplay = true;
        columns.forEach(column => {
            if (globalActiveFilters[column] && globalActiveFilters[column].size > 0) {
                const cell = row.querySelector(`td:nth-child(${columns.indexOf(column) + 2})`);
                let cellValue = '';
                
                // Verificar si la celda contiene un input (para valores editables)
                const input = cell.querySelector('input');
                if (input) {
                    cellValue = input.value; // Usar el valor del input
                } else {
                    cellValue = cell.textContent; // Si no es un input, usar el texto de la celda
                }

                if (!globalActiveFilters[column].has(cellValue)) {
                    shouldDisplay = false;
                }
            }
        });
        row.style.display = shouldDisplay ? '' : 'none';
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






function renderEditableTable(response, containerId) {
    const {table_name, columns, data } = response;
    const container = document.getElementById(containerId);

    // Limpiar la tabla existente
    container.innerHTML = '';

    // Crear y configurar la tabla
    const table = createTableElement('editable-table');

    // Contenedor para los filtros activos globales
    const globalActiveFilters = {};

    // Crear encabezados con filtros
    const thead = createTableHeader(columns, containerId, data, table, globalActiveFilters);

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


function createTableHeader(columns, containerId, data, table, globalActiveFilters) {
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
        const { container: filterContainer, activeFilters } = createFilterSelect(column, data, columns, table);
        globalActiveFilters[column] = activeFilters; // Guardar referencia a filtros activos

        th.appendChild(filterContainer);
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

    // Actualizar tabla al aplicar filtros
    table.addEventListener('filters-updated', () => {
        updateTableRows(tbody, data, globalActiveFilters, columns);
    });

    return tbody;
}


function createEditableCell(row, column, data, rowIndex, table_name) {
    const td = document.createElement('td');
    const cellValue = row[column] !== null && row[column] !== undefined ? row[column] : '';
    

    // Manejar la columna 'areas' con un <select>
    if (column === 'areas' && cellValue !== 'Paros Menores') {
        const select = document.createElement('select');
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
            updateTableJson(table_name, data)
        });

        td.appendChild(select);
    } 
    // Manejar columnas 'sintoma', 'observaciones', o 'OEE' con <input>
    else if (['sintoma', 'observaciones', 'oee'].includes(column)) {
        const input = document.createElement('input');
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
            updateTableJson(table_name, data)
        });

        td.appendChild(input);
    } 
    // Manejar celdas normales sin edición
    else {
        td.textContent = cellValue;
    }

    return td;
}


function createButtonCell(rowElement, tbody, data, table_name) {
    const buttonCell = document.createElement('td');

    const button = document.createElement('button');
    button.classList.add('delete-button');
    button.textContent = 'x';

    button.addEventListener('click', () => {
        if (confirm('¿Seguro que quieres eliminar esta fila?')) {
            // Obtener las filas actuales en el tbody
            const rows = Array.from(tbody.rows);

            // Encontrar el índice dinámico de la fila en el array de datos
            const rowIndex = rows.indexOf(rowElement);

            if (rowIndex !== -1) {
                // Eliminar del array de datos
                data.splice(rowIndex, 1);

                // Eliminar la fila del DOM
                rowElement.remove();
                updateTableJson(table_name, data)
            } else {
                console.error('No se encontró la fila en el DOM para eliminar.');
            }
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


function updateTableRows(tbody, data, globalActiveFilters, columns) {
    // Filtrar datos según los filtros activos
    const filteredData = data.filter(row => {
        return columns.every(column => {
            const activeFilters = globalActiveFilters[column];
            return !activeFilters || activeFilters.size === 0 || activeFilters.has(row[column]);
        });
    });

    // Limpiar cuerpo de la tabla
    tbody.innerHTML = '';

    // Rellenar con datos filtrados
    filteredData.forEach(row => {
        const tr = tbody.insertRow();
        columns.forEach(column => {
            const td = createTextCell(row[column]);
            tr.appendChild(td);
        });
    });
}


// Función para actualizar el JSON de la tabla
async function updateTableJson(table_name, data) {
    // Obtener el formato de JSON usando loadTableData
    const originalData = await loadTableData('editable-container-tab2', 'Tab2', table_name, false);
    if (!originalData) {
        console.error('Error al obtener el formato de JSON');
        return;
    }
    
     // Reemplazar originalData.data con data
    originalData.data = data;
    saveData(originalData)
 
}


async function saveData(data) {
    try {
        const response = await fetch('http://localhost:5000/save', {
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
            metrics.disp[id] = disponibilidad > 0 ? parseFloat(((totalMinutosProduccion / disponibilidad) * 100).toFixed(2)) : 0;
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
            oeeAverages[id] = ( (oeeTotals[id] / counts[id]) * 100 ).toFixed(2) + '%'; // Promedio por ID
        } else {
            oeeAverages[id] = 0; // Si no hay datos, asignar 0
        }
    });

    // Calcular el promedio total de OEE
    const overallOEE = totalCount > 0 ? totalOEE / totalCount : 0;

    // Asignar el promedio total a PLANTA
    oeeAverages.PLANTA = (overallOEE * 100).toFixed(2) + '%';

    return oeeAverages; // Devolver ambos valores
}


// Función para actualizar indData
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
            row.disp = metrics.disp[id];
        }

        if (avg.hasOwnProperty(id)) {
            row.oee = avg[id];
        }

    });

    return indData;
}






function cargarPowerBI() {
    fetch('/cargar-powerbi', { method: 'POST' })
        .then(response => response.json())
        .then(data => alert(data.mensaje))
        .catch(err => console.error('Error:', err));
}


