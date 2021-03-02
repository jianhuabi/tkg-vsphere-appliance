#!/bin/bash
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

# OS Specific Settings where ordering does not matter

set -euo pipefail

echo -e "\e[92mConfiguring OS Root password ..." > /dev/console
echo "root:${ROOT_PASSWORD}" | /usr/sbin/chpasswd

echo -e "\e[92mConfiguring Root SSH Keys ..." > /dev/console
echo "${ROOT_SSH_KEY}" >> /root/.ssh/authorized_keys

echo -e "\e[92mConfiguring SSH forwarding ..." > /dev/console
sed -i 's/^AllowTcpForwarding.*/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
systemctl restart sshd

echo -e "\e[92mConfiguring Firewall ..." > /dev/console
# 8080 (Yelb Demo), 443,6443 (vSphere & K8s API)
iptables -A INPUT -p tcp --dport 8080 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 6443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
# Allow KIND container to reach local Harbor Registry
iptables -A INPUT -i docker0 -j ACCEPT
# Allow ICMP
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save