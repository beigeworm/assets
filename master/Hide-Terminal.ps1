$Async = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$Type = Add-Type -Member $Async -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$hwnd = (Get-Process -PID $pid).MainWindowHandle
$Host.UI.RawUI.WindowTitle = 'hideme'
$Proc = (Get-Process | Where-Object {$_.MainWindowTitle -eq 'hideme'})
$hwnd = $Proc.MainWindowHandle
$Type::ShowWindowAsync($hwnd, 0)