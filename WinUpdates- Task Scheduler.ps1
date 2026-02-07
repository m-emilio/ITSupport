# Windows Update Automation Script

# Function to download and install updates
function Install-WindowsUpdates {
    # Check for available updates
    $UpdateSession = New-Object -ComObject Microsoft.Update.Session
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
    
    try {
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        if ($SearchResult.Updates.Count -eq 0) {
            Write-Output "No updates are available."
            return
        }
        
        # Download updates
        $Downloader = $UpdateSession.CreateUpdateDownloader()
        $Downloader.Updates = $SearchResult.Updates
        $Downloader.Download()
        
        # Prepare installation
        $Installer = $UpdateSession.CreateUpdateInstaller()
        $Installer.Updates = $SearchResult.Updates
        $InstallationResult = $Installer.Install()
        
        # Log results
        if ($InstallationResult.ResultCode -eq 2) {
            Write-Output "Updates installed successfully."
        } else {
            Write-Output "Update installation failed. Result code: $($InstallationResult.ResultCode)"
        }
    }
    catch {
        Write-Error "An error occurred during update process: $_"
    }
}

# Create a scheduled task to run updates weekly
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\WindowsUpdateAutomation.ps1"'
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "Weekly Windows Update" -Description "Automatic Windows Update Installation"

# Directly call the update function
Install-WindowsUpdates