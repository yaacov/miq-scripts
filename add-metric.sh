#!/bin/bash

# run this file as root on remote machine
#   e.g. ssh root@vm-test-02.example.com 'bash -s' < add-metric.sh

# create the metric pods
# ----------------------

# add metrics public url to master config file
sed -i "/assetConfig:/a\ \ metricsPublicURL: https://vm-test-02.example.com/hawkular/metrics" /etc/origin/master/master-config.yaml

# make the default node to be infra
sed -i s/defaultNodeSelector:\ \"\"/defaultNodeSelector:\ \"region=infra\"/g /etc/origin/master/master-config.yaml

# creat the metric pods, and set authentications
git clone https://github.com/openshift/origin-metrics.git
cd origin-metrics/
oc create -f metrics-deployer-setup.yaml -n openshift-infra
oadm policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer -n openshift-infra
oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster -n openshift-infra
oc secrets new metrics-deployer nothing=/dev/null -n openshift-infra
oc process -f metrics.yaml -v HAWKULAR_METRICS_HOSTNAME=vm-test-02.example.com,USE_PERSISTENT_STORAGE=false | oc create -n openshift-infra -f -

# create route to hawkular
# ------------------------

# create route for comunicating with manageiq
oadm router management-metrics --credentials=/etc/origin/master/openshift-router.kubeconfig --service-account=router --ports='443:5000' --stats-port=1937 --host-network=false

# reboot
# ------

reboot

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
# curl -X GET https://vm-test-02.example.com/hawkular/metrics/status --insecure

