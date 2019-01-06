#!/bin/bash
# DNS Server Check Script:
# Aktuell eingerichtete DNS-Server prüfen. Löscht alle DNS-Server die nicht antworten.
# Wenn weniger als 3 DNS-Server eingerichtet sind, die server.conf neu einrichten.
# Prefered-DNS bevorzugen und mit Backup-DNS auf 5 Einträge auffüllen.

# Config Daten
working_dns=0
dnsmasq_config="/etc/dnsmasq.d/server.conf"
dig_switch="+short +time=2 +tries=0"
dig_test_url="www.heise.de"

# Backup der aktuellen Config erzeugen
cp $dnsmasq_config $dnsmasq_config.bak

# Prefered-DNS Liste
prefered_dns=( "85.214.20.141" "74.82.42.42" "194.150.168.168" "84.200.69.80" "91.239.100.100" )
# 85.214.20.141		FoeBud/digitalcourage
# 74.82.42.42		Hurricane Electric
# 194.150.168.168	dns.as250.net
# 84.200.69.80		DNS.WATCH-1
# 91.239.100.100	uncensoreddns.org-1
# 84.200.70.40		DNS.WATCH-2
# 89.233.43.71		uncensoreddns.org-2

# Backup-DNS Liste. Api Beschreibung unter: https://api.opennicproject.org/geoip/?help
backup_dns=($(curl -s https://api.opennicproject.org/geoip/?bare))

# Teste alle DNS-Server aus der server.conf.
# DNS-Server die nicht antworten löschen.
echo "Ueberpruefe DNS-Server aus der server.conf."
for i in $(cat $dnsmasq_config|grep server|sed 's/server=//'); do
	echo "Teste DNS-Server: $i"
	if [[ ! $(dig $dig_switch @$i $dig_test_url) =~ ^([0-9]{1,3}\.)[0-9]{1,3}$ ]]; then
		echo "Keine Antwort von $i. Wird aus der server.conf geloescht."
		sed -i "/$i/d" $dnsmasq_config	# DNS-Server ohne Antwort löschen
		restart_dnsmasq="yes"	# Restart Flag für Config Änderung setzen
	fi
done

# Sollten nicht mindestens 3 DNS-Server uebrig bleiben, dann eine neue server.conf erzeugen
if [[ $(cat $dnsmasq_config|wc -l) -lt 3 ]]; then
	echo "Liste hat weniger als 3 Eintraege. Neue server.conf wird erzeugt."
	:> $dnsmasq_config	# server.conf leeren
	# Prefered-DNS testen und funktionierende DNS-Server eintragen
	for j in "${prefered_dns[@]}"; do
		echo "Teste Prefered-DNS-Server: $j"
		if [[ $(dig $dig_switch @$j $dig_test_url) =~ ^([0-9]{1,3}\.)[0-9]{1,3}$ ]]; then
			echo "Uebernehme Prefered-DNS-Server $j in die server.conf"
			echo "server=$j" >> $dnsmasq_config # Getestete DNS-Server eintragen
			working_dns=$((working_dns+1));
		fi
	done
	# Mit Backup-DNS auffüllen, wenn nicht mindestens 5 Einträge vorhanden sind.
	backup_dns_count=0
	while [[ $working_dns -lt 5 ]]; do
		echo "Teste Backup-DNS-Server: ${backup_dns[$backup_dns_count]}"
		if [[ ${backup_dns[$backup_dns_count]} =~ ^([0-9]{1,3}\.)[0-9]{1,3}$ ]]; then
			echo "Uebernehme Backup-DNS-Server ${backup_dns[$backup_dns_count]} in die server.conf"
			echo "server=${backup_dns[$backup_dns_count]}" >> $dnsmasq_config
			working_dns=$((working_dns+1))
			backup_dns_count=$((backup_dns_count+1))
		fi
	done
	restart_dnsmasq="yes"	# Restart Flag für Config Änderung setzen
fi
# Neustart bei Änderung der Config
if [[ $restart_dnsmasq = "yes" ]]; then
	echo "Config neu laden, um Aenderungen zu uebernehmen."
	/usr/sbin/service dnsmasq restart
fi 
