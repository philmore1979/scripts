#!/bin/bash

awk -F',' '{print $3","$4","$5","$6","$7","$8","$9","$10","$11}' AD.csv > AD2.csv

sed -i '/,"True",/d' AD2.csv
sed -i '/Students/d' AD2.csv
sed -i '/Users\/Technology Department\/colonial.k12.de.us/d' AD2.csv
sed -i '/Users\/colonial.k12.de.us/d' AD2.csv
sed -i '/Cafeterias/d' AD2.csv
sed -i '/Temp Users\/colonial.k12.de.us/d' AD2.csv
sed -i '/SpecialAccounts/d' AD2.csv
sed -i '/DSC/d' AD2.csv
sed -i '/DCAS/d' AD2.csv
sed -i '/Board of Education/d' AD2.csv
sed -i '/_NEW HIRES/d' AD2.csv
sed -i '/Contractors/d' AD2.csv
sed -i '/DTI-Admin/d' AD2.csv
sed -i '/BusDrivers_CafeWorkers_Custodians/d' AD2.csv
sed -i '/Technology Department/d' AD2.csv
sed -i '/Disabled/d' AD2.csv
sed -i '/Reading Corp/d' AD2.csv
sed -i '/Student Teacher/d' AD2.csv
sed -i '/\/Leach\//d' AD2.csv #Need to address with Div of Lib
sed -i '/\/Colwyck\//d' AD2.csv #Need to address with Div of Lib
sed -i '/\/Admin Bldg\//d' AD2.csv #Add in later
sed -i '/Maintenance\//d' AD2.csv #Add in later
sed -i '/\/Transportation\//d' AD2.csv #Add in later

sed -i 's/\"//g' AD2.csv

sed -i 's/Users\/Carrie Downie\/colonial.k12.de.us/COLDOWNIE/g' AD2.csv
sed -i 's/Users\/Castle Hills\/colonial.k12.de.us/COLCASTLE/g' AD2.csv
sed -i 's/Users\/Pleasantville\/colonial.k12.de.us/COLPLEASNT/g' AD2.csv
sed -i 's/Users\/Wilmington Manor\/colonial.k12.de.us/COLWILMMAN/g' AD2.csv
sed -i 's/Users\/Southern\/colonial.k12.de.us/COLSOUTHRN/g' AD2.csv
sed -i 's/Users\/Kathleen H Wilbur\/colonial.k12.de.us/COLWILBUR/g' AD2.csv
sed -i 's/Users\/New Castle Elementary\/colonial.k12.de.us/COLNCELEM/g' AD2.csv
sed -i 's/Users\/Eisenberg\/colonial.k12.de.us/COLEISENBG/g' AD2.csv
sed -i 's/Users\/Gunning Bedford\/colonial.k12.de.us/COLBEDFORD/g' AD2.csv
sed -i 's/Users\/George Read\/colonial.k12.de.us/COLREAD/g' AD2.csv
sed -i 's/Users\/McCullough Middle\/colonial.k12.de.us/COLMCCULL/g' AD2.csv
sed -i 's/Users\/William Penn\/colonial.k12.de.us/COLPENN/g' AD2.csv
sed -i 's/Users\/Wallin\/colonial.k12.de.us/COLPENN/g' AD2.csv

awk -F , '{ printf "%s,%s,%s,%s,%s,%s,%06i,%s,%s\n" , $1 , $2 , $3 , $4 , $5 , $6 , $7 , $8 , $9 }' AD2.csv > adulttemp.csv

awk -F',' 'NR>1{print "888"$7",888"$7",\""$8", "$6"\","$4",COLSTAFF,,FULL,,,,,NEVER,,,,,,,,,,,"$5}' adulttemp.csv > adult.csv

sed -i '/,888000000,/d' adult.csv


