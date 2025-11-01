# 關閉 IPv4 網路
Disable-NetAdapterBinding -Name "乙太網路 2" -ComponentID ms_tcpip
  
# 啟用 IPv6 網路
Enable-NetAdapterBinding -Name "乙太網路 2" -ComponentID ms_tcpip6
  
# 設置 IPv6 網路中的 mde DNS 伺服器 (設計系)
$dnsServers = "2001:b000:168::1"
Set-DnsClientServerAddress -InterfaceAlias "*" -ServerAddresses $dnsServers


# 設定 IPv6 固定位址 (fixed address), 子網路首碼長度 (subnet prefix) 與網路預設閘道 (gateway) 等三個變數
# 以序號 100 為例
$ipv6Address = "2001:288:6004:17:2025:1a::13"
$subnetPrefixLength = 64
$gateway = "2001:288:6004:17::254"
 
# 參考 https://serverfault.com/questions/427234/getting-network-interface-device-name-in-powershell
$query = "SELECT * FROM Win32_NetworkAdapter WHERE Manufacturer != 'Microsoft' AND NOT PNPDeviceID LIKE 'ROOT\\%'"
$interfaces = Get-WmiObject -Query $query | Sort index
$interfaces | ForEach{
    $friendlyname = $_ | ForEach-Object { $_.NetConnectionID }
    New-NetIPAddress -AddressFamily "IPv6" -InterfaceAlias $friendlyname -IPAddress $ipv6Address -PrefixLength $subnetPrefixLength -DefaultGateway $gateway
}

 
# 列出所使用的 IPv6 網路通訊協定內容
Write-Host "IPv6 Address: $ipv6Address/$subnetPrefixLength"

Write-Host "IPv6 Gateway: $gateway"

