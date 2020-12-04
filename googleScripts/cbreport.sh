#!/bin/sh
##Script to grab reports from Gsuite about Chromebooks
##Requires that GAM be installed

###Set gam command
gam="/Users/philmore/bin/gam/gam"
###Set Date for file
NOW=`date +%F`

###Input for which report to run
echo "Which type of report would you like?"
echo "A) All Devices"
echo "B) Active Status Devices"
echo "C) Active Status Devices Used by Students" 
echo "D) Active Status Student Devices used in the Last 30 days"
echo "E) Active Status Student Devices used in the Last 10 days"
echo "F) Active Status Student Devices used in the Last XX days"
echo "-- "
read CHOICE

###Keep or Delete temp files
echo "Would you like to keep the temp files? (N/y)"
echo "-- " 
read DELTEMP

###Get the newest data from Google
$gam print cros fields status,lastsync,serialnumber,recentUsers listlimit 1 > cbdatacurrent.csv

###All Devices
if [[ $CHOICE == "A" ]] || [[ $CHOICE == "a" ]]; then
	echo "SerialNumber,User,Date,DeviceID,Status" > CBReport-$NOW.csv
	awk -F',' 'NR>1{print $2","$6","$4","$1","$3}' cbdatacurrent.csv >> CBReport-$NOW.csv

###Active Status Devices
elif [[ $CHOICE == "B" ]] || [[ $CHOICE == "b" ]]; then
	grep -F ',ACTIVE,' cbdatacurrent.csv > cbdatacurrent_active.csv
	echo "SerialNumber,User,Date,DeviceID" > CBReport_Active-$NOW.csv
	awk -F',' '{print $2","$6","$4","$1}' cbdatacurrent_active.csv >> CBReport_Active-$NOW.csv

###Active Status Devices Used by Students
elif [[ $CHOICE == "C" ]] || [[ $CHOICE == "c" ]]; then
        grep -F ',ACTIVE,' cbdatacurrent.csv > cbdatacurrent_active.csv	
	cat cbdatacurrent_active.csv | grep '[0-9][0-9][0-9][0-9][0-9][0-9]@colonial.k12.de.us' > cbdatacurrent_activestudent.csv
	echo "SerialNumber,User,Date,DeviceID" > CBReport_ActiveStudents-$NOW.csv
        awk -F',' '{print $2","$6","$4","$1}' cbdatacurrent_activestudent.csv >> CBReport_ActiveStudents-$NOW.csv

###Active Status Devices, Used by Students, Used in last 30 days
elif [[ $CHOICE == "D" ]] || [[ $CHOICE == "d" ]]; then
	grep -F ',ACTIVE,' cbdatacurrent.csv > cbdatacurrent_active.csv
        cat cbdatacurrent_active.csv | grep '[0-9][0-9][0-9][0-9][0-9][0-9]@colonial.k12.de.us' > cbdatacurrent_activestudent.csv
        for i in `seq 0 30`; do 
		DAY=`date -v -"$i"d  +"%F"`
		cat cbdatacurrent_activestudent.csv | grep $DAY >> cbdatacurrent_activestudent30.csv
 	done
	echo "SerialNumber,User,Date,DeviceID" > CBReport_ActiveStudentsLast30-$NOW.csv
        awk -F',' '{print $2","$6","$4","$1}' cbdatacurrent_activestudent30.csv >> CBReport_ActiveStudentsLast30-$NOW.csv	

###Active Status Devices, Used by Students, Used in last 10 days
elif [[ $CHOICE == "E" ]] || [[ $CHOICE == "e" ]]; then
        grep -F ',ACTIVE,' cbdatacurrent.csv > cbdatacurrent_active.csv
        cat cbdatacurrent_active.csv | grep '[0-9][0-9][0-9][0-9][0-9][0-9]@colonial.k12.de.us' > cbdatacurrent_activestudent.csv
        for i in `seq 0 10`; do
                DAY=`date -v -"$i"d  +"%F"`
                cat cbdatacurrent_activestudent.csv | grep $DAY >> cbdatacurrent_activestudent10.csv
        done
        echo "SerialNumber,User,Date,DeviceID" > CBReport_ActiveStudentsLast10-$NOW.csv
        awk -F',' '{print $2","$6","$4","$1}' cbdatacurrent_activestudent10.csv >> CBReport_ActiveStudentsLast10-$NOW.csv

###Active Status Devices, Used by Students, Used in last XX days
elif [[ $CHOICE == "F" ]] || [[ $CHOICE == "f" ]]; then
	echo "How many days back do you want?"
	echo "-- "
	read DAYS
        while [[ $((DAYS)) != $DAYS ]]; do
                echo "Please use a number: "
                read DAYS
        done
	grep -F ',ACTIVE,' cbdatacurrent.csv > cbdatacurrent_active.csv
        cat cbdatacurrent_active.csv | grep '[0-9][0-9][0-9][0-9][0-9][0-9]@colonial.k12.de.us' > cbdatacurrent_activestudent.csv
        for i in `seq 0 $DAYS`; do
                DAY=`date -v -"$i"d  +"%F"`
                cat cbdatacurrent_activestudent.csv | grep $DAY >> cbdatacurrent_activestudent$DAYS.csv
        done
        echo "SerialNumber,User,Date,DeviceID" > CBReport_ActiveStudentsLast$DAYS-$NOW.csv
        awk -F',' '{print $2","$6","$4","$1}' cbdatacurrent_activestudent$DAYS.csv >> CBReport_ActiveStudentsLast$DAYS-$NOW.csv
###Non-option
else
	echo "You lose, sir! Good Day!!"
fi

if [[ $DELTEMP == "Y" ]] || [[ $DELTEMP == "y" ]]; then
	echo "Files Retained"
else
	rm cbdatacurrent*.csv
fi

echo "Thank you"
