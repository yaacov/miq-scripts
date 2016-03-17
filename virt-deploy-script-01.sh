#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ "$#" -eq 1 ]
then
  hostname_prefix="$1"
else
  echo "Usage: $0 hostname-prefix"
  exit
fi

echo "Create VMs"
echo "----------"
ip2=$(virt-deploy create "$hostname_prefix"-02.example.com centos-7.1 -o memory=2048 password=pass | grep 'ip address:' | cut -d: -f2)
ip3=$(virt-deploy create "$hostname_prefix"-03.example.com centos-7.1 -o memory=2048 password=pass | grep 'ip address:' | cut -d: -f2)

echo "Edit VMs on etc/hosts"
echo "---------------------"
echo "$ip2    vm-$hostname_prefix-02.example.com vm-$hostname_prefix-02" >> /etc/hosts
echo "$ip3    vm-$hostname_prefix-03.example.com vm-$hostname_prefi"-03" >> /etc/hosts

echo "Start VMs"
echo "---------"
virt-deploy start "$hostname_prefix"-02.example.com-centos-7.1-x86_64
virt-deploy start "$hostname_prefix"-03.example.com-centos-7.1-x86_64
