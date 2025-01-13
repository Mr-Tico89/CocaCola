
window.onscroll = function() {scrollFunction()};

document.addEventListener('DOMContentLoaded', async () => {
    await loadTableOptions();
    document.getElementById('table-select').addEventListener('change', loadTableData);
    loadTableData('averias-container', 'Tab2', 'db_averias_consolidado');
    loadTableData('Indicador-container', 'Tab4', 'indicador_semanal');
});

// Mostrar el botón cuando el usuario se desplaza hacia abajo 20px desde la parte superior del documento
function scrollFunction() {
    const scrollToTopBtn = document.getElementById("scrollToTopBtn");
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
        scrollToTopBtn.style.display = "block";
    } else {
        scrollToTopBtn.style.display = "none";
    }
}

// Cuando el usuario hace clic en el botón, desplácese hacia arriba hasta la parte superior del documento
function scrollToTop() {
    document.body.scrollTop = 0; // Para Safari
    document.documentElement.scrollTop = 0; // Para Chrome, Firefox, IE y Opera
}


async function loadTableOptions() {
    try {
        const response = await fetch('http://localhost:5000/tables');
        const tables = await response.json();
        const tableSelect = document.getElementById('table-select');
        tables.forEach(table => {
            const option = document.createElement('option');
            option.value = table;
            option.textContent = table;
            tableSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error fetching tables:', error);
    }
}

async function loadTableData(containerId, tabName, tableName = null) {
    const table = tableName || document.getElementById('table-select').value;
    if (!table) return;

    const response = await fetch(`http://localhost:5000/tables/${table}`);
    const data = await response.json();

    renderEditableTable(data, containerId);

}

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

    // Opciones únicas
    const uniqueValues = [...new Set(data.map(row => row[column]))];
    console.log(uniqueValues)
    uniqueValues.forEach(value => {
        const checkboxContainer = document.createElement('label');
        checkboxContainer.classList.add('dropdown-item');

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.value = value;

        const label = document.createElement('span');
        label.textContent = value;

        checkboxContainer.appendChild(checkbox);
        checkboxContainer.appendChild(label);
        dropdownMenu.appendChild(checkboxContainer);
    });


    // Mostrar u ocultar el menú desplegable
    dropdownButton.addEventListener('click', () => {
        dropdownMenu.classList.toggle('show');
    });

    // Filtrar la tabla al seleccionar opciones
    dropdownMenu.addEventListener('change', () => {
        const selectedOptions = Array.from(dropdownMenu.querySelectorAll('input:checked')).map(
            checkbox => checkbox.value
        );

        // Filtrar filas de la tabla
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach(row => {
            const cell = row.querySelector(`td:nth-child(${columns.indexOf(column) + 1})`);
            if (
                selectedOptions.length === 0 ||
                selectedOptions.includes(cell.textContent)
            ) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });

    // Agregar elementos al contenedor
    container.appendChild(dropdownButton);
    container.appendChild(dropdownMenu);

    return container;
}


function createEditableCell(row, column, data, rowIndex) {
    const td = document.createElement('td');
    const cellValue = row[column] || ''; // Handle missing values
    if (!td) {
        console.error('td is not defined or is not a valid element');
        return;
    }
    if (column === 'observaciones') {
        const input = document.createElement('input');
        input.type = 'text';
        input.placeholder = 'Edit here';
        input.value = input.value.toUpperCase();
        input.addEventListener('input', () => {
            input.value = input.value.toUpperCase();
        });
        input.addEventListener('blur', () => {
            data[rowIndex][column] = input.value;
        });
        td.appendChild(input);
    } 
    else if (column === 'areas' && cellValue !== 'Paros Menores') {
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
        });
        td.appendChild(select);
    } 
    else {
        td.textContent = cellValue;
    }

    return td;
}

function renderEditableTable(response, containerId) {
    const container = document.getElementById(containerId);
    const { columns, data } = response;

    // Clear existing table
    container.innerHTML = '';

    // Create table element
    const table = document.createElement('table');
    table.classList.add('editable-table');

    // Create table headers with filter selects
    const thead = table.createTHead();
    thead.classList.add('editable-table-header');
    const headerRow = thead.insertRow();
    columns.forEach(column => {
        const th = document.createElement('th');
        th.textContent = column.charAt(0).toUpperCase() + column.slice(1);

        //filtro
        const filterSelect = createFilterSelect(column, data, columns, table);
        th.appendChild(filterSelect);
        headerRow.appendChild(th);
    });

    // Create table body
    const tbody = table.createTBody();
    tbody.classList.add('editable-table-body');
    data.forEach((row, rowIndex) => {
        const tr = tbody.insertRow();
        columns.forEach(column => {
            const td = containerId === 'averias-container'
                ? createEditableCell(row, column, data, rowIndex)
                : document.createElement('td');
            if (td.textContent === '' && containerId !== 'averias-container' ) td.textContent = row[column] || ''; // Static text fallback
            tr.appendChild(td);
        });
    });

    // Append thead and tbody to the table
    table.appendChild(thead);
    table.appendChild(tbody);

    // Append table to container
    container.appendChild(table);
}


async function sendDataToDB() {
    const container = document.getElementById('averias-container');
    const inputs = container.querySelectorAll('.editable');
    const updates = [];

    inputs.forEach(input => {
        const row = input.closest('tr');
        const id = row.querySelector('td:first-child').textContent; // Supongamos que el ID está en la primera columna
        const column = input.dataset.column;
        const value = input.value;

        updates.push({ id, column, value });
    });

    try {
        const response = await fetch('http://localhost:5000/update_averias', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ updates }),
        });

        if (response.ok) {
            alert('Datos guardados exitosamente');
            loadAveriasTable(); // Recargar la tabla después de guardar
        } else {
            alert('Error al guardar los datos');
        }
    } catch (error) {
        console.error('Error enviando datos:', error);
    }
}

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



// Abrir la primera pestaña por defecto
document.querySelector('.tablinks').click();