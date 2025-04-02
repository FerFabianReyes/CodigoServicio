
async function cargarDatos() {
    const matricula = document.getElementById("matriculaInput").value.trim();
    if (matricula === "") {
        alert("Ingrese una matrícula válida.");
        return;
    }

    try {
        const response = await fetch(`consult.php?matricula=${matricula}`);
        const    data = await response.json();

        mostrarTabla(data); // Llamar a la función para mostrar los datos
        initCharts(matricula);
    } catch (error) {
        console.error("Error al obtener los datos:", error);
    }
}

function mostrarTabla(data) {
    let tablaHTML = "<table class='table table-hover text-nowra' ><tr><th>Matricula</th><th>Ciclo de ingreso</th><th>Ciclo actual</th><th>Ciclo Egreso</th><th>Semestre Actual</th><th>Creditos</th><th>Promedio Actual</th></tr>";

    data.info.forEach(item => {
        tablaHTML += `<tr>
            <td>${item.alumno}</td>
            <td>${item.ciclo}</td>
            <td>${item.cicloActual || '-'}</td>  <!-- Evita valores nulos -->
            <td>${item.cicloegr || '-'}</td>
            <td>${item.semestreActual || '-'}</td>
            <td>${item.creditos}</td>
            <td>${item.promedioFinal}</td>
        </tr>`;
    });

    tablaHTML += "</table>";

    document.getElementById("tablaDatos").innerHTML = tablaHTML;
}

const creditos = async (matricula) => {
    try {
        const response = await fetch(`consult.php?matricula=${matricula}`);
        const data = await response.json();

        if (!data.creditos) {
            console.error("No hay datos de créditos.");
            return null;
        }

        const creditosData = data.creditos.map(item => item.creditos);
        console.log("Créditos extraídos:", creditosData); 

        const totalCreditos = creditosData.reduce((acc, curr) => acc + curr, 0);

        return {
            tooltip: {
                trigger: 'axis',
                axisPointer: {
                    type: 'shadow'
                }
            },
            legend: {},
            grid: {
                left: '3%',
                right: '4%',
                bottom: '3%',
                containLabel: true
            },
            xAxis: {
                type: 'value',
                axisLabel: {
                    show: false 
                }
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
                    emphasis: { focus: 'series' },
                    data: [totalCreditos]
                },
                {
                    name: 'Créditos por cursar',
                    type: 'bar',
                    stack: 'total',
                    label: { show: true },
                    emphasis: { focus: 'series' },
                    data: [470 - totalCreditos]
                },
                {
                    name: 'Límite de créditos',
                    color: 'green',
                    type: 'line',
                    markLine: {
                        silent: true,
                        label: {
                            show: true,
                            position: 'end',
                            formatter: 'Créditos máximos'
                        },
                        lineStyle: {
                            type: 'dashed',
                            color: 'green'
                        },
                        data: [{ xAxis: 500 }]
                    }
                }
            ]
        };

    } catch (error) {
        console.error("Error al obtener los datos:", error);
    }
};


const initCharts = async () => {
    const chartCreditos = echarts.init(document.getElementById("creditos"));

    const optionsCreditos = await creditos();  // tener los datos antes de hacer la grafica
    chartCreditos.setOption(optionsCreditos);
    chartCreditos.resize();

};