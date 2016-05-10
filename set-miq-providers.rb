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
# name      new providers name
# hostname  new providers hostname
# token     new providers token
def create_prov_with_auth(name, hostname, token)
  prov = ManageIQ::Providers::Openshift::ContainerManager.new(
    :hostname => hostname,
    :name => name,
    :port => 8443,
    :zone => Zone.first)
  prov.save

  AuthToken.create(
    :name => 'ManageIQ::Providers::Openshift::ContainerManager ' + name,
    :authtype => 'bearer',
    :userid => '_',
    :resource_id => prov.id,
    :resource_type => 'ExtManagementSystem',
    :type => 'AuthToken',
    :auth_key => token).save

  EmsRefresh.refresh(prov)
end

# ------------------------------------
# delete the providers in the database
# and add some new ones
# ------------------------------------

token1 = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tMThmaTAiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImQ5MjYyYjVjLThmN2ItMTFlNS1hODA2LTAwMWE0YTIzMTI5MCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.mWvcSwE6_WR8mHm_QBrXM_IHF9I9qOvfB-9Le-g7_DTrzEcM6Jy5smR6v7XmwRizjCheQJxbLjHmATxOXZGxyiG9ZXQGht1TcenCsLKJzxeVp5Lt3K9hdnFdXS9bXNHRav8VNpTwnjS2mRnzGQNxop2BJ1nGWU1mzMSyK5hWKoaUSVKsKwT1UyPfPC6_we-ygjhZpIbSxPEalzm_tjTUFSdWvUFlNBzUQrHvE0zoPxJ4sbbC5uNcaWo7aTey4eIcAn9vnPvNzHTJTIzbVyYIp65jehUr2QKD0CvGAjLWS_Pp-EeINOWaEQe_xNxK0IAl8b4uwhPVc-rRjFb4GkqVoQ'
token2 = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tc2ZscmkiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjM2ZjdmNWU2LTExZmUtMTFlNi1hMmJkLTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.BKoo2F8yAdUIbIkMvyCGZExTG-vCZtD39Xti7LqZHhnRlZQ-0xoJhvS1uYjLdzrMuuUNcS6HEtayFam5vEv5Z8jVEydfCps9OAlW52J_TlFa4vUlMaFRgXqASHrMRub-jgtUEmlllZcJ2AEEPcpBobB9lXDLDOyZ5RTIBEsRHhgdIY6NeEvC2dCuZQe9Y2LP9TvbpgCwyCOu2DsNlCmeLdbWeapJ5DhSuKc2_lLXmX-43O1-x-3glQI-D_-HpC-jlUzJOjA8W4QBIqYI5z5EoW4qhqhzgKG7sQQlMfygoy9QMVtJLSyo2lx0B7pruPcO6T3xOu7sn7cujmIcFMdawg'
token3 = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tYnk3YmUiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImNlNWI2ZTBlLTA1ZmQtMTFlNi04OTU2LTAwMWE0YTE2OTc5OSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.nwj1ptGn7h1xhsaSQk8xC38fgIA1dWgUmGQ_IRhh0HoALXaM5oOTlXGL90faCE_PJuWfaqnV7OW9SkX6SpP4NVRoZs9cJ32kRBWJorbWAV6AcFCpvGo1dSfnByTjkX_TmyrLfmWVG-45UTAX5ff7bqYZ7g0DN11oTnqW_PNwWOFVsC12PZJ73C-IzgRiLmyIUaVLKLVGBjAXo5RaEmUzfSAqgTwnpVb2IJqiaMcslR_PX8uB8PcbwELYd6OOndILT06kr2ZK9odE-Q0IB5nqOlBVJHPjC2Bj1j4yCgSKVQ2GCvpxcs5eCKU9T0EaDie849ICt-0-sWDjRCXqdWA7ew'

delete_providers
create_prov_with_auth('Molecule', 'oshift01.eng.lab.tlv.redhat.com', token1)
create_prov_with_auth('EngLab', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token2)
create_prov_with_auth('QaLab', 'ose-master.qa.lab.tlv.redhat.com', token3)

