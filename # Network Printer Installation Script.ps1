# Network Printer Installation Script
param (
    [string]$PrintServer = "HOSTNAME",
    [string]$PrinterShareName = "SHARENAME",
    [string]$PrinterFriendlyName = "SHARENAME"
)

# Logging function
function Write-Log {
    param([string]$Message)
    Write-Output $Message
}

# Function to add network printer
function Add-NetworkPrinter {
    try {
        # Add the network printer
        Add-Printer -ConnectionName "\\$PrintServer\$PrinterShareName"
        Write-Log "Successfully added network printer: $PrinterShareName"
        return $true
    }
    catch {
        Write-Log "Failed to add printer. Error: $($_.Exception.Message)"
        return $false
    }
}

# Function to verify printer installation
function Test-PrinterInstalled {
    try {
        # Check if printer exists
        $printer = Get-Printer | Where-Object { 
            $_.Name -like "*$PrinterFriendlyName*" -or 
            $_.Name -eq $PrinterShareName 
        }
        
        return ($printer -ne $null)
    }
    catch {
        Write-Log "Error checking printer installation: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
try {
    # Check if printer is already installed
    if (Test-PrinterInstalled) {
        Write-Log "Printer is already installed."
        exit 0
    }
    
    # Attempt to add the printer
    $addResult = Add-NetworkPrinter
    
    # Verify installation
    if ($addResult -and (Test-PrinterInstalled)) {
        Write-Log "Printer successfully installed and verified."
        exit 0
    }
    else {
        Write-Log "Failed to install or verify printer."
        exit 1
    }
}
catch {
    Write-Log "Unexpected error: $($_.Exception.Message)"
    exit 1
}