#!/bin/bash

###Script to Upload Library Users to the Div of Lib###
###
###
##Start script in the correct folder
cd /home/philmore/scripts/DivOfLib

###///Download Student Cognos and Homeroom csv files from DOE SFTP///###
##nutritionemails-en.csv: a report previously used to load students into Nurtition Management System
##homeroom-en.csv: a report that has all of the student homeroom info
##UPDATE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/nutritionemails-en.csv
get Cognos/homeroom-en.csv
exit
EOF

###///Download Staff file from EXTools (AD)///###
###File is generated daily on the server 34999-extools.colonial.k12.de.us
sshpass -f '/home/philmore/.ssh/AD' sftp administrator@34999-extools.colonial.k12.de.us <<EOF
cd /C:/temp
get adout.csv
exit
EOF

###///Create mapping.csv from homerooms-en.csv file///###
###Remove WP students
####NOTE: WP Students will have their emails added to the homeroom field later
sed -i '/340490,/d' homeroom-en.csv
###Special command to ignore the commas within the Quotes
awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{print $5,$3}' homeroom-en.csv > mappingtemp1.csv
###Remove the commas from the mapping temp file
sed -i 's/\"//g' mappingtemp1.csv
###Create the final mapping file
###NOTE:mapping studentID to Homeroom Teacher LastName
awk -F',' 'NR>1{print $1","$2}' mappingtemp1.csv > mapping.csv

###///Create temp CSV File and Add Headers///###
echo ".USER_ID,.USER_ALT_ID.,.NAME.,.USER_LIBRARY.,.USER_PROFILE.,.USER_DEPARTMENT.,.USER_CATEGORY1.,.USER_CATEGORY2.,.USER_CATEGORY3.,.USER_CATEGORY4.,.USER_CATEGORY5.,.USER_PRIV_EXPIRES.,.ATTN.,.STREET.,.CITYSTZIP.,.BLANK.,.ZIP.,.HOMEPHONE.,.BLANK.,.BLANK.,.PERIOD.,.PERIOD.,.EMAIL." > colotemp.csv

##///Student Section///##

###Read Data from Downloaded File and Put in Right Field
awk -F',' 'NR>1{print "123"$1",123"$1",\""$3", "$2"\","$6",2"$6",,LIMITED,,,"$10","$7",20200515,,"$1",,,"$6"-"$17",,,,,,"$1"@colonial.k12.de.us"}' nutritionemails-en.csv >> colotemp.csv

###Substitute Teacher Name for StudentID in Row Q
awk -F',' 'NR==FNR{a[$1]=$2} NR>FNR{$15=a[$15];print}' OFS=',' mapping.csv colotemp.csv > colo.csv

###Change School Number to Proper School Code
sed -i 's/,410,/,COLDOWNIE,/g' colo.csv
sed -i 's/,412,/,COLCASTLE,/g' colo.csv
sed -i 's/,418,/,COLPLEASNT,/g' colo.csv
sed -i 's/,420,/,COLWILMMAN,/g' colo.csv
sed -i 's/,427,/,COLSOUTHRN,/g' colo.csv
sed -i 's/,422,/,COLWILBUR,/g' colo.csv
sed -i 's/,432,/,COLNCELEM,/g' colo.csv
sed -i 's/,456,/,COLEISENBG,/g' colo.csv
sed -i 's/,470,/,COLBEDFORD,/g' colo.csv
sed -i 's/,474,/,COLREAD,/g' colo.csv
sed -i 's/,476,/,COLMCCULL,/g' colo.csv
sed -i 's/,490,/,COLPENN,/g' colo.csv
sed -i 's/,522,/,COLPENN,/g' colo.csv
sed -i 's/,888,/,DELETE,/g' colo.csv
sed -i 's/,514,/,DELETE,/g' colo.csv
sed -i 's/,450,/,DELETE,/g' colo.csv

###Change 2ndary School Number to User Profile
sed -i 's/,2410,/,COLESTU,/g' colo.csv
sed -i 's/,2412,/,COLESTU,/g' colo.csv
sed -i 's/,2418,/,COLESTU,/g' colo.csv
sed -i 's/,2420,/,COLESTU,/g' colo.csv
sed -i 's/,2422,/,COLESTU,/g' colo.csv
sed -i 's/,2427,/,COLESTU,/g' colo.csv
sed -i 's/,2432,/,COLESTU,/g' colo.csv
sed -i 's/,2456,/,COLESTU,/g' colo.csv
sed -i 's/,2470,/,COLMSTU,/g' colo.csv
sed -i 's/,2474,/,COLMSTU,/g' colo.csv
sed -i 's/,2476,/,COLMSTU,/g' colo.csv
sed -i 's/,2490,/,COLHSTU,/g' colo.csv
sed -i 's/,2522,/,COLWSTU,/g' colo.csv

###Change Gender Field to Proper Format
sed -i 's/,F,/,FEMALE,/g' colo.csv
sed -i 's/,M,/,MALE,/g' colo.csv

