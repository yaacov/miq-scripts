#!/bin/bash

if [ "$#" -eq 1 ]
then
  hostname_prefix="$1"
else
  echo "Usage: $0 hostname-prefix"
  exit
fi

dir="$(dirname "$0")"

sed s/'$hostname_prefix'/$hostname_prefix/g > "$dir/hosts.$hostname_prefix" <<EOF
# This is an example of a bring your own (byo) host inventory

# A host file for openshift-ansible ansible-playbook
# ansible-playbook ./playbooks/byo/config.yml -i <PATH-TO-FILE>/hosts.local
# e.g. when run from openshift-ansible source dir:
#      ansible-playbook playbooks/byo/config.yml -i ../miq-scripts/hosts.local

# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]

# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=root
deployment_type=origin
openshift_use_manageiq=True

# host group for masters
[masters]
vm-$hostname_prefix-02.example.com

# host group for nodes
[nodes]
vm-$hostname_prefix-02.example.com openshift_node_labels="{'region':'infra','zone':'default'}" openshift_schedulable=true
vm-$hostname_prefix-03.example.com openshift_node_labels="{'region':'primary','zone':'west'}"
EOF

echo "$dir/hosts.$hostname_prefix generated."
