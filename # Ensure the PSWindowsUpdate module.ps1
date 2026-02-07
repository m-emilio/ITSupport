# Ensure the PSWindowsUpdate module is installed
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
}

# Import the module
Import-Module PSWindowsUpdate

# Check for updates
$updates = Get-WindowsUpdate

# Display the updates found
if ($updates.Count -eq 0) {
    Write-Output "No updates available."
} else {
    Write-Output "The following updates will be installed:"
    $updates | ForEach-Object {
        Write-Output "$($_.Title)"
    }

    # Download and install updates
    Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose
}
