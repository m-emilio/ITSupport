$deviceID = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty IdentifyingNumber
Write-Output "Device ID: $deviceID"
