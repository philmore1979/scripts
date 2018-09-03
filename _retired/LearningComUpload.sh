#!/bin/bash

##Script to Update Learning.com via Clever
##Learning.com is a learning site for TechED
##Clever is a single sign-on service used by Dreambox to automate user
##assignments and accounts

###Download Cognos XLSX file from DOE SFTP
##UPDATE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
sshpass '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/Learning-en.xlsx
exit
EOF

###Convert XLSX file to CSV files
ssconvert -S Learning-en.xlsx learn.csv

###Rename CSV files to correct names
mv learn.csv.0 schools.csv
mv learn.csv.1 students.csv
mv learn.csv.2 teachers.csv
mv learn.csv.3 sections.csv 
mv learn.csv.4 enrollments.csv


###Upload CSV files to Clever
sftp -- harmonious-desk-9541@sftp.clever.com <<EOF
mput *.csv
exit
EOF

###Cleanup
rm schools.csv
rm students.csv
rm teachers.csv
rm sections.csv 
rm enrollments.csv
rm Learning-en.xlsx
