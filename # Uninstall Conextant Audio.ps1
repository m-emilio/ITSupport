# Ensure script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    exit
}

# Step 1: Uninstall Conexant Smart Audio using more reliable methods
Write-Host "Uninstalling Conexant Smart Audio..." -ForegroundColor Cyan
$conexantApps = Get-Package | Where-Object { $_.Name -match "Conexant|Smart Audio" }
if ($conexantApps) {
    foreach ($app in $conexantApps) {
        Write-Host "Uninstalling $($app.Name)..." -ForegroundColor Green
        $app | Uninstall-Package -Force
        Write-Host "$($app.Name) has been uninstalled." -ForegroundColor Green
    }
} else {
    Write-Host "No Conexant or Smart Audio applications found." -ForegroundColor Yellow
    
    # Fallback to WMI method if Get-Package doesn't find anything
    $wmiApps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "Conexant|Smart Audio" }
    if ($wmiApps) {
        foreach ($app in $wmiApps) {
            $appName = $app.Name
            Write-Host "Uninstalling $appName using WMI method..." -ForegroundColor Green
            $app.Uninstall()
            Write-Host "$appName has been uninstalled." -ForegroundColor Green
        }
    }
}

# Step 2: Remove Conexant-related registry entries
Write-Host "Cleaning registry entries related to Conexant..." -ForegroundColor Cyan
$regKeys = @(
    "HKLM:\SOFTWARE\Conexant",
    "HKLM:\SOFTWARE\WOW6432Node\Conexant",
    "HKCU:\Software\Conexant"
)
foreach ($key in $regKeys) {
    if (Test-Path $key) {
        Write-Host "Removing registry key: $key" -ForegroundColor Green
        try {
            Remove-Item -Path $key -Recurse -Force -ErrorAction Stop
            Write-Host "Registry key removed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to remove registry key: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Registry key not found: $key" -ForegroundColor Yellow
    }
}

# Step 3: Delete any remaining Conexant-related files
Write-Host "Removing Conexant-related files..." -ForegroundColor Cyan
$directories = @(
    "C:\Program Files\Conexant",
    "C:\Program Files (x86)\Conexant",
    "$env:SystemDrive\Conexant"
)
foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Host "Deleting directory: $dir" -ForegroundColor Green
        try {
            Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
            Write-Host "Directory removed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to remove directory: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Directory not found: $dir" -ForegroundColor Yellow
    }
}

# Step 4: Handle Device Manager cleanup
Write-Host "Handling Conexant devices in Device Manager..." -ForegroundColor Cyan

# First approach: Using PnP cmdlets (PowerShell 5.1+)
try {
    $conexantDevices = Get-PnpDevice | Where-Object { $_.FriendlyName -match "Conexant" -and $_.Status -eq "OK" }
    if ($conexantDevices) {
        foreach ($device in $conexantDevices) {
            Write-Host "Disabling device: $($device.FriendlyName)" -ForegroundColor Green
            $device | Disable-PnpDevice -Confirm:$false
            Write-Host "Device disabled successfully." -ForegroundColor Green
        }
    } else {
        Write-Host "No active Conexant devices found with PnP cmdlets." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error using PnP cmdlets: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Falling back to WMI method..." -ForegroundColor Yellow
    
    # Fallback approach: Using WMI (for older PowerShell versions)
    $deviceManager = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceName -match "Conexant" }
    if ($deviceManager) {
        foreach ($driver in $deviceManager) {
            Write-Host "Found Conexant driver: $($driver.DeviceName)" -ForegroundColor Green
            # Note: WMI method doesn't allow direct uninstallation, marking for attention
            Write-Host "Manual removal may be required for: $($driver.DeviceName)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No Conexant drivers found with WMI method." -ForegroundColor Yellow
    }
}

# Step 5: Clean the driver store (advanced)
Write-Host "Cleaning Conexant drivers from driver store..." -ForegroundColor Cyan
try {
    $conexantDrivers = pnputil.exe -e | Select-String "Conexant" -Context 0,3
    if ($conexantDrivers) {
        $driverNames = $conexantDrivers | ForEach-Object {
            if ($_ -match "Published name ?: ?(.+)") {
                $matches[1]
            }
        }
        
        foreach ($driverName in $driverNames) {
            if ($driverName) {
                Write-Host "Removing driver package: $driverName" -ForegroundColor Green
                $result = pnputil.exe -d $driverName
                Write-Host $result -ForegroundColor Green
            }
        }
    } else {
        Write-Host "No Conexant driver packages found in driver store." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error cleaning driver store: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Finish and Restart recommendation
Write-Host "Clean-up completed. Please restart your computer for all changes to take effect." -ForegroundColor Green
$restart = Read-Host "Would you like to restart now? (Y/N)"
if ($restart -eq "Y" -or $restart -eq "y") {
    Restart-Computer -Force
}