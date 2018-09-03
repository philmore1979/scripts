#!/bin/bash
# Add Servers to Known Hosts File
# Script to add a list of servers to the known hosts file
# Prevents being asked to confirm adding when using new client

# Variables
echo "Please enter your username: "
read $USER
echo "Please enter the file name containing servers: "
read SERVERS
echo "+++++++++++++++++++++++++++++++++++++++++++++++"

# For Loop
for SERVERNAME in `cat $SERVERS`; do
    ssh-keyscan $SERVERNAME >> /home/$USER/.ssh/known_hosts
done
    
