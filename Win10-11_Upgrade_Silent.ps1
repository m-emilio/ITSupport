Write-Host "`nOverall Compatibility: " -NoNewline
if ($compatible) {
    Write-Host "COMPATIBLE" -ForegroundColor Green
    Write-Host "Automatically starting the Windows 11 upgrade process..." -ForegroundColor Yellow

    # Create a restore point
    Write-Host "`nCreating system restore point..." -ForegroundColor Yellow
    Checkpoint-Computer -Description "Before Windows 11 Upgrade" -RestorePointType "MODIFY_SETTINGS"

    # Download and verify Windows 11 Installation Assistant
    $installerPath = Download-Windows11Assistant

    if ($installerPath -and (Test-Path $installerPath)) {
        # Start the upgrade process
        $success = Start-Windows11Upgrade -installerPath $installerPath

        if ($success) {
            Write-Host "`nWindows 11 upgrade process has been initiated." -ForegroundColor Green
            Write-Host "Your PC will restart automatically to complete the upgrade."
            Write-Host "Please save any open work before continuing."
        } else {
            Write-Host "`nThe upgrade process could not be started automatically." -ForegroundColor Red
            Write-Host "Please visit https://www.microsoft.com/software-download/windows11"
            Write-Host "to download and run the Installation Assistant manually."
        }
    }
} else {
    Write-Host "NOT COMPATIBLE" -ForegroundColor Red
    Write-Host "`nReview the detailed output above to identify specific issues."
    Write-Host "If you believe these results are incorrect, verify using:"
    Write-Host "1. Windows Security Center (Windows + I → Security)"
    Write-Host "2. System Information (Run 'msinfo32')"
    Write-Host "3. Microsoft's PC Health Check app"
}
