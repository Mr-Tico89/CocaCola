
// para llenar los filtros de ind semanal 
function populateUniqueSelect(selectId) {
    const select = document.getElementById(selectId);
    // Verificar si el select existe
    if (!select) {
        console.error(`No se encontró el elemento con ID: ${selectId}`);
        return;
    }

    let cleanedselectId = selectId.slice(7); //elimina filter- de selectId en el html

    // Extraer valores únicos de la tabla para este caso sirve que solo se fije en db_averias_consolidado
    
    //archivo filters.js
    fetchUniqueValues(cleanedselectId, "db_averias_consolidado")
    .then((uniqueValues) => {
        // Limpiar las opciones previas antes de agregar nuevas
        select.innerHTML = '';

        // Agregar el atributo multiple si no existe
        select.setAttribute('multiple', 'true');

        // Agregar las nuevas opciones al select
        uniqueValues.forEach(value => {
            const option = document.createElement('option');
            option.value = value;
            option.textContent = value;
            select.appendChild(option);
        });

        select.addEventListener('change', () => {
            // Obtener los valores seleccionados
            //const selectedValues = Array.from(select.selectedOptions).map(option => option.value);
            //console.log(selectedValues);  // Muestra el array con los valores seleccionados

            // funcion para aplicar filtro y cambiar valores unicos de las otros selects WIP
            //FilteredDataIndSem(tableName, containerId);
        });
      })

      .catch((error) => {
        // Manejar errores en caso de que algo falle
        console.error("Error al obtener los valores únicos:", error);
    });
}


// Función para actualizar los filtros seleccionados en indicador semanal
function updateSelectedFilters(selectId, value) {
    if (value.length > 0) {
        selectedFilters[selectId] = value; // Actualiza el valor seleccionado
    } else {
        delete selectedFilters[selectId]; // Elimina el filtro si no hay selección
    }
}


//func main para rellenar los 4 fitros 
async function loadAndPopulateFilters() {
    // Llenar los filtros con los datos obtenidos
    populateUniqueSelect('filter-año'); // Filtro Año
    populateUniqueSelect('filter-mes'); // Filtro Mes
    populateUniqueSelect('filter-semana'); // Filtro Semana
    populateUniqueSelect('filter-areas'); // Filtro Semana
}


//funcion para cargar todos los datos del backtend al front, no usar para renderizar la tabla (LAG!!)
async function loadFullTableData(tableName = null) {
    const table = tableName || document.getElementById('table-select').value;
    if (!table) return;

    try {
        const response = await fetch(`/tables/${table}/data`);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error(`Error fetching data for table ${table}:`, error);
    }
}


//funcion para rellenar la tabla ind semanal realizando todos los calculos y recopilacion de datos en la tabla
function applyFiltersAndCalculate() {
    return Promise.all([
        loadFullTableData('db_averias_consolidado'),
        loadFullTableData('hpr_oee'),
        loadFullTableData('indicador_semanal')
    ])
    .then(([averiasData, oeeData, indData]) => {
        if (!averiasData || !averiasData.data || !oeeData || !oeeData.data) {
            throw new Error("Los datos de las tablas no son válidos.");
        }

        // Filtrar los datos según los filtros seleccionados db_averias_consolidado
        const filteredAverias = averiasData.data.filter(row => {
            return Object.entries(selectedFilters).every(([key, values]) => {
                const rowValue = String(row[key] || ""); // Asegurarse de que el valor sea una cadena
                return values.includes(rowValue);
            });
        });

        // Filtrar los datos según los filtros seleccionados OEE
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

        //aqui van los calculos de los datos
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
            metrics.disp[id] = disponibilidad > 0
                ? parseFloat((totalMinutosProduccion / disponibilidad).toFixed(4) ): 0;
        }
    }

    return metrics;
}


//calcula el OEE promedio simple de cada linea
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
            oeeAverages[id] = parseFloat (( oeeTotals[id] / counts[id]).toFixed(4)); // Promedio por ID
        } else {
            oeeAverages[id] = 0; // Si no hay datos, asignar 0
        }
    });

    // Calcular el promedio total de OEE
    const overallOEE = totalCount > 0 ? totalOEE / totalCount : 0;

    // Asignar el promedio total a PLANTA
    oeeAverages.PLANTA = parseFloat( (overallOEE).toFixed(4) );

    return oeeAverages; // Devolver ambos valores
}


// actualiza la tabla indicador semanal con los valores calculados
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
            row.disp = (metrics.disp[id] * 100).toFixed(2) + "%";  // Convertir float a porcentaje (ej. 0.87 -> '87.00%')
        }

        if (avg.hasOwnProperty(id)) {
            row.oee = (avg[id] * 100).toFixed(2) + "%";  // Convertir float a porcentaje (ej. 0.87 -> '87.00%')
        }

    });

    return indData;
}