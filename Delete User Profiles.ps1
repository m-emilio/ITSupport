# Define the threshold for inactive days (e.g., 30 days)
$inactiveDays = 30

# Get the list of user profiles
$profiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }

# Get the current date
$currentDate = Get-Date

# Iterate through each user profile
foreach ($profile in $profiles) {
    # Get the last logon date of the user
    $lastLogonDate = $profile.ConvertToDateTime($profile.LastUseTime)

    # Calculate the number of inactive days
    $inactivePeriod = $currentDate.Subtract($lastLogonDate).Days

    # Check if the user is inactive
    if ($inactivePeriod -ge $inactiveDays) {
        # Delete the user profile folder
        Remove-Item -Path $profile.LocalPath -Force -Recurse

        # Remove the user profile from the registry
        $sid = $profile.SID
        $profileKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid"
        Remove-Item -Path $profileKey -Force
        Write-Host "Deleted user profile: $sid"
    }
}
