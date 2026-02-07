# List of package names for apps to remove
$appsToRemove = "Microsoft.3DBuilder",
                "Microsoft.Microsoft3DViewer",
                "Microsoft.Office.OneNote",
                "Microsoft.SkypeApp",
                "Microsoft.MicrosoftSolitaireCollection",
                "Microsoft.StorePurchaseApp",
                "Microsoft.Wallet",
                "Microsoft.People",
                "Microsoft.Xbox.TCUI",
                "Microsoft.XboxGamingOverlay",
                "Microsoft.XboxIdentityProvider",
                "Microsoft.XboxSpeechToTextOverlay",
                "Microsoft.YourPhone"

# Loop through the list of app package names and remove each one
foreach ($app in $appsToRemove) {
    # Check if the app is installed
    if (Get-AppxPackage -Name $app -AllUsers) {
        # If it's installed, remove it
        Write-Host "Removing app package $app..."
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage
    } else {
        # If it's not installed, skip it
        Write-Host "App package $app not found, skipping..."
    }
}

# Optional: remove any additional apps that are specific to your installation
# Example: Remove-AppxPackage Microsoft.ZuneMusic_10.19121.12911.0_x64__8wekyb3d8bbwe
