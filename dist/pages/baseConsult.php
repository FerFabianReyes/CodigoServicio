<?php
//No se usa pero es un ejemplo de tener varias consultas en un mismo archivo
include 'connec.php'; 
error_reporting(E_ALL);
ini_set('display_errors', 1);

$matricula = isset($_GET['matricula']) ? $conn->real_escape_string($_GET['matricula']) : '';

$response = [];

//Los creditos en cada ciclo de un alumno
$sqlCreditos = "SELECT CICLO, CREDITOS from creditos_ciclos where alumno='0906138K';";
$resultCreditos = $conn->query($sql);
$response['creditosCiiclos'] = $resultCreditos->fetch_all(MYSQLI_ASSOC);

//El promedio de cada ciclo de un alumno 
$sqlCreditAlum = "SELECT CICLO, PROMEDIO from promedios_ciclos2 where alumno='0906138K';";
$resultCreditAlum = $conn->query($sql);
$response['cred_alum_apr'] = $resultCreditAlum->fetch_all(MYSQLI_ASSOC);

//Total de creditos aprobados de cada alumno dela tabla de matricula
$sqlOtro = "SELECT alumno, creditos from matricula where alumno='0906138K';";
$resultOtro = $conn->query($sql);
$response['otro'] = $resultOtro->fetch_all(MYSQLI_ASSOC);



// para hacerlo json
echo json_encode($response);

$conn->close(); 
?>
