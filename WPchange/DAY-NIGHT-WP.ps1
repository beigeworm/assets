$nighturl = "https://github.com/beigeworm/assets/blob/main/WPchange/night.jpg?raw=true"
$nightpath = "$env:temp\night.jpg"
$dayurl = "https://github.com/beigeworm/assets/blob/main/WPchange/day.jpg?raw=true"
$daypath = "$env:temp\day.jpg"
$statepath = "$env:temp\current.log"
$state = Get-Content $statepath -Raw
$wallpaperStyle = 2

if (!(Test-Path $daypath)){
    IWR -Uri $dayurl -OutFile $daypath
}

if (!(Test-Path $nightpath)){
    IWR -Uri $nighturl -OutFile $nightpath

}

$signature = @'
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
'@

Add-Type -TypeDefinition $signature

$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDCHANGE = 0x02

if ($state -match 'day'){
    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $nightpath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)
    'night' | Out-File -FilePath $statepath -Force
    Write-Host "Set wallpaper to night"
}
else{
    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $daypath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)
    'day' | Out-File -FilePath $statepath -Force
    Write-Host "Set wallpaper to day"
}
