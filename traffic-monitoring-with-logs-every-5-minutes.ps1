# Napló fájl helye
$logFile = "$PSScriptRoot\network_log.csv"

# Ha nem létezik a naplófájl, létrehozása fejléc sorral
if (-not (Test-Path $logFile)) {
    "Timestamp,ActiveTCP,UDP53,ICMP_SentPerSec,ICMP_ReceivedPerSec,WinUpdateStatus,TimeSyncStatus" | Out-File -FilePath $logFile -Encoding UTF8
}

# Megfigyelési ciklus hossza (másodperc)
$interval = 300  # 5 perc

# Végtelen ciklus - Ctrl+C kilépéshez
while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Aktív TCP kapcsolatok száma
    $tcpCount = (Get-NetTCPConnection | Where-Object { $_.State -eq "Established" }).Count

    # UDP 53-as porton levő végpontok (DNS)
    $udpDnsCount = (Get-NetUDPEndpoint | Where-Object { $_.LocalPort -eq 53 -or $_.RemotePort -eq 53 }).Count

    # ICMP számlálók
    $icmp = Get-Counter -Counter "ICMPv4\*Messages Sent/sec", "ICMPv4\*Messages Received/sec"
    $icmpSent = ($icmp.CounterSamples | Where-Object { $_.Path -like "*Sent/sec*" }).CookedValue
    $icmpReceived = ($icmp.CounterSamples | Where-Object { $_.Path -like "*Received/sec*" }).CookedValue

    # Szolgáltatások állapota
    $wuStatus = (Get-Service -Name wuauserv).Status
    $timeStatus = (Get-Service -Name w32time).Status

    # Sor összeállítása
    $logLine = "$timestamp,$tcpCount,$udpDnsCount,$icmpSent,$icmpReceived,$wuStatus,$timeStatus"

    # Napló fájlba írás
    $logLine | Out-File -FilePath $logFile -Append -Encoding UTF8

    Write-Host "[$timestamp] Naplózva: TCP=$tcpCount, UDP/53=$udpDnsCount, ICMP Sent=$icmpSent, Update=$wuStatus"

    # Várakozás következő ciklusig
    Start-Sleep -Seconds $interval
}
