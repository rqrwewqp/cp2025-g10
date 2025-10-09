# 請以系統管理員身分執行

$Interface = "乙太網路2"
$IPv6Addr = "2001:288:6004:17:2025:1b::13"
$Prefix = 64
$Gateway = "2001:288:6004:17::254"
$DNS = "2001:b000:168::1"
$Proxy = "p4.cycu.org:3128"

Write-Host "[1] 移除 IPv4 協定綁定..."
try {
    Disable-NetAdapterBinding -Name $Interface -ComponentID "ms_tcpip" -ErrorAction Stop
    Write-Host "✅ IPv4 協定已移除"
} catch {
    Write-Host "⚠️ 發生錯誤：" + $_.Exception.Message
}

Write-Host "[2] 確保 IPv6 已啟用..."
try {
    Enable-NetAdapterBinding -Name $Interface -ComponentID "ms_tcpip6" -ErrorAction Stop
    Write-Host "✅ IPv6 協定已啟用"
} catch {
    Write-Host "⚠️ IPv6 啟用失敗：" + $_.Exception.Message
}

Write-Host "[3] 設定 IPv6 與閘道..."
try {
    New-NetIPAddress -InterfaceAlias $Interface -IPAddress $IPv6Addr -PrefixLength $Prefix -AddressFamily IPv6 -DefaultGateway $Gateway -ErrorAction Stop
    Write-Host "✅ IPv6 位址已設定"
} catch {
    Write-Host "⚠️ 設定 IPv6 發生錯誤：" + $_.Exception.Message
}

Write-Host "[4] 設定 DNS..."
try {
    Set-DnsClientServerAddress -InterfaceAlias $Interface -ServerAddresses $DNS -ErrorAction Stop
    Write-Host "✅ DNS 已設定為 $DNS"
} catch {
    Write-Host "⚠️ DNS 設定錯誤：" + $_.Exception.Message
}

Write-Host "[5] 設定 Proxy..."
netsh winhttp set proxy $Proxy

Write-Host "[6] 設定 IE/使用者層級 Proxy..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value $Proxy
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyOverride -Value "<local>"

Write-Host "✅ 所有設定完成"
