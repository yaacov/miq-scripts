#!/bin/bash

# Script to push container providers into manageIQ DB
# Based on Ari Zellner's fill_er_up.sh
#
# Run from the manageIQ code directory.
#     e.g. ../miq-scripts/set-miq-providers.sh

create_prov () {
cmd_prov="prov = ManageIQ::Providers::Openshift::ContainerManager.new(:hostname => '$2', :port => 8443,  :name =>'$1', :zone => Zone.first)"
cmd_token="AuthToken.create(:name => 'ManageIQ::Providers::Openshift::ContainerManager $1', :authtype => 'bearer', :userid => '_', :resource_id => prov.id, :resource_type => 'ExtManagementSystem', :type => 'AuthToken', :auth_key => '$3').save"

cmd="$cmd_prov
prov.save
$cmd_token
EmsRefresh.refresh(prov)
"

bundle exec rails runner "$cmd"
}

# clean the DB
# ------------

cmd_delete_all="
ManageIQ::Providers::Kubernetes::ContainerManager.destroy_all
ManageIQ::Providers::Openshift::ContainerManager.destroy_all
"
bundle exec rails runner "$cmd_delete_all"

# add the molecule provider
# -------------------------

name1=Molecule
url1=oshift01.eng.lab.tlv.redhat.com
token1=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tMThmaTAiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImQ5MjYyYjVjLThmN2ItMTFlNS1hODA2LTAwMWE0YTIzMTI5MCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.mWvcSwE6_WR8mHm_QBrXM_IHF9I9qOvfB-9Le-g7_DTrzEcM6Jy5smR6v7XmwRizjCheQJxbLjHmATxOXZGxyiG9ZXQGht1TcenCsLKJzxeVp5Lt3K9hdnFdXS9bXNHRav8VNpTwnjS2mRnzGQNxop2BJ1nGWU1mzMSyK5hWKoaUSVKsKwT1UyPfPC6_we-ygjhZpIbSxPEalzm_tjTUFSdWvUFlNBzUQrHvE0zoPxJ4sbbC5uNcaWo7aTey4eIcAn9vnPvNzHTJTIzbVyYIp65jehUr2QKD0CvGAjLWS_Pp-EeINOWaEQe_xNxK0IAl8b4uwhPVc-rRjFb4GkqVoQ

create_prov $name1 $url1 $token1

# add the local provider
# -------------------------

# to get the token:
# on the master vm do -
# secret=`oc get -n management-infra sa/management-admin --template='{{range .secrets}}{{printf "%s\n" .name}}{{end}}' | grep management-admin-token | head -n 1`; oc get -n management-infra secrets $secret --template='{{.data.token}}' | base64 -d > token.txt; cat token.txt; echo

name2=Local
url2=vm-test-02.example.com
token2=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tbzRpM3YiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjJkYzE5YjFjLWRhZjUtMTFlNS1hODMwLTUyNTQwMDM2NzkwMiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.nEnH7URxPDgTJ2CKtRIKmI812BpiSoe7v9uDsrbv9OLunQ7gQ1CTXWFa9UJnY4ip8EA1Gao6PZO7ARyBhBLzJ9XdLm4PiWV-o9Adlf6ATyu-qVeGVS2UJjPO4porGjHKOu5W488F0M1MOQ-Xyu_8T8zV5H0HX2IEouxOK5Vx8zDRy58IYPR8TrvZkfYcc9xkr5rPNO6Pba8mtPNYo2Eqj9qlhIYHAoERkmdknBIOc2kZ-vXMI6UPu8IMxfyLGHO4gpRthkzifMf77ROncLlwCzClPDoTLZ48bU0AGZ1xpaD1ixwxwG512PK84jNWuzOHwRPA_pmBFsL1U4LbV9iBtw

create_prov $name2 $url2 $token2

