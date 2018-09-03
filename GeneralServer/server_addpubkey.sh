#!/bin/bash
# Add ssh key to servers
# Script to add my public key to servers from a list

# Intro
echo "+++++++++++++++++++++++++++++++++++++++"
echo "This script will copy your public keys to the servers in the list."
echo "+++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

#Gather Variables
echo "+++++++++++++++++++++++++++++++++++++++"
echo "Please enter your username: "
read USER
echo "Please enter your password: (will not be displayed)" 
read -s PASS
echo ""
echo "Please enter the server list file name: "
read SERVERS
echo "Please enter key file name: "
read KEY
echo "+++++++++++++++++++++++++++++++++++++++"

# For Loop
# Going through list of servers

for SERVERNAME in `cat $SERVERS` ; do 
    echo $SERVERNAME
    sshpass -p $PASS ssh $USER@$SERVERNAME mkdir -p .ssh
    cat $KEY | sshpass -p $PASS ssh $USER@$SERVERNAME 'cat >> .ssh/authorized_keys'
done


