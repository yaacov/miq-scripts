#!/bin/bash

# getting the token
#    oc get -n management-infra sa/management-admin --template='{{range .secrets}}{{printf "%s\n" .name}}{{end}}' | grep management-admin-token
# use the management-admin-token found in next command
#    oc get -n management-infra secrets management-admin-token-q5msc --template='{{.data.token}}' | base64 -d

# cleaning up
# oc delete all --selector=metrics-infra -n openshift-infra
# oc delete secrets --selector=metrics-infra -n openshift-infra
# oc delete sa --selector=metrics-infra -n openshift-infra
# oc delete templates --selector=metrics-infra -n openshift-infra

# creat the metric pods, and set authentications
git clone https://github.com/openshift/origin-metrics.git
cd origin-metrics/
oc create -f metrics-deployer-setup.yaml -n openshift-infra
oadm policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer -n openshift-infra
oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster -n openshift-infra
oc secrets new metrics-deployer nothing=/dev/null -n openshift-infra
oc process -f metrics.yaml -v HAWKULAR_METRICS_HOSTNAME=vm-vm-test-02,USE_PERSISTENT_STORAGE=false | oc create -n openshift-infra -f -

# check the metric pods
oc get pods -n openshift-infra

# when casndra, hawkular and heapster are all running, test
curl -X GET https://vm-vm-test-02/hawkular/metrics/status --insecure

# create route for comunicating with manageiq
oadm router management-metrics --credentials=/etc/origin/master/openshift-router.kubeconfig --service-account=router --ports='443:5000' --selector='kubernetes.io/hostname=vm-vm-test-02' --stats-port=1937 --host-network=false
