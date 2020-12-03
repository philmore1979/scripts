#!/bin/sh
##Script to grab reports from Gsuite about Chromebooks
##Requires that GAM be installed

###Set gam command
gam="/Users/philmore/bin/gam/gam"
###Set Date for file
now=`date +%F`

###
echo "Which type of report would you like?"
echo "A) All Devices"
echo "B) Active Devices"
read CHOICE

###All Devices
if [[ $CHOICE == "A" ]] || [[ $CHOICE == "a" ]]; then
	$gam print cros fields status,lastsync,serialnumber,recentUsers listlimit 1 > cbdatacurrent.csv
	echo "SerialNumber,User,Date,DeviceID,Status" > CBReport-$now.csv
	awk -F',' 'NR>1{print $2","$6","$4","$1","$3}' cbdatacurrent.csv >> CBReport-$now.csv 
	rm cbdatacurrent.csv
###Only Active Devices
elif [[ $CHOICE == "B" ]] || [[ $CHOICE == "b" ]]; then
	$gam print cros fields status,lastsync,serialnumber,recentUsers listlimit 1 > cbdatacurrent.csv
	grep -F ',ACTIVE,' cbdatacurrent.csv > cbdatacurrent_active.csv
	echo "SerialNumber,User,Date,DeviceID" > CBReport_Active-$now.csv
	awk -F',' '{print $2","$6","$4","$1}' cbdatacurrent_active.csv >> CBReport_Active-$now.csv
	rm cbdatacurrent.csv
###Only Active Student Devices
elif [[ $CHOICE == "C" ]] || [[ $CHOICE == "c" ]]; then
	$gam print cros fields status,lastsync,serialnumber,recentUsers listlimit 1 > cbdatacurrent.csv
        grep -F ',ACTIVE,' cbdatacurrent.csv > cbdatacurrent_active.csv	
	cat cbdatacurrent_active.csv | grep '[0-9][0-9][0-9][0-9][0-9][0-9]@colonial.k12.de.us' > cbdatacurrent_activestudent.csv
	echo "SerialNumber,User,Date,DeviceID" > CBReport_ActiveStudents-$now.csv
        awk -F',' '{print $2","$6","$4","$1}' cbdatacurrent_activestudent.csv >> CBReport_ActiveStudents-$now.csv
        rm cbdatacurrent*.csv
###Non-option
else
	echo "You lose, sir! Good Day!!"
fi
echo "Thank you"
