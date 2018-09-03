#!/bin/bash
# File Copy Script
# Script to copy a file to multiple servers

# Intro
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "This script is used to copy a file to multiple servers"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

# Gather Variables
echo "+++++++++++++++++++++++++++++++++++++++"
echo "Please enter your username: "
read USER
echo "Please enter your password: (will not be displayed)" 
read -s PASS
echo ""
echo "Please enter the server list file name: "
read SERVERS
echo "Please enter the name of the file to copy: "
read FILE


# FOR Loop

for SERVERNAME in `cat $SERVERS`; do
    echo "Copying to $SERVERNAME"
    sshpass -p $PASS scp $FILE $USER@$SERVERNAME:
done
