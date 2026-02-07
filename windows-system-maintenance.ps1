[CmdletBinding()]
param(
    [switch]$SkipUpgrade,
    [switch]$QuietMode,
    [switch]$CreateRestorePoint,
    [switch]$SkipDiskCleanup
)

# Check Admin Rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run as administrator" -ForegroundColor Red
    exit
}

# Create Restore Point
if ($CreateRestorePoint) {
    try {
        Enable-ComputerRestore -Drive "C:\"
        Checkpoint-Computer -Description "Pre-maintenance" -RestorePointType "MODIFY_SETTINGS"
        Write-Host "Restore point created" -ForegroundColor Green
    } catch {
        Write-Host "Failed: $_" -ForegroundColor Red
    }
}

# Enable ICMP Firewall Rule
$ruleName = "File and Printer Sharing (Echo Request - ICMPv4-In)"
$rule = Get-NetFirewallRule | Where-Object DisplayName -eq $ruleName
if ($rule.Enabled -eq 'False') {
    Enable-NetFirewallRule -Name $rule.Name
    Write-Host "Firewall rule enabled" -ForegroundColor Green
}

# Clear Edge Data
$edgeUserDataPath = "\AppData\Local\Microsoft\Edge\User Data"
Get-ChildItem "C:\Users" -Directory | ForEach-Object {
    $path = Join-Path $_.FullName $edgeUserDataPath
    if (Test-Path $path) {
        Stop-Process -Name *edge* -Force -ErrorAction SilentlyContinue
        Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Update Packages
try {
    Invoke-Expression 'cmd /c "winget upgrade --all --accept-source-agreements --accept-package-agreements"'
} catch {
    Write-Host "Update error: $_" -ForegroundColor Red
}

# Clear Temp Files
@("$env:TEMP", "$env:SystemRoot\Temp", "$env:SystemRoot\Prefetch") | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item "$_\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# System File Check
Start-Process "sfc" -ArgumentList "/scannow" -Wait -NoNewWindow

# Disk Cleanup
if (!$SkipDiskCleanup) {
    Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait
}

# Disable Hibernation
powercfg /hibernate off

# Windows 11 Upgrade
if (!$SkipUpgrade) {
    $UpdateAssistantURL = "https://go.microsoft.com/fwlink/?linkid=2171764"
    $DownloadPath = "C:\Temp\W11Update.exe"
    
    New-Item -ItemType Directory -Path "C:\Temp" -ErrorAction SilentlyContinue
    
    try {
        Invoke-WebRequest -Uri $UpdateAssistantURL -OutFile $DownloadPath
        Start-Process -FilePath $DownloadPath -Wait
        Remove-Item -Path $DownloadPath -Force
    } catch {
        Write-Host "Upgrade error: $_" -ForegroundColor Red
    }
}

Write-Host "Maintenance complete" -ForegroundColor Green