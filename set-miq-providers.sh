#!/bin/bash

create_prov () {
cmd_prov="prov = ManageIQ::Providers::Openshift::ContainerManager.new(:hostname => '$2', :port => 8443,  :name =>'$1', :zone => Zone.first)"
cmd_token="AuthToken.create(:name => 'ManageIQ::Providers::Openshift::ContainerManager $1', :authtype => 'bearer', :userid => '_', :resource_id => prov.id, :resource_type => 'ExtManagementSystem', :type => 'AuthToken', :auth_key => '$3').save"

echo "$cmd_prov
prov.save
$cmd_token
EmsRefresh.refresh(prov)
"
}

name1=Molecule
url1=oshift01.eng.lab.tlv.redhat.com
token1=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tMThmaTAiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImQ5MjYyYjVjLThmN2ItMTFlNS1hODA2LTAwMWE0YTIzMTI5MCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.mWvcSwE6_WR8mHm_QBrXM_IHF9I9qOvfB-9Le-g7_DTrzEcM6Jy5smR6v7XmwRizjCheQJxbLjHmATxOXZGxyiG9ZXQGht1TcenCsLKJzxeVp5Lt3K9hdnFdXS9bXNHRav8VNpTwnjS2mRnzGQNxop2BJ1nGWU1mzMSyK5hWKoaUSVKsKwT1UyPfPC6_we-ygjhZpIbSxPEalzm_tjTUFSdWvUFlNBzUQrHvE0zoPxJ4sbbC5uNcaWo7aTey4eIcAn9vnPvNzHTJTIzbVyYIp65jehUr2QKD0CvGAjLWS_Pp-EeINOWaEQe_xNxK0IAl8b4uwhPVc-rRjFb4GkqVoQ

name2=Local
url2=vm-test-02.example.com

# get token from server
sftp root@vm-test-02.example.com:token.txt
token2=`cat token.txt`

cmd="
ManageIQ::Providers::Kubernetes::ContainerManager.destroy_all
ManageIQ::Providers::Openshift::ContainerManager.destroy_all

`create_prov $name1 $url1 $token1`
`create_prov $name2 $url2 $token2`
"

bundle exec rails runner "$cmd"

