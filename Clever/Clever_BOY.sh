#!/bin/bash

#NOTE: This script can be used at the very beginning of the year 
# when all of the students/sections are not in the system yet

###Script to upload District information to Clever
###Clever is a single sign-on service used for user/class assignments
###Software that currently uses Clever
##Dreambox
##Think Through Math
##Learning.com
##Mastery Connect
###Requires gnumeric to run correctly (for ssconvert)
###Requires sshpass to run correctly (to give password to DOE server)

###Start in correct folder
cd /home/philmore/scripts/Clever

###Download Cognos XLSX file from DOE SFTP
##UPDATE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
##UPDATE 2: Have changed from having password in the script to calling a file
##with the password.  Talked to DOE to see if we can setup SSHKey auth
sshpass -f /home/philmore/.ssh/DOE sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/clever-en.xlsx
exit
EOF

###Convert XLSX file to CSV files
ssconvert -S clever-en.xlsx clever.csv

###Rename CSV files
###Files that do not need to be fixed have final name
###Files that need to be fixed have 'tmp' in the name
mv clever.csv.0 schools.csv
mv clever.csv.1 studentstmp.csv
mv clever.csv.2 teachers.csv
mv clever.csv.3 adminstmp.csv
mv clever.csv.4 sectionstmp.csv
mv clever.csv.5 enrollmentstmp.csv
rm adminstmp.csv

###Fixing CSV files

##Teacher File
##Change header 'Email' to 'Teacher_email'
sed -i 's/,Email,/,Teacher_email,/g' teachers.csv

##Sections File
##NOTE: Updated 9/1/2018 to include Period field
##Prepend 'School_id' to 'Section_id'
##Change header from 'School_id-Section_id' to 'Section_id'
##Remove 'tmp' file
awk -F',' '{print $1","$1"-"$2","$3","$4","$5","$6","$7","$8}' sectionstmp.csv > sections.csv
sed -i 's/,School_id-Section_id,/,Section_id,/g' sections.csv
rm sectionstmp.csv

##Enrollments File
##Prepend 'School_id' to 'Section_id'
##Change header from 'School_id-Section_id' to 'Section_id'
##Remove 'tmp' file
awk -F',' '{print $1","$1"-"$2","$3}' enrollmentstmp.csv > enrollments.csv
sed -i 's/,School_id-Section_id,/,Section_id,/g' enrollments.csv
rm enrollmentstmp.csv

##Student File
##Extract Student_id, Student_id with '@colonial.k12.de.us', and DOB from studentstmp.csv
awk -F',' '{print $2","$2"@colonial.k12.de.us,"$9}' studentstmp.csv > studentextrainfo.csv
##Change headers to Username, Student_email, and Password
sed -i 's/Student_id,/Username,/g' studentextrainfo.csv
sed -i 's/,Student_id@colonial.k12.de.us,/,Student_email,/g' studentextrainfo.csv
sed -i 's/,DOB/,Password/g' studentextrainfo.csv
##Take '/' out of DOB to create Passwords
awk -F'/' '{print $1$2$3}' studentextrainfo.csv > studentextrainfofixed.csv
##Combine Studentstmp.csv and file with fixed extra information into one
paste -d ',' studentstmp.csv studentextrainfofixed.csv > students.csv
##Remove all tmp files
rm studentstmp.csv studentextrainfo.csv studentextrainfofixed.csv
##Section to force update Student's name
##Used for changes requested by the parents/student
sed -i 's/,West,,Talitha,/,West,,Taye,/g' students.csv


###Upload CSV files to Clever
sftp responsible-chalkboard-2639@sftp.clever.com <<EOF
mput *.csv
exit
EOF

###Cleanup
rm schools.csv students.csv teachers.csv sections.csv enrollments.csv clever-en.xlsx
