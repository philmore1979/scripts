#!/bin/bash
# Updater Script
# Script to Update Ubuntu Servers

#Global Var
CURRENTDATE=`date "+%m_%d_%y_%H:%M:%S"`
FILENAME="updater-log-$CURRENTDATE"

# Intro
echo "+++++++++++++++++++++++++++++++++++++++"
echo "This script will update Ubuntu servers"
echo "from a list of servers in a file"
echo "+++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

# Gather Variables
echo "+++++++++++++++++++++++++++++++++++++++"
echo "Please enter your username: "
read USER
echo "Please enter your password: (will not be displayed)" 
read -s PASS
echo ""
echo "Please enter the Ubuntu server list file name: "
read SERVERS
echo "+++++++++++++++++++++++++++++++++++++++"

# Create Log File
touch $FILENAME

# FOR Loop

for SERVERNAME in `cat $SERVERS`; do 
    echo "UPDATING: $SERVERNAME" | tee -a "$FILENAME" 
    sshpass -p $PASS ssh $USER@$SERVERNAME 'sudo apt-get update'
    sshpass -p $PASS ssh $USER@$SERVERNAME 'sudo -S apt-get upgrade -y'
    sshpass -p $PASS ssh $USER@$SERVERNAME 'date > updatetime.log'
    echo "$SERVERNAME - Operation Complete" | tee -a "$FILENAME" 
done
