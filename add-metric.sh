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

# Switch to the openshift-infra project
oc project openshift-infra

# Create a metrics-deployer service account
oc create -f - <<API
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-deployer
secrets:
- name: metrics-deployer
API

# Grante the edit permission for the openshift-infra project
oadm policy add-role-to-user \
    edit system:serviceaccount:openshift-infra:metrics-deployer

# Grante the cluster-reader permission for the Heapster service account
oadm policy add-cluster-role-to-user \
    cluster-reader system:serviceaccount:openshift-infra:heapster

# ?
oadm policy add-role-to-user \
    view system:serviceaccount:openshift-infra:hawkular -n openshift-infra

# Using Generated Self-Signed Certificates
oc secrets new metrics-deployer nothing=/dev/null

# Deploying metrics without Persistent Storage
wget https://raw.githubusercontent.com/openshift/origin-metrics/master/metrics.yaml
oc new-app -f metrics.yaml \
    -p USE_PERSISTENT_STORAGE=false \
    -p HAWKULAR_METRICS_HOSTNAME=$(hostname) \
    -p IMAGE_VERSION=v3.6.0-rc.0

# Exit
exit

# get the openshift tokens
# ------------------------
# get bearer token
oc sa get-token management-admin -n management-infra
#echo Authorization: Bearer $(oc sa get-token management-admin -n management-infra) > bearer_auth.txt; cat bearer_auth.txt; echo
# get basic authentication
oc -n openshift-infra export secret hawkular-metrics-account | grep password | cut -d: -f2 | sed 's/ //g' | base64 --decode
#echo Authorization: Basic $(echo hawkular:$(oc -n openshift-infra export secret hawkular-metrics-account | grep password | cut -d: -f2 | sed 's/ //g' | base64 --decode) | base64 | cut -c 1-32) > basic_auth.txt; cat basic_auth.txt; echo

# cleaning up
# -----------

oc delete all --selector="metrics-infra"
oc delete sa --selector="metrics-infra"
oc delete templates --selector="metrics-infra"
oc delete secrets --selector="metrics-infra"
oc delete pvc --selector="metrics-infra"
oc delete sa metrics-deployer
oc delete secret metrics-deployer

# check all
# ---------

# watch the metric pods until all are running
oc get pods --all-namespaces -w

# wait for casndra, hawkular and heapster pods to run then test
curl -X GET https://$(hostname)/hawkular/metrics/status --insecure
