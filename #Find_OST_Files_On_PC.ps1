# Script to find and delete .OST files in user profiles
 
# Set the root path for user profiles (usually C:\Users)
$UserProfileRoot = "C:\Users"
 
# Define the file extension to search for
$FileExtension = "*.ost"
 
# Prompt for confirmation before deleting files
$ConfirmDelete = $true
 
# Get all user profiles
$UserProfiles = Get-ChildItem -Path $UserProfileRoot -Directory | Where-Object {$_.Name -ne "Public" -and $_.Name -ne "Default" -and $_.Name -ne "Default User" -and $_.Name -ne "All Users"}
 
# Loop through each user profile
foreach ($UserProfile in $UserProfiles) {
    $UserProfilePath = $UserProfile.FullName
    Write-Host "Searching in profile: $($UserProfile.Name)"
 
    # Construct the search path
    $SearchPath = Join-Path -Path $UserProfilePath -ChildPath "AppData\Local\Microsoft\Outlook"
 
    # Check if the Outlook folder exists
    if (Test-Path -Path $SearchPath) {
        # Find all .OST files
        $OSTFiles = Get-ChildItem -Path $SearchPath -Filter $FileExtension -File -Recurse -ErrorAction SilentlyContinue
 
        # Loop through each found .OST file
        foreach ($OSTFile in $OSTFiles) {
            Write-Host "Found: $($OSTFile.FullName)"
 
            # Prompt for confirmation if enabled
            if ($ConfirmDelete) {
                $Confirmation = Read-Host "Delete $($OSTFile.FullName)? (Y/N)"
                if ($Confirmation -eq "Y") {
                    try {
                        Remove-Item -Path $OSTFile.FullName -Force
                        Write-Host "Deleted: $($OSTFile.FullName)"
                    }
                    catch {
                        Write-Error "Failed to delete $($OSTFile.FullName): $($_.Exception.Message)"
                    }
 
                }
                else {
                    Write-Host "Skipped: $($OSTFile.FullName)"
                }
            }
            else {
                try {
                    Remove-Item -Path $OSTFile.FullName -Force
                    Write-Host "Deleted: $($OSTFile.FullName)"
                }
                catch {
                    Write-Error "Failed to delete $($OSTFile.FullName): $($_.Exception.Message)"
                }
            }
        }
    }
    else {
        Write-Host "Outlook folder not found in profile: $($UserProfile.Name)"
    }
}
 
Write-Host "Script completed."