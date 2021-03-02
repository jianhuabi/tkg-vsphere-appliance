#!/bin/bash
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

set -euo pipefail

# Extract all OVF Properties
TKG_DEBUG=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.debug" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
HOSTNAME=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.hostname" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
IP_ADDRESS=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.ipaddress" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
NETMASK=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.netmask" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}' | awk -F ' ' '{print $1}')
GATEWAY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.gateway" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
DNS_SERVER=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.dns" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
DNS_DOMAIN=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.domain" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
NTP_SERVER=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.ntp" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
HTTP_PROXY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.http_proxy" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
HTTPS_PROXY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.https_proxy" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
PROXY_USERNAME=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.proxy_username" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
PROXY_PASSWORD=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.proxy_password" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
NO_PROXY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.no_proxy" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
ROOT_PASSWORD=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.root_password" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
ROOT_SSH_KEY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.root_ssh_key" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')

if [ -e /root/ran_customization ]; then
    exit
else
	VEBA_LOG_FILE=/var/log/bootstrap.log
	if [ ${TKG_DEBUG} == "True" ]; then
		VEBA_LOG_FILE=/var/log/bootstrap-debug.log
		set -x
		exec 2>> ${VEBA_LOG_FILE}
		echo
        echo "### WARNING -- DEBUG LOG CONTAINS ALL EXECUTED COMMANDS WHICH INCLUDES CREDENTIALS -- WARNING ###"
        echo "### WARNING --             PLEASE REMOVE CREDENTIALS BEFORE SHARING LOG            -- WARNING ###"
        echo
	fi

	echo -e "\e[92mStarting Customization ..." > /dev/console

	echo -e "\e[92mStarting OS Configuration ..." > /dev/console
	. /root/setup/setup-01-os.sh

	echo -e "\e[92mStarting Network Proxy Configuration ..." > /dev/console
	. /root/setup/setup-02-proxy.sh

	echo -e "\e[92mStarting Network Configuration ..." > /dev/console
	. /root/setup/setup-03-network.sh

	echo -e "\e[92mStarting TKG Configuration ..."> /dev/console
	. /root/setup/setup-04-tkg.sh &

	echo -e "\e[92mStarting OS Banner Configuration ..."> /dev/console
	. /root/setup/setup-09-banner.sh &

	echo -e "\e[92mStarting Harbor Registry ..."> /dev/console
	cd /root/harbor
    docker-compose start

	# Clear guestinfo.ovfEnv
	vmtoolsd --cmd "info-set guestinfo.ovfEnv NULL"

	echo -e "\e[92mCustomization Completed ..." > /dev/console

	# Ensure we don't run customization again
	touch /root/ran_customization
fi