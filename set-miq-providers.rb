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

  #EmsRefresh.refresh(prov)
end

# ------------------------------------
# delete the providers in the database
# and add some new ones
# ------------------------------------

token1 = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tMThmaTAiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImQ5MjYyYjVjLThmN2ItMTFlNS1hODA2LTAwMWE0YTIzMTI5MCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.mWvcSwE6_WR8mHm_QBrXM_IHF9I9qOvfB-9Le-g7_DTrzEcM6Jy5smR6v7XmwRizjCheQJxbLjHmATxOXZGxyiG9ZXQGht1TcenCsLKJzxeVp5Lt3K9hdnFdXS9bXNHRav8VNpTwnjS2mRnzGQNxop2BJ1nGWU1mzMSyK5hWKoaUSVKsKwT1UyPfPC6_we-ygjhZpIbSxPEalzm_tjTUFSdWvUFlNBzUQrHvE0zoPxJ4sbbC5uNcaWo7aTey4eIcAn9vnPvNzHTJTIzbVyYIp65jehUr2QKD0CvGAjLWS_Pp-EeINOWaEQe_xNxK0IAl8b4uwhPVc-rRjFb4GkqVoQ'
token2 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tZmh1aDciLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjNjNDBlMTc5LTdmMzAtMTFlNi1iZDA1LTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.i2vN3EoH7z4j9dQkVsNO2wX_YFVdq_Kzj1JZ6oFG-R4ObyF16GIsKHldMFYs91t0i2i5YKCdpi16fod3NBWzg_7uyevgh3-h2exM8iItznStqRNMr4rc1C8L1UC7D7t4gHbZJKJgXqQM4iervtTTtgx3nkkSoALkKDoqa9jUhgpZz8_TUmSfg4b1gHttuX2o_Q-otAZvr-U4mqPq-G3qML_HwjnULhWlBxGawM8VPfhu828dLM55OkCFoM3gSdMQz47QWZ1ctpMRAwBjaZ3cZSL0Xu-LtMVZHBAD-VbYZhalBpWvX-wF0Fz102FlctPyuX3EtsZvFcV4aHcmwqCxc'
token3 = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tdXI2YW0iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjYxNWU2MWRkLTMyMTMtMTFlNi1iMzg3LTAwMWE0YTE2OTc5OSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.lnv42HrZ3hujxG8kIovb89XiOVdJEY83FU6hsfA5RFK05gMI8vqBStJmFYpCTRScrBXkljajDKX7OT83mhZ6JoWkfJtDAul4NE7tV1NL_yr1IT-YwNY0eCD_BjvJw-H_JdEDo0ivyByAHnfJOB7GK27a6DtOYu4aR5eqlV7kQb3zusgNcAScEeYJcVDHWbGgr0hBc1E7Zc4EvvjZWOmv_S7H5RxpZfXkPvOr20-rEpaj0RJ2hs7nxZv4ahuSPUlwzSQdRj_BQss2iGy7mbSpgBbHTTagOHwhrZmMSgwfwpzPAiFij42xF61HCK_ZLrDEZ7_HDfHAXRa0pHEbh4D2IQ'

delete_providers
create_prov_with_auth('Molecule', 'oshift01.eng.lab.tlv.redhat.com', token1)
create_prov_with_auth('EngLab', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token2)
#create_prov_with_auth('QaLab', 'ose-master.qa.lab.tlv.redhat.com', token3)
