function Verify-SystemHealth {
    # Check Windows Update status
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $searchResult = $updateSearcher.Search("IsInstalled=0")

    # Check disk health
    $diskHealth = Get-PhysicalDisk | Where-Object {$_.HealthStatus -ne 'Healthy'}

    # Check system logs for critical errors
    $criticalLogs = Get-EventLog -LogName System -EntryType Error, Critical -After (Get-Date).AddDays(-1)

    # Generate report
    $report = @{
        PendingUpdates = $searchResult.Updates.Count
        UnhealthyDisks = $diskHealth.Count
        CriticalLogEntries = $criticalLogs.Count
    }

    return $report
}

# Run health check and output results
Verify-SystemHealth | Format-List
