#!/bin/bash
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

set -euo pipefail

echo -e "\e[92mUpdating TKG templates referencing localy Harbor registry ..." > /dev/console

# Thanks to Ryan Johnson for registry.rainpole.io #

# ~/.tkg/providers/infrastructure-vsphere/ytt/vsphere-overlay.yaml

cat > /root/.tkg/providers/infrastructure-vsphere/ytt/vsphere-overlay.yaml <<EOF
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind":"KubeadmControlPlane"})
---
apiVersion: controlplane.cluster.x-k8s.io/v1alpha3
kind: KubeadmControlPlane
spec:
  kubeadmConfigSpec:
    preKubeadmCommands:
    #! Add nameserver to all k8s nodes
    #@overlay/append
    - echo "${IP_ADDRESS}   registry.rainpole.io" >> /etc/hosts

#@overlay/match by=overlay.subset({"kind":"KubeadmConfigTemplate"})
---
apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
kind: KubeadmConfigTemplate
spec:
  template:
    spec:
      preKubeadmCommands:
      #! Add nameserver to all k8s nodes
      #@overlay/append
      - echo "${IP_ADDRESS}   registry.rainpole.io" >> /etc/hosts
EOF