#!/bin/bash

# cleaning up
# -----------

# oc delete all --selector=metrics-infra -n openshift-infra
# oc delete secrets --selector=metrics-infra -n openshift-infra
# oc delete sa --selector=metrics-infra -n openshift-infra
# oc delete templates --selector=metrics-infra -n openshift-infra

# getting the openshift provider token
# ------------------------------------

secret=`oc get -n management-infra sa/management-admin --template='{{range .secrets}}{{printf "%s\n" .name}}{{end}}' | grep management-admin-token | head -n 1`; oc get -n management-infra secrets $secret --template='{{.data.token}}' | base64 -d > token.txt; cat token.txt; echo

# create the metric pods
# ----------------------

# add metrics public url to master confiv file
sed -i "/assetConfig:/a\ \ metricsPublicURL: https://vm-test-02/hawkular/metrics" /etc/origin/master/master-config.yaml

# make the default node to be infra
sed -i s/defaultNodeSelector:\ \"\"/defaultNodeSelector:\ \"region=infra\"/g /etc/origin/master/master-config.yaml

# creat the metric pods, and set authentications
git clone https://github.com/openshift/origin-metrics.git
cd origin-metrics/
oc create -f metrics-deployer-setup.yaml -n openshift-infra
oadm policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer -n openshift-infra
oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster -n openshift-infra
oc secrets new metrics-deployer nothing=/dev/null -n openshift-infra
oc process -f metrics.yaml -v HAWKULAR_METRICS_HOSTNAME=vm-test-02,USE_PERSISTENT_STORAGE=false | oc create -n openshift-infra -f -

# check all
# ---------

# watch the metric pods until all are running
oc get pods --all-namespaces -w

# wait for casndra, hawkular and heapster pods to run then test
curl -X GET https://vm-test-02/hawkular/metrics/status --insecure

# create route to hawkular
# ------------------------

# create route for comunicating with manageiq
oadm router management-metrics --credentials=/etc/origin/master/openshift-router.kubeconfig --service-account=router --ports='443:5000' --stats-port=1937 --host-network=false

# reboot

