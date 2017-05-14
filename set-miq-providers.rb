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
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tNmdsbjAiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImExNDQ2YTFlLTMzMWMtMTFlNy1iZWRhLTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.Qf_Kl24bZa2oqcsXBgAZDfccPVPKh7FzTvsOxLXCdOIfAciKvKNQrAlj26Od01uZjS-4VsGH37phSHl5LavlF_wK4w_npeWsBE11cSjA9sXciPB99_xDcGzINSKdYx9B46F7wrVnEiMuFT2Lf1LvBkiG4VzPFJtKpvTImccPASmLHad1Yrsg10dBJmbMHkRFe9Wvgs0jfqUb1UDYHOafZ6XmT_C9YYGvTmCgW3lQkB0xzXQwTok0zQl1tu-4lT8gN-qQw2V89Nma4ZGc_DpkUB8EHtN6Xv5cR42NkfNs6XePUuvZy8L7zqpXr1g1jBEin9tOiD4BMsYWisOXuCwbrg'
token2 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tc2QyNWIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImE2YjBhOGMyLTMzZDMtMTFlNy05MmFkLTAwMWE0YTIzMTRkNiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.RtVUQKgrIFdNVzR6FCoDPaVULvEI4_J2gh40MsxeApt51mY8eoWcbOIFu1Iqkg21f2b7MekqHSgCoQ2CzZVaTHoNIp1UTlDCKZC0EtBzHW8Ns-QrYjoVbCJfkMHsBlqMYqJ-8YfIi1CbVEcEiXEOWOfEtKZRytmsMGKzo4UsJM-B5BrculWW4ALtLG-zc34j6sHfwGbs3y4t-1DAANsiULRcY0UPKvevF7msNR_pfMOC-_UMystLDqhI434Dh2FqYHM2_dLAyJ28K4lYCTea3siB6qEsnWbwZCXhp72sNQsI923YZNWJN3mQpFaF1erQ4Z_a8zx12KzIEz9C2WU27A'
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
create_prov_with_auth('EngLab2', 'yzamir-centos7-2.eng.lab.tlv.redhat.com', token2)
#create_prov_with_auth('Mooli-2', 'vm-48-45.eng.lab.tlv.redhat.com', token3)

