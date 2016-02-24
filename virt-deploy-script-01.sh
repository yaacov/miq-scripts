#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Create VMs"
echo "----------"
ip2=`virt-deploy create test-02.example.com centos-7.1 -o memory=2048 password=pass | grep 'ip address:' | cut -d: -f2`
ip3=`virt-deploy create test-03.example.com centos-7.1 -o memory=2048 password=pass | grep 'ip address:' | cut -d: -f2`

echo "Edit VMs on etc/hosts"
echo "---------------------"
echo "$ip2    vm-test-02.example.com vm-test-02" >> /etc/hosts
echo "$ip3    vm-test-03.example.com vm-test-03" >> /etc/hosts

echo "Start VMs"
echo "---------"
virt-deploy start test-02.example.com-centos-7.1-x86_64
virt-deploy start test-03.example.com-centos-7.1-x86_64

