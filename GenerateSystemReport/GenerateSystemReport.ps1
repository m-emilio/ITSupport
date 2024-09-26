#PowerShell script that collects system information and saves it to a file 

# Define the output file path
$outputFilePath = "C:\ITSupportReports\SystemInfoReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Create the output directory if it doesn't exist
$outputDirectory = [System.IO.Path]::GetDirectoryName($outputFilePath)
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory
}

# Collect system information
$report = @()

# Computer Name
$report += "Computer Name: $(Get-ComputerInfo | Select-Object -ExpandProperty CsName)"

# OS Version
$report += "Operating System: $(Get-ComputerInfo | Select-Object -ExpandProperty WindowsVersion) $(Get-ComputerInfo | Select-Object -ExpandProperty WindowsBuildLabEx)"

# Memory Information
$memory = Get-WmiObject -Class Win32_ComputerSystem
$report += "Total Physical Memory: $([math]::round($memory.TotalPhysicalMemory / 1GB, 2)) GB"
$report += "Available Physical Memory: $([math]::round($memory.FreePhysicalMemory * 1KB / 1GB, 2)) GB"

# Disk Information
$disks = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3"
foreach ($disk in $disks) {
    $report += "Drive $($disk.DeviceID): $([math]::round($disk.Size / 1GB, 2)) GB Total, $([math]::round($disk.FreeSpace / 1GB, 2)) GB Free"
}

# CPU Information
$cpu = Get-WmiObject -Class Win32_Processor
foreach ($processor in $cpu) {
    $report += "CPU: $($processor.Name), $($processor.NumberOfCores) Cores, $($processor.NumberOfLogicalProcessors) Logical Processors"
}

# Network Information
$networkAdapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'"
foreach ($adapter in $networkAdapters) {
    $report += "Network Adapter: $($adapter.Description)"
    $report += "IP Address(es): $($adapter.IPAddress -join ', ')"
    $report += "MAC Address: $($adapter.MACAddress)"
}

# Output to file
$report | Out-File -FilePath $outputFilePath -Encoding UTF8

Write-Output "System information report has been generated: $outputFilePath"
