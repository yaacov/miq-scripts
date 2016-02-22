#!/bin/bash

if [ "$EUID" -eq 0 ]
  then echo "Please run as regular user"
  exit
fi

echo "Remove ssh fingerprints"
echo "-----------------------"
ssh-keygen -R "vm-test-02.example.com"
ssh-keygen -R "vm-test-03.example.com"

echo "Add root auth"
echo "-------------"
echo
echo "All passwords are set to 'pass'"
read -p "Press any key..."

ssh-copy-id root@vm-test-02.example.com
ssh-copy-id root@vm-test-03.example.com

