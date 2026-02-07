# Log function to output messages
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
}

# Function to check if a process is already installed
function Is-DriverInstalled {
    param (
        [string]$driverName
    )
    # For simplicity, assume a simple check for an existing file or registry check.
    # Add any checks here based on how you verify drivers are installed.
    return $false
}

# Function to run the installer silently and handle user input for failed installs
function Try-RunInstaller {
    param (
        [System.IO.FileInfo]$file,
        [string[]]$switches
    )
    
    foreach ($argsString in $switches) {
        Write-Log "Attempting: $($file.Name) $argsString"
        
        if ($WhatIf) {
            Write-Log "[WhatIf] Would run $($file.Name) $argsString"
            return $true
        }
        
        try {
            # Start the process with silent parameters, no conflicting arguments
            $proc = Start-Process -FilePath $file.FullName -ArgumentList $argsString -Wait -PassThru
            $proc.WaitForExit()  # Wait for process to exit
            $exitCode = $proc.ExitCode

            if ($exitCode -eq 0) {
                Write-Log "Exit code 0 (success)."
                return $true
            } elseif ($exitCode -eq 259) {
                Write-Log "Exit code 259 — process still running, possible UI interaction needed."
                
                # Prompt user to retry or continue
                $userInput = Read-Host "Installer $($file.Name) is waiting for user input (Exit Code 259). Would you like to [R]etry, [C]ontinue, or [S]kip?"

                if ($userInput -eq 'R' -or $userInput -eq 'r') {
                    Write-Log "Retrying installer $($file.Name)..."
                    return Try-RunInstaller -file $file -switches $switches  # Retry the installer
                } elseif ($userInput -eq 'C' -or $userInput -eq 'c') {
                    Write-Log "Continuing to the next installer."
                    return $false  # Continue to next installer
                } elseif ($userInput -eq 'S' -or $userInput -eq 's') {
                    Write-Log "Skipping installer $($file.Name)."
                    return $false  # Skip this installer
                }
            } else {
                Write-Log "Exit code $exitCode."
            }
        } catch {
            Write-Log "Error starting $($file.Name): $_"
        }
    }
    return $false
}

# Main driver installation process
$exeFiles = Get-ChildItem -Path "C:\Users\Administrator\Desktop\Lenovo E14 Gen 7 (Type 21T9, 21TA) Laptops (ThinkPad)" -Filter *.exe
$WhatIf = $false  # Set to $true for testing, to not actually execute the installations

Write-Log "==== Driver install run started $(Get-Date -Format u) ===="

# List existing installed driver packages (if needed for any further logic)
$existingDrivers = @()  # This would normally be populated with existing drivers

Write-Log "Detected $($existingDrivers.Count) existing driver packages."

foreach ($file in $exeFiles) {
    if (Is-DriverInstalled -driverName $file.Name) {
        Write-Log "Driver $($file.Name) is already installed. Skipping..."
        continue
    }

    Write-Log "Processing: $($file.Name)"
    
    # Check for any known installation switches
    $installSwitches = @("/S", "/silent", "/quiet", "/VERYSILENT /NORESTART", "/qn")  # Customize as per your installer switches
    $installationResult = Try-RunInstaller -file $file -switches $installSwitches
    
    if (-not $installationResult) {
        Write-Log "Failed to install $($file.Name) or user chose to skip."
    }
}

Write-Log "==== Driver install run complete $(Get-Date -Format u) ===="
