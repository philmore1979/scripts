#!/bin/bash
## Destiny Student File Creation
## Script to create a file suitable for updating the students in Destiny
## Currently, only the Middle Schools use Destiny
## It is slated to be retired soonish

## Download Student File from Cognos
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/nutrition-en.csv
exit
EOF

## Create Destiny File
### Add correct csv file headers
echo "field_siteShortName,field_barcode,field_lastName,field_firstName,field_middleName,field_patronType,field_gender,field_homeroom,field_gradeLevel,field_isTeacher,field_userDefined1,field_birthdate,field_addressPrimaryLine1,field_addressPrimaryLine2,field_addressPrimaryCity,field_addressPrimaryState,field_addressPrimaryZipCode,field_addressPrimaryPhoneNumberPrimary,field_addressPrimaryPhoneNumberSecondary,Status" >Destiny.csv
### Reorganize columns from base file, add extra columns, and add to Destiny file
awk -F',' 'NR>=2 {print $6","$1","$3","$2","$4",Student,"$10","$17","$7",FALSE, ,"$5","$11","$13","$14","$15","$16","$20", ,A"}' nutrition-en.csv >> Destiny.csv
### Remove leading zeroes from student ids
sed -i 's/^0*\([^,]\)/\1/;s/,0*\([^,]\)/,\1/g' Destiny.csv

## Copy file to Destiny server
sshpass -f '/home/philmore/.ssh/DESTINY' sftp -oHostKeyAlgorithms=+ssh-dss philmore@10.5.11.73 <<EOF
put Destiny.csv
exit
EOF

## Cleanup 
rm nutrition-en.csv Destiny.csv
