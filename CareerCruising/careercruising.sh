#!/bin/bash

###Script to prepare files for Career Cruising
##Career Cruising is software used by New Castle Elementary for ???
##Files need to be .txt format with Pipe (|) delimited
##Requires Four Files: School.txt, Student.txt, StudentCourses.txt, and CourseCodes.txt

###Start in current path
cd /home/philmore/CareerCruising

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

###School.txt
##For one school, it's easier to just create the file manually
##If this software expands, this part will need to be reworked
echo "SchoolCode|Name|SchoolType" > School.txt
echo "340432|New Castle Elementary|2" >> School.txt

###Student.txt
awk -F',' 'NR>1{print $2","$6","$4","$8","$9","$7",340432,,DE,"$2"@colonial.k12.de.us,"$9}' students.tmp >> Student.csv

###StudentCourses.txt
awk -F',' 'NR>1{print $3","$2",,,0,0,2019-06-15"}' >> StudentCourses.csv
###CourseCodes.txt
echo "SchoolCode,CourseCode,CourseName,CreditValue,GradeLower,GradeUpper" > CourseCodes.txt
awk -F',' 'NR>{print $1","$2","$4",1,"$5","$5}' sectionstmp.csv >> CourseCodes.txt
sed -i 's/\,/\|/g' CourseCodes.txt


###Create Mapping File
###File maps Teacher_id to Email
awk -F',' 'NR>1{print $2","$4}' teacherstmp.csv > tchmapping.csv


------------
OLD SECTIONS
###Fixing CSV files

##Group.csv
##Get data from sectionstmp.csv
awk -F',' 'NR>1{print $2","$4","$3","$1}' sectionstmp.csv >> group_tmp.csv
##Map Teacher_id to Email for InstructorLogin
awk -F',' 'NR==FNR{a[$1]=$2} NR>FNR{$3=a[$3];print}' OFS=',' tchmapping.csv group_tmp.csv > group_emails.csv
##Create group.csv file with correct headers
echo "GroupId,GroupName,InstructorLogin,SiteLogin" > group.csv
##Dump data from group_emails.csv to group
cat group_emails.csv >> group.csv


##Student_group.csv
##Create student_group.csv with correct headers
echo "GroupId,StudentLogin" > student_group.csv
##Get data from enrollmentstmp.csv
awk -F',' 'NR>1{print $2","$3}' enrollmentstmp.csv >> student_group.csv
##For Loop to delete all nonELA group 
for i in `cat NonELAIds.csv`; do
	sed -i "/$i/d" student_group.csv
done

##Student.csv
##Create student.csv file with correct headers
echo "Login,FirstName,MiddleInitial,LastName,GradeTrack,InstructorLogin,SiteLogin" > student.csv
##Get data from studentstmp.csv
awk -F',' 'NR>1{print $2","$6","$5","$4","$7","$2","$1}' studentstmp.csv >> student.csv
##Change locations to correct format for RH
sed -i 's/340410/downie/g' student.csv
sed -i 's/340412/CastleHills/g' student.csv
sed -i 's/340456/Eisenberg/g' student.csv
sed -i 's/340418/Pleasantville/g' student.csv
sed -i 's/340432/NewCastle/g' student.csv
sed -i 's/340422/Wilbur/g' student.csv
sed -i 's/340427/SouthernElementary/g' student.csv
##Use Mapping file student_group.csv to convert StudentID in field 6 to GroupID
awk -F',' 'NR==FNR{a[$2]=$1} NR>FNR{$6=a[$6];print}' OFS=',' student_group.csv student.csv > student_w_secIDs.csv
##Use Mapping file group.csv to covert GroupID in field 6 to InstructorLogin
awk -F',' 'NR==FNR{a[$1]=$3} NR>FNR{$6=a[$6];print}' OFS=',' group.csv student_w_secIDs.csv > student_w_instructors.csv
##Finishing up the file
echo "Login,FirstName,MiddleInitial,LastName,GradeTrack,InstructorLogin,SiteLogin" > student.csv
tail -n +2 student_w_instructors.csv >> student.csv

###Cleanup
rm group.csv student*.csv instructor.csv instructor_site.csv *.xlsx
