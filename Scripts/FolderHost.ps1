<#
============================== Beigeworm's HTTP File Server ===============================

SYNOPSIS
This script serves the contents the folder it is ran in.

INSTRUCTIONS
Run script and input given URL in a browser.

#>
<#
============================== Beigeworm's HTTP File Server ===============================

SYNOPSIS
This script serves the contents the folder it is ran in.

INSTRUCTIONS
Run script and input given URL in a browser.

#>
Write-Host "=======================================================================================" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "██╗  ██╗████████╗████████╗██████╗     ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ " -ForegroundColor Cyan -BackgroundColor Black
Write-Host "██║  ██║╚══██╔══╝╚══██╔══╝██╔══██╗    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "███████║   ██║      ██║   ██████╔╝    ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "██╔══██║   ██║      ██║   ██╔═══╝     ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "██║  ██║   ██║      ██║   ██║         ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝         ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "=======================================================================================" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "============================= Simple HTTP File Server =================================" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "=======================================================================================`n" -ForegroundColor Cyan -BackgroundColor Black
Write-Host "More info at : https://github.com/beigeworm" -ForegroundColor Gray
Write-Host "This script will start a HTTP fileserver with the contents of this folder.`n"
sleep 1

Write-Host "================================== Server Setup =======================================" -ForegroundColor Green

Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

Write-Host "Checking User Permissions.."

$Button = [System.Windows.MessageBoxButton]::OKCancel
$ErrorIco = [System.Windows.MessageBoxImage]::Information
$Ask = '        This Script Needs Administrator Privileges.

        Select "OK" to Run as an Administrator
        
        Select "Cancel" to Stop the Script'

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "Admin privileges needed for this script..." -ForegroundColor Red
    Write-Host "Sending User Prompt."
    $Prompt = [System.Windows.MessageBox]::Show($Ask, "Run as an Admin?", $Button, $ErrorIco) 
    Switch ($Prompt) {
        OK {
            Write-Host "This script will self elevate to run as an Administrator and continue." -ForegroundColor Green
            $fpath = $PWD.Path
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
else{
        if (-Not (Test-Path -Path "$env:temp/homepath.txt")) {
        $fpath = Read-Host "Input the local path for the folder you want to host "
        $fpath | Out-File -FilePath "$env:temp/homepath.txt"
        }
        else{
        }
}

Write-Host "Detecting primary network interface."
$networkInterfaces = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual' }

$filteredInterfaces = $networkInterfaces | Where-Object { $_.Name -match 'Wi*' -or  $_.Name -match 'Eth*'}

$primaryInterface = $filteredInterfaces | Select-Object -First 1

if ($primaryInterface) {
    if ($primaryInterface.Name -match 'Wi*') {
        Write-Output "Wi-Fi is the primary internet connection."
        $loip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi*" | Select-Object -ExpandProperty IPAddress
    } elseif ($primaryInterface.Name -match 'Eth*') {
        Write-Output "Ethernet is the primary internet connection."
        $loip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Eth*" | Select-Object -ExpandProperty IPAddress
    } else {
        Write-Output "Unknown primary internet connection."
    }
} else {
    Write-Output "No primary internet connection found."
}

Write-Host "Server Started at : http://localhost:5000/"
Write-Host "Opening port 5000 on the local machine"
Write-Host "Setup Complete! `n" -ForegroundColor Green
Write-Host "=================================== Server Details ===================================="  -ForegroundColor Green
New-NetFirewallRule -DisplayName "AllowWebServer" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow

Write-Host "===================================== Folder Setup ===================================="  -ForegroundColor Green
Write-Host "Checking folder path.."
$hpath = Get-Content -Path "$env:temp/homepath.txt"
cd "$hpath"
$httpsrvlsnr = New-Object System.Net.HttpListener;
$httpsrvlsnr.Prefixes.Add("http://"+$loip+":5000/");
$httpsrvlsnr.Prefixes.Add("http://localhost:5000/");

$httpsrvlsnr.Start();
Write-Host "Setting folder root as : $hpath `n"

$webroot = New-PSDrive -Name webroot -PSProvider FileSystem -Root $PWD.Path
[byte[]]$buffer = $null
Write-Host "=======================================================================================" -ForegroundColor Green
Write-Host "==============================   HTTP SERVER STARTED   ================================" -ForegroundColor Green
Write-Host "=======================================================================================" -ForegroundColor Green
Write-Host ("Network Devices Can Reach the server at : http://"+$loip+":5000")
Write-Host "`n"

Remove-Item -Path "$env:temp/homepath.txt" -Force

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
    }
    catch [System.Net.HttpListenerException] {
        Write-Host ($_);
    }}
Write-Host "Server Stopped!" -ForegroundColor Green
Sleep 3

