#!/bin/bash
# DNS server check script:
# Testing installed DNS servers. Deleting all DNS server not responding.
# If less than 3 DNS servers are set up, set up the server.conf again.
# Prefer Prefered-DNS list and populate with backup DNS list to 5 entries.

# Configuration
working_dns=0
dnsmasq_config="/etc/dnsmasq.d/server.conf"
dig_switch="+short +time=2 +tries=0"
dig_test_url="www.heise.de"

# Backup server.conf
cp $dnsmasq_config $dnsmasq_config.bak

# Prefered-DNS list
prefered_dns=( "85.214.20.141" "74.82.42.42" "194.150.168.168" "84.200.69.80" "91.239.100.100" )
# 85.214.20.141		FoeBud/digitalcourage
# 74.82.42.42		Hurricane Electric
# 194.150.168.168	dns.as250.net
# 84.200.69.80		DNS.WATCH-1
# 91.239.100.100	uncensoreddns.org-1
# 84.200.70.40		DNS.WATCH-2
# 89.233.43.71		uncensoreddns.org-2

# Backup-DNS list. API description: https://api.opennicproject.org/geoip/?help
backup_dns=($(curl -s https://api.opennicproject.org/geoip/?bare))

# Test all DNS servers from server.conf.
# Delete DNS servers that are not responding.
echo "Testing all DNS server from server.conf."
for i in $(cat $dnsmasq_config|grep server|sed 's/server=//'); do
	echo "Check DNS server: $i"
	if [[ ! $(dig $dig_switch @$i $dig_test_url) =~ ^([0-9]{1,3}\.)[0-9]{1,3}$ ]]; then
		echo "No answer from $i. Deleted from server.conf."
		sed -i "/$i/d" $dnsmasq_config	# Delete DNS server without reply
		restart_dnsmasq="yes"	# Restart flag set due to config change
	fi
done

# If there are not at least 3 DNS servers left, then create a new server.conf
if [[ $(cat $dnsmasq_config|wc -l) -lt 3 ]]; then
	echo "List has less than 3 entries. New server.conf is created."
	:> $dnsmasq_config	# Clear server.conf
	# Test Prefered-DNS and add working DNS to server.conf
	for j in "${prefered_dns[@]}"; do
		echo "Check prefered DNS server: $j"
		if [[ $(dig $dig_switch @$j $dig_test_url) =~ ^([0-9]{1,3}\.)[0-9]{1,3}$ ]]; then
			echo "Write prefered DNS server $j to server.conf"
			echo "server=$j" >> $dnsmasq_config # Enter tested DNS servers
			working_dns=$((working_dns+1));
		fi
	done
	# Fill with backup DNS if there are not at least 5 entries.
	backup_dns_count=0
	while [[ $working_dns -lt 5 ]]; do
		echo "Check backup DNS server: ${backup_dns[$backup_dns_count]}"
		if [[ ${backup_dns[$backup_dns_count]} =~ ^([0-9]{1,3}\.)[0-9]{1,3}$ ]]; then
			echo "Write backup DNS server ${backup_dns[$backup_dns_count]} to server.conf"
			echo "server=${backup_dns[$backup_dns_count]}" >> $dnsmasq_config
			working_dns=$((working_dns+1))
			backup_dns_count=$((backup_dns_count+1))
		fi
	done
	restart_dnsmasq="yes"	# Set restart flag for config change
fi

# Restart when config is changed
if [[ $restart_dnsmasq = "yes" ]]; then
	echo "Reload Config to apply changes."
	/usr/sbin/service dnsmasq restart
fi 
