# Requires elevation (Runs as Administrator)
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    Start-Process powershell "-ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    exit
}

Write-Host "Starting Cleanup Script..." -ForegroundColor Green

# Define paths to clean
$PathsToClean = @(
    "$env:Temp\*",
    "$env:SystemRoot\Temp\*",
    "$env:SystemRoot\Prefetch\*",
    "$env:LocalAppData\Temp\*",
    "$env:LocalAppData\Microsoft\Windows\WER\ReportQueue\*",
    "$env:LocalAppData\Microsoft\Edge\User Data\Default\Cache\*",
    "$env:LocalAppData\Google\Chrome\User Data\Default\Cache\*"
)

# Log file path for records
$LogFile = "$env:UserProfile\Desktop\CleanupLog.txt"
Write-Output "Cleanup started at $(Get-Date)" | Out-File $LogFile -Encoding utf8 -Append

foreach ($Path in $PathsToClean) {
    if (Test-Path $Path) {
        Write-Host "Cleaning: $Path" -ForegroundColor Yellow
        try {
            Get-ChildItem -Path $Path -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction Stop
            Write-Output "Successfully cleaned: $Path" | Out-File $LogFile -Encoding utf8 -Append
        }
        catch {
            Write-Host "Failed to clean: $Path - $_" -ForegroundColor Red
            Write-Output "Failed to clean: $Path - $_" | Out-File $LogFile -Encoding utf8 -Append
        }
    }
    else {
        Write-Host "Path not found: $Path" -ForegroundColor Gray
        Write-Output "Path not found: $Path" | Out-File $LogFile -Encoding utf8 -Append
    }
}

Write-Host "Cleanup completed successfully!" -ForegroundColor Green
Write-Output "Cleanup completed at $(Get-Date)" | Out-File $LogFile -Encoding utf8 -Append
