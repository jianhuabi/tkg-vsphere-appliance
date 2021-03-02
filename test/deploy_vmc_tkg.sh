#!/bin/bash
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

# Sample Shell Script to test deployment of TKG_APPLIANCE w/OpenFaaS Processor

OVFTOOL_BIN_PATH="/Applications/VMware OVF Tool/ovftool"
TKG_APPLIANCE_OVA="../output-vmware-iso/TKG-Demo-Appliance_1.1.0.ova"

# vCenter
DEPLOYMENT_TARGET_ADDRESS="192.168.30.200"
DEPLOYMENT_TARGET_USERNAME="administrator@vsphere.local"
DEPLOYMENT_TARGET_PASSWORD="VMware1!"
DEPLOYMENT_TARGET_DATACENTER="Primp-Datacenter"
DEPLOYMNET_TARGET_CLUSTER="Supermicro-Cluster"

TKG_APPLIANCE_NAME="TKG-DEMO-APPLIANCE"
TKG_APPLIANCE_IP="192.168.30.180"
TKG_APPLIANCE_HOSTNAME="tkg.primp-industries.com"
TKG_APPLIANCE_PREFIX="24 (255.255.255.0)"
TKG_APPLIANCE_GW="192.168.30.1"
TKG_APPLIANCE_DNS="192.168.30.1"
TKG_APPLIANCE_DNS_DOMAIN="primp-industries.com"
TKG_APPLIANCE_NTP="pool.ntp.org"
TKG_APPLIANCE_OS_PASSWORD="VMware1!"
TKG_APPLIANCE_NETWORK="VM Network"
TKG_APPLIANCE_DATASTORE="sm-vsanDatastore"
TKG_APPLIANCE_DEBUG="True"

### DO NOT EDIT BEYOND HERE ###

"${OVFTOOL_BIN_PATH}" \
    --powerOn \
    --noSSLVerify \
    --sourceType=OVA \
    --allowExtraConfig \
    --diskMode=thin \
    --name="${TKG_APPLIANCE_NAME}" \
    --net:"VM Network"="${TKG_APPLIANCE_NETWORK}" \
    --datastore="${TKG_APPLIANCE_DATASTORE}" \
    --prop:guestinfo.ipaddress=${TKG_APPLIANCE_IP} \
    --prop:guestinfo.hostname=${TKG_APPLIANCE_HOSTNAME} \
    --prop:guestinfo.netmask="${TKG_APPLIANCE_PREFIX}" \
    --prop:guestinfo.gateway=${TKG_APPLIANCE_GW} \
    --prop:guestinfo.dns=${TKG_APPLIANCE_DNS} \
    --prop:guestinfo.domain=${TKG_APPLIANCE_DNS_DOMAIN} \
    --prop:guestinfo.ntp=${TKG_APPLIANCE_NTP} \
    --prop:guestinfo.root_password=${TKG_APPLIANCE_OS_PASSWORD} \
    --prop:guestinfo.debug=${TKG_APPLIANCE_DEBUG} \
    "${TKG_APPLIANCE_OVA}" \
    "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/${DEPLOYMENT_TARGET_DATACENTER}/host/${DEPLOYMNET_TARGET_CLUSTER}"
