# Update Whitelisted Apps for Windows 11 Compatibility
[regex]$WhitelistedApps = 'Microsoft.ScreenSketch|Microsoft.Paint3D|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|CanonicalGroupLimited.UbuntuonWindows|Microsoft.MicrosoftStickyNotes|Microsoft.MSPaint|Microsoft.WindowsCamera|.NET|Framework|Microsoft.HEIFImageExtension|Microsoft.ScreenSketch|Microsoft.StorePurchaseApp|Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.DesktopAppInstaller|NewAppForWindows11'

# Add or Modify Windows 11 Specific Registry Keys

# Modify Privacy Settings for Windows 11

# Review and Adjust Scheduled Tasks for Windows 11 Compatibility

# Test and Validate the Script on a Windows 11 Environment

# Document all Changes Made for Clarity and Maintenance

# Initiate Script Functions
Begin-SysPrep
Start-Debloat
Remove-Keys
FixWhitelistedApps
Protect-Privacy
CheckDMWService
CheckInstallService
Write-Output "Finished all tasks."
