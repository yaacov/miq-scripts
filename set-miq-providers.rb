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
  #EmsRefresh.refresh(prov)
end

# ------
# Tokens
# ------
token1 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tcjRjMnQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImYzYzU1NWNlLTAwZTctMTFlOC04MDk3LTAwMWE0YTE2MjZkYiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.TJfDwlDxULPgVPBLuaYjLxxwDGYFQz7nKBlJuEqr8igzVcDc-2rSkvfUWQskyaNXEvpY3keOnWX-dME8__p4sua1XGyp13EYqyEmiPtWVnzmiC71EcTeUU6CGzTPJiE79lf9PdUUXO8TcrNBOtmM3B9KAhYNHILrVdjA5g8ujQb5LE3kCqhVLdcROmkDyt9SQlptfUmeDNcbEG09VkfSTo40P7QAmVopWQmW6QCrPEStubNffrAaelZY6tBK693uZqR6y_uYHSz0dULgXUm8oT8Aa-TnYvMJ9JkQKSsc-xOM9e1_C_jZn60e27q9c32cIkGaH7jw1V4zIAB6viAtGw'

# ---------------------------
# Delete all curent providers
# ---------------------------
delete_providers

# ---------------------------
# Create new curent providers
# ---------------------------

# yzamir-centos7-1.eng.lab.tlv.redhat.com
#create_prov_with_auth('EngLab-mohawk', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token1, 'moh.10.35.19.246.nip.io', :hawkular)
#create_prov_with_auth('EngLab-prometheus', 'master.10.35.19.246.nip.io', token1, 'prometheus.10.35.19.246.nip.io', :prometheus)

# jenkins
create_prov_with_auth('CMLab-promet', 'yaacov1-promet.10.35.48.219.nip.io', token1, 'prometheus-openshift-metrics.10.35.48.220.nip.io', :prometheus)
create_prov_with_auth('CMLab-mohawk', 'yaacov1-mohawk.10.35.48.219.nip.io', token1, 'mohawk.10.35.48.220.nip.io', :hawkular)
