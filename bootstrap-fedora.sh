#!/bin/bash

# run this file as root on master machine
# e.g. (replace HOSTNAME-PREFIX with your chosen prefix):
#   ssh root@vm-HOSTNAME-PREFIX-02.example.com 'bash -s HOSTNAME-PREFIX' < add-metric.sh
# (or copy/checkout the script there and just run 'bash add-metric.sh HOSTNAME-PREFIX')

if [ "$#" -eq 1 ]
then
  hostname="$1"
else
  echo "Usage: $0 <hostname>"
  exit
fi

ssh-keygen -R $hostname
ssh-copy-id root@$hostname

scp /etc/yum.repos.d/fedora.repo "root@$hostname:/etc/yum.repos.d/fedora.repo"
echo 'dnf upgrade -y' | ssh "root@$hostname"
echo 'dnf groupinstall -y "System tools"' | ssh "root@$hostname"
echo 'dnf install -y python2 python2-dnf libselinux-python libsemanage-python python2-firewall tar unzip bzip2 vim' | ssh "root@$hostname"

