#!/bin/bash

###Script to prepare files for RH Discovery 
##RH Discovery is an ELA program used by K-3 grade

###Download Cognos XLSX file from DOE SFTP
##UPDATE: At some point before 10/10/2016, DOE changed the config on their SFTP server
##Now, the option -oHostKeyAlgorithms=+ssh-dss is needed
#sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
#get Cognos/clever-en.xlsx
#exit
#EOF
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
rm adminstmp.csv schools.csv

###Combine enrollments files into one file and remove old files
cat enrollments1.csv >> enrollmentstmp.csv
cat enrollments2.csv >> enrollmentstmp.csv
rm enrollments1.csv enrollments2.csv

###Drop all Non-WP Students from the studentstmp.csv file
sed -i '/340490/!d' studentstmp.csv

###Drop all Non Credit Recovery sections from sectionstmp.csv
sed '/Credit Recovery/!d' sectionstmp.csv > crsections.csv

###Drop all Credit Recovery sections 
###and make file that will be used to delete non Credit Recovery in enrollments file
sed '/Credit Recovery/d' sectionstmp.csv > nonCrSections.csv
awk -F',' 'NR>1{print $2}' nonCrSections.csv > nonCrSectionNumbers.csv

###Drop all Non-WP Students from the enrollmentstmp.csv
sed -i '/340490/!d' enrollmentstmp.csv

##For Loop to delete all non Credit Recovery enrollments 
for i in `cat nonCrSectionNumbers.csv`; do
	sed -i "/$i/d" enrollmentstmp.csv
done

###Create mapping for StudentID to Section Number
awk -F',' 'NR>1{print $3","$2}' enrollmentstmp.csv > studentToSectionNumber.csv

###Create file with correct headers
echo "User Name,Password,First Name,Middle Initial,Last Name,Grade,Student Id Number,SIF Provided Student Id,Parent User Name,Parent Password,Gender,Hispanic/Latino,Not Hispanic/Latino,American Indian/Alaskan Native,Asian,Black,Native Hawaiian/Pacific Islander,White,ESL/ESOL/ELL/LEP,Title I Math,Title I Reading,Speech,LD,Physically Challenged,ESE/Special Needs,Attendance Concern,Free or Reduced Lunch,Hearing Impaired,Economically Disadvantaged,Migrant,Continuous Enrollment,Gifted,After School Programs,Intervention,Class Name,Lab Number,Operation Type,Texas SSI" > CLuploadtmp.csv

###Pull data from studentstmp.csv into upload file
awk -F',' 'NR>1{print $2","$9","$6",,"$4","$7","$2",,,,"$8",,,,,,,,,,,,,,,,,,,,,,,,"$2",,,,"}' studentstmp.csv >> CLuploadtmp.csv

###Map SectionIDs to StudentIDs
awk -F',' 'NR==FNR{a[$1]=$2} NR>FNR{$35=a[$35];print}' OFS=',' studentToSectionNumber.csv CLuploadtmp.csv > CLuploadWithSectionNumbers.csv

###Drop lines with Blank SectionID (IE, not in Credit Recovery)
awk -F','  '$35!=""' CLuploadWithSectionNumbers.csv > CLuploadonlyCR.csv

###Change Section Numbers to CL Class names
sed -i 's/1000124240/Period 1/g' CLuploadonlyCR.csv
sed -i 's/1000124241/Period 2/g' CLuploadonlyCR.csv
sed -i 's/1000124242/Period 3/g' CLuploadonlyCR.csv
sed -i 's/1000124243/Period 4/g' CLuploadonlyCR.csv
sed -i 's/1000124244/Period 5/g' CLuploadonlyCR.csv
sed -i 's/1000124245/Period 6/g' CLuploadonlyCR.csv
sed -i 's/1000124246/Period 7/g' CLuploadonlyCR.csv
sed -i 's/1000124247/Period 8/g' CLuploadonlyCR.csv
sed -i 's/1000124248/Period 9/g' CLuploadonlyCR.csv
sed -i 's/1000124249/Period 10/g' CLuploadonlyCR.csv
sed -i 's/1000124250/Period 11/g' CLuploadonlyCR.csv
sed -i 's/1000124251/Period 12/g' CLuploadonlyCR.csv
sed -i 's/1000124252/Period 13/g' CLuploadonlyCR.csv
sed -i 's/1000124253/Period 14/g' CLuploadonlyCR.csv
sed -i 's/1000124254/Period 15/g' CLuploadonlyCR.csv
sed -i 's/1000124255/Period 16/g' CLuploadonlyCR.csv

###Covert DOB from mm/dd/yyyy to mmddyyyy
awk -F'/' '{print $1$2$3}' CLuploadonlyCR.csv > CLuploadWithPasswords.csv

###Create Final File with Headers
echo "User Name,Password,First Name,Middle Initial,Last Name,Grade,Student Id Number,SIF Provided Student Id,Parent User Name,Parent Password,Gender,Hispanic/Latino,Not Hispanic/Latino,American Indian/Alaskan Native,Asian,Black,Native Hawaiian/Pacific Islander,White,ESL/ESOL/ELL/LEP,Title I Math,Title I Reading,Speech,LD,Physically Challenged,ESE/Special Needs,Attendance Concern,Free or Reduced Lunch,Hearing Impaired,Economically Disadvantaged,Migrant,Continuous Enrollment,Gifted,After School Programs,Intervention,Class Name,Lab Number,Operation Type,Texas SSI" > CLupload.csv
###Dump final data into final file
cat CLuploadWithPasswords.csv >> CLupload.csv
###Final Cleanup - taking up the extraordinary classes
sed -i '/1000124349/d' CLupload.csv
sed -i '/1000124353/d' CLupload.csv
sed -i '/1000124355/d' CLupload.csv
sed -i '/1000124359/d' CLupload.csv
sed -i '/1000124361/d' CLupload.csv
sed -i '/1000130713/d' CLupload.csv
sed -i '/1000131214/d' CLupload.csv
sed -i '/1000131883/d' CLupload.csv

###Convert the unix-type csv to a windows-type csv
awk 'sub("$", "\r")' CLupload.csv > WPCreditRecovery.csv


###Delete all files except final
rm CLuploadonlyCR.csv CLuploadtmp.csv CLuploadWithSectionNumbers.csv crsections.csv enrollmentstmp.csv nonCrSectionNumbers.csv nonCrSections.csv sectionstmp.csv studentstmp.csv studentToSectionNumber.csv teacherstmp.csv CLuploadWithPasswords.csv CLupload.csv