###Change Grade Field to Proper Format
sed -i 's/,01,/,GRADE-01,/g' colo.csv
sed -i 's/,02,/,GRADE-02,/g' colo.csv
sed -i 's/,03,/,GRADE-03,/g' colo.csv
sed -i 's/,04,/,GRADE-04,/g' colo.csv
sed -i 's/,05,/,GRADE-05,/g' colo.csv
sed -i 's/,06,/,GRADE-06,/g' colo.csv
sed -i 's/,07,/,GRADE-07,/g' colo.csv
sed -i 's/,08,/,GRADE-08,/g' colo.csv
sed -i 's/,09,/,FRESHMAN,/g' colo.csv
sed -i 's/,10,/,SOPHOMORE,/g' colo.csv
sed -i 's/,11,/,JUNIOR,/g' colo.csv
sed -i 's/,12,/,SENIOR,/g' colo.csv
sed -i 's/,KN,/,GRADE-KN,/g' colo.csv

###Remove Leach and 888 Students
sed -i '/,DELETE,/d' colo.csv

##///Staff Section///##
###Cleaning up adout.csv file
###NOTE: EmplID field needs to be 6 digits (with leading zeroes) before starting

###Delete Headers
sed -i '/ActiveDirectory/d' adout.csv
sed -i '/EmployeeID/d' adout.csv
###Delete Accounts that we are not importing
###09/27/2017 : Not adding Admin, Nutrition, Bus Drivers, Custodians at this time
sed -i '/Students/d' adout.csv
sed -i '/Operations/d' adout.csv
sed -i '/Technology/d' adout.csv
sed -i '/Admin/d' adout.csv
sed -i '/Disabled/d' adout.csv
###Delete 'Jrs' (throws off flow)
sed -i '/Jr./d' adout.csv
sed -i '/JR/d' adout.csv
###Remove Double Quotes
sed -i 's/\"//g' adout.csv
###Remove piece of Distinguished Name to leave location
sed -i 's/,DC=colonial,DC=k12,DC=de,DC=us//g' adout.csv
sed -i 's/,OU=Users//g' adout.csv

###Convert OU to School Location
#HighSchool and Wallin
sed -i 's/,OU=William Penn,/,COLPENN,/g' adout.csv
sed -i 's/,OU=Wallin,/,COLPENN,/g' adout.csv #Wallin Staff wil go to WP for their books
#Middle Schools
sed -i 's/,OU=Gunning Bedford,/,COLBEDFORD,/g' adout.csv
sed -i 's/,OU=George Read,/,COLREAD,/g' adout.csv
sed -i 's/,OU=McCullough Middle,/,COLMCCULL,/g' adout.csv
#Elementary Schools
sed -i 's/,OU=Carrie Downie,/,COLDOWNIE,/g' adout.csv
sed -i 's/,OU=Castle Hills,/,COLCASTLE,/g' adout.csv
sed -i 's/,OU=Eisenberg,/,COLEISENBG,/g' adout.csv
sed -i 's/,OU=New Castle Elementary,/,COLNCELEM,/g' adout.csv
sed -i 's/,OU=Pleasantville,/,COLPLEASNT,/g' adout.csv
sed -i 's/,OU=Southern,/,COLSOUTHRN,/g' adout.csv
sed -i 's/,OU=Kathleen H Wilbur,/,COLWILBUR,/g' adout.csv
sed -i 's/,OU=Wilmington Manor,/,COLWILMMAN,/g' adout.csv
#Special Schools
sed -i 's/,OU=Leach,/,COLEISENBG,/g' adout.csv #Leach Staff will go to Eisenberg for their books
sed -i 's/,OU=Colwyck,/,COLEISENBG,/g' adout.csv #Colwyck Staff will go to Eisenberg for their books

###Make EmplID 6-digits long
awk -F',' '{ printf "%06i,%s,%s,%s,%s,%s,%s\n" , $1 , $2 , $3 , $4 , $5 , $6 , $7 }' adout.csv > adulttemp.csv

###Format file to Lib Format
awk -F',' 'NR>1{print "888"$1",888"$1",\""$2", "$3"\","$6",COLSTAFF,,LIMITED,,,,,NEVER,,,,,,,,,,,"$4}' adulttemp.csv > adult.csv

###Remove any staff without an EmplID
sed -i '/,888000000,/d' adult.csv

###Append Adults into the 'colo.csv' file
cat adult.csv >> colo.csv

###Check File for Duplicate Records
sort -u colo.csv -o colo.csv

###Upload CSV files to Div of Lib Server
###File needs to have no extension
mv colo.csv colo
###Remove junk record
sed -i '/.USER_ID/d' colo

###Connect to server over port 822
sshpass -f '/home/philmore/.ssh/DIVOFLIB' sftp -oPort=822 dela@dela.sirsi.net <<EOF
rm colo
put colo
exit
EOF

###Cleanup
rm -rf *.csv # colo
