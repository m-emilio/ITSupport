# Script to upgrade Windows 10 to Windows 11 using the Update Assistant
# Run as Administrator

# Define URLs and paths
$UpdateAssistantURL = "https://go.microsoft.com/fwlink/?linkid=2171764"
$DownloadPath = "C:\Temp\Windows11UpdateAssistant.exe"
$LogPath = "C:\Temp\Windows11UpgradeLog.txt"

# Create a Temp directory if it doesn't exist
if (!(Test-Path "C:\Temp")) {
    Write-Host "Creating Temp directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "C:\Temp"
}

# Download the Windows 11 Update Assistant
Write-Host "Downloading Windows 11 Update Assistant..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $UpdateAssistantURL -OutFile $DownloadPath
    Write-Host "Update Assistant downloaded successfully to $DownloadPath." -ForegroundColor Green
} catch {
    Write-Host "Error: Unable to download the Update Assistant. Exiting..." -ForegroundColor Red
    exit 1
}

# Run the Update Assistant
Write-Host "Starting the Windows 11 Update Assistant..." -ForegroundColor Green
try {
    Start-Process -FilePath $DownloadPath -ArgumentList "/quiet /norestart" -Wait
    Write-Host "The Update Assistant has been launched. Monitor its progress for completion." -ForegroundColor Green
} catch {
    Write-Host "Error: Unable to start the Update Assistant. Exiting..." -ForegroundColor Red
    exit 1
}

# Clean up downloaded files
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
try {
    Remove-Item -Path $DownloadPath -Force
    Write-Host "Temporary files cleaned up successfully." -ForegroundColor Green
} catch {
    Write-Host "Warning: Unable to clean up temporary files. You may need to remove them manually." -ForegroundColor Red
}

# Logging
Write-Host "A log of this operation has been saved at $LogPath." -ForegroundColor Cyan
try {
    Add-Content -Path $LogPath -Value "$(Get-Date): Windows 11 Update Assistant script executed."
} catch {
    Write-Host "Warning: Unable to write to log file." -ForegroundColor Red
}
