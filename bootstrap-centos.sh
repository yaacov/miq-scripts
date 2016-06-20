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
