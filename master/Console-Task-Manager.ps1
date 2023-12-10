<#========================= Live System Metrics Monitor ==============================

SYNPOSIS
Minature console window that outputs live system load information.

#>

# Resize console and background
# Set buffer size and window size
[console]::BufferWidth = [console]::WindowWidth = 30
[console]::BufferHeight = [console]::WindowHeight = 8

[Console]::BackgroundColor = "Black"
#[Console]::SetWindowSize(30, 8)
[Console]::Title = "System Metrics"
[Console]::CursorVisible = $false
Clear-Host

# Function for the output header
Function Header{
Write-Host "++++++++++++++++++++++++++++++" -ForegroundColor Green
Write-Host "++++    System Metrics    ++++" -ForegroundColor Green
Write-Host "++++++++++++++++++++++++++++++" -ForegroundColor Green
}

# Credit and kudos to Dagnazty for this function 
function Get-PerformanceMetrics {

    $cpuUsage = Get-Counter '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue
    $memoryUsage = Get-Counter '\Memory\% Committed Bytes In Use' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue
    $diskIO = Get-Counter '\PhysicalDisk(_Total)\Disk Transfers/sec' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue
    $networkIO = Get-Counter '\Network Interface(*)\Bytes Total/sec' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue

    return [PSCustomObject]@{
        CPUUsage = "{0:F2}" -f $cpuUsage.CookedValue
        MemoryUsage = "{0:F2}" -f $memoryUsage.CookedValue
        DiskIO = "{0:F1}" -f $diskIO.CookedValue
        NetworkIO = "{0:F1}" -f $networkIO.CookedValue
    }
}

# Loading Information
Header
Write-Host "`n@beigeworm | Discord - egieb" -ForegroundColor Gray
Write-Host "https://github.com/beigeworm"
sleep 2;cls
Header
Write-Host "`nLoading Performance Metrics.." -ForegroundColor Yellow
sleep 1
Write-Host "`Starting..." -ForegroundColor Green

# Main loop
while($true){
$metrics = Get-PerformanceMetrics
cls
Header
Write-Host "CPU Usage: $($metrics.CPUUsage)%"
Write-Host "Memory Usage: $($metrics.MemoryUsage)%"
Write-Host "Disk I/O: $($metrics.DiskIO) transfers/sec"
Write-Host "Network I/O: $($metrics.NetworkIO) bytes/sec"
}