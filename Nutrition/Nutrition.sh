#!/bin/bash

###Nutrition Script
###Script to download student information file, convert it to tab deliminated
###and copy it to Nutrition Software's web server
###NOTE: Updated 08/13/2018. Reworked the logic. Keeping Colwyck and Leach as separate sites now and removing Z calendar students

###Download Cognos file from DOE SFTP
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/nutritionemails-en.csv
exit
EOF


###Delete all Z-calendar (888) students
sed -i '/,888,/d' nutritionemails-en.csv 

###Convert File from comma deliminated to tab deliminated
cat nutritionemails-en.csv | tr "," "\\t" > student.txt


###Copy file to District PrimeroEdge web server
sshpass -f '/home/philmore/.ssh/PESERVER' sftp -- administrator@34999nutr-web.colonial.k12.de.us <<EOF
cd /C:/Data/Files/Incoming/Student
put student.txt
exit
EOF


###Cleanup
rm nutritionemails-en.csv student.txt

