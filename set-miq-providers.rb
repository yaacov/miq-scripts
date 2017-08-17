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
def create_prov_with_auth(name, hostname, token, metrics_hostname=nil, role=:hawkular)
  metrics_hostname ||= hostname
  prov = ManageIQ::Providers::Openshift::ContainerManager.new(
    :name                      => name,
    :zone                      => Zone.last,
    :connection_configurations => [{:endpoint       => {:role       => :default,
                                                        :hostname   => hostname,
                                                        :port       => "8443",
                                                        :verify_ssl => false},
                                    :authentication => {:role     => :bearer,
                                                        :auth_key => token}},
                                   {:endpoint       => {:role       => role,
                                                        :hostname   => metrics_hostname,
                                                        :port       => "443",
                                                        :verify_ssl => false},
                                    :authentication => {:role     => role,
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
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tejBncmYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjEzYjgxZjI0LTcyOTktMTFlNy04MjIxLTAwMWE0YTIzMTRkNyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.G_ht7AJi1sd73vH8fO8_fZyjYA2-Qpz_M2DJ0JrjiBTBzISfJcUZETLN_ZRQUhqicWtEe3YWmN2lVY-7OoAl24v5mr-_9Qax_p44TUzBgNqng0wl-kXi4Ay6uoTtf470w0QuBMgJGnB05-nxA52G24doZQG493wGqxmKr5OLePJ0cg7vlG6wUjxznbG-u8lQM1qt59CHKzxPc_pgWMtSBHlXisuYV9dwNFLlfvwIHQZwc1qq72eMud9PtorD6QontuHAARLNTieCtrjlKk6-EFH5zOWXDukNyFPcMD43FGLqBxFkqboHaa04iEivViUrmXVvB6CqkOZoNPxSrG98LQ'

# ---------------------------
# Delete all curent providers
# ---------------------------
#delete_providers

# ---------------------------
# Create new curent providers
# ---------------------------
create_prov_with_auth('EngLab', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token1)
create_prov_with_auth('EngLab-mohawk', 'yzamir-centos7-2.eng.lab.tlv.redhat.com', token2)
create_prov_with_auth('EngLab-prometheus', 'yzamir-centos7-3.eng.lab.tlv.redhat.com', token3, 'prometheus.10.35.19.248.nip.io', :prometheus)
