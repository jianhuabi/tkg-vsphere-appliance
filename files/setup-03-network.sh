#!/bin/bash
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

# Setup Networking

set -euo pipefail

echo -e "\e[92mConfiguring Static IP Address ..." > /dev/console

NETWORK_CONFIG_FILE=$(ls /etc/systemd/network | grep .network)

cat > /etc/systemd/network/${NETWORK_CONFIG_FILE} << __CUSTOMIZE_PHOTON__
[Match]
Name=e*

[Network]
Address=${IP_ADDRESS}/${NETMASK}
Gateway=${GATEWAY}
DNS=${IP_ADDRESS}
Domain=${DNS_DOMAIN}
__CUSTOMIZE_PHOTON__

echo -e "\e[92mConfiguring NTP ..." > /dev/console
cat > /etc/systemd/timesyncd.conf << __CUSTOMIZE_PHOTON__

[Match]
Name=e*

[Time]
NTP=${NTP_SERVER}
__CUSTOMIZE_PHOTON__

echo -e "\e[92mConfiguring hostname ..." > /dev/console
echo "${IP_ADDRESS} ${HOSTNAME}" >> /etc/hosts
hostnamectl set-hostname ${HOSTNAME}

echo -e "\e[92mRestarting Network ..." > /dev/console
systemctl restart systemd-networkd

echo -e "\e[92mRestarting Timesync ..." > /dev/console
systemctl restart systemd-timesyncd

# Handle resolve conf
echo -e "\e[92mConfiguring /etc/hosts ..." > /dev/console
echo "${IP_ADDRESS}   registry.rainpole.io" >> /etc/hosts

echo -e "\e[92mConfiguring and enabling dnsmasq ..." > /dev/console
# DNSMASQ
cat > /etc/dnsmasq.conf << __DNSMASQ__
listen-address=127.0.0.1,${IP_ADDRESS}
interface=lo,eth0
bind-interfaces
expand-hosts
bogus-priv
__DNSMASQ__

for DNS in ${DNS_SERVER[@]};
do
    echo "server=${DNS}" >> /etc/dnsmasq.conf
done

systemctl start dnsmasq
systemctl enable dnsmasq
systemctl restart docker