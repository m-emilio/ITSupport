# PowerShell script to enable the "File and Printer Sharing (Echo Request - ICMPv4-In)" firewall rule

# Rule name for "File and Printer Sharing (Echo Request - ICMPv4-In)"
$ruleName = "File and Printer Sharing (Echo Request - ICMPv4-In)"

# Retrieve the firewall rule by name
$firewallRule = Get-NetFirewallRule | Where-Object { $_.DisplayName -eq $ruleName }

# Check if the rule exists and enable it if disabled
if ($firewallRule) {
    if ($firewallRule.Enabled -eq 'False') {
        Write-Host "Enabling rule: $ruleName" -ForegroundColor Green
        Enable-NetFirewallRule -Name $firewallRule.Name
    } else {
        Write-Host "Rule is already enabled: $ruleName" -ForegroundColor Yellow
    }
} else {
    Write-Host "Firewall rule '$ruleName' not found!" -ForegroundColor Red
}

Write-Host "Script execution completed." -ForegroundColor Cyan
