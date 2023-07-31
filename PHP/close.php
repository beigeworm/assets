<?php
// PowerShell command to be executed (Replace 'msedge.exe' with the process name you want to kill, if needed)
$command = "taskkill /F /IM msedge.exe";

// Execute the PowerShell command
exec("powershell.exe -Command \"$command\"", $output, $returnCode);

// Send the output and return code as a JSON response
$response = array(
    "output" => $output,
    "returnCode" => $returnCode
);

header('Content-Type: application/json');
echo json_encode($response);
?>
