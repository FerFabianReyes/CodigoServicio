<?php
//Conexión a la base de datos local
$servername = "localhost";
$username = "fabian";
$password = "Salsadecaramelo+1";
$database = "Servicio";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}
?>
