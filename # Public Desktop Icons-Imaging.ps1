# Define the path for Public Desktop
$publicDesktop = "C:\Users\Public\Desktop"

# Create Acacia IT Ticketing System Shortcut
$shortcutAcacia = (Join-Path $publicDesktop "REPLACE.lnk")
$WshShellAcacia = New-Object -comObject WScript.Shell
$shortcutAcaciaPath = $WshShellREPLACE.CreateShortcut($shortcutREPLACE)
$shortcutAcaciaPath.TargetPath = "https://itsupport.acacianetwork.org"
$shortcutAcaciaPath.Save()

# Create Office.com Shortcut
$shortcutOffice = (Join-Path $publicDesktop "Microsoft Office.lnk")
$WshShellOffice = New-Object -comObject WScript.Shell
$shortcutOfficePath = $WshShellOffice.CreateShortcut($shortcutOffice)
$shortcutOfficePath.TargetPath = "https://Office.com"
$shortcutOfficePath.Save()

# Create Microsoft Password Reset Shortcut
$shortcutPasswordReset = (Join-Path $publicDesktop "Microsoft Password Reset.lnk")
$WshShellPasswordReset = New-Object -comObject WScript.Shell
$shortcutPasswordResetPath = $WshShellPasswordReset.CreateShortcut($shortcutPasswordReset)
$shortcutPasswordResetPath.TargetPath = "https://passwordreset.microsoftonline.com"
$shortcutPasswordResetPath.Save()

# Create LogMeIn123 Shortcut
$shortcutLogMeIn = (Join-Path $publicDesktop "LogMeIn123.lnk")
$WshShellLogMeIn = New-Object -comObject WScript.Shell
$shortcutLogMeInPath = $WshShellLogMeIn.CreateShortcut($shortcutLogMeIn)
$shortcutLogMeInPath.TargetPath = "https://logmein123.com"
$shortcutLogMeInPath.Save()

# Create Office Application Shortcuts
$officeApps = @{
    "Word" = "WINWORD.EXE"
    "Excel" = "EXCEL.EXE"
    "Outlook" = "OUTLOOK.EXE"
    "PowerPoint" = "POWERPNT.EXE"
    "Publisher" = "MSPUB.EXE"
}

foreach ($app in $officeApps.Keys) {
    $shortcutPath = (Join-Path $publicDesktop "$app.lnk")
    $WshShell = New-Object -comObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = (Get-Command $officeApps[$app]).Source
    $shortcut.Save()
}

Write-Host "All shortcuts have been created on the Public Desktop."