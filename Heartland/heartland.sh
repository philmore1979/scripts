#!/bin/bash

###Script to Upload Student Data to Heartland(MySchoolBucks)
###Will allow parents to pay student fees with a credit card via secure site
###
##

###Start in correct directory
cd /home/philmore/scripts/Heartland

###Download Student Cognos files from DOE SFTP
##NOTE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/nutritionemails-en.csv
exit
EOF

###Read Data from Downloaded File and Put in Right Field
###Overwrites file if already existing
awk -F',' 'NR>1{print $1","$2","$3","$5","$6","$7",1"}' nutritionemails-en.csv > colonial_myschoolbucks.csv

###Upload Email File back to DOE SFTP
#sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
#put email.csv Uploads/email.csv
#exit
#EOF
