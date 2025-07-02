# Időbélyeg
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "Hálózati ellenőrzés indul: $timestamp" -ForegroundColor Cyan

# 1. Aktív TCP kapcsolatok kilistázása
Write-Host "`n[1] Aktív TCP kapcsolatok:" -ForegroundColor Yellow
Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } | Format-Table -AutoSize

# 2. UDP végpontok (pl. DNS)
Write-Host "`n[2] UDP végpontok (különösen DNS 53-as port):" -ForegroundColor Yellow
Get-NetUDPEndpoint | Where-Object { $_.LocalPort -eq 53 -or $_.RemotePort -eq 53 } | Format-Table -AutoSize

# 3. ICMP forgalom ellenőrzése (ping)
Write-Host "`n[3] ICMP forgalom (ping) számlálók:" -ForegroundColor Yellow
Get-Counter -Counter "ICMPv4\*Messages Sent/sec", "ICMPv4\*Messages Received/sec" | Select-Object -ExpandProperty CounterSamples | Format-Table Path, CookedValue

# 4. Windows Update és Time Sync szolgáltatások állapota
Write-Host "`n[4] Szolgáltatások állapota (Windows Update, Time):" -ForegroundColor Yellow
Get-Service -Name wuauserv, w32time | Format-Table Name, Status, StartType

# 5. Tűzfal naplók (ha engedélyezve van)
Write-Host "`n[5] Tűzfal események (ha naplózás aktív):" -ForegroundColor Yellow
Get-WinEvent -LogName "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" -MaxEvents 20 | 
    Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -AutoSize

# Zárás
Write-Host "`nEllenőrzés kész: $(Get-Date -Format "HH:mm:ss")" -ForegroundColor Green
