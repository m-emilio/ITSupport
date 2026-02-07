function Get-Win11Eligibility {
    # Capture TPM information
    $tpm = Get-CimInstance -Namespace root\cimv2\security\microsofttpm -ClassName win32_tpm

    # If TPM is not present, exit
    If ($null -eq $tpm) {
        Write-Output "Device is not Windows 11 Ready. Trusted Platform Module cannot be found."
        return $false
    }

    # Stores TPM information
    $tpmEnabled = $tpm.IsEnabled_InitialValue
    $tpmActivated = $tpm.IsActivated_InitialValue

    # TPM Version must be 2.0 or higher
    $tpmVer = if ($tpm.SpecVersion -and [int]$tpm.SpecVersion.Substring(0, 1) -ge 2) { $true } else { $false }

    # Primary storage must be larger than 64GB
    $disk = Get-Disk -Number 0
    $diskMax = if ($disk.Size -ge 64000000000) { $true } else { $false }

    # Total RAM capacity must be higher than 4GB
    $totalRam = if ((Get-CimInstance -ClassName CIM_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum -ge 4000000000) { $true } else { $false }

    # Evaluation of the TPM/Drive/Ram
    if ($tpmEnabled -eq $true -and $tpmActivated -eq $true -and $tpmVer -eq $true -and $diskMax -eq $true -and $totalRam -eq $true) {
        return $true
    } else {
        return $false
    }
}

# --! Evaluate Compliance !--
if ([System.Environment]::OSVersion.Version.Major -eq 10 -and [System.Environment]::OSVersion.Version.Minor -eq 0 -and [System.Environment]::OSVersion.Version.Build -ge 22000) {
    Write-Output "Device is already on Windows 11 and compliant. Now exiting."
    Exit 0
}

Write-Output "Device is on a Windows 10 build. Running the Windows 11 Readiness Check to determine eligibility for the Feature Upgrade."
if (Get-Win11Eligibility) {
    Write-Output "Eligibility check passed. Device is Windows 11 Ready. `nFlagging for remediation."
    Exit 2
} else {
    Write-Output "Device did not pass the Windows 11 eligibility check. `nNow exiting."
    Exit 0
}
