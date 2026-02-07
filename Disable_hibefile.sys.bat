@echo off
REM Disable hibernation to remove hiberfile.sys
powercfg /hibernate off

echo Hibernation has been disabled, and hiberfile.sys has been removed.
pause
