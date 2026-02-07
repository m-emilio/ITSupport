$computer = "misws01-1006"
$message = "Hello Test"
$username = ".\administrator"
$password = "Drowssap1"

$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock {
    msg * "$using:message"
}
