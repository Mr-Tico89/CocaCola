// funcion para limpiar filtros, se usa cada vez que cambia de pestaña
function clearGlobalActiveFilters(filters) {
    Object.keys(filters).forEach(key => delete filters[key]);
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
async function createFilterSelect(column, tableName, containerId) {

    // Crear el contenedor para el filtro
    const { container, dropdownMenu } = createDropdownFilter(column, tableName, containerId);

    // Obtener valores únicos desde el backend
    const uniqueValues = await fetchUniqueValues(column, tableName);  

    // Agregar los checkboxes para los valores únicos obtenidos
    addCheckboxesToDropdown(uniqueValues, column, dropdownMenu, tableName, containerId);

    return { container, activeFilters: globalActiveFilters };
}


// Función auxiliar para agregar los checkboxes al menú desplegable, cada vez que se activa uno activa fetchFilteredData
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



// crea el menu desplegable
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


    // Manejo dinámico de los menús desplegables
    dropdownMenu.querySelectorAll('dropdown-menu').forEach(menu => {
        menu.addEventListener('mouseover', () => {
            const rect = menu.getBoundingClientRect();
            // Si el menú se desborda por el lado derecho, ajusta su posición
            if (rect.right > window.innerWidth) {
                menu.classList.add('adjust-left'); // Agrega clase para ajustarlo hacia la izquierda
            } else {
                menu.classList.remove('adjust-left'); // Quita la clase si ya no se desborda
            }
        });
    });

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