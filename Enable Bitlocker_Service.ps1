# Check if the BitLocker service is already enabled
$service = Get-Service -Name "BDESVC" -ErrorAction SilentlyContinue

if ($service.Status -eq "Running") {
    Write-Output "BitLocker service is already enabled."
}
else {
    # Enable the BitLocker service
    Set-Service -Name "BDESVC" -StartupType Automatic
    Start-Service -Name "BDESVC"
    Write-Output "BitLocker service enabled successfully."
}
