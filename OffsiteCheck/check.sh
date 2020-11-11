#!/bin/bash

###OffSite Server Check
###Script to scan network servers from off network 
###DEPENDENCIES
####Needs NMAP and SSMTP installed
####SSMTP needs to be configured with an SMTP Host

###Starting directory
cd /home/philmore/scripts/OffsiteCheck

###Get Timestamp
Time=$(date)

###Create blank log file
echo "This script ran at $Time" > log

###Define Servers
SERVERS=('34999-inventory.colonial.k12.de.us' 'helpdesk.colonial.k12.de.us' 'jamf.colonial.k12.de.us' '34999-wellness.colonial.k12.de.us')

###Scan Servers to see if up and log it
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
	echo "All good" | /etc/ssmtp philmore1979@gmail.com
fi
