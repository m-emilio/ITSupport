# Windows Update and Winget Automation Script
# This script automates both Windows Update and winget package updates

# Function to check if PSWindowsUpdate module is installed
function Check-PSWindowsUpdateModule {
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Output "PSWindowsUpdate module not found. Installing..."
        Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
        Write-Output "PSWindowsUpdate module installed successfully."
    } else {
        Write-Output "PSWindowsUpdate module already installed."
    }
}

# Function to check if winget is installed
function Check-Winget {
    try {
        $wingetVersion = winget --version
        Write-Output "Winget is installed: $wingetVersion"
        return $true
    } catch {
        Write-Output "Winget is not installed or not in PATH."
        return $false
    }
}

# Function to run Windows Update
function Run-WindowsUpdate {
    Write-Output "Importing PSWindowsUpdate module..."
    Import-Module PSWindowsUpdate
    
    Write-Output "Checking for Windows updates..."
    $updates = Get-WindowsUpdate
    
    if ($updates.Count -eq 0) {
        Write-Output "No Windows updates found."
    } else {
        Write-Output "Found $($updates.Count) updates. Installing..."
        # Install updates, accept all, auto-reboot if needed
        Install-WindowsUpdate -AcceptAll -AutoReboot -Silent
        Write-Output "Windows updates installation complete."
    }
}

# Function to run winget updates
function Run-WingetUpdate {
    Write-Output "Checking for winget application updates..."
    
    # Update all applications, accept source agreements, and run silently
    winget upgrade --all --accept-source-agreements --accept-package-agreements --silent
    
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Winget updates completed successfully."
    } else {
        Write-Output "Winget updates completed with exit code: $LASTEXITCODE"
    }
}

# Main script execution
try {
    # Set execution policy to allow script to run
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    
    # Check and install PSWindowsUpdate module
    Check-PSWindowsUpdateModule
    
    # Run Windows Update
    Run-WindowsUpdate
    
    # Check if winget is available and run updates
    if (Check-Winget) {
        Run-WingetUpdate
    }
    
    Write-Output "All update operations completed."
} catch {
    Write-Error "An error occurred: $_"
}