<#
.SYNOPSIS
Identifies and removes duplicate user profiles from the Windows registry.

.DESCRIPTION
This script scans the Windows registry for user profiles, identifies potential duplicates,
and allows the user to interactively remove them after confirmation. It includes safety 
features such as administrator privilege verification, registry backup, and detailed 
profile information display before any action is taken.

.NOTES
- Requires administrator privileges to run
- Use with caution as removing profiles can affect system operation
- Always review profile information before confirming removal

.EXAMPLE
.\Remove-DuplicateProfiles.ps1
#>

#Requires -RunAsAdministrator

function Test-Administrator {
    <#
    .SYNOPSIS
    Checks if the current PowerShell session is running with administrator privileges.
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Backup-RegistryKey {
    <#
    .SYNOPSIS
    Creates a backup of the specified registry key.

    .PARAMETER Path
    The registry path to backup.

    .PARAMETER BackupFile
    The file path where the backup will be saved.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $true)]
        [string]$BackupFile
    )
    
    try {
        $null = reg export $Path $BackupFile /y
        Write-Host "Registry backup created at: $BackupFile" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to create registry backup: $_" -ForegroundColor Red
        return $false
    }
}

function Get-UserProfiles {
    <#
    .SYNOPSIS
    Retrieves all user profiles from the Windows registry.
    #>
    $profileListPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    
    try {
        $profiles = Get-ChildItem -Path $profileListPath -ErrorAction Stop
        Write-Host "Found $($profiles.Count) profiles in the registry." -ForegroundColor Cyan
        return $profiles
    }
    catch {
        Write-Host "Error accessing profile information: $_" -ForegroundColor Red
        return $null
    }
}

function Get-ProfileDetails {
    <#
    .SYNOPSIS
    Extracts and returns detailed information about a user profile.

    .PARAMETER ProfileKey
    The registry key object representing a user profile.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryKey]$ProfileKey
    )
    
    try {
        $sid = Split-Path -Path $ProfileKey.Name -Leaf
        $profileImagePath = $ProfileKey.GetValue("ProfileImagePath")
        $profileState = $ProfileKey.GetValue("State")
        $lastWriteTime = $ProfileKey.LastWriteTime
        
        # Extract username from path
        $username = $null
        if ($profileImagePath -match "\\([^\\]+)$") {
            $username = $matches[1]
        }
        
        return [PSCustomObject]@{
            SID = $sid
            Username = $username
            ProfilePath = $profileImagePath
            LastWriteTime = $lastWriteTime
            State = $profileState
            RegistryKey = $ProfileKey.Name
        }
    }
    catch {
        Write-Host "Error retrieving profile details for $($ProfileKey.Name): $_" -ForegroundColor Red
        return $null
    }
}

function Find-DuplicateProfiles {
    <#
    .SYNOPSIS
    Identifies potential duplicate profiles based on username and profile path.

    .PARAMETER Profiles
    An array of profile objects to analyze.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [array]$Profiles
    )
    
    $userProfiles = @{}
    $pathProfiles = @{}
    $duplicates = @()
    
    # Group profiles by username and path
    foreach ($profile in $Profiles) {
        $details = Get-ProfileDetails -ProfileKey $profile
        
        if ($null -ne $details) {
            # Group by username
            if ($null -ne $details.Username) {
                if (-not $userProfiles.ContainsKey($details.Username)) {
                    $userProfiles[$details.Username] = @()
                }
                $userProfiles[$details.Username] += $details
            }
            
            # Group by profile path
            if ($null -ne $details.ProfilePath) {
                if (-not $pathProfiles.ContainsKey($details.ProfilePath)) {
                    $pathProfiles[$details.ProfilePath] = @()
                }
                $pathProfiles[$details.ProfilePath] += $details
            }
        }
    }
    
    # Find duplicate usernames (more than one profile per username)
    foreach ($username in $userProfiles.Keys) {
        if ($userProfiles[$username].Count -gt 1) {
            $duplicates += $userProfiles[$username]
        }
    }
    
    # Find duplicate paths (more than one profile pointing to the same path)
    foreach ($path in $pathProfiles.Keys) {
        if ($pathProfiles[$path].Count -gt 1) {
            # Add only profiles not already added from username duplicates
            foreach ($profile in $pathProfiles[$path]) {
                if ($duplicates -notcontains $profile) {
                    $duplicates += $profile
                }
            }
        }
    }
    
    # Look for .bak or similar profile paths that might be duplicates
    $allProfiles = $Profiles | ForEach-Object { Get-ProfileDetails -ProfileKey $_ }
    foreach ($profile in $allProfiles) {
        if ($null -ne $profile.ProfilePath) {
            if ($profile.ProfilePath -match "\.(bak|old|temp)$" -or $profile.ProfilePath -match "\.000$") {
                if ($duplicates -notcontains $profile) {
                    $duplicates += $profile
                }
            }
        }
    }
    
    return $duplicates | Sort-Object -Property Username
}

