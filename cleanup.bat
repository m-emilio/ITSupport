@echo off
echo Starting cleanup process...

:: Delete all files in the %TEMP% folder
echo Deleting files in %TEMP% folder...
del /s /q "%TEMP%\*"
for /d %%p in ("%TEMP%\*.*") do @rd /s /q "%%p" 2>nul

:: Clean up Recycle Bin
echo Emptying Recycle Bin...
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Confirm:$false"

:: Clean up Windows Update files
echo Cleaning up Windows Update files...
Dism.exe /Online /Cleanup-Image /StartComponentCleanup

:: Clean up system temporary files
echo Cleaning up system temporary files...
cleanmgr /sagerun:1

:: Remove old Windows Update files
echo Removing old Windows Update files...
Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore

:: Clean up shutdown cache files
echo Cleaning up shutdown cache files...
del /s /q "C:\Windows\Prefetch\*"

:: Clean up Explorer temporary files
echo Cleaning up Explorer temporary files...
del /s /q "%LocalAppData%\Microsoft\Windows\Explorer\*"

:: Delete offline web pages
echo Deleting offline web pages...
del /s /q "%LocalAppData%\Microsoft\Windows\INetCache\IE\*"

:: Remove cached wallpapers
echo Removing cached wallpapers...
del /s /q "%LocalAppData%\Microsoft\Windows\Themes\CachedFiles\*"

:: Clean up system cache files
echo Cleaning up system cache files...
del /s /q "C:\Windows\SoftwareDistribution\Download\*"

echo Cleanup completed.

:: Prompt user to finish
echo.
echo Press Enter to close this window...
pause >nul