<?php
// Get Nginx version
$nginx_version = shell_exec('nginx -v 2>&1');
$nginx_version = explode(': ', $nginx_version)[1];

// App version (static for simplicity)
$app_version = "1.0.0";

// Get Nginx and PHP-FPM instance counts
$nginx_instance_count = shell_exec("ps aux | grep -v grep | grep -c 'nginx: master'");

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HashiStack Server</title>
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
            <td>Nginx</td>
            <td><?php echo $nginx_version; ?></td>
            <td><?php echo $nginx_instance_count; ?></td>
        </tr>
    </table>
</body>
</html>
