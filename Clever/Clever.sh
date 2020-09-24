#!/bin/bash

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
mv clever.csv.2 teacherstmp.csv
mv clever.csv.3 adminstmp.csv
mv clever.csv.4 sectionstmp.csv
mv clever.csv.5 enrollments1.csv
mv clever.csv.6 enrollments2.csv
rm adminstmp.csv
###Combine the two Enrollment files into one file
###Remove separate Enrollment files
cat enrollments1.csv >> enrollmentstmp.csv
cat enrollments2.csv >> enrollmentstmp.csv
rm enrollments1.csv enrollments2.csv

###Fixing CSV files

##Teacher File
#Setup headers for Teacher file
echo "School_id,Teacher_id,Teacher_number,Teacher_email,First_name,Middle_name,Last_name" > teachers.csv
##Drop Duplicate Teachers
sort -u -t',' -k3,3 teacherstmp.csv >> teachers.csv  
##Remove Principals from Teacher File
##Needed to prevent conflicts with the admin.csv file
sed -i '/douglas.timm@colonial.k12.de.us/Id' teachers.csv ##CDE
sed -i '/teray.ross@colonial.k12.de.us/Id' teachers.csv ##NCE
sed -i '/janissa.nuneville@colonial.k12.de.us/Id' teachers.csv ##CHE
sed -i '/David.Distler@colonial.k12.de.us/Id' teachers.csv ##EIS
sed -i '/jennifer.alexander@colonial.k12.de.us/Id' teachers.csv ##PLV
sed -i '/elizabeth.howell@colonial.k12.de.us/Id' teachers.csv ##WIL
sed -i '/Jeffory.Gibeault@colonial.k12.de.us@colonial.k12.de.us/Id' teachers.csv ##SOU
sed -i '/lindsay.diemidio@colonial.k12.de.us/Id' teachers.csv ##WME
sed -i '/nicholas.wolfe@colonial.k12.de.us/Id' teachers.csv ##GRM
sed -i '/daniel.bartnik@colonial.k12.de.us@colonial.k12.de.us/Id' teachers.csv ##GBM
sed -i '/william.johnston@colonial.k12.de.us/Id' teachers.csv ##MCC
sed -i '/lisa.brewington@colonial.k12.de.us/Id' teachers.csv ##WP
sed -i '/kevin.white@colonial.k12.de.us@colonial.k12.de.us/Id' teachers.csv ##WW
sed -i '/katrina.daniels@colonial.k12.de.us/Id' teachers.csv ##COL
sed -i '/kristina.lamia@colonial.k12.de.us/Id' teachers.csv ##COL
sed -i '/,dmanninga,/d' teachers.csv #Remove extra account
sed -i '/,dmanningb,/d' teachers.csv #Remove extra account
sed -i '/,EKrauss2,/d' teachers.csv # remove extra account

##Remove Tmp teacher file
rm teacherstmp.csv

##Sections File
##NOTE: Updated 9/1/2018 to include Period field
##Prepend 'School_id' to 'Section_id'
##Change header from 'School_id-Section_id' to 'Section_id'
##Remove 'tmp' file
awk -F',' '{print $1","$1"-"$2","$3","$4","$5","$6","$7","$8}' sectionstmp.csv > sections.csv
sed -i 's/,School_id-Section_id,/,Section_id,/g' sections.csv
#Update 11/14/2019
#Need to update Teacher_IDs for Hoban and Haugh to reflect one that wasnt dropped
sed -i 's/,340422-choban,/,340410-choban,/g' sections.csv
sed -i 's/,340427-jhaugh,/,340420-jhaugh,/g' sections.csv
#Remove tmp file
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
##Section to force update Student's name
##Used for changes requested by the parents/student
sed -i 's/,West,,Talitha,/,West,,Taye,/g' students.csv

##Remove all tmp files
rm studentstmp.csv studentextrainfo.csv studentextrainfofixed.csv



###Upload CSV files to Clever
sshpass -f /home/philmore/.ssh/CLEVER sftp responsible-chalkboard-2639@sftp.clever.com <<EOF
mput *.csv
exit
EOF

###Cleanup
rm schools.csv students.csv teachers.csv sections.csv enrollments.csv clever-en.xlsx
