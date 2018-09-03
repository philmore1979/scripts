#!/bin/bash

#Script to configure Centos 7 as a KVM VMhost
#This script should be run as root
#This script requires one input - a disk location
#For example - /dev/sdx

#Input - needed for LVM creation later in script
DISK1=$1

#Update OS
yum -y  update

#Install KVM Virtualization software
yum -y install qemu-kvm libvirt virt-install bridge-utils

#Start and Enable the Virtualizaton Service
systemctl start libvirtd 
systemctl enable libvirtd 

#Configure LVM for VM Storage

#Wipe any existing data on LVM drive
dd  if=/dev/zero of=$DISK1 bs=1k count=1
blockdev --rereadpt $DISK1

#Initial_ize  Disk for LVM
pvcreate $DISK1 
pvs

#Create Volume Group on Disk
vgcreate virt-mach $DISK1
vgs

#Create Bridge Network Configuration file for br0
echo "DEVICE=br0" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "TYPE=Bridge" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "ONBOOT=YES" >> /etc/sysconfig/network-scripts/ifcfg-br0

#Create Bridge Network Configuration file for br1
echo "DEVICE=br1" >> /etc/sysconfig/network-scripts/ifcfg-br1
echo "TYPE=Bridge" >> /etc/sysconfig/network-scripts/ifcfg-br1
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-br1
echo "ONBOOT=YES" >> /etc/sysconfig/network-scripts/ifcfg-br1

#Remaining Tasks after this script
echo "The following tasks need to be performed after this script runs:"
echo "###############################"
echo "0. REBOOT!!!"
echo "1. Configure one of the network cards to use the bridge connection"
echo "2. Connect to the server via virt-manager (local or remote)"
echo "3. In virt-manager, configure virt-mach VG as a storage pool"
