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
