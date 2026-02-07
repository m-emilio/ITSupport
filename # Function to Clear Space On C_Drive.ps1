# Function to clear temporary files
function Clear-TempFiles {
    Write-Host "Clearing temporary files..."
    $tempPaths = @("$env:TEMP", "$env:windir\Temp")
    foreach ($tempPath in $tempPaths) {
        Remove-Item "$tempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Temporary files cleared."
}

# Function to clear the Recycle Bin
function Clear-RecycleBin {
    Write-Host "Clearing Recycle Bin..."
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "Recycle Bin cleared."
}

# Function to delete Windows Update cache files
function Clear-WindowsUpdateCache {
    Write-Host "Clearing Windows Update cache..."
    Stop-Service -Name wuauserv -Force
    Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv
    Write-Host "Windows Update cache cleared."
}

# Function to remove old system files (e.g., previous Windows installations)
function Remove-OldSystemFiles {
    Write-Host "Removing old system files..."
    $windowsCleanup = Get-ChildItem "$env:SystemDrive\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
    if ($windowsCleanup) {
        Remove-Item "$env:SystemDrive\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Old system files removed."
    } else {
        Write-Host "No old system files found."
    }
}

# Function to clean up system files using Disk Cleanup tool
function Run-DiskCleanup {
    Write-Host "Running Disk Cleanup tool..."
    Start-Process cleanmgr -ArgumentList "/sagerun:1" -NoNewWindow -Wait
    Write-Host "Disk Cleanup completed."
}

# Run all cleanup functions
Clear-TempFiles
Clear-RecycleBin
Clear-WindowsUpdateCache
Remove-OldSystemFiles
Run-DiskCleanup

Write-Host "Cleanup completed. Space has been freed on the C: drive."
