#!/bin/bash

echo "Remove ssh fingerprints"
echo "-----------------------"
ssh-keygen -R "vm-test-02"
ssh-keygen -R "vm-test-03"
ssh-keygen -R "vm-test-04"
ssh-keygen -R "vm-test-05"

echo "Add root auth"
echo "-------------"
ssh-copy-id root@vm-test-02
ssh-copy-id root@vm-test-03
ssh-copy-id root@vm-test-04
ssh-copy-id root@vm-test-05

