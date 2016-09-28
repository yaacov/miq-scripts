#!/usr/bin/env ruby

# Load Rails
ENV['RAILS_ENV'] = ARGV[0] || 'development'
DIR = File.dirname(__FILE__)
require DIR + '/../manageiq/config/environment'

# --------------------
# functions and consts
# --------------------

# delete all providers from database
def delete_providers
  ManageIQ::Providers::Kubernetes::ContainerManager.destroy_all
  ManageIQ::Providers::Openshift::ContainerManager.destroy_all
end

# insert a new openshift provider to the database
# with authentication
#
# we asume default and hawkular endpoints has the same
# hostname and token
#
# name      new providers name
# hostname  new providers hostname
# token     new providers token
def create_prov_with_auth(name, hostname, token)
  prov = ManageIQ::Providers::Openshift::ContainerManager.new(
    :name                      => name,
    :zone                      => Zone.first,
    :connection_configurations => [{:endpoint       => {:role     => :default,
                                                        :hostname => hostname,
                                                        :port     => "8443"},
                                    :authentication => {:role     => :bearer,
                                                        :auth_key => token,
                                                        :userid   => "_"}},
                                   {:endpoint       => {:role     => :hawkular,
                                                        :hostname => hostname,
                                                        :port     => "443"},
                                    :authentication => {:role     => :hawkular,
                                                        :auth_key => token,
                                                        :userid   => "_"}}])
  prov.save

  EmsRefresh.refresh(prov)
end

# ------------------------------------
# delete the providers in the database
# and add some new ones
# ------------------------------------

token1 = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tMThmaTAiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImQ5MjYyYjVjLThmN2ItMTFlNS1hODA2LTAwMWE0YTIzMTI5MCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.mWvcSwE6_WR8mHm_QBrXM_IHF9I9qOvfB-9Le-g7_DTrzEcM6Jy5smR6v7XmwRizjCheQJxbLjHmATxOXZGxyiG9ZXQGht1TcenCsLKJzxeVp5Lt3K9hdnFdXS9bXNHRav8VNpTwnjS2mRnzGQNxop2BJ1nGWU1mzMSyK5hWKoaUSVKsKwT1UyPfPC6_we-ygjhZpIbSxPEalzm_tjTUFSdWvUFlNBzUQrHvE0zoPxJ4sbbC5uNcaWo7aTey4eIcAn9vnPvNzHTJTIzbVyYIp65jehUr2QKD0CvGAjLWS_Pp-EeINOWaEQe_xNxK0IAl8b4uwhPVc-rRjFb4GkqVoQ'
token2 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tbDd3cnAiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjMwNzM3ZGU3LTgzNjAtMTFlNi04MDg2LTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.Glu0frTVxI7W-dVX7SHDmE4hKy7c9Z60xdCOxoFAGwW3bQwPsxjsjcL0lh8-JnlZj4AW9ctwyQ07l8I-6ayT18alpnifdgOVm-4Ci7BRp-VPGHrvDxWHw7BfqkQ6mHFR1c7-tcVHYAX8tbi7LXbhUyqel8MmCjPYx6qqtnApGbCwcR42T-h4xZzj6AvPNn3iwFsWetWSNGbuRFuC4nIlSuzWuXbDzN5MKJLXbyFSgNKeuS5-Dz1IDcntdW6JzJZRnt4Oig2OtSCGdDHjMcJ9k3zXrhTi-fTwclY9IXMNZYxMdCpvxifbAdzT7opJuuaM_QRWKspgwtJ74CCkr4bvNw'

delete_providers
#create_prov_with_auth('Molecule', 'oshift01.eng.lab.tlv.redhat.com', token1)
create_prov_with_auth('EngLab', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token2)
