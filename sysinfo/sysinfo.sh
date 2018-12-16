#!/bin/bash
wan=`curl -s http://ipcheck.jojo3171.de`									# External
en0=`ifconfig en0 | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'`	# Ethernet
en1=`ifconfig en1 | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'`	# Wireless
myram=$((`sysctl hw.memsize | awk '{print $2}'`/1048576))
mywan=`if [ $wan != "" ]; then echo $wan; else echo "INACTIVE"; fi`
myen0=`if [ "$en0" != "" ]; then echo "$en0"; else echo "INACTIVE"; fi`
myen1=`if [ "$en1" != "" ]; then echo "$en1"; else echo "INACTIVE"; fi`
mycpu=`sysctl -a | grep "machdep.cpu.brand_string:" | cut -d':' -f2 | sed 's/^ //'`
echo -e "Welcome Jojo!
:+++++++++++++++++++++++: System Data :++++++++++++++++++++++++:
+  Hostname: `hostname`
+  External: `echo $mywan`
+  Ethernet: `echo $myen0`
+  Wireless: `echo $myen1`
+  System:   `system_profiler SPSoftwareDataType|grep "System Version" | sed 's/^[ ]*System Version: //'`
+  Uptime:   `uptime | sed 's/^.*up //'| sed 's/,.*$//'`
+  CPU:      `echo $mycpu`
+  Memory:   `echo $myram MB`
:++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++:"
