#!/bin/bash

echo "Delete VMs"
echo "----------"
sudo virt-deploy delete test-02.example.com-centos-7.1-x86_64
sudo virt-deploy delete test-03.example.com-centos-7.1-x86_64

echo "Delete VMs images from lib cache"
echo "--------------------------------"
sudo rm -rf /var/lib/libvirt/images/test-02.example.com-centos-7.1-x86_64.qcow2
sudo rm -rf /var/lib/libvirt/images/test-03.example.com-centos-7.1-x86_64.qcow2

echo "Delete VMs from etc/hosts"
echo "-------------------------"
sudo sed '/\.example\.com vm-test-/d' -i /etc/hosts

echo "Remove ssh fingerprints"
echo "-----------------------"
ssh-keygen -R "vm-test-02.example.com"
ssh-keygen -R "vm-test-03.example.com"

