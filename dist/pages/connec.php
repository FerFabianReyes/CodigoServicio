<?php
//Conexión a la base de datos local
$servername = "localhost";
$username = "root";
$password = "bp119B1A$3";
$database = "testServicio";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}
?>
