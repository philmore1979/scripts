#!/bin/bash

###Script to prepare files for RH Discovery 
##RH Discovery is an ELA program used by K-3 grade
##Requires Five files: group.csv, instructor.csv, instructor_site.csv, student.csv, student_group.csv

###Download Cognos XLSX file from DOE SFTP
##UPDATE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/rhdiscovery-en.xlsx
exit
EOF

###Convert XLSX file to CSV files
ssconvert -S rhdiscovery-en.xlsx rhdis.csv

###Rename CSV files
###Files that do not need to be fixed have final name
###Files that need to be fixed have 'tmp' in the name
mv rhdis.csv.0 schools.csv
mv rhdis.csv.1 studentstmp.csv
mv rhdis.csv.2 teacherstmp.csv
mv rhdis.csv.3 adminstmp.csv
mv rhdis.csv.4 sectionstmp.csv
mv rhdis.csv.5 enrollmentstmp.csv
rm adminstmp.csv schools.csv

###Create Mapping File
###File maps Teacher_id to Email
awk -F',' 'NR>1{print $2","$4}' teacherstmp.csv > tchmapping.csv

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
##Change locations to correct format for RH
sed -i 's/340410/downie/g' group.csv
sed -i 's/340412/CastleHills/g' group.csv
sed -i 's/340456/Eisenberg/g' group.csv
sed -i 's/340418/Pleasantville/g' group.csv
sed -i 's/340432/NewCastle/g' group.csv
sed -i 's/340422/Wilbur/g' group.csv
sed -i 's/340427/SouthernElementary/g' group.csv
##Create file for all NON-ELA groups
sed '/English Language/d' group.csv > NonELA.csv
sed -i '/English Langauge/d' NonELA.csv
awk -F',' 'NR>1{print $1}' NonELA.csv > NonELAIds.csv
##Drop all groups that are not ELA
sed -i '/Art"/d' group.csv
sed -i '/Music/d' group.csv
sed -i '/Science/d' group.csv
sed -i '/Education/d' group.csv
sed -i '/Studies/d' group.csv
sed -i '/Tech/d' group.csv
sed -i '/Mathematics/d' group.csv
sed -i '/Educ/d' group.csv
sed -i '/LEARNING/d' group.csv
sed -i '/Library/d' group.csv

##Instructor.csv
##Create instructor.csv file with correct headers
echo "InstructorLogin,FirstName,LastName,PrimarySiteLogin,AdminLevel" > instructor.csv
##Get data from teacherstmp.csv
awk -F',' 'NR>1{print $4","$5","$7","$1",Instructor"}' teacherstmp.csv >> instructor.csv
##Change locations to correct format for RH
sed -i 's/340410/downie/g' instructor.csv
sed -i 's/340412/CastleHills/g' instructor.csv
sed -i 's/340456/Eisenberg/g' instructor.csv
sed -i 's/340418/Pleasantville/g' instructor.csv
sed -i 's/340432/NewCastle/g' instructor.csv
sed -i 's/340422/Wilbur/g' instructor.csv
sed -i 's/340427/SouthernElementary/g' instructor.csv

##Instructor_site.csv
##Create instructor_site.csv file with correct headers
echo "InstructorLogin,SiteLogin" > instructor_site.csv
##Get data from teacherstmp.csv
awk -F',' 'NR>1{print $4","$1}' teacherstmp.csv >> instructor_site.csv
##Change locations to correct format for RH
sed -i 's/340410/downie/g' instructor_site.csv
sed -i 's/340412/CastleHills/g' instructor_site.csv
sed -i 's/340456/Eisenberg/g' instructor_site.csv
sed -i 's/340418/Pleasantville/g' instructor_site.csv
sed -i 's/340432/NewCastle/g' instructor_site.csv
sed -i 's/340422/Wilbur/g' instructor_site.csv
sed -i 's/340427/SouthernElementary/g' instructor_site.csv

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

##Remove all tmp files
rm *tmp.csv tchmapping.csv student_w_*.csv Non*.csv group_emails.csv

###Addition: 10/18/2018
###Adding Coaches as Admins at all sites
###Coach information is in the coachesinstructor.csv file (existing file)
##Remove coaches from Instructor and Instrutor Site files (gets rid of old access)
sed -i '/Boykin/d' instructor.csv
sed -i '/Pankowski/d' instructor.csv
sed -i '/Costa/d' instructor.csv
sed -i '/boykin/d' instructor_site.csv
sed -i '/pankowski/d' instructor_site.csv
sed -i '/boykin/d' instructor.csv
sed -i '/pankowski/d' instructor.csv
sed -i '/Quinn/d' instructor.csv
sed -i '/Franklin/d' instructor.csv
sed -i '/quinn/d' instructor_site.csv
sed -i '/franklin/d' instructor_site.csv
sed -i '/Bufano/d' instructor.csv
sed -i '/bufano/d' instructor_site.csv

##Add Coaches to each site as Admins in instructor.csv
cat coachesinstructor.csv >> instructor.csv
##Add Coaches to instructor_site.csv
awk -F',' 'NR>1{print $1","$4}' coachesinstructor.csv >> instructor_site.csv

###Upload CSV files to Reading Horizon
###RH uses FTPS instead of the more secure SFTP
curl -T "student.csv" -k -u "Colonial-3966:q6qchqFdvtYd" "ftps://api.readinghorizons.com"
curl -T "student_group.csv" -k -u "Colonial-3966:q6qchqFdvtYd" "ftps://api.readinghorizons.com"
curl -T "instructor.csv" -k -u "Colonial-3966:q6qchqFdvtYd" "ftps://api.readinghorizons.com"
curl -T "instructor_site.csv" -k -u "Colonial-3966:q6qchqFdvtYd" "ftps://api.readinghorizons.com"
curl -T "group.csv" -k -u "Colonial-3966:q6qchqFdvtYd" "ftps://api.readinghorizons.com"

###Cleanup
rm group.csv student*.csv instructor.csv instructor_site.csv *.xlsx
