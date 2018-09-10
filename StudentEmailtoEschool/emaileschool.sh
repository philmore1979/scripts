#!/bin/bash

###Script to Upload Student Email Address to eSchool
###This allows for greater integration with Clever, Schoology, and Google
###
##

###Start in correct directory
cd /home/philmore/scripts/StudentEmailtoEschool

###Download Student Cognos files from DOE SFTP
##NOTE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/nutritionemails-en.csv
exit
EOF

###Read Data from Downloaded File and Put in Right Field
###Overwrites file if already existing
awk -F',' 'NR>1{print $1","$1"@colonial.k12.de.us"}' nutritionemails-en.csv > email.csv

###Upload Email File back to DOE SFTP
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
put email.csv Uploads/email.csv
exit
EOF
