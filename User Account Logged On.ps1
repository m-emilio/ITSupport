$Username = Read-Host -Prompt 'Enter the username'

$DomainControllers = Get-ADDomainController -Filter * | Select-Object -ExpandProperty Name

foreach ($DC in $DomainControllers) {
    $LoggedOnUsers = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $DC).UserName | ForEach-Object { $_ -split '\\' } | Select-Object -Last 1

    foreach ($User in $LoggedOnUsers) {
        if ($User -eq $Username) {
            Write-Output "$Username is logged on to $DC"
        }
    }
}
