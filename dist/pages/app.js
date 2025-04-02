async function cargarDatos() {
    const matricula = document.getElementById("matriculaInput").value.trim();
    if (matricula === "") {
        alert("Ingrese una matrícula válida.");
        return;
    }

    try {
        document.getElementById("tablaDatos").innerHTML = '<div class="loader">Cargando datos...</div>';
        document.getElementById("creditos").innerHTML = '<div class="loader">Cargando créditos...</div>';

        const response = await fetch(`consult.php?matricula=${matricula}`);
        const data = await response.json();

        // Limpiar gráfico anterior si existe
        const chartElement = document.getElementById("creditos");
        if (window.creditosChart) {
            window.creditosChart.dispose(); // Destruir instancia anterior
        }

        // Verificar si hay datos
        if (!data.success || data.info.length === 0) {
            throw new Error("No se encontraron datos para esta matrícula");
        }

        // Mostrar tabla y gráfico con los mismos datos
        mostrarCreditos(data.creditos);
        mostrarTabla(data);
        

    } catch (error) {
        console.error("Error:", error);
        document.getElementById("tablaDatos").innerHTML = `<div class="error">${error.message}</div>`;
        document.getElementById("creditos").innerHTML = '<div class="error">Error al cargar créditos</div>';
    }
}

function mostrarTabla(data) {
    if (!data.info || data.info.length === 0) {
        document.getElementById("tablaDatos").innerHTML = '<div class="no-data">No se encontraron datos del alumno</div>';
        return;
    }

    let tablaHTML = `
        <table class='table table-hover text-nowra'>
            <thead>
                <tr>
                    <th>Matrícula</th>
                    <th>Ciclo de ingreso</th>
                    <th>Ciclo actual</th>
                    <th>Ciclo Egreso</th>
                    <th>Semestre Actual</th>
                    <th>Créditos</th>
                    <th>Promedio Actual</th>
                </tr>
            </thead>
            <tbody>`;

    data.info.forEach(item => {
        tablaHTML += `
            <tr>
                <td>${item.alumno}</td>
                <td>${item.ciclo}</td>
                <td>${item.cicloActual || '-'}</td>
                <td>${item.cicloegr || '-'}</td>
                <td>${item.semestreActual || '-'}</td>
                <td>${item.creditos}</td>
                <td>${item.promedioFinal}</td>
            </tr>`;
    });

    tablaHTML += `</tbody></table>`;
    document.getElementById("tablaDatos").innerHTML = tablaHTML;
}

function mostrarCreditos(creditosData) {
    try {
        // Verificar si hay datos de créditos
        if (!creditosData || creditosData.length === 0) {
            document.getElementById("creditos").innerHTML = '<div class="no-data">No se encontraron datos de créditos</div>';
            return;
        }

        const totalCreditos = Array.isArray(creditosData) 
        ? creditosData.reduce((sum, item) => sum + (parseInt(item?.creditos) || 0), 0)
        : 0;

        const faltantes = 470 - totalCreditos;
        if (totalCreditos >= 470) {
            faltantes = 0;
        }

        const options = {
            tooltip: {
                trigger: 'axis',
                axisPointer: { type: 'shadow' }
            },
            legend: {
                data: ['Créditos cursados', 'Créditos por cursar']
            },
            grid: {
                left: '3%',
                right: '4%',
                bottom: '3%',
                containLabel: true
            },
            xAxis: {
                type: 'value',
                max: 500
            },
            yAxis: {
                type: 'category',
                data: ['Créditos']
            },
            series: [
                {
                    name: 'Créditos cursados',
                    type: 'bar',
                    stack: 'total',
                    label: { show: true },
                    data: [totalCreditos],
                    itemStyle: { color: '#5470C6' }
                },
                {
                    name: 'Créditos por cursar',
                    type: 'bar',
                    stack: 'total',
                    label: { show: true },
                    data: [faltantes],
                    itemStyle: { color: '#91CC75' }
                },
                {
                    type: 'line',
                    markLine: {
                        silent: true,
                        label: {
                            show: true,
                            position: 'end',
                            formatter: 'Necesarios: {c}'
                        },
                        lineStyle: {
                            type: 'dashed',
                            color: '#EE6666'
                        },
                        data: [{ xAxis: 470 }]
                    }
                }
            ]
        };

         // Crear o actualizar gráfico
         window.creditosChart = echarts.init(document.getElementById("creditos"));
         window.creditosChart.setOption(options);
         
         // Redimensionar al cambiar tamaño de ventana
         window.addEventListener('resize', function() {
             window.creditosChart.resize();
         });

    } catch (error) {
        console.error("Error al mostrar créditos:", error);
        document.getElementById("creditos").innerHTML = '<div class="error">Error al mostrar créditos</div>';
    }
}