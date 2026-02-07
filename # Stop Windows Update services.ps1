# Stop Windows Update services
Stop-Service wuauserv -Force
Stop-Service cryptSvc -Force
Stop-Service bits -Force
Stop-Service msiserver -Force

# Rename the SoftwareDistribution and Catroot2 folders
Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "SoftwareDistribution.old" -Force
Rename-Item -Path "C:\Windows\System32\catroot2" -NewName "Catroot2.old" -Force

# Start Windows Update services
Start-Service wuauserv
Start-Service cryptSvc
Start-Service bits
Start-Service msiserver
