#!/bin/bash

###Script to upload District information to Pearson EasyBridge
###EasyBridge is a single sign-on service used for user/class assignments for Pearson Products
###Requires 7 or 8 files (1 file optional)
###CODE_DISTRICT.txt,SCHOOL.txt,PIF_SECTION.txt,STAFF.txt,STUDENT.txt,PIF_SECTION_STAFF.txt,PIF_SECTION_STUDENT.txt
###CODE_DISTRICT.txt and SCHOOL.txt are created manually once

###Start the script in the correct directory
###This directory has the static files needed for the uploads
###SCHOOL.txt and CODE_DISTRICT.txt
cd /home/philmore/datascripts/Pearson

###Download Cognos XLSX file from DOE SFTP
##UPDATE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
##UPDATE 2: Changed the script so the DOE password is no longer embedded
##Now, it points to a password file
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/clever-en.xlsx
exit
EOF

###Convert XLSX file to CSV files
ssconvert -S clever-en.xlsx clever.csv

###Rename CSV files
###Files that do not need to be fixed have final name
###Files that need to be fixed have 'tmp' in the name
mv clever.csv.0 schoolstmp.csv
mv clever.csv.1 studentstmp.csv
mv clever.csv.2 teacherstmp.csv
mv clever.csv.3 adminstmp.csv
mv clever.csv.4 sectionstmp.csv
mv clever.csv.5 enrollments1.csv
mv clever.csv.6 enrollments2.csv
rm adminstmp.csv schoolstmp.csv 
###Combine the two Enrollment files into one file
###Remove separate Enrollment files
cat enrollments1.csv >> enrollmentstmp.csv
cat enrollments2.csv >> enrollmentstmp.csv
rm enrollments1.csv enrollments2.csv

###Fixing CSV files

##Removing Jim Zimmerman from the teacherstmp.csv file
##His name is formatted in a way that causes issues
##He does not need to be in there anyway
sed -i '/340490-jzimmerman/d' teacherstmp.csv

##PIF_Section
##Create PIF_SECTION file with correct headers
echo "native_section_code,school_code,section_type,section_type_description,date_start,date_end,school_year,course_number,course_name,section_name,section_number" > PIF_SECTION.csv
##Drop all non-math sections
sed -i '/Math/!d' sectionstmp.csv
##Pull Data from sectionstmp.csv and put into proper cells
awk -F',' 'NR>1{print $2","$1",,,2018-08-27,2019-06-07,2018,"$6","$4","$4","$2}' sectionstmp.csv >> PIF_SECTION.csv

##STAFF
##Create STAFF file with correct headers
echo "staff_code,last_name,first_name,middle_name,email,title,staff_number,username,password,federated_id" > STAFF.csv 
##Pull Data from teacherstmp.csv and put into proper cells
awk -F',' 'NR>1{print $2","$7","$5","$6","$4",,"$2","$4",,"$4}' teacherstmp.csv >> staff_emailsupper.csv
##Fix emails so that they are all lowercase
awk -F, '{$10=tolower($10);print}' OFS="," staff_emailsupper.csv > staff_lower1.csv
awk -F, '{$8=tolower($8);print}' OFS="," staff_lower1.csv > staff_lower2.csv
awk -F, '{$5=tolower($5);print}' OFS="," staff_lower2.csv >> STAFF.csv
##Remove Temp Teacher file
rm teacherstmp.csv

##STUDENT
##Create STUDENT file with correct headers
echo "student_code,last_name,first_name,middle_name,gender_code,dob,email,student_number,federated_id" > STUDENT.csv
##Pull Data from studentstmp.csv and put into additional temp file 
awk -F',' 'NR>1{print $3","$4","$6","$5","$8",,"$2"@colonial.k12.de.us,"$3","$2"@colonial.k12.de.us"}' studentstmp.csv >> STUDENTtmp.csv
##Fix Password Field and put into final file
awk -F'/' '{print $1$2$3}' STUDENTtmp.csv >> STUDENT.csv
##Remove Temp Student Files
rm studentstmp.csv STUDENTtmp.csv

##PIF_SECTION_STAFF
##Create PIF_SECTION_STAFF file with correct headers
echo "section_teacher_code,staff_code,native_section_code,date_start,date_end,school_year,teacher_of_record,teaching_assignment" > PIF_SECTION_STAFF.csv

##Pull Data from sectionstmp.csv and put into proper cells
awk -F',' 'NR>1{print $3"-"$2","$3","$2",2018-08-27,2019-06-07,2018,true,,"}' sectionstmp.csv >> PIF_SECTION_STAFF.csv
##Remove Temp Sections File
rm sectionstmp.csv

##PIF_SECTION_STUDENT
##Create PIF_SECTION_STUDENT file with correct headers
echo "section_student_code,student_code,native_section_code,date_start,date_end,school_year" > PIF_SECTION_STUDENT.csv
##Pull Data from enrollmentstmp.csv and put into proper cells
awk -F',' 'NR>1{print $2"-"$3","$3","$2",2018-08-27,2019-06-07,2018"}' enrollmentstmp.csv >> PIF_SECTION_STUDENT.csv
##Remove Temp Enrollments File
rm enrollmentstmp.csv

###Convert CSV files to TXT using rename command
rename 's/csv/txt/' *.csv

###Create Zip file for upload
zip "Colonial-$(date +"%Y-%m-%d").zip" PIF_SECTION.txt STAFF.txt STUDENT.txt PIF_SECTION_STAFF.txt PIF_SECTION_STUDENT.txt CODE_DISTRICT.txt SCHOOL.txt

###Upload CSV files to Pearson
sshpass -f '/home/philmore/.ssh/PEARSON' sftp 5b6df6cb94c2387ab335b401@sftp.pifdata.net <<EOF
cd SIS
put *.zip
exit
EOF

###Cleanup
rm PIF_SECTION.txt STAFF.txt STUDENT.txt PIF_SECTION_STAFF.txt PIF_SECTION_STUDENT.txt *.zip staff_*.txt
