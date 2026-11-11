# Read-only local Windows system health summary.
# Run in an authorized Windows PowerShell environment.
[CmdletBinding()]
param()

$os = Get-CimInstance Win32_OperatingSystem
$disks = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3'
$services = Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' }

[pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    OS = $os.Caption
    LastBootTime = $os.LastBootUpTime
    TotalMemoryGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    FreeMemoryGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    AutomaticServicesNotRunning = @($services).Count
} | Format-List

$disks | Select-Object DeviceID,
    @{Name='SizeGB';Expression={[math]::Round($_.Size / 1GB, 2)}},
    @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace / 1GB, 2)}} |
    Format-Table -AutoSize

# A stopped automatic service is not necessarily an incident.
