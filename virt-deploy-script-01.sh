#!/bin/bash

echo "Delete VMs"
echo "----------"
sudo virt-deploy delete vm-test-02-centos-7.1-x86_64
sudo virt-deploy delete vm-test-03-centos-7.1-x86_64

echo "Delete VMs images from lib cache"
echo "--------------------------------"
sudo rm -rf /var/lib/libvirt/images/vm-test-02-centos-7.1-x86_64.qcow2
sudo rm -rf /var/lib/libvirt/images/vm-test-03-centos-7.1-x86_64.qcow2

echo "Delete VMs from etc/hosts"
echo "-------------------------"
sudo sed '/\.example\.com vm-test-/d' -i /etc/hosts

echo "Create VMs"
echo "----------"
sudo ip2=`virt-deploy create vm-test-02 centos-7.1 -o memory=3072 password=pass | grep 'ip address:' | cut -d: -f2`
sudo ip3=`virt-deploy create vm-test-03 centos-7.1 -o memory=3072 password=pass | grep 'ip address:' | cut -d: -f2`

echo "Edit VMs on etc/hosts"
echo "---------------------"
sudo echo "$ip2    vm-test-02.example.com vm-test-02" >> /etc/hosts
sudo echo "$ip3    vm-test-03.example.com vm-test-03" >> /etc/hosts

echo "Start VMs"
echo "---------"
sudo virt-deploy start vm-test-02-centos-7.1-x86_64
sudo virt-deploy start vm-test-03-centos-7.1-x86_64f

