#!/bin/bash
# Modify Sudo - Commands without Password
# Script to add user to the sudoers file and run commands without entering password

# Intro
echo "+++++++++++++++++++++++++++++++++++++++"
echo "This script will modify your sudoers file."
echo "It will add you to the sudoers file with the"
echo "ability to run the following commands without "
echo "entering a password: "
echo "--- apt-get update --"
echo "--- apt-get upgrade -y ---"
echo "--- apt-get dist-upgrade -y ---"
echo "NOTE: you will need to enter your password for every server"
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
echo "+++++++++++++++++++++++++++++++++++++++"

# For Loop
# Going through list of servers

for SERVERNAME in `cat $SERVERS` ; do 
    echo $SERVERNAME
    sshpass -p $PASS ssh $USER@$SERVERNAME 'echo "philmore ALL=(ALL) NOPASSWD: /usr/bin/apt-get update,/usr/bin/apt-get -y,/usr/bin/apt-get -y" > sudomod'
    sshpass -p $PASS ssh $USER@$SERVERNAME 'cat sudomod | sudo -S <<< Chobit5u tee -a /etc/sudoers'
    
done


