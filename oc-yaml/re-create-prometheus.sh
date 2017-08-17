wget https://raw.githubusercontent.com/openshift/origin/master/examples/prometheus/prometheus.yaml

oc delete serviceaccount prometheus
oc delete clusterrolebinding prometheus-cluster-reader
oc delete service prometheus
oc delete deployment prometheus
oc delete configmap prometheus
oc delete template prometheus
oc delete route prometheus

oc create -f re-create-prometheus.yaml
oc new-app prometheus
