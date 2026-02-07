# Get the path to the Users folder
$usersPath = [System.IO.Path]::GetFullPath("C:\Users")

# Get a list of all user profiles
$userProfiles = Get-ChildItem -Path $usersPath | Where-Object { $_.PSIsContainer }

# Path to the Edge user data folder
$edgeUserDataFolder = "\AppData\Local\Microsoft\Edge\User Data"

foreach ($profile in $userProfiles) {
    # Construct the full path to the Edge user data folder for each user
    $userEdgeDataPath = Join-Path -Path $profile.FullName -ChildPath $edgeUserDataFolder
    
    # Check if the Edge user data folder exists
    if (Test-Path -Path $userEdgeDataPath) {
        try {
            # Delete the contents of the Edge user data folder
            Remove-Item -Path "$userEdgeDataPath\*" -Recurse -Force
            Write-Output "Cleared Edge user data for $($profile.Name)"
        } catch {
            Write-Output "Failed to clear Edge user data for $($profile.Name): $_"
        }
    } else {
        Write-Output "Edge user data folder not found for $($profile.Name)"
    }
}
