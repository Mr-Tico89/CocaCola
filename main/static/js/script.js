// Proyecto CocaCola
// rev: 2.0
// Fecha: 10-02-2025
// Autor: Mr.Tico89
// Contacto: matinico71@gmail.com, @mati_rojasv (IG)
// Respositorio: https://github.com/Mr-Tico89/CocaCola.git

// Para el futuro practicante:  
    //  
    // Si estás leyendo esto, es probable que te hayan enviado a revisar el código.  
    // Seré honesto: este es mi primer proyecto de página web, así que seguro está lleno  
    // de bugs y vulnerabilidades.  
    //  
    // Tu misión es continuar con este legado. Si es posible, me encantaría saber cómo 
    // evoluciona mi "primer hijo" (le tengo cariño, jeje). No dudes en hacer preguntas 
    // si necesitas ayuda. Mucho éxito en tu camino.  
    //  
    // "El universo dijo que tú eres el universo probándose a sí mismo, hablándose a sí mismo, 
    //  leyendo su propio código." 
    //  -Minecraft  
    //  
    // Se despide el primer practicante Ing. civil en computacion de mantenimiento (hasta donde sé).  
//
//     ⠀⠀⠀⠀⢸⠓⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠀⠀⢸⠀⠀⠑⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠀⠀⢸⡆⠀⠀⠀⠙⢤⡷⣤⣦⣀⠤⠖⠚⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⣠⡿⠢⢄⡀⠀⡇⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠸⠷⣶⠂⠀⠀⠀⣀⣀⠀⠀⠀
//    ⢸⣃⠀⠀⠉⠳⣷⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⢉⡭⠋
//    ⠀⠘⣆⠀⠀⠀⠁⠀⢀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀
//    ⠀⠀⠘⣦⠆⠀⠀⢀⡎⢹⡀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⡀⣠⠔⠋⠀⠀⠀⠀
//    ⠀⠀⠀⡏⠀⠀⣆⠘⣄⠸⢧⠀⠀⠀⠀⢀⣠⠖⢻⠀⠀⠀⣿⢥⣄⣀⣀⣀⠀⠀
//    ⠀⠀⢸⠁⠀⠀⡏⢣⣌⠙⠚⠀⠀⠠⣖⡛⠀⣠⠏⠀⠀⠀⠇⠀⠀⠀⠀⢙⣣⠄
//    ⠀⠀⢸⡀⠀⠀⠳⡞⠈⢻⠶⠤⣄⣀⣈⣉⣉⣡⡔⠀⠀⢀⠀⠀⣀⡤⠖⠚⠀⠀
//    ⠀⠀⡼⣇⠀⠀⠀⠙⠦⣞⡀⠀⢀⡏⠀⢸⣣⠞⠀⠀⠀⡼⠚⠋⠁⠀⠀⠀⠀⠀
//    ⠀⢰⡇⠙⠀⠀⠀⠀⠀⠀⠉⠙⠚⠒⠚⠉⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⢧⡀⠀⢠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠙⣶⣶⣿⠢⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠀⠀⠉⠀⠀⠀⠙⢿⣳⠞⠳⡄⠀⠀⠀⢀⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠹⣄⣀⡤⠋⠀


document.addEventListener('DOMContentLoaded', function () {
    // Llamar a loadTableOptions cuando la página se carga
    loadTableOptions();

    // Agregar eventos a los filtros
    document.querySelectorAll('.filter-select').forEach(select => {
        select.addEventListener('change', (event) => {
            const selectId = event.target.id.replace('filter-', ''); // ID del select
            const value = Array.from(event.target.selectedOptions).map(option => option.value); // Valores seleccionados
            console.log (value)
            updateSelectedFilters(selectId, value);
        });
    });


    // Agregar eventos a los botones de pestañas
    document.querySelectorAll('.tablinks').forEach(button => {
        button.addEventListener('click', (event) => {
            const tabId = event.target.getAttribute('onclick').match(/'(.*?)'/)[1]; // Extrae el ID de la pestaña
            clearGlobalActiveFilters(globalActiveFilters)
            clearGlobalActiveFilters(selectedFilters)
            // Definir las acciones para cada pestaña
            switch (tabId) {
                case 'Tab2':
                    loadTableData('editable-container-tab2', 'Tab2', 'db_averias_consolidado', true)
                    break;

                case 'Tab3':
                    loadTableData('editable-container-tab3', 'Tab3', 'hpr_oee', true);
                    break;

                case 'Tab4':
                    loadTableData('Indicador-container', 'Tab4', 'INDICADOR_SEMANAL', true);
                    loadAndPopulateFilters()
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
                const result = CreateJsonInd(data, selectedFilters.areas.includes("Paros Menores"));
                await saveData(result);
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


//funcion para mostrar los botones de descarga y cambiar pagina 
// en la tab 'ver tablas' cuando se selecciona una 
function showDownloadButton() {
    document.getElementById("download-btn").style.display = "block";
    document.getElementById("pagination").style.display = "flex"; // Mostrar paginación
}


//crea el json para guardarlo en ind_semanal_historico
function CreateJsonInd(jsonData, boolean) {
    const newColumns = ["id", "año", "semana", "disp", "meta", "mtbf", "mttr", "averias", "minutos", "oee", "parosmenores"];
    const ParosMenores = boolean
    const año = selectedFilters.año[0]; // Obtener el año desde selectedFilters
    const semana = selectedFilters.semana[0]; // Obtener la semana desde selectedFilters
    const resultado = {
        columns: newColumns,
        data: jsonData.data
            .filter(item => item.total_general !== "PLANTA") // Filtrar "PLANTA"
            .map(item => ({
                id: item.total_general, // Renombrar total_general a id
                año: año,
                semana: semana,
                disp: parseFloat(item.disp.replace('%', '')) / 100 || 0, // Convertir porcentaje a decimal
                mtbf: parseFloat(item.mtbf) || 0,
                mttr: parseFloat(item.mttr) || 0,
                averias: parseInt(item.averias) || 0,
                minutos: parseInt(item.minutos) || 0,
                oee: parseFloat(item.oee.replace('%', '')) / 100 || 0,
                parosmenores: ParosMenores,  
            })),
        table_name: "indicador_semanal_historico"
    };
    return resultado
}


// para descargar tablas completas, la funcion activa por el boton
function downloadTable() {
    let tableName = document.getElementById("table-select").value;

    fetch('/download', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ table_name: tableName })
    })

    .then(response => {
        if (!response.ok) {
            return response.json().then(err => { throw new Error(err.error || "Error desconocido"); });
        }
        return response.blob();
    })
    .then(blob => {
        let url = window.URL.createObjectURL(blob);
        let a = document.createElement("a");
        a.href = url;
        a.download = tableName + ".xlsx";
        document.body.appendChild(a);
        a.click();
        a.remove();
    })
    .catch(error => {
        console.error("Error:", error);
        alert("Error al descargar la tabla: " + error.message);
    });
}