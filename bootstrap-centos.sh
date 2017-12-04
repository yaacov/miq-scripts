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

#echo 'yum install epel-release -y' | ssh "root@$hostname"

#echo 'curl -o /etc/yum.repos.d/CentOS-OpenShift.repo https://tdawson.fedorapeople.org/centos/CentOS-OpenShift.repo' | ssh "root@$hostname"
#echo 'curl -o /etc/yum.repos.d/CentOS7.repo https://raw.githubusercontent.com/yaacov/miq-scripts/master/yum.repos.d/CentOS7.repo' | ssh "root@$hostname"
#echo 'curl -o /etc/yum.repos.d/CentOS7-Base.repo https://raw.githubusercontent.com/yaacov/miq-scripts/master/yum.repos.d/CentOS-Base.repo' | ssh "root@$hostname"

echo 'yum clean all' | ssh "root@$hostname"
echo 'yum upgrade -y' | ssh "root@$hostname"
#echo 'yum clean all' | ssh "root@$hostname"
echo 'yum install epel-release centos-release-paas-common centos-release-openshift-origin docker wget vim -y' | ssh "root@$hostname"
#echo 'yum clean all' | ssh "root@$hostname"
#echo 'yum upgrade -y' | ssh "root@$hostname"

