# delete running mohawk
oc process -f mohawk.yaml -p ROUTE_URL="mohawk.$(ifconfig eth0 | grep "inet " | cut -f 10 -d" ").nip.io" | oc delete -f - 

# set mohawk with nip.io route
oc process -f mohawk.yaml -p ROUTE_URL="mohawk.$(ifconfig eth0 | grep "inet " | cut -f 10 -d" ").nip.io" | oc create -f - 

# check if server is running
curl -k https://mohawk.<IP_OF_OPENSHIFT_MASTER>.nip.io/hawkular/metrics/status

# check if server is getting metrics from heapster
curl -k https://mohawk.<IP_OF_OPENSHIFT_MASTER>.nip.io/hawkular/metrics/metrics -H "Hawkular-Tenant: _system"
