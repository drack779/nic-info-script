# Get-NetworkInfo.ps1
# Skriptas išveda naudojamo kompiuterio tinklo parametrus

Write-Output "=== Tinklo parametrai - $(Get-Date) ===`n"

Write-Output "-> Tinklo adapteriai"
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed | Format-Table -AutoSize
Write-Output ""

Write-Output "-> IP konfigūracija"
Get-NetIPConfiguration | ForEach-Object {
    Write-Output "Interface: $($_.InterfaceAlias)"
    $_.IPv4Address | ForEach-Object { Write-Output "  IPv4: $($_.IPAddress) / PrefixLength: $($_.PrefixLength)" }
    $_.IPv6Address | ForEach-Object { Write-Output "  IPv6: $($_.IPAddress) / PrefixLength: $($_.PrefixLength)" }
    if ($_.IPv4DefaultGateway) { Write-Output "  Default Gateway: $($_.IPv4DefaultGateway.NextHop)" }
    Write-Output "  DNS Servers: " + ($_.DnsServer.ServerAddresses -join ", ")
    Write-Output "  DHCP Enabled: $($_.DhcpEnabled)"
    Write-Output ""
}

Write-Output "-> DNS klientų serveriai"
Get-DnsClientServerAddress | Select-Object InterfaceAlias, AddressFamily, ServerAddresses | Format-List
Write-Output ""

Write-Output "-> Maršrutų lentelė"
Get-NetRoute -AddressFamily IPv4 | Sort-Object DestinationPrefix | Select-Object DestinationPrefix, NextHop, RouteMetric, InterfaceAlias | Format-Table -AutoSize
Write-Output ""

Write-Output "-> ARP lentelė"
arp -a
Write-Output ""

Write-Output "-> Aktyvūs TCP ryšiai (pirmi 20)"
Get-NetTCPConnection | Sort-Object -Property State -Descending | Select-Object -First 20 LocalAddress, LocalPort, RemoteAddress, RemotePort, State, @{Name='ProcessId';Expression={$_.OwningProcess}} | Format-Table -AutoSize
Write-Output ""

Write-Output "-> Viešasis IP"
try {
    $pub = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json' -UseBasicParsing -ErrorAction Stop
    if ($pub.ip) { Write-Output "Public IP: $($pub.ip)" } else { Write-Output "Public IP: $pub" }
} catch {
    Write-Output "Public IP: neprieinama ($($_.Exception.Message))"
}

Write-Output "`n=== Pabaiga ==="