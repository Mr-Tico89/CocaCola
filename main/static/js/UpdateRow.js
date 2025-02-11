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