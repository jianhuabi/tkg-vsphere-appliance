# Sample PowerShell Script to deploy VMware Appliance for F@H to vCenter Server from Windows

$OVFTOOL_BIN_PATH="C:\Program Files\VMware\VMware OVF Tool\ovftool.exe"
$FAH_OVA="TKG-Demo-Appliance-1.2.1.ova"

# vCenter
$DEPLOYMENT_TARGET_ADDRESS="vc.bri.com"
$DEPLOYMENT_TARGET_USERNAME="administrator@vsphere.local"
$DEPLOYMENT_TARGET_PASSWORD="VMware1!"
$DEPLOYMENT_TARGET_DATACENTER="Datacenter-WCP"
$DEPLOYMNET_TARGET_CLUSTER="tkg-cluster"

$FAH_NAME="tkg-demo-app"
$FAH_CPU_COUNT="4"
$FAH_IP="10.2.9.40"
$FAH_HOSTNAME="tkg-demo-app.bri.com"
$FAH_PREFIX="21 (255.255.248.0)"
$FAH_GW="10.2.8.1"
$FAH_DNS="10.2.9.34"
$FAH_DNS_DOMAIN="bri.com"
$FAH_NTP="10.2.76.21"
$FAH_OS_PASSWORD="VMware1!"
$FAH_NETWORK="VM Network"
$FAH_DATASTORE="vsanDatastore"
$FAH_DEBUG="True"
$FAH_USERNAME="root"

### DO NOT EDIT BEYOND HERE ###

& "${OVFTOOL_BIN_PATH}" `
--powerOn `
--noSSLVerify `
--sourceType=OVA `
--allowExtraConfig `
--diskMode=thin `
--numberOfCpus:*=${FAH_CPU_COUNT} `
--name="${FAH_NAME}" `
--net:"VM Network"="${FAH_NETWORK}" `
--datastore="${FAH_DATASTORE}" `
--prop:guestinfo.ipaddress=${FAH_IP} `
--prop:guestinfo.hostname=${FAH_HOSTNAME} `
--prop:guestinfo.netmask="${FAH_PREFIX}" `
--prop:guestinfo.gateway=${FAH_GW} `
--prop:guestinfo.dns=${FAH_DNS} `
--prop:guestinfo.domain=${FAH_DNS_DOMAIN} `
--prop:guestinfo.ntp=${FAH_NTP} `
--prop:guestinfo.root_password=${FAH_OS_PASSWORD} `
--prop:guestinfo.debug=${FAH_DEBUG} `
"${FAH_OVA}" `
"vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/${DEPLOYMENT_TARGET_DATACENTER}/host/${DEPLOYMNET_TARGET_CLUSTER}"
