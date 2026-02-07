# Function to check if running as administrator
function Check-Admin {
    $currentUser = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

# Relaunch the script with elevated privileges if not running as administrator
if (-not (Check-Admin)) {
    Write-Host "Script is not running as administrator. Relaunching with elevated privileges..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Import the Windows Store module (if needed)
Import-Module Appx

# Get a list of all installed Windows Store apps
$installedApps = Get-AppxPackage

# Check if there are any apps to update
if ($installedApps.Count -eq 0) {
    Write-Host "No apps found in the Windows Store library." -ForegroundColor Yellow
    exit
}

# Update each app in the library
foreach ($app in $installedApps) {
    try {
        Write-Host "Updating app: $($app.Name)" -ForegroundColor Green
        Update-AppxPackage -Package $app
    }
    catch {
        Write-Host "Failed to update app: $($app.Name). Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "All available apps have been updated." -ForegroundColor Cyan
