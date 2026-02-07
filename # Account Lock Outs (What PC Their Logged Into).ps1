# Replace 'username' with the target user's username
$username = "kdapaah@promesa.org"

Get-ADComputer -Filter * | ForEach-Object {
    $computer = $_.Name
    $sessions = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer -ErrorAction SilentlyContinue
    if ($sessions) {
        if ($sessions.UserName -like "*$username*") {
            Write-Output "$username is logged into $computer"
        }
    }
}
