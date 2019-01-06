# toogleAirport
Found somewhere 100 years ago.
## Script to the following directory:
/Library/Scripts/toggleAirport.sh
## Set permissions:
sudo chmod 755 /Library/Scripts/toggleAirport.sh
## PLIST to the following directory:
/System/Library/LaunchAgents/com.mine.toggleairport.plist
## Start the service with:
sudo launchctl load /System/Library/LaunchAgents/com.mine.toggleairport.plist
