$prefix = "SUPHOUSINGLT"
$characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$number_of_names = 10

for ($i = 1; $i -le $number_of_names; $i++) {
    $random_chars = -join ((Get-Random -Count 6 -InputObject $characters).ToLower())
    $computer_name = $prefix + $random_chars
    Write-Output $computer_name
}
