# Disable Teams from starting up for all users
$registryPath = HKLMSOFTWAREMicrosoftWindowsCurrentVersionRun
$registryName = Teams
$registryValue = CUsersuserAppDataLocalMicrosoftTeamsUpdate.exe --processStart Teams.exe
$registryKeyExists = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue

if ($registryKeyExists) {
    Set-ItemProperty -Path $registryPath -Name $registryName -Value  -Force
    Write-Output Teams startup disabled for all users.
} else {
    Write-Output Teams startup is already disabled for all users.
}
