<?php
    date_default_timezone_set("Asia/Kuala_Lumpur");

    // LocalHost Ip address to store database location
    $host = "127.0.0.1";

    // A standard port number to use for pHpMyAdmin MYSQL database in XAMPP 
    $port = 3306;

    // the extend for port if the ip in the port is full
    $socket = "";

    // database username
    $user = "root";

    // Most of the time the password is empty 
    $password = "";

    // database name 
    $dbname = "florahub_db";

    // Connection mysqli carry all define above variable to phpadmin
    // die - php immediately stop the function

    // type of connection : mysql object oriented
    $con = new mysqli($host, $user, $password, $dbname, $port, $socket);

    if ($con->connect_error) {
        die("Connection failed: " . $con->connect_error);
    }

    // Get the sensor data from the HTTP POST request
    $date = $_POST['date'];
    $reading = $_POST['reading'];
    $percent = $_POST['percent'];

    //$date = date('Y-m-d H:i:s');
    //$reading = 50;
    //$percent = 75;

    // Insert the sensor data into the 'data' table
    $sql = "INSERT INTO data (date, reading, percent) VALUES ('$date', '$reading', '$percent')";

    if ($con->query($sql) === TRUE) {
        echo "Sensor data inserted successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $con->error;
    }

    $con->close();
?>