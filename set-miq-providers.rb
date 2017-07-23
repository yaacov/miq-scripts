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
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4taHY5M3EiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjFjY2FiOTZlLTZmODQtMTFlNy05ZDNjLTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.I2xG6ORylR7zxjJHb-DnNqKG5Ae37tYSYSvcsX4YpaW1ktY3oVT2CM9GBtDwkS6TY3o7wqvF4lpkYgGcv5rANLAgQT3WKFO1207RE1plTca85nMMIiZZkmsWpCa4U__PEOHv54LJ-hSHO8LTq1TlWRX0lL60Bxr-j79BmiEA05FN8u84uFRYJQ7JNWk-qII23eXOs4Zkq09zWUn8NGpeVa-mIszWvqUdrknvRtvvtCT0EkvKU5Odnugvi8DTaH_reInHdRo8y4_Csxem8SFAnCvEBzU4EIg1nUPSoD4sFGeljOC7v6EWg5q0408xmFBg1_oS5J8SeqNzZK57sCqn3w'
token2 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tejJjZDciLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImExOGY3MTgwLTZkMTgtMTFlNy04ZGVkLTAwMWE0YTIzMTRkNiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.cck_tbnkibOyYfZ4TeDSKNQTb-K3TZHzFNIsaSF5fxvxBQkPUC3iKjzkRYMFbuw6_kQ6aICItRNgRG6KfYwIlyE679W5g7QKsp8aEpgqbE9aWn6ipsBagnZpWK3U0Vglunl3dxngrA8z4aNRP4GvEbhVMSyedzzVPV1SYzoC071skokt6HwkDRnuL9lLZh9InWiHt85kE6gykPxXmbBvf9Cw1IWA0KeRupi6BWfdw8Em-ESNeE6Brhaiz7D8AyTACjJ0BC0XKB3-YCIOrb-XPqDWdl7BD9gMX1CFyW4N3eHDzBGHnf7sE2KAAI-97KDE37-TagUfqDnotoi2MLuFDw'
token3 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tdmt4dnYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImY1MTk0NWFhLTZmODYtMTFlNy1iNDczLTAwMWE0YTIzMTRkNyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.3-qJT_9Vc4gMQ5Vb5gpIUhHHZngadDyo8LAwqmYaPhycZDgDJSX2FCEwkZP1A6V2V9YQc-c7IV4nT0Rkj8BOqcjuR49dVe2aEuW6iJsUFCWHS544oKVR8_sTj-5SNVQxQx5um9Bxkg3Go9YJx3hJqIJMfqh0bNVwepG868iDZ6xFtbmfzoh238y8ynCk_ZoqN_T2oRCtvgCs5k26VRJ6srC3VZ2z9yM1rvt3q-V3duBJQHH-QmTRfT9i8rIGrVnePQRHjgoeLhjqKHDi88i_wq7tyPLRo58NhPCndKI4fFCcTz3wy6SxF-O2ECzCUyEECP6VmTrM5aMOyRdtohh7eA'

# ---------------------------
# Delete all curent providers
# ---------------------------
delete_providers

# ---------------------------
# Create new curent providers
# ---------------------------
create_prov_with_auth('EngLab', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token1)
create_prov_with_auth('EngLab-mohawk', 'yzamir-centos7-2.eng.lab.tlv.redhat.com', token2)
#create_prov_with_auth('EngLab-prometheus', 'yzamir-centos7-3.eng.lab.tlv.redhat.com', token3)
create_prov_with_auth('EngLab-prometheus', 'hawkular.10.35.19.248.nip.io', token3)
