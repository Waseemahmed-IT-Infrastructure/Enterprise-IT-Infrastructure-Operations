# Read-only connectivity checks to an explicitly supplied, authorized target.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName,
    [ValidateRange(1,65535)]
    [int]$Port = 443
)

Write-Host "DNS lookup for $ComputerName"
try { Resolve-DnsName -Name $ComputerName -ErrorAction Stop | Select-Object -First 5 Name, Type, IPAddress }
catch { Write-Warning "DNS lookup failed: $($_.Exception.Message)" }

Write-Host "TCP connectivity test to $ComputerName on port $Port"
Test-NetConnection -ComputerName $ComputerName -Port $Port |
    Select-Object ComputerName, RemoteAddress, RemotePort, TcpTestSucceeded

# Example: .\Test-NetworkConnectivity.ps1 -ComputerName example.com -Port 443
