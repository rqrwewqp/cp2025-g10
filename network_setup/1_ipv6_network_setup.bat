REM Get-ExecutionPolicy -List
REM Set-ExecutionPolicy RemoteSigned
echo "disable ipv4 and setup proxy for ipv6"
SET CurrentDir=%~dp0
%windir%\system32\reg.exe import %CurrentDir%1_2022_cadlab_network_setup.reg
REM powershell -noexit -executionpolicy bypass -File %CurrentDir%1_disable_ipv4.ps1
powershell -executionpolicy bypass -File %CurrentDir%1_disable_ipv4.ps1
rem mstsc /admin /v:2001:288:6004:17:10ff::1
rem mstsc /admin /v:[2001:288:6004:17::229]:9089
rem mstsc /admin /v:exam.cycu.org
exit