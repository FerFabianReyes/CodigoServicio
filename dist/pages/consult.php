<?php
//Este archivo es el que se usa para mostar los datos
include 'connec.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

$matricula = isset($_GET['matricula']) ? $conn->real_escape_string($_GET['matricula']) : '';

$response = [];

if (!empty($matricula)) {
    // Filtrar los datos por la matrícula ingresada
    $queryEgresado = "SELECT ALUMNO FROM matricula WHERE CICLOEGR IS NOT NULL AND CICLOEGR != '' AND Alumno = '$matricula'";
    $resultEgresado = $conn->query($queryEgresado);
    
    //Hacer la consulta para
    $sqlCreditos = "SELECT creditos from matricula where alumno = '$matricula'" ;
    $resultCreditos = $conn->query($sqlCreditos);
    
    if ($resultEgresado->num_rows > 0) {
        // El alumno ha egresado
        $sqlInfo = "SELECT * from vInfoAlumnoGeneralEgresado WHERE Alumno = '$matricula'";
    } else {
        // El alumno no ha egresado
        $sqlInfo = "SELECT * from vInfoAlumnoGeneral WHERE Alumno = '$matricula'";
    }
    
} else {
    $sqlInfo = "SELECT * from vInfoAlumnoGeneralEgresado WHERE Alumno = ''";
}

$resultInfo = $conn->query($sqlInfo);
$response['info'] = $resultInfo->fetch_all(MYSQLI_ASSOC);

$response['creditos'] = $resultCreditos->fetch_all(MYSQLI_ASSOC);


echo json_encode($response);
$conn->close();
?>
