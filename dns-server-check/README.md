# Automatic DNS check for dnsmasq
Check whether the configured DNS servers are responding.
Delete all DNS servers that are not responding.
If less than 3 DNS servers are set up, create a new server.conf.
The DNS servers are selected from 2 lists:
 - First select all DNS servers from the list of preferred DNS servers.
 - If at least 5 DNS servers are not responding, the missing DNS servers will be filled from the list of backup DNS servers.
 
Restart when config is changed
