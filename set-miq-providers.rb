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
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tMHMwcHIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjVjMWM1OGIyLTYwOWItMTFlNy05YWM3LTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.QVnD-lH3GFD9DvL4Rsb_iTZt8LuOTAgYrPGlF8PebdJynAAGuSqlcZZspV4VKdCQT3AAJSlgI3NoQ_dCL84jGeQGir9MgVZtml8-6tBOAMWUp7InL_mDuXRpdIzHUKeqSCqAlmWu5doBL8DPBoFWIKktHrN2G7UH3ZOaKFQJNznCqPMP1cTj28G2sgn00emdRFukOflebKTN_ngYWmcus7by9U7WF42wDV7KDVn4EfbqWZPm3duZtiHx5YQVFhvSx-k8cWbSTuOrOU-gI6C97GuXqvO9uuKEIDIP5_2QIxm448cru9_FjVcVGo_c_z1n_7HpUd2lbo5BopvEz4YyPw'
token2 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4td204ZDUiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjE3YTc5N2FhLTYwOGQtMTFlNy04OGVlLTAwMWE0YTIzMTRkNiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.szUAHmA10p5DsIJaCJR1ijAgYTn-jhyspEfoKP_OSVByI_V80YNFGgTi7PHbs1O3p7LhNm-PUG9PsUcYZW2mgPZleYnysoZTb_yLNDmm7d6LiT6-mDlWWGPP0bouZGeM0UYVA-ZtgSvJtq2TlgRtK2PqXduw2I7n--rk4iHLyAddEuXyel1VqV93YJcCJm4bkrHuMsIjEaLT5X9XmBo7yQm47S2GrJCact_kml8EyqA491eRbPNmJ2O3Ku6BtPTaEm-XUdl9qXb9UIJNLfcXPV25XfiuZdbsF0paIG-C4Eo41PgupS45UAnCdziorm-gcwzxLxATFW_p7KmsePyZwQ'
token3 =
'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tODB2MXAiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjExOTY1NzYyLTYxN2MtMTFlNy04Mzc5LTAwMWE0YTIzMTRkNyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.aNzM79bGMy0JrIFOslMJ61dspa-GcH-rN4IRIkg8rD9lu__ZJYEO_YVQ4U2zYRQNyIQRMg7Bx3tImYJPp4N01yEzoSU4dxDfAqHbQMg_NGGW6f59QwoQ2I_KWuO_WcSSE8_tTnfaxbIZqf3rKHMOZDznTj-aYz20YFLh4AyIXkW6xX4WWYnzJ7uK4pbounW28bAspToI6EspUuckH8WH9RNncA5UxcfnBY6qslbvRAyZ1idK9WXIfEzcoQwg_Njtao6MhNqR2Sp9tRta1-fnWQRgjeU_NCjmenkUotBZi3XY14jdGzzPm2WigU8epYRXDZRuLnS0sfxp3a3qH-vgTw'

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


