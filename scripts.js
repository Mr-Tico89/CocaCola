
window.onscroll = function() {scrollFunction()};
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


// Agregar eventos a los botones de pestañas
document.addEventListener('DOMContentLoaded', async () => {
    await loadTableOptions();

    // Agregar eventos a los botones de pestañas
    document.querySelectorAll('.tablinks').forEach(button => {
        button.addEventListener('click', (event) => {
            const tabId = event.target.getAttribute('onclick').match(/'(.*?)'/)[1]; // Extrae el ID de la pestaña
            switch (tabId) {
                case 'Tab2': //carga la tabla db_averias_consolidado al entrar en la pestaña 2
                    loadTableData('averias-container', 'Tab2', 'db_averias_consolidado');
                    break;
                case 'Tab4': //carga la tabla db_averias_consolidado al entrar en la pestaña 2
                    loadTableData('Indicador-container', 'Tab4', 'indicador_semanal');
                    break;
            }
        });
    });
});

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
async function loadTableData(containerId, tabName, tableName = null) {
    const table = tableName || document.getElementById('table-select').value;
    if (!table) return;

    const response = await fetch(`http://localhost:5000/tables/${table}`);
    const data = await response.json();

    renderEditableTable(data, containerId);

}

// Objeto global para almacenar filtros activos por columna
const globalActiveFilters  = {};

// Función para crear el selector de filtros
function createFilterSelect(column, data, columns, table) {
    // Contenedor principal
    const container = document.createElement('div');
    container.classList.add('filter-container');

    // Botón del menú desplegable
    const dropdownButton = document.createElement('button');
    dropdownButton.textContent = '▼';
    dropdownButton.classList.add('dropdown-button');

    // Contenedor de opciones
    const dropdownMenu = document.createElement('div');
    dropdownMenu.classList.add('dropdown-menu');

    // Inicializar filtros activos para esta columna si no existen
    globalActiveFilters[column] = globalActiveFilters[column] || new Set();

    // Mostrar u ocultar el menú desplegable
    dropdownButton.addEventListener('click', (event) => {
        event.stopPropagation();
        dropdownMenu.classList.toggle('show');
    });

    // Cerrar el menú desplegable al sacar el mouse
    let closeTimeout;
    dropdownMenu.addEventListener('mouseleave', () => {
        closeTimeout = setTimeout(() => {
            dropdownMenu.classList.remove('show');
        }, 75);
    });

    dropdownMenu.addEventListener('mouseenter', () => {
        clearTimeout(closeTimeout);
    });

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

    // Botón para borrar filtros de la columna actual
    const clearButton = document.createElement('button');
    clearButton.textContent = 'Borrar filtros';
    clearButton.classList.add('clear-filters-button');
    clearButton.addEventListener('click', (event) => {
        event.stopPropagation();

        // Desmarcar todas las opciones de la columna específica
        dropdownMenu.querySelectorAll('input:checked').forEach(checkbox => {
            checkbox.checked = false;
        });

        // Limpiar los filtros activos para esta columna CAMBIARLOO
        globalActiveFilters[column].clear();

        // Aplicar filtros globalmente
        applyFilters(columns, table);
    });

    // Añadir el botón de borrar filtros al menú desplegable
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
                console.log(columns)
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
        });

        td.appendChild(input);
    }
    else {
        // Si no es 'sintoma' ni 'observaciones', mostrar el valor normal
        td.textContent = cellValue; // Valor predeterminado
    }

    return td;
}

//funcion para renderizar la tabla
function renderEditableTable(response, containerId) {
    const container = document.getElementById(containerId);
    const { columns, data } = response;

    // Limpiar la tabla existente
    container.innerHTML = '';

    // Crear el elemento de tabla
    const table = document.createElement('table');
    table.classList.add('editable-table');

    // Crear encabezados de tabla con filtros
    const thead = table.createTHead();
    thead.classList.add('editable-table-header');
    const headerRow = thead.insertRow();

    // Agregar encabezado de columna para checkbox si corresponde
    const buttonHeader = document.createElement('th');
    buttonHeader.textContent = 'Quitar';
    if (containerId !== 'averias-container') { // ocultar la columna quitar para que filten bien los datos
        buttonHeader.classList.add('hidden-column');
    }
    headerRow.appendChild(buttonHeader);


    // Contenedor de filtros activos global
    const globalActiveFilters = {};

    columns.forEach(column => {
        const th = document.createElement('th');
        th.textContent = column.replace(/_/g, ' ').charAt(0).toUpperCase() + column.replace(/_/g, ' ').slice(1);

        // Crear filtro y asignar contenedor
        const { container: filterContainer, activeFilters } = createFilterSelect(column, data, columns, table);
        globalActiveFilters[column] = activeFilters[column] || new Set();

        th.appendChild(filterContainer);
        headerRow.appendChild(th);
    });

    // Crear cuerpo de la tabla
    const tbody = table.createTBody();
    tbody.classList.add('editable-table-body');
    data.forEach((row, rowIndex) => {
        const tr = tbody.insertRow();

        // Agregar columna de checkbox si corresponde
        const buttonCell = tr.insertCell();
        buttonCell.classList.add('action-cell');
        if (containerId !== 'averias-container') { // ocultar la columna quitar para que filten bien los datos 
            buttonCell.classList.add('hidden-column');
        }
        const button = document.createElement('button');
        
        button.classList.add('delete-button');
        button.textContent = 'X';

        // Agregar funcionalidad al botón
        button.addEventListener('click', () => {
            // Eliminar la fila correspondiente de la tabla
            tr.remove();
            // También puedes eliminar la fila de los datos
            data.splice(rowIndex, 1);
            saveData(data); // Guardar los datos actualizados
        });
        buttonCell.appendChild(button);
    
        
         // Crear las celdas básicas
         const cells = columns.map(() => {
            const td = tr.insertCell();
            return td;
        });

         // Actualizar celdas con contenido editable al final
        columns.forEach((column, columnIndex) => {
            const td = cells[columnIndex];
            if (containerId === 'averias-container') {
                const editableCell = createEditableCell(row, column, data, rowIndex);
                td.replaceWith(editableCell); // Reemplaza la celda básica con la editable
            } else {
                td.textContent = row[column] || ''; // Valor predeterminado
            }
        });
    });

    // Agregar tabla al contenedor
    container.appendChild(table);
}


function saveData(data) {
    fetch('http://localhost:5000/save', {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        console.log('Datos guardados:', result);
    })
    .catch(error => {
        console.error('Error al guardar los datos:', error);
    });
}

// Abrir la primera pestaña por defecto
document.querySelector('.tablinks').click();