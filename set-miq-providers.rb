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
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tYjQxN3oiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImJhZDVlM2ZhLTNhMTItMTFlNy1hOGIxLTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.GO0Rm32ZPRVwHieC2jWR_ZLN6QhW_2olhkA2mB6S18RrSLDLZi4k9kHSBDGBNnWtm-8TC7vYkgTbv6l-O1ExH1ilr_R-Q2t9BTxC10mTI2BSHmMLtvoYqx_s7GcQO0PIzcgq3M9KUHJBP3FG6UfAopeFysHsUKwFVPcQmUl4Pa9ZN3eINdGc4mJiuNdTaEfseGGa2GgieQe_WRYcT-AOBvKmEb9IRZKbGfWsRbRSYP3zKMPlMQ_e9JVS9fAEyWJL0AR119Kq6ax12SQBspl7dxZBt8ba4LRKlLvvWVSh1eQffoUiI87TxfVJ3Vq9wWPmsfYdGxixAvrh3BmkyQ4C4w'
token2 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tdjMxMTMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImRjY2MzNzJkLTNhMTUtMTFlNy05OGVmLTAwMWE0YTIzMTRkNiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.oRXkvCRwJYWOi_Ta4BP48Mw-kh5IKYalKvhapFC8ayjpsHgwXFCPvQiWLZaPkmQ36RsMq8ofU6duZNulhgFW42djYA1SpPd6jwDxXc2Kq5UwH-cFeYvdeAuoLIM6TK5KmBr0DMJUSTnTrDuqvptL-oM1euS_45kKbGoUSKnVFehh0U4MTJii3hBQUlur-G6L1SyupQ7KILkC2-8OetuKp3wSq3RoHGBLvaCg4BlX2CDJFpMH-d9WkNrg1J25suMUch4QUuZyyIxSYceVWD9xAVXOPVyAbgouYkhRg42BpkllCLY7guj19SydihcgIccTQ4CD1Kzjc6n3g4jRmjPwaQ'
token3 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tbWIyeDkiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6Ijk4NTJmM2YyLTNhMTktMTFlNy1hM2ViLTAwMWE0YTIzMTRkNyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.lfd9Cfp22EArNlrzqPs76aO3KfHDZVeCWF-E_ZyYVmtPvDhg1M75lJ1_xuVuTH4b5CESq6mwmlq9ttV0z8x6KlbvenSiiYNzNqGOGKJTuDhvq-lUL2HwNWWZT-BHnM2M0GtgSimWGIgZL0ubQf2ta0MiOEJexhqxG2AIp8eHQRfgVB77vTlwJy5tRqyXsDO5NwpT7zRxFzIgauPsq8FHGRhwg2n2HfhFM5xHxf1yIWizUtkk8RyzQ7WucN4zPeK_1HszM343UXrn0mvL0xoHCppOsnDZSs_PNeVMKrQR8TShAAo1xo0HG9EW5wEgFruGZw4o0nCPnCzZJHmWIia4tg'

# ---------------------------
# Delete all curent providers
# ---------------------------
delete_providers

# ---------------------------
# Create new curent providers
# ---------------------------
create_prov_with_auth('EngLab', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token1)
create_prov_with_auth('EngLab-mohawk', 'yzamir-centos7-2.eng.lab.tlv.redhat.com', token2)
create_prov_with_auth('EngLab-prometheus', 'yzamir-centos7-3.eng.lab.tlv.redhat.com', token3)

