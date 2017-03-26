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
    :zone                      => Zone.last,
    :connection_configurations => [{:endpoint       => {:role       => :default,
                                                        :hostname   => hostname,
                                                        :port       => "8443",
                                                        :verify_ssl => false},
                                    :authentication => {:role     => :bearer,
                                                        :auth_key => token}},
                                   {:endpoint       => {:role       => :hawkular,
                                                        :hostname   => hostname,
                                                        :port       => "443",
                                                        :verify_ssl => false},
                                    :authentication => {:role     => :hawkular,
                                                        :auth_key => token}}])
  prov.save
  prov.authentication_check_types(:bearer, :hawkular)
  EmsRefresh.refresh(prov)
end

# ------
# Tokens
# ------
token1 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tdG42ZXUiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjBlYzhmNWFiLTEyMTMtMTFlNy04MjNkLTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.mmPvzMn23DDG1bQnAJW8GyyEATilT7aLXwt4foB-RQB6gOx3JHaQbZksYi0aRhze0jwtVRwyHaXaX78KN0z49O0aRFoUJ-V4iEAdcEpcVSA8tJEZ1Fj-m0OFMjfWtC9LPH_9Upqrb9aIFXXX4qiURMMe7xzCOS4Dj8wxtgAw2388S4NXRj5BkYXNj-GIvn3gz7_DZ-pjfbgwU7H0i5mHeQGjguzTHjkquApnogSRjY8k3Wqt4_e8ADP_t2Dtz2PMIp2eCQ1nV4NSLxfdbfeLfotJ3NKnV7NU502irUs7Tar9aw019XWvQIdwqPP_Hs8V3cQr9yonqskGK-v5QVEjAw'
token2 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tbHY0bWMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjU0YjU2MjA5LWIwMTMtMTFlNi1hMDYyLTAwMWE0YTE2MjYyYiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.OjM23tmvo_cdcn-FRDY7O77TCpFiyDMheRaX20hDnr8AO9m9DdRE1ovg2HtIFhJlXpYS4oIrtNilkx01fUMgmYVhR2jWKnH7CRFWJ7cj5hT-gBz68X3Dzat76cVBBCtgmTHs-kkr-qHqTsId3wMcvOKxQJSfzDvoRzhHP_vDehU2Mb7_RYVZnwKhgjtrWTELOM1cRjJPc2-7gpKRXjsm3Yuj7nYYHOHUgJAtUrFEsQ8iHV5B8bMywtoJCs9sz2mDXCZKBHbbQ-c8ABERIe-5IFP3z5CrPLwSXgL_UpzaYZF5r9pjWzDvfQ7pQ0qEW-4H15G7YcFmcwaDHZ7dC-b4ig'
token3 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4taml3ZGIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjkyNzk3NDIyLWI2ZGUtMTFlNi1iYWIyLTAwMWE0YTE2MjYyZCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.UgT2F3yLuQrQPFN49x-69lhLFrlSsvwEbrpAERPerVo5XaUTndjmgKarXYKij55qZ0E6JL-gcuh_H5Yxq6otGTjjAllc_DR0oYiphd_pCFwhKWtXBTDcqBkaR72oFxlcec9HkxZqAFGDQ9tnPlVn2NHr6PoBPeoWCasqm7B8v_RHHlPTS7VSRMtfrQYYf94RJxtjGxy1hbSpdxU0Q58qiMaOmHsrk7KJDguEnoYrzONG2m1VEpMEP38kF09ksGEXqPyr7Edq0KBBHPQh4h9eweKFrIswNlAPb9IbgyHiDw9yA0lnVpXpz6jaKkxpd8F1KSW5Qu-CIyFPEtH-HhYsDA'

# ---------------------------
# Delete all curent providers
# ---------------------------
delete_providers

# ---------------------------
# Create new curent providers
# ---------------------------
create_prov_with_auth('EngLab', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token1)
#create_prov_with_auth('Mooli-1', 'vm-48-43.eng.lab.tlv.redhat.com', token2)
#create_prov_with_auth('Mooli-2', 'vm-48-45.eng.lab.tlv.redhat.com', token3)

