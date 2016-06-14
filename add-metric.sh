#!/bin/bash

# run this file as root on master machine
# e.g. (replace HOSTNAME with your chosen hostname):
#   ssh root@HOSTNAME 'bash -s HOSTNAME' < add-metric.sh
# (or copy/checkout the script there and just run 'bash add-metric.sh HOSTNAME')

if [ "$#" -eq 1 ]
then
  hostname="$1"
else
  hostname="$HOSTNAME"
fi

# create the metric pods
# ----------------------

# creat the metric pods, and set authentications
git clone https://github.com/openshift/origin-metrics.git
cd origin-metrics/
oc create -f metrics-deployer-setup.yaml -n openshift-infra
oadm policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer -n openshift-infra
oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster -n openshift-infra
oc secrets new metrics-deployer nothing=/dev/null -n openshift-infra
oc process -f metrics.yaml -v HAWKULAR_METRICS_HOSTNAME=$hostname,USE_PERSISTENT_STORAGE=false | oc create -n openshift-infra -f -

# reboot
# ------

#reboot

# get the openshift token
# -----------------------

# secret=`oc get -n management-infra sa/management-admin --template='{{range .secrets}}{{printf "%s\n" .name}}{{end}}' | grep management-admin-token | head -n 1`; oc get -n management-infra secrets $secret --template='{{.data.token}}' | base64 -d > token.txt; cat token.txt; echo

# cleaning up
# -----------

# oc delete all --selector=metrics-infra -n openshift-infra
# oc delete secrets --selector=metrics-infra -n openshift-infra
# oc delete sa --selector=metrics-infra -n openshift-infra
# oc delete templates --selector=metrics-infra -n openshift-infra

# check all
# ---------

# watch the metric pods until all are running
# oc get pods --all-namespaces -w

# wait for casndra, hawkular and heapster pods to run then test
# curl -X GET https://$hostname/hawkular/metrics/status --insecure
