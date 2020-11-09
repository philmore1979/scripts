#!/bin/bash

###Script to check if servers are up from home

###Define servers
SERVERS=(helpdesk.colonial.k12.de.us 34999-inventory.colonial.k12.de.us jamf.colonial.k12.de.us 34999-wellness.colonial.k12.de.us)

###Scan servers with nmap
for i in $SERVERS 
do 
    echo $i
    #nmap -p 443 $i
done