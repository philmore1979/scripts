#!/bin/bash

###InDistrict Server Check
###Script to scan routers and servers from within the District 
###DEPENDENCIES
####Needs NMAP and SSMTP installed
####SSMTP needs to be configured with an SMTP Host

###Starting directory
cd /home/philmore/scripts/InDistrictCheck

###Get Timestamp
Time=$(date)

###Create blank log file
echo "This script ran at $Time" > log

###Define Servers
WEBSERVERS=('34999-inventory.colonial.k12.de.us' 'helpdesk.colonial.k12.de.us' 'jamf.colonial.k12.de.us' '34999-wellness.colonial.k12.de.us')
DHCPSERVERS
ROUTERS
VMHOSTS=(

###See if can connect to VMHOSTS
for i in {159..171}; do 
	nmap -p 22 10.$i.3.30 >> log
done

###Ping Routers
for i in {159..171}; do 
	ping -c 1 10.$i.1.1 >> log
done


###Scan Web Servers to see if up and log it
for i in "${SERVERS[@]}"; do 
	nmap -p 443 $i >> log
done

###Remove annoying start line from report
sed -i '/Starting/d' log

###Look through log and email if not up
if grep -q down log; then
	/usr/bin/mpack -s "We've got problems!" log philmore1979@gmail.com
elif grep -q filtered log; then
	/usr/bin/mpack -s "This is weird!" log philmore1979@gmail.com
else
	echo "All good" | /usr/sbin/ssmtp philmore1979@gmail.com
fi
