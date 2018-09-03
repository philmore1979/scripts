#!/bin/bash
# Ping servers
# Script to ping a list of servers to be sure they are accessible
#Global Var
CURRENTDATE=`date "+%m_%d_%y_%H:%M:%S"`
FILENAME="ping-log-$CURRENTDATE"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "This script will ping all of the servers in the file you list."
echo "The output will be available at : $FILENAME"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

# Read in Variables
echo "Please enter the file name containing servers: "
read SERVERS
echo "+++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

# Create log files
touch "$FILENAME"

# For Loop
for SERVERNAME in `cat $SERVERS`; do
    echo "" | tee -a "$FILENAME"
    echo "=======================" | tee -a "$FILENAME" 
    echo $SERVERNAME | tee -a "$FILENAME" 
    ping -c 2 $SERVERNAME 2>&1 | tee -a "$FILENAME"
    echo "======================="
    echo "" | tee -a "$FILENAME"
done
    
