###Student Mail User Script###
#This script is used to find all students that are not Mail Users and Make them Mail Users
#Being a mail user with an external SMTP of STUDENTID@colonialschooldistrict.org allows students
#to receive email sent to both @colonial.k12.de.us and @colonialschooldistrict.org

###Finding the students without email addresses in AD 
get-aduser -filter {Enabled -eq $True} -SearchBase "OU=Students,DC=colonial,DC=k12,DC=de,DC=us" -properties * | where {!$_.emailaddress} | select-object samaccountname | export-csv c:\scripts\noemailusers.csv

###Make "Mail Users" from csv
Import-Csv c:\scripts\noemailusers.csv | Foreach-Object{Enable-MailUser -DomainController coldovkdc1.colonial.k12.de.us -Identity $_.sAMAccountName -ExternalEmailAddress ($_.sAMAccountName + '@colonialschooldistrict.org')}

###Hide Students from GAL
###For security, we do not have students visible in the GAL
Import-Csv c:\scripts\noemailusers.csv | Foreach-Object{Set-MailUser -DomainController coldovkdc1.colonial.k12.de.us -Identity $_.sAMAccountName -HiddenFromAddressListsEnabled $true}

