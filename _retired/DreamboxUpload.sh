#!/bin/bash

##Script to Update Dreambox via Clever
##Dreambox is a math program used by the Elementary Schools
##Clever is a single sign-on service used by Dreambox to automate user
##assignments and accounts

###Download Cognos XLSX file from DOE SFTP
sshpass -f '/home/philmore/.ssh/DOE' sftp -- colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/Dreambox-en.xlsx
exit
EOF

###Convert XLSX file to CSV files
ssconvert -S Dreambox-en.xlsx dream.csv

###Rename CSV files to correct names
mv dream.csv.0 schools.csv
mv dream.csv.1 students.csv
mv dream.csv.2 teachers.csv
mv dream.csv.3 sections.csv 
mv dream.csv.4 enrollments.csv

###Upload CSV files to Clever
sftp -- responsible-chalkboard-2639@sftp.clever.com <<EOF
mput *.csv
exit
EOF

###Cleanup
rm schools.csv
rm students.csv
rm teachers.csv
rm sections.csv 
rm enrollments.csv
rm Dreambox-en.xlsx
