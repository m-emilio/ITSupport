Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "& {
winget install --id=GlavSoft.TightVNC -e --accept-package-agreements --accept-source-agreements;
winget install --id=Adobe.Acrobat.Reader.64-bit -e --accept-package-agreements --accept-source-agreements;
winget install --id=Google.Chrome -e --accept-package-agreements --accept-source-agreements;
winget install --id=TeamViewer.TeamViewer -e --accept-package-agreements --accept-source-agreements;
winget install --id=VideoLAN.VLC -e --accept-package-agreements --accept-source-agreements;
winget install --id=Zoom.Zoom -e --accept-package-agreements --accept-source-agreements;
winget install --id=Microsoft.Office -e --accept-package-agreements --accept-source-agreements;
winget install --id=Microsoft.Teams.Free -e --accept-package-agreements --accept-source-agreements
}"'