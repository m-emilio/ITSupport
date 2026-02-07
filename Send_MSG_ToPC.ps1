$computer = "HOSTNAME"
$message = "Hello Test"
$username = ".\administrator"
$password = "PASSWORD"

$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock {
    msg * "$using:message"
}

