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
awk -F',' 'NR>1{print "123"$1",123"$1",\""$3", "$2"\","$6",2"$6",,LIMITED,,,"$10","$7",20190607,,"$1",,,"$6"-"$17",,,,,,"$1"@colonial.k12.de.us"}' nutritionemails-en.csv >> colotemp.csv

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
###Cleaning up AD.csv file
###NOTE: File needs to be manually downloaded from AD and saved as a CSV file
###NOTE 2: EmplID field needs to be 6 digits (with leading zeroes) before starting
###NOTE 3: To be save, making a copy of the ActiveDirectory.csv file to AD.csv
cp ActiveDirectory.csv AD.csv

###Delete Accounts that we are not importing
###09/27/2017 : Not adding Admin, Nutrition, Bus Drivers, Custodians at this time
sed -i '/,"True",/d' AD.csv
sed -i '/Students/d' AD.csv
sed -i '/Users\/Technology Department\/colonial.k12.de.us/d' AD.csv
sed -i '/Users\/colonial.k12.de.us/d' AD.csv
sed -i '/Cafeterias/d' AD.csv
sed -i '/Temp Users\/colonial.k12.de.us/d' AD.csv
sed -i '/SpecialAccounts/d' AD.csv
sed -i '/DSC/d' AD.csv
sed -i '/DCAS/d' AD.csv
sed -i '/Board of Education/d' AD.csv
sed -i '/_NEW HIRES/d' AD.csv
sed -i '/Contractors/d' AD.csv
sed -i '/DTI-Admin/d' AD.csv
sed -i '/BusDrivers_CafeWorkers_Custodians/d' AD.csv
sed -i '/Technology Department/d' AD.csv
sed -i '/Disabled/d' AD.csv
sed -i '/Reading Corp/d' AD.csv
sed -i '/Student Teacher/d' AD.csv
sed -i '/Maintenance\//d' AD.csv #Add in later
sed -i '/\/Transportation\//d' AD.csv #Add in later

###Remove Double Quotes
sed -i 's/\"//g' AD.csv

###Convert OU to School Location
sed -i 's/Business\/Users\/Admin Bldg\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/HR\/Users\/Admin Bldg\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/Operations\/Users\/Admin Bldg\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/Schools\/Users\/Admin Bldg\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/Curriculum and Instruction\/Users\/Admin Bldg\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/Superintendents Office\/Users\/Admin Bldg\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/Student Services\/Users\/Admin Bldg\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/Users\/Admin Bldg\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/Users\/Carrie Downie\/colonial.k12.de.us/COLDOWNIE/g' AD.csv
sed -i 's/Users\/Castle Hills\/colonial.k12.de.us/COLCASTLE/g' AD.csv
sed -i 's/Users\/Pleasantville\/colonial.k12.de.us/COLPLEASNT/g' AD.csv
sed -i 's/Users\/Wilmington Manor\/colonial.k12.de.us/COLWILMMAN/g' AD.csv
sed -i 's/Users\/Southern\/colonial.k12.de.us/COLSOUTHRN/g' AD.csv
sed -i 's/Users\/Kathleen H Wilbur\/colonial.k12.de.us/COLWILBUR/g' AD.csv
sed -i 's/Users\/New Castle Elementary\/colonial.k12.de.us/COLNCELEM/g' AD.csv
sed -i 's/Users\/Eisenberg\/colonial.k12.de.us/COLEISENBG/g' AD.csv
sed -i 's/Users\/Gunning Bedford\/colonial.k12.de.us/COLBEDFORD/g' AD.csv
sed -i 's/Users\/George Read\/colonial.k12.de.us/COLREAD/g' AD.csv
sed -i 's/Users\/McCullough Middle\/colonial.k12.de.us/COLMCCULL/g' AD.csv
sed -i 's/Users\/William Penn\/colonial.k12.de.us/COLPENN/g' AD.csv
sed -i 's/Users\/Wallin\/colonial.k12.de.us/COLPENN/g' AD.csv
sed -i 's/Users\/Leach\/colonial.k12.de.us/COLEISENBG/g' AD.csv #Leach Staff will go to Eisenberg for their books
sed -i 's/Users\/Colwyck\/colonial.k12.de.us/COLEISENBG/g' AD.csv #Colwyck Staff will go to Eisenberg for their books

###Make EmplID 6-digits long
awk -F',' '{ printf "%s,%s,%s,%s,%s,%s,%s,%s,%06i,%s,%s\n" , $1 , $2 , $3 , $4 , $5 , $6 , $7 , $8 , $9 , $10 , $11 }' AD.csv > adulttemp.csv

###Format file to Lib Format
awk -F',' 'NR>1{print "888"$9",888"$9",\""$10", "$8"\","$6",COLSTAFF,,LIMITED,,,,,NEVER,,,,,,,,,,,"$7}' adulttemp.csv > adult.csv

###Remove all staff without an EmplID
sed -i '/,888000000,/d' adult.csv

###Append Adults into the 'colo.csv' file
cat adult.csv >> colo.csv

###Check File for Duplicate Records
sort -u colo.csv -o colo.csv

###Upload CSV files to Div of Lib Server
###File needs to have no extension
mv colo.csv colo
###Connect to server over port 822
sshpass -f '/home/philmore/.ssh/DIVOFLIB' sftp -oPort=822 dela@dela.sirsi.net <<EOF
rm colo
put colo
exit
EOF

###Cleanup
rm -rf adult*.csv nutritionemails-en.csv AD.csv *temp.csv mapping*.csv homeroom-en.csv colo.csv # colo
