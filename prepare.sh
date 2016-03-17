#!/bin/bash

if [ "$EUID" -eq 0 ]
then
  echo "Please run as regular user"
  exit
fi

if [ "$#" -eq 1 ]
then
  hostname_prefix="$1"
else
  echo "Usage: $0 hostname-prefix"
  exit
fi

dir="$(dirname "$0")"

echo "Create VMs"
echo "----------"
ip2=$(sudo virt-deploy create $hostname_prefix-02.example.com centos-7.1 -o memory=2048 password=pass | grep 'ip address:' | cut -d: -f2)
ip3=$(sudo virt-deploy create $hostname_prefix-03.example.com centos-7.1 -o memory=2048 password=pass | grep 'ip address:' | cut -d: -f2)

echo "Add VMs to etc/hosts"
echo "--------------------"
echo "$ip2    vm-$hostname_prefix-02.example.com vm-$hostname_prefix-02" | sudo tee --append /etc/hosts
echo "$ip3    vm-$hostname_prefix-03.example.com vm-$hostname_prefix-03" | sudo tee --append /etc/hosts

echo "Start VMs"
echo "---------"
virt-deploy start $hostname_prefix-02.example.com-centos-7.1-x86_64
virt-deploy start $hostname_prefix-03.example.com-centos-7.1-x86_64

echo "Add root auth"
echo "-------------"
echo
echo "All passwords are set to 'pass'"
read -p "Press any key..."

ssh-copy-id root@vm-$hostname_prefix-02.example.com
ssh-copy-id root@vm-$hostname_prefix-03.example.com

echo "Generate inventory"
echo "------------------"
"$dir/hosts-generate.sh" $hostname_prefix
echo "Now you can run:"
echo "    ansible-playbook <PATH-TO-OPENSHIFT-ANSIBLE>/playbooks/byo/config.yml -i $dir/hosts.$hostname_prefix"
