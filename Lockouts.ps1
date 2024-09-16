# Description: Clears all credentials from the Windows Credential Manager and logs off the current user.

# Path to PsExec (Make sure PsExec is in this location)
$psexecPath = "C:\Path\To\PsExec\PsExec.exe"

# Remote computer name (leave empty for local computer)
$computerName = $env:COMPUTERNAME  # Uses the current computer name

# Function to log the output
function Log-Output {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "$timestamp - $message"
}

# Check if the CredentialManager module is installed
function Check-InstallCredentialManager {
    if (-not (Get-Module -ListAvailable -Name "CredentialManager")) {
        Log-Output "CredentialManager module not found. Installing..."
        try {
            Install-Module -Name CredentialManager -Scope CurrentUser -Force -ErrorAction Stop
            Log-Output "CredentialManager module installed successfully."
        } catch {
            Log-Output "Failed to install CredentialManager module. Error: $_"
            exit 1
        }
    } else {
        Log-Output "CredentialManager module is already installed."
    }
}

# Check if PsExec exists at the specified path
function Check-PsExec {
    if (-not (Test-Path $psexecPath)) {
        Log-Output "PsExec not found at $psexecPath. Please download and place it in the specified path."
        exit 1
    } else {
        Log-Output "PsExec is found at $psexecPath."
    }
}

# Clear all credentials from Windows Credential Manager
function Clear-CredentialManager {
    Log-Output "Listing all stored credentials in the Credential Manager..."

    # List all credentials
    $credentials = Get-StoredCredential -Enumerate

    if ($credentials) {
        Log-Output "Found the following stored credentials:"
        foreach ($cred in $credentials) {
            Log-Output "Target: $($cred.TargetName)"
        }

        Log-Output "Removing all stored credentials..."
        foreach ($cred in $credentials) {
            try {
                # Remove the stored credential
                Remove-StoredCredential -Target $cred.TargetName
                Log-Output "Removed credential: $($cred.TargetName)"
            } catch {
                Log-Output "Failed to remove credential: $($cred.TargetName). Error: $_"
            }
        }
        Log-Output "All stored credentials have been cleared."
    } else {
        Log-Output "No stored credentials found in the Credential Manager."
    }
}

# Function to log off the user
function LogOff-User {
    Log-Output "Logging off the user on the computer: $computerName..."

    # Command to log off the user using PsExec
    $psexecCommand = "& `"$psexecPath`" \\\$computerName -nobanner -accepteula logoff"

    try {
        Invoke-Expression $psexecCommand
        Log-Output "Logoff command executed successfully."
    } catch {
        Log-Output "Failed to log off the user. Error: $_"
    }
}

# Start of the script
Log-Output "Starting Credential Manager cleanup..."

# Check and install dependencies
Check-InstallCredentialManager
Check-PsExec

# Clear credentials and log off the user
Clear-CredentialManager
LogOff-User

Log-Output "Script execution completed."
