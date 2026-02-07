# Windows 10 to Windows 11 Upgrade Script
# This script must be run as administrator

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrator privileges. Please restart as administrator." -ForegroundColor Red
    Exit 1
}

# Create log file
$logFile = "$env:TEMP\Win11Upgrade_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $logFile

Write-Host "Starting Windows 11 upgrade process..." -ForegroundColor Green

# Create a directory for downloads if it doesn't exist
$downloadDir = "$env:USERPROFILE\Downloads\Win11Upgrade"
if (-not (Test-Path $downloadDir)) {
    New-Item -Path $downloadDir -ItemType Directory -Force | Out-Null
}

# Download Windows 11 Installation Assistant
$win11InstallerUrl = "https://go.microsoft.com/fwlink/?linkid=2171764"
$installerPath = "$downloadDir\Win11InstallationAssistant.exe"

Write-Host "Downloading Windows 11 Installation Assistant..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $win11InstallerUrl -OutFile $installerPath
    Write-Host "Download completed successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to download Windows 11 Installation Assistant: $_" -ForegroundColor Red
    Stop-Transcript
    Exit 1
}

# Check if any user is currently logged in (except current admin session)
function Test-UserLoggedIn {
    $loggedInUsers = @(Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    
    # Filter out the current user (who is running this script)
    $otherUsers = $loggedInUsers | Where-Object { $_ -ne $currentUser -and $_ -ne $null }
    
    return $otherUsers.Count -gt 0
}

# Create a marker file to detect reboots
$markerFile = "$env:SystemDrive\Win11UpgradeInProgress.marker"

# Check if this is the first run or a post-reboot session
if (Test-Path $markerFile) {
    # This is a post-reboot session, clean up the marker and scheduled task
    Write-Host "Post-reboot detected. Cleaning up temporary tasks..." -ForegroundColor Cyan
    Remove-Item -Path $markerFile -Force
    
    # Remove any scheduled task
    if (Get-ScheduledTask -TaskName "Win11UpgradeReboot" -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName "Win11UpgradeReboot" -Confirm:$false
        Write-Host "Removed reboot scheduled task." -ForegroundColor Green
    }
    
    # Remove cleanup batch file if it exists
    if (Test-Path "$env:SystemDrive\Win11UpgradeCleanup.bat") {
        Remove-Item -Path "$env:SystemDrive\Win11UpgradeCleanup.bat" -Force
    }
    
    Write-Host "Windows 11 upgrade process completed." -ForegroundColor Green
    Stop-Transcript
    Exit 0
}

# Function to start the upgrade
function Start-Win11Upgrade {
    Write-Host "Starting Windows 11 Installation Assistant..." -ForegroundColor Cyan
    
    # Create a marker file to detect post-reboot sessions
    "Upgrade in progress" | Out-File -FilePath $markerFile -Force
    
    # Create a batch file to run at startup that will clean up tasks
    $batchPath = "$env:SystemDrive\Win11UpgradeCleanup.bat"
    @"
@echo off
schtasks /delete /tn "Win11UpgradeReboot" /f 2>nul
del "$markerFile"
del "%~f0"
"@ | Out-File -FilePath $batchPath -Force
    
    # Add a startup registry entry to run the cleanup batch
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    $regName = "Win11UpgradeCleanup"
    $regValue = "cmd.exe /c `"$batchPath`""
    
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType String -Force | Out-Null
    Write-Host "Created registry cleanup entry." -ForegroundColor Green
    
    # Start the Windows 11 Installation Assistant with silent parameters
    Write-Host "Running Windows 11 Installation Assistant... This may take some time." -ForegroundColor Cyan
    Write-Host "DO NOT manually reboot during this process." -ForegroundColor Yellow
    
    # Run the Installation Assistant and wait for it to complete
    # The /quiet parameter makes it run silently, and /norestart prevents automatic restart
    Start-Process -FilePath $installerPath -ArgumentList "/quiet /norestart" -Wait
    
    Write-Host "Windows 11 Installation Assistant has completed the preparation phase." -ForegroundColor Green
    
    # Now that the installer has finished, check if we should reboot
    if (-not (Test-UserLoggedIn)) {
        Write-Host "No users logged in. System will restart automatically in 60 seconds to complete the upgrade." -ForegroundColor Yellow
        Stop-Transcript
        
        # Direct reboot approach - simpler and more reliable after the installation prep is done
        shutdown /r /t 60 /f
    } else {
        Write-Host "Users are currently logged in. Automatic restart is deferred until users log off." -ForegroundColor Yellow
        Write-Host "A restart is required to complete the Windows 11 upgrade." -ForegroundColor Yellow
        Stop-Transcript
    }
}

# Check system requirements
Write-Host "Checking system requirements for Windows 11..." -ForegroundColor Cyan

# Check TPM version
$tpm = Get-WmiObject -Namespace "root\CIMV2\Security\MicrosoftTpm" -Class Win32_Tpm
if ($tpm -and $tpm.SpecVersion -match "2.0") {
    Write-Host "TPM 2.0 is available." -ForegroundColor Green
} else {
    Write-Host "WARNING: TPM 2.0 may not be available. Windows 11 requires TPM 2.0." -ForegroundColor Yellow
}

# Check processor compatibility (basic check)
$processor = Get-WmiObject -Class Win32_Processor
$cpuCompatible = $processor.Name -match "i[3579]|Ryzen|Xeon" -and $processor.NumberOfCores -ge 2
if ($cpuCompatible) {
    Write-Host "Processor appears to be compatible with Windows 11." -ForegroundColor Green
} else {
    Write-Host "WARNING: Processor may not meet Windows 11 requirements." -ForegroundColor Yellow
}

# Check RAM
$ram = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
if ($ram -ge 4) {
    Write-Host "RAM: $ram GB (Sufficient for Windows 11)" -ForegroundColor Green
} else {
    Write-Host "WARNING: Only $ram GB RAM detected. Windows 11 requires at least 4GB." -ForegroundColor Yellow
}

# Check secure boot capability
$secureBootStatus = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
if ($secureBootStatus) {
    Write-Host "Secure Boot is enabled." -ForegroundColor Green
} else {
    Write-Host "WARNING: Secure Boot may not be enabled. Windows 11 requires Secure Boot capability." -ForegroundColor Yellow
}

# Check disk space
$systemDrive = $env:SystemDrive
$freeSpace = [math]::Round((Get-PSDrive $systemDrive.TrimEnd(":")).Free / 1GB)
if ($freeSpace -ge 64) {
    Write-Host "Free disk space: $freeSpace GB (Sufficient for Windows 11)" -ForegroundColor Green
} else {
    Write-Host "WARNING: Only $freeSpace GB free space on $systemDrive. Windows 11 requires at least 64GB of free space." -ForegroundColor Yellow
}

# Ask for confirmation to proceed
Write-Host ""
Write-Host "System check completed. Some warnings may be advisory only." -ForegroundColor Cyan
Write-Host "Would you like to proceed with the Windows 11 upgrade? (Y/N)" -ForegroundColor Yellow
$confirmation = Read-Host

if ($confirmation -eq "Y" -or $confirmation -eq "y") {
    Start-Win11Upgrade
} else {
    Write-Host "Windows 11 upgrade cancelled by user." -ForegroundColor Red
    Stop-Transcript
    Exit 0
}