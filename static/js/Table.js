

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


    // Contenedor para los filtros activos globales
    const globalActiveFilters = {};


    // Crear encabezados con filtros
    const thead = createTableHeader(columns, containerId, globalActiveFilters, table_name);


    // Crear cuerpo de la tabla
    const tbody = createTableBody(columns, data, containerId, table_name);

    if (containerId !== 'Indicador-container') {
        //archivo Pagination
        updatePagination(response, table_name, containerId);
    }

    // Ensamblar la tabla
    table.appendChild(thead);
    table.appendChild(tbody);
    container.appendChild(table);
}


//crear el encabezado de la tabla
function createTableHeader(columns, containerId, globalActiveFilters, tableName) {
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
            column.replace(/_/g, ' ').charAt(0).toUpperCase() + column.replace(/_/g, ' ').slice(1)
        );

        // Crear filtro para cada columna
        // archivo filters
        createFilterSelect(column, tableName, containerId).then(({ container, activeFilters }) => {
            globalActiveFilters[column] = activeFilters; // Guardar referencia a filtros activos
            th.appendChild(container);  // Añadir el contenedor del filtro al encabezado de la columna
        });

        headerRow.appendChild(th);
    });

    return thead;
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


function createTableElement(className) {
    const table = document.createElement('table');
    table.classList.add(className);
    return table;
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
