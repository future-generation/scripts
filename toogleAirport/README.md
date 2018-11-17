# toogleAirport
Vor 100 Jahren irgendwo mal gefunden
## Script in folgendes Verzeichnis:
/Library/Scripts/toggleAirport.sh
## Rechte setzen:
sudo chmod 755 /Library/Scripts/toggleAirport.sh
## PLIST in folgendes Verzeichnis:
/System/Library/LaunchAgents/com.mine.toggleairport.plist
## Starten des Dienstes mit:
sudo launchctl load /System/Library/LaunchAgents/com.mine.toggleairport.plist
