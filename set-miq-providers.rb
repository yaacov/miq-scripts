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
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tbjZxMmsiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImE4ZjRhMzA5LTg3ZjMtMTFlNy05MDc4LTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.FTWdK2S-XGj_ZmyvQNS7GhrkC3yvhpC1NEBY56q8szoTsmjpERGM7Bf30dTi3uJuPHa9w2bN20EL3fLbDdW2VmadS5heiC-a50RfcG_TyAX4yayZIO4bh3X7Cp8tOnJGVy95TmtbnOz9eEae477J7DeOWryMBhhmdwY0wDwt4DgfAsDXUohTweDaM7jBBZJDZNntw1OQKM_02U8ALeYmVbWtA-mRcWv5FOIvk0jVobSPr_rNr0CItx986nxIOQuhZIgtF2jBsn_NhduChIhArAuqBiHNDIhsEvNKioxATS69NQxny_LjEPAvLlZs_fBG9qljlu7rc8i6Wfqy7g90_w'
token2 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tanRjdHoiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjhmOGI3OTM1LWJhNDUtMTFlNy04ZDcwLTAwMWE0YTIzMTRkNiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.SVJMAhxYIv25R_qK-dsMmG-EGlr7NnahL4SyChZMFNVG0WgIZwgYdE-p-qpH_SmaVeqtWmroY4-MbgKK5cvxII6vfGefMvfzBmHW1LigHRUDX2LGevYjDSljNnKuEG87pU2NdbJSH3Um2QmL5eQT83TCebfZebQnJnsj-1U9eNjNPm_aHbRi4_9bXRZ8qgqBtswUy2IUchVpQDeMuW_Qcl7xpBWNZBARVP_EP2B7xc2eHe9Wif7vsywuqe49fr4vnz2unsDoR5JXJjARNu-Un12nBjubisTp531oZKFdR4q3LPEd8qkXKoZlxg-zPXWOSG42miuwHPXaMkDdngkX_g'
token3='eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tenJwbWQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImIxNjlhODIxLWI3YzYtMTFlNy04NWY1LTUyNTQwMGQ2ZjRmMyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.hWI6l2SDQBkdNjnSRjUHyxxWmsUvrxafF5o-e1AzYekPUbeRM2vQEYB4lDwralU9nzEM1o_xGYOFwsuWsvwfaePWTt_nPgklV0sFKWWrw-aPRLxD_knhOuRAebwn4lXbXyckA12WbzFOYX7vMWiUYeD8Zd94pzRCwkfXbSyHSnDeh9rXqETOyxDnuTQfJzxgtsyzTkkqGz4fJ3lJL-QKSSp4maG3vMiZ9UOoKKBd8NAMcMrkburYDf4z8CXTHylN4P3vO8q5gYkt7--5_6CDFCIyExrSzW3AQRr_cpD-th2H5nP857nroX7kIqKkpJvvaPpBfOBBOH8NrCcO1IJEtA'

# ---------------------------
# Delete all curent providers
# ---------------------------
delete_providers

# ---------------------------
# Create new curent providers
# ---------------------------

# yzamir-centos7-1.eng.lab.tlv.redhat.com
create_prov_with_auth('EngLab-mohawk', 'yzamir-centos7-1.eng.lab.tlv.redhat.com', token1, 'moh.10.35.19.246.nip.io', :hawkular)
create_prov_with_auth('EngLab-prometheus', 'master.10.35.19.246.nip.io', token1, 'prometheus.10.35.19.246.nip.io', :prometheus)

# yzamir-centos7-2.eng.lab.tlv.redhat.com
create_prov_with_auth('EngLab-hawkular', 'yzamir-centos7-2.eng.lab.tlv.redhat.com', token2)

# mas-1.example.com
create_prov_with_auth('LocalVirt', 'mas-1.example.com', token3, 'pro-1.example.com', :prometheus)
