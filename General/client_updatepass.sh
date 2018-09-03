#!/bin/bash
# Password Changing Script
# Script to change a password on multiple servers

#Global Var
CURRENTDATE=`date "+%m_%d_%y_%H:%M:%S"`
FILENAME="password-log-$CURRENTDATE"

# Intro
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "This script is used to change a user password to multiple servers"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

# Gather Variables
echo "+++++++++++++++++++++++++++++++++++++++"
echo "Please enter your username: "
read USER
echo "Please enter your current password: (will not be displayed)" 
read -s CURRENTPASS
echo ""
echo "Please enter your new password: (will not be displayed)"
read -s NEWPASS1
echo ""
echo "Please re-enter your new password: (will not be displayed)"
read -s NEWPASS2
echo ""
echo "Please enter the server list file name: "
read SERVERS

# Create Log File
touch $FILENAME


# FOR Loop

for SERVERNAME in `cat $SERVERS`; do
    echo "" | tee -a $FILENAME
    echo "==========================================" | tee -a $FILENAME
    echo "Updating Password on Server: $SERVERNAME" | tee -a $FILENAME
    ssh $USER@$SERVERNAME "echo -e '$CURRENTPASS\n$NEWPASS1\n$NEWPASS2' | passwd $USER" 2>&1 | tee -a $FILENAME
    echo "==========================================" | tee -a $FILENAME
    echo "" | tee -a $FILENAME
done