function Remove-UserProfile {
    <#
    .SYNOPSIS
    Removes a user profile from the Windows registry after confirmation.

    .PARAMETER ProfileDetails
    An object containing details about the user profile to remove.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$ProfileDetails
    )
    
    # Display profile information
    Write-Host "`nProfile Details:" -ForegroundColor Yellow
    Write-Host "SID:          $($ProfileDetails.SID)" -ForegroundColor Cyan
    Write-Host "Username:     $($ProfileDetails.Username)" -ForegroundColor Cyan
    Write-Host "Profile Path: $($ProfileDetails.ProfilePath)" -ForegroundColor Cyan
    Write-Host "Last Write:   $($ProfileDetails.LastWriteTime)" -ForegroundColor Cyan
    Write-Host "State:        $($ProfileDetails.State)" -ForegroundColor Cyan
    Write-Host "Registry Key: $($ProfileDetails.RegistryKey)" -ForegroundColor Cyan
    
    # Prompt for confirmation
    $confirm = Read-Host "Do you want to remove this profile? (Y/N)"
    
    if ($confirm -eq "Y" -or $confirm -eq "y") {
        try {
            # Remove the registry key
            Remove-Item -Path "Registry::$($ProfileDetails.RegistryKey)" -Recurse -Force
            Write-Host "Profile removed successfully." -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "Failed to remove profile: $_" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "Profile removal skipped." -ForegroundColor Yellow
        return $false
    }
}

# Main script execution
function Main {
    Write-Host "=============================================" -ForegroundColor Blue
    Write-Host "   Windows User Profile Duplicate Remover    " -ForegroundColor Blue
    Write-Host "=============================================" -ForegroundColor Blue
    Write-Host

    # Check for administrator privileges
    if (-not (Test-Administrator)) {
        Write-Host "This script requires administrator privileges to run." -ForegroundColor Red
        Write-Host "Please restart PowerShell as an administrator and try again." -ForegroundColor Red
        return
    }
    
    # Create a backup of the ProfileList registry key
    $backupPath = Join-Path -Path $env:TEMP -ChildPath "ProfileList_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
    $backupSuccess = Backup-RegistryKey -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -BackupFile $backupPath
    
    if (-not $backupSuccess) {
        $continueWithoutBackup = Read-Host "Failed to create a backup. Do you want to continue without a backup? (Y/N)"
        if ($continueWithoutBackup -ne "Y" -and $continueWithoutBackup -ne "y") {
            Write-Host "Operation cancelled by user." -ForegroundColor Yellow
            return
        }
    }
    
    # Get all user profiles
    $profiles = Get-UserProfiles
    if ($null -eq $profiles) {
        Write-Host "Unable to retrieve user profiles. Exiting." -ForegroundColor Red
        return
    }
    
    # Find potential duplicates
    $duplicates = Find-DuplicateProfiles -Profiles $profiles
    
    if ($duplicates.Count -eq 0) {
        Write-Host "No duplicate profiles found." -ForegroundColor Green
        return
    }
    
    Write-Host "Found $($duplicates.Count) potential duplicate profiles." -ForegroundColor Yellow
    
    # Display warning
    Write-Host "`n⚠️  WARNING ⚠️" -ForegroundColor Red
    Write-Host "Removing user profiles can affect system operation if done incorrectly." -ForegroundColor Red
    Write-Host "Make sure to carefully review each profile before confirming removal." -ForegroundColor Red
    Write-Host "A registry backup has been created at: $backupPath" -ForegroundColor Red
    
    $continueAfterWarning = Read-Host "`nDo you want to continue? (Y/N)"
    if ($continueAfterWarning -ne "Y" -and $continueAfterWarning -ne "y") {
        Write-Host "Operation cancelled by user." -ForegroundColor Yellow
        return
    }
    
    # Process each duplicate
    $removedCount = 0
    foreach ($profile in $duplicates) {
        Write-Host "`n---------------------------------------------" -ForegroundColor Gray
        $removed = Remove-UserProfile -ProfileDetails $profile
        if ($removed) {
            $removedCount++
        }
    }
    
    # Summary
    Write-Host "`n=============================================" -ForegroundColor Blue
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "Total potential duplicates found: $($duplicates.Count)" -ForegroundColor Cyan
    Write-Host "Total profiles removed: $removedCount" -ForegroundColor Cyan
    Write-Host "Registry backup location: $backupPath" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Blue
    
    # Instructions for restoring from backup if needed
    Write-Host "`nIf you need to restore profiles from the backup, you can:" -ForegroundColor Yellow
    Write-Host "1. Double-click the backup file ($backupPath)" -ForegroundColor Yellow
    Write-Host "2. Confirm the registry import when prompted" -ForegroundColor Yellow
}

# Execute the main function
Main

