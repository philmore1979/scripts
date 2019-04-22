#!/bin/bash

###Script to create student and staff csv files for Adobe Spark
###
###

###Start in correct directory
cd /home/philmore/scripts/Adobe

###Download Student Cognos files from DOE SFTP
##NOTE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/nutritionemails-en.csv
exit
EOF

##STUDENT CSV FILE SECTION##
###Create student csv file with correct headers
echo "Identity Type,Username,Domain,Email,First Name,Last Name,Country Code,Product Configurations,Admin Roles,Product Configurations Administered,User Groups,User Groups Administered,Products Administered,Developer Access" > adobe_student.csv
###Read Data from Cognos  File and Put in Right Fields in Temp file
awk -F',' 'NR>1{print "Federated ID,"$1"@colonial.k12.de.us,colonial.k12.de.us,"$1"@colonial.k12.de.us,"$2","$3",US,Default Spark with Premium Features for K-12 - 2 GB configuration,,,AllStudents,,,"}' nutritionemails-en.csv >> temp_adobe_student.csv

###Remove Duplicates in Student CSV File and put into final student file
sort -u temp_adobe_student.csv >> adobe_student.csv

##STAFF CSV FILE SECTION##
##TODO

