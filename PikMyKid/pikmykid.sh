#!/bin/bash

###PikMyKid Script
###Script to download student information file and upload to the dismissal software
###NOTE: 10/27/2020 : only being used at Wilbur Elementary

###Download Cognos file from DOE SFTP
###Using the same file as used for Nutrition services
sshpass -f '/home/philmore/.ssh/DOE' sftp -oHostKeyAlgorithms=+ssh-dss colonialdata@ftp.doe.k12.de.us <<EOF
get Cognos/nutritionemails-en.csv
exit
EOF


###Delete all schools except Wilbur Z-calendar (888) students
#dropschools = [410, 412, 420, 427, 432, 450, 456, 470, 474, 476, 490, 514, 522]
for i in 410 412 420 427 432 450 456 470 474 476 490 514 522
 do sed -i '/,$i,/d' nutritionemails-en.csv
done

###Create final file
echo "SchoolCode,FirstName,LastName,Grade,MostUsedPickupMode,BusRoute,AfterSchool,Guardian1FirstName,Guardian1LastName,Guardian1Mobile,Guardian2FirstName,Guardian2LastName,Guardian2Mobile,GuardianEmail,HomeRoom,StudentSchoolID
" > studentrecords.csv
##
awk -F',' '{print $6","$2","$3","$7",,,,"$18","$19","$20",,,,"$22","$17","$1}' nutritionemails-en.csv >> studentrecords.csv



###Copy file to PikMyKid server
#sshpass -f '/home/philmore/.ssh/PESERVER' sftp -- ColonialFTP@ftp.primeroedge.com <<EOF
#cd Student
#put student.txt
#exit
#EOF


###Cleanup
#rm nutritionemails-en.csv studentrecords.csv

