#!/bin/bash

if [ "$#" -eq 1 ]
then
  hostname_prefix="$1"
else
  echo "Usage: $0 hostname-prefix"
  exit
fi

echo "Delete VMs"
echo "----------"
sudo virt-deploy delete $hostname_prefix-02.example.com-centos-7.1-x86_64
sudo virt-deploy delete $hostname_prefix-03.example.com-centos-7.1-x86_64

echo "Delete VMs images from lib cache"
echo "--------------------------------"
sudo rm -rf /var/lib/libvirt/images/$hostname_prefix-02.example.com-centos-7.1-x86_64.qcow2
sudo rm -rf /var/lib/libvirt/images/$hostname_prefix-03.example.com-centos-7.1-x86_64.qcow2

echo "Delete VMs from etc/hosts"
echo "-------------------------"
sudo sed "/\.example\.com vm-$hostname_prefix-/d" -i /etc/hosts

echo "Remove ssh fingerprints"
echo "-----------------------"
ssh-keygen -R "vm-$hostname_prefix-02.example.com"
ssh-keygen -R "vm-$hostname_prefix-03.example.com"
