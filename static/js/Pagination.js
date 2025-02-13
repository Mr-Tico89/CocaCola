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
        console.log(current_page)
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