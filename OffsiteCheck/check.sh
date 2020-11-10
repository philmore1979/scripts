#!/bin/bash

###OffSite Server Check
###Script to scan network servers from off network 

###Define Servers
SERVERS=('34999-inventory.colonial.k12.de.us' 'helpdesk.colonial.k12.de.us' 'jamf.colonial.k12.de.us' '34999-wellness.colonial.k12.de.us')

###Scan them
for i in "${SERVERS[@]}"; do 
	nmap -p 443 $i
done
