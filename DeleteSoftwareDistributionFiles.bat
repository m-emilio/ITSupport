@echo off
:: Stop Windows Update services
net stop wuauserv
net stop bits

:: Delete the files in the SoftwareDistribution\Download folder
echo Deleting files in C:\Windows\SoftwareDistribution\Download...
del /q /s "C:\Windows\SoftwareDistribution\Download\*"

:: Restart Windows Update services
net start wuauserv
net start bits

echo Files deleted successfully.
pause
