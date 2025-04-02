<?php
include 'connec.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Inicializar respuesta con estructura completa
$response = [
    'info' => [],
    'creditos' => [],
    'success' => false,
    'error' => null
];

$matricula = isset($_GET['matricula']) ? $conn->real_escape_string(trim($_GET['matricula'])) : '';

if (empty($matricula)) {
    echo json_encode($response);
    exit;
}

try {
    // Verificar si es egresado
    $queryEgresado = "SELECT ALUMNO FROM matricula WHERE CICLOEGR IS NOT NULL AND CICLOEGR != '' AND Alumno = '$matricula'";
    $resultEgresado = $conn->query($queryEgresado);

    // Consulta de información del alumno dependiendo si es egresasdo o no
    if ($resultEgresado->num_rows > 0) {
        $sqlInfo = "SELECT * FROM vInfoAlumnoGeneralEgresado WHERE Alumno = '$matricula'";
    } else {
        $sqlInfo = "SELECT * FROM vInfoAlumnoGeneral WHERE Alumno = '$matricula'";
    }

    $resultInfo = $conn->query($sqlInfo);
    $response['info'] = $resultInfo->fetch_all(MYSQLI_ASSOC);

    // Consulta de créditos
    $sqlCreditos = "SELECT creditos FROM matricula WHERE alumno = '$matricula'";
    $resultCreditos = $conn->query($sqlCreditos);
    $response['creditos'] = $resultCreditos->fetch_all(MYSQLI_ASSOC);

    $response['success'] = true;

} catch (Exception $e) {
    $response['error'] = $e->getMessage();
}

echo json_encode($response);
$conn->close();
?>