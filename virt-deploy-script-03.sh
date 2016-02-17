#!/bin/bash

echo "Delete VMs"
echo "----------"
sudo virt-deploy delete vm-test-02-centos-7.1-x86_64
sudo virt-deploy delete vm-test-03-centos-7.1-x86_64
sudo virt-deploy delete vm-test-04-centos-7.1-x86_64
sudo virt-deploy delete vm-test-05-centos-7.1-x86_64

echo "Delete VMs images from lib cache"
echo "--------------------------------"
sudo rm -rf /var/lib/libvirt/images/vm-test-02-centos-7.1-x86_64.qcow2
sudo rm -rf /var/lib/libvirt/images/vm-test-03-centos-7.1-x86_64.qcow2
sudo rm -rf /var/lib/libvirt/images/vm-test-04-centos-7.1-x86_64.qcow2
sudo rm -rf /var/lib/libvirt/images/vm-test-05-centos-7.1-x86_64.qcow2

echo "Delete VMs from etc/hosts"
echo "-------------------------"
sudo sed '/\.example\.com vm-test-/d' -i /etc/hosts

echo "Remove ssh fingerprints"
echo "-----------------------"
ssh-keygen -R "vm-test-02"
ssh-keygen -R "vm-test-03"
ssh-keygen -R "vm-test-04"
ssh-keygen -R "vm-test-05"

