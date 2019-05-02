#!/bin/bash

###Script to prepare files for Career Cruising
##Career Cruising is software used by New Castle Elementary for ???
##Files need to be .txt format with Pipe (|) delimited
##Requires Four Files: School.txt, Student.txt, StudentCourses.txt, and CourseCodes.txt

###Start in current path
cd /home/philmore/scripts/CareerCruising

###Download Cognos XLSX file from DOE SFTP
##UPDATE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/rhdiscovery-en.xlsx
exit
EOF

###Convert XLSX file to CSV files
ssconvert -S rhdiscovery-en.xlsx  cc.csv

###Rename CSV files
###Files that do not need to be fixed have final name
###Files that need to be fixed have 'tmp' in the name
mv cc.csv.0 schools.csv
mv cc.csv.1 studentstmp.csv
mv cc.csv.2 teacherstmp.csv
mv cc.csv.3 adminstmp.csv
mv cc.csv.4 sectionstmp.csv
mv cc.csv.5 enrollmentstmp.csv
rm adminstmp.csv schools.csv teacherstmp.csv

###Remove all information that is not relevant to New Castle Elementary
##NOTE: If this software starts being used elsewhere, this will need to be adjusted
##Remove uneeded schools
##Currently, only NCE (340432) is needed
sed -i '/340410/d' studentstmp.csv
sed -i '/340412/d' studentstmp.csv
sed -i '/340418/d' studentstmp.csv
sed -i '/340420/d' studentstmp.csv
sed -i '/340422/d' studentstmp.csv
sed -i '/340427/d' studentstmp.csv
sed -i '/340456/d' studentstmp.csv
sed -i '/340410/d' sectionstmp.csv
sed -i '/340412/d' sectionstmp.csv
sed -i '/340418/d' sectionstmp.csv
sed -i '/340420/d' sectionstmp.csv
sed -i '/340422/d' sectionstmp.csv
sed -i '/340427/d' sectionstmp.csv
sed -i '/340456/d' sectionstmp.csv
sed -i '/340410/d' enrollmentstmp.csv
sed -i '/340412/d' enrollmentstmp.csv
sed -i '/340418/d' enrollmentstmp.csv
sed -i '/340420/d' enrollmentstmp.csv
sed -i '/340422/d' enrollmentstmp.csv
sed -i '/340427/d' enrollmentstmp.csv
sed -i '/340456/d' enrollmentstmp.csv

##Remove unneeded grades 
##Currently, program is used for 2nd - 5th Grade
sed -i '/,1,/d' sectionstmp.csv
sed -i '/,Kindergarten,/d' sectionstmp.csv
sed -i '/,1,/d' studentstmp.csv
sed -i '/,Kindergarten,/d' studentstmp.csv
sed -i '/Kindergarten-1/d' sectionstmp.csv
sed -i '/Kindergarten-1/d' studentstmp.csv

##Create Mapping File -> Course Name to Course Code
awk -F',' 'NR>1{print $2","$4}' sectionstmp.csv > coursemapping.csv

###School.txt
##For one school, it's easier to just create the file manually
##If this software expands, this part will need to be reworked
echo "SchoolCode|Name|SchoolType" > School.txt
echo "340432|New Castle Elementary|2" >> School.txt

###Student.txt
##Create Final file with correct headers
echo "StudentID,FirstName,LastName,Gender,DateOfBirth,CurrentGrade,CurrentSchoolCode,PreRegSchoolCode,StateProvNumber,Email,Password" > Student.txt
##Pull data into temp file
awk -F',' 'NR>1{print $2","$6","$4","$8","$9","$7",340432,,DE,"$2"@colonial.k12.de.us,"$9}' studentstmp.csv  >> Student.csv
##Change date in fifth cell to yyyy-mm-dd
awk -F',' -vOFS=',' '
function fail() {
        printf "Bad data at line %d: ", NR
        print
        next
    }
    {
        if (split($5, date, "/") != 3) fail()
        $5 = sprintf("%.4d-%.2d-%.2d", date[3], date[1], date[2])
        print
    }' Student.csv > Student_DOB.csv
##Change date in 11th field to no slashes
awk -F',' -vOFS=',' '
function fail() {
        printf "Bad data at line %d: ", NR
        print
        next
    }
    {
        if (split($11, date, "/") != 3) fail()
        $11 = sprintf("%.2d%.2d%.4d", date[1], date[2], date[3])
        print
    }' Student_DOB.csv >> Student.txt
##Change commas to pipes
sed -i 's/\,/\|/g' Student.txt 

###StudentCourses.txt
##Create Final file with correct headers
echo "StudentID,CourseCode,CourseName,GradeLevel,GradeMark,CreditValue,DateCourseComplete" > StudentCourse.txt
##Create temp file with data
awk -F',' 'NR>1{print $3","$2","$2",,0,0,2019-06-15"}' enrollmentstmp.csv >> studentcourses.csv
##Use Mapping file to translate course numbers to course names
awk -F',' 'NR==FNR{a[$1]=$2} NR>FNR{$3=a[$3];print}' OFS=',' coursemapping.csv studentcourses.csv >> StudentCourse.txt
##Remove courses that were not needed (K and 1st)
sed -i '/,,,0,0/d' StudentCourse.txt
##Change commas to pipes
sed -i 's/\,/\|/g' StudentCourse.txt


###CourseCodes.txt
echo "SchoolCode,CourseCode,CourseName,CreditValue,GradeLower,GradeUpper" > CourseCodes.txt
awk -F',' 'NR>1{print $1","$2","$4",1,"$5","$5}' sectionstmp.csv >> CourseCodes.txt
sed -i 's/\,/\|/g' CourseCodes.txt


###Cleanup
rm *.csv *.xlsx

