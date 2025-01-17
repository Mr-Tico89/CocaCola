
//para el boton de subir
window.onscroll = function() {scrollFunction()};


// Abrir la primera pestaña por defecto
document.querySelector('.tablinks').click();


// Maneja el envío del formulario
document.getElementById('upload-form').addEventListener('submit', function(event) {
    event.preventDefault();  // Previene el comportamiento por defecto del formulario
    var formData = new FormData(this);

    // Enviar el formulario a la ruta '/upload' usando fetch
    fetch('http://127.0.0.1:5000/uploads', {  // Enviar datos al backend
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        document.getElementById('upload-status').innerText = data.message;
    })
    .catch(error => {
        console.error('Error al subir el archivo:', error);
    });
});


document.addEventListener('DOMContentLoaded', function() {
    // Llamamos a loadTableOptions cuando la página se carga
    loadTableOptions();
});


// Agregar eventos a los botones de pestañas
document.addEventListener('DOMContentLoaded', async () => {
    document.querySelectorAll('.tablinks').forEach(button => {
        button.addEventListener('click', (event) => {
            const tabId = event.target.getAttribute('onclick').match(/'(.*?)'/)[1]; // Extrae el ID de la pestaña
            switch (tabId) {
                case 'Tab2': //carga la tabla db_averias_consolidado al entrar en la pestaña 2
                    loadTableData('editable-container', 'Tab2', 'db_averias_consolidado');
                    break;
                case 'Tab4': //carga la tabla indicador_semanal al entrar en la pestaña 4
                    loadTableData('Indicador-container', 'Tab4', 'indicador_semanal');
                    break;
                case 'Tab6': //carga la tabla HPR_OEE al entrar en la pestaña 6
                    loadTableData('OEE-container', 'Tab6', 'hpr_oee');
                    break;

            }
        });
    });
});


// Objeto global para almacenar filtros activos por columna
const globalActiveFilters  = {};


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
async function loadTableData(containerId, tabName,  tableName = null) {
    const table = tableName || document.getElementById('table-select').value;
    if (!table) return;

    const response = await fetch(`http://localhost:5000/tables/${table}`);
    const data = await response.json();

    renderEditableTable(data, containerId);

}


// Crear el contenedor principal del filtro
function createFilterContainer() {
    const container = document.createElement('div');
    container.classList.add('filter-container');
    return container;
}


// Crear un botón desplegable
function createDropdownButton() {
    const dropdownButton = document.createElement('button');
    dropdownButton.textContent = '▼';
    dropdownButton.classList.add('dropdown-button');
    return dropdownButton;
}


// Crear el menú desplegable
function createDropdownMenu() {
    const dropdownMenu = document.createElement('div');
    dropdownMenu.classList.add('dropdown-menu');
    return dropdownMenu;
}


// Manejar eventos para mostrar/ocultar el menú
function setupDropdownEvents(dropdownButton, dropdownMenu) {
    dropdownButton.addEventListener('click', (event) => {
        event.stopPropagation();
        dropdownMenu.classList.toggle('show');
    });

    let closeTimeout;
    dropdownMenu.addEventListener('mouseleave', () => {
        closeTimeout = setTimeout(() => dropdownMenu.classList.remove('show'), 75);
    });

    dropdownMenu.addEventListener('mouseenter', () => clearTimeout(closeTimeout));
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
    const container = createFilterContainer();
    const dropdownButton = createDropdownButton();
    const dropdownMenu = createDropdownMenu();

    // Inicializar filtros activos para esta columna si no existen
    globalActiveFilters[column] = globalActiveFilters[column] || new Set();

    // Configurar eventos del menú desplegable
    setupDropdownEvents(dropdownButton, dropdownMenu);

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
                globalActiveFilters[column].add(value);
            } else {
                globalActiveFilters[column].delete(value);
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
                const cell = row.querySelector(`td:nth-child(${columns.indexOf(column) + 1})`);
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


//funcion de las celdas editables
function createEditableCell(row, column, data, rowIndex) {
    const td = document.createElement('td');
    const cellValue = row[column] || ''; // Handle missing values
    
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
        select.addEventListener('change', (e) => {
            data[rowIndex][column] = e.target.value;
            saveData(data);
        });
        td.appendChild(select);
    } 

    // Solo permitir edición en las columnas 'sintoma' y 'observaciones'
    else if (column === 'sintoma' || column === 'observaciones') {
        // Crear un input editable
        const input = document.createElement('input');
        input.type = 'text';
        input.placeholder = 'Editar'
        input.value = cellValue; // Valor inicial

        // Forzar mayúsculas solo en la columna 'observaciones'
        if (column === 'observaciones') {
            input.addEventListener('input', () => {
                input.value = input.value.toUpperCase();
            });
        }

        // Guardar cambios al perder el foco
        input.addEventListener('blur', () => {
            data[rowIndex][column] = input.value;
            saveData(data)
        });

        td.appendChild(input);
    }
    else {

        td.textContent = cellValue; // Valor predeterminado
    }

    return td;
}


function renderEditableTable(response, containerId) {
    const { columns, data } = response;
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
    const tbody = createTableBody(columns, data, containerId, globalActiveFilters, table);

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
    if (containerId !== 'editable-container') { // ocultar la columna quitar para que filten bien los datos
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


function createTableBody(columns, data, containerId, globalActiveFilters, table) {
    const tbody = document.createElement('tbody');
    tbody.classList.add('editable-table-body');

    data.forEach((row, rowIndex) => {
        const tr = tbody.insertRow();

        const buttonCell = createButtonCell(tr, tbody, data);
        if (containerId !== 'editable-container') { // ocultar la columna quitar para que filten bien los datos
            buttonCell.classList.add('hidden-column');
        }
        tr.appendChild(buttonCell);
        

        columns.forEach(column => {
            const td = containerId === 'editable-container'
                ? createEditableCell(row, column, data, rowIndex)
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


function createButtonCell(rowElement, tbody, data) {
    const buttonCell = document.createElement('td');
    buttonCell.classList.add('action-cell');

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

                // Guardar los datos actualizados
                saveData(data);
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
    td.textContent = content || '';
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


function saveData(data) {
    column_names = ["id", "mes", "semana", "fecha", "año", "turno", "maquina", "sintoma", "areas", "minutos", "observaciones"]
    datas = {
        "columns": column_names,
        "data": data
    }
    fetch('http://localhost:5000/save', {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        
        body: JSON.stringify(datas)
    })
    .then(response => response.json())
    .then(result => {
        console.log('Datos guardados:', result);
    })
    .catch(error => {
        console.error('Error al guardar los datos:', error);
    });
}


