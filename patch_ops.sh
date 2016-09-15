#!/bin/bash

# Install hawkular python client
pip install hawkular-client

# Add default hawkular server configuration
rm -rf /etc/openshift_tools/hawk_client.yaml
cp hawk_client.yaml /etc/openshift_tools/

# Replace the monitoring library
rm -rf /usr/lib/python2.7/site-packages/openshift_tools/monitoring/*
cp -f ./openshift-tools/openshift_tools/monitoring/* /usr/lib/python2.7/site-packages/openshift_tools/monitoring/

