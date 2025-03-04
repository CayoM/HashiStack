<?php
// Get Nginx version
$nginx_version = shell_exec('nginx -v 2>&1');
$nginx_version = explode(': ', $nginx_version)[1];

// App version (static for simplicity)
$app_version = "2.0.0";

// Get Nginx and PHP-FPM instance counts
$nginx_instance_count = shell_exec("ps aux | grep -v grep | grep -c 'nginx: master'");

$backend_url_status = "http://backend:5000/status";
$api_token = "my-secret-token"; // Token aus der Datenbank

$options = [
    "http" => [
        "header" => "Authorization: $api_token\r\n"
    ]
];

$context = stream_context_create($options);
$response = file_get_contents($backend_url_status, false, $context);
$data = json_decode($response, true);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HashiStack Server - 3 Tier</title>
    <style>
        table {
            width: 60%;
            border-collapse: collapse;
            margin: 20px auto;
        }
        th, td {
            padding: 8px 12px;
            border: 1px solid #ddd;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <h1 style="text-align: center;">HashiStack Status Page</h1>

    <table>
        <tr>
            <th>Component</th>
            <th>Version</th>
            <th>Instance Count</th>
        </tr>
        <tr>
            <td>HashiStack App</td>
            <td><?php echo $app_version; ?></td>
            <td> - </td>
        </tr>
        <tr>
            <td>FrontEnd</td>
            <td><?php echo $nginx_version; ?></td>
            <td><?php echo $nginx_instance_count; ?></td>
        </tr>
        <tr>
            <td>BackEnd</td>
            <td><?php echo $data["server"] . "/" . $data["backend_version"]; ?></td>
            <td><?php echo 1; ?></td>
        </tr>
        <tr>
            <td>Database</td>
            <td><?php echo $data["database"]["version"]; ?></td>
            <td><?php echo 1; ?></td>
        </tr>
    </table>

    <?php
    // Überprüfen, ob die Datenbankverbindung erfolgreich war, bevor die zweite Tabelle angezeigt wird
    if (isset($data["database"]["user"]) && isset($data["database"]["password"])) {
        // Datenbank-Verbindungsdetails anzeigen
    ?>
        <h2 style="text-align: center;">Database Connection Details</h2>
        <table>
            <tr>
                <th>Component</th>
                <th>Value</th>
            </tr>
            <tr>
                <td>User</td>
                <td><?php echo $data["database"]["user"]; ?></td>
            </tr>
            <tr>
                <td>Password</td>
                <td><?php echo $data["database"]["password"]; ?></td>
            </tr>
        </table>
    <?php
    }
    ?>
</body>
</html>
