# Define the path to the user profiles registry key
$profilesRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

# Get a list of all user profiles on the computer
$profileList = Get-ChildItem $profilesRegistryPath | Where-Object { $_.PSChildName -match "S-1-5-21-\d+-\d+-\d+-\d+$" }

# Get the list of currently logged-in users
$loggedInUsers = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName

# Loop through the user profiles and delete those not currently logged in
foreach ($profile in $profileList) {
    $sid = $profile.PSChildName

    # Check if the profile is currently in use
    if ($loggedInUsers -notcontains "user-$sid") {
        # Delete the registry key for the user profile
        Remove-Item -Path (Join-Path $profilesRegistryPath $sid) -Force -Recurse
        Write-Host "Deleted profile key for $sid"
    } else {
        Write-Host "Profile $sid is currently in use, skipping deletion"
    }
}

# Inform the user when the process is complete
Write-Host "User profile cleanup complete."
