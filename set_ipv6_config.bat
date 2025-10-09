@echo off
REM -------------------------------------------------------
REM Windows 批次檔：設定 IPv6 網路 + Proxy + 停用 IPv4
REM 適用於介面名稱：乙太網路2
REM -------------------------------------------------------

set "IFNAME=乙太網路2"
set "IPV6_ADDR=2001:288:6004:17:2025:1b::13"
set "PREFIXLEN=64"
set "GATEWAY=2001:288:6004:17::254"
set "DNSv6=2001:b000:168::1"
set "PROXY=p4.cycu.org:3128"

echo =============================
echo 正在設定網路介面：%IFNAME%
echo =============================

REM 1) 停用 IPv4（移除 IPv4 協定綁定）
powershell -NoProfile -Command ^
  "try { Disable-NetAdapterBinding -Name '%IFNAME%' -ComponentID 'ms_tcpip' -ErrorAction Stop; Write-Host '已移除 IPv4 協定'; } catch { Write-Warning '移除 IPv4 失敗或已處理: ' + $_.Exception.Message }"

REM 2) 確保 IPv6 協定啟用
powershell -NoProfile -Command ^
  "try { Enable-NetAdapterBinding -Name '%IFNAME%' -ComponentID 'ms_tcpip6' -ErrorAction Stop; Write-Host 'IPv6 協定已啟用'; } catch { Write-Warning 'IPv6 啟用失敗或已啟用: ' + $_.Exception.Message }"

REM 3) 移除現有 IPv6 位址（可略）
powershell -NoProfile -Command ^
  "Get-NetIPAddress -InterfaceAlias '%IFNAME%' -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -ne '::1' } | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue;"

REM 4) 設定 IPv6 位址與預設閘道
powershell -NoProfile -Command ^
  "try { New-NetIPAddress -InterfaceAlias '%IFNAME%' -IPAddress '%IPV6_ADDR%' -PrefixLength %PREFIXLEN% -AddressFamily IPv6 -DefaultGateway '%GATEWAY%' -ErrorAction Stop; Write-Host '已設定 IPv6 與閘道'; } catch { Write-Warning '設定 IPv6 發生錯誤: ' + $_.Exception.Message }"

REM 5) 設定 DNS
powershell -NoProfile -Command ^
  "try { Set-DnsClientServerAddress -InterfaceAlias '%IFNAME%' -ServerAddresses '%DNSv6%' -ErrorAction Stop; Write-Host 'DNS 設定完成 (%DNSv6%)'; } catch { Write-Warning 'DNS 設定失敗: ' + $_.Exception.Message }"

REM 6) 設定 WinHTTP Proxy
echo 設定 WinHTTP Proxy 為：%PROXY%
netsh winhttp set proxy %PROXY%

REM 7) 設定目前使用者的 IE/WinINet Proxy（HKCU）
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d %PROXY% /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "<local>" /f >nul
echo 已設定使用者層級代理伺服器（IE/WinINet）

echo.
echo 所有設定完成！請使用以下指令檢查設定：
echo     ipconfig /all
echo     netsh interface ipv6 show address
echo     netsh winhttp show proxy
echo     Get-NetIPAddress -InterfaceAlias "%IFNAME%"
pause
