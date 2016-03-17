#!/bin/bash

if [ "$EUID" -eq 0 ]
  then echo "Please run as regular user"
  exit
fi

if [ "$#" -eq 1 ]
then
  hostname_prefix="$1"
else
  echo "Usage: $0 hostname-prefix"
  exit
fi

echo "Add root auth"
echo "-------------"
echo
echo "All passwords are set to 'pass'"
read -p "Press any key..."

ssh-copy-id root@vm-"$hostname_prefix"-02.example.com
ssh-copy-id root@vm-"$hostname_prefix"-03.example.com
