#!/bin/bash -eux
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

##
## Configure Harbor
##

echo '> Configuring Harbor...'

# This is required as we need to setup Harbor initially to pre-download VMware images for air-gap/non-internet scenarios
# Customers can change the password after deployment with manual guidance
DEFAULT_HARBOR_PASSWORD='Tanzu1!'
HARBOR_CONFIG=harbor.yml

echo "127.0.0.1  registry.rainpole.io" >> /etc/hosts

# Update registry hostname + generated certificates (self-sign is NOT supported, must use a real certificate)
cd /root/harbor
mv /root/harbor/harbor.yml.tmpl /root/harbor/${HARBOR_CONFIG}
sed -i 's/hostname:.*/hostname: registry.rainpole.io/g' ${HARBOR_CONFIG}
sed -i 's/certificate:.*/certificate: \/etc\/docker\/certs.d\/registry.rainpole.io\/registry.rainpole.io.cert/g' ${HARBOR_CONFIG}
sed -i 's/private_key:.*/private_key: \/etc\/docker\/certs.d\/registry.rainpole.io\/registry.rainpole.io.key/g' ${HARBOR_CONFIG}
sed -i "s/harbor_admin_password:.*/harbor_admin_password: ${DEFAULT_HARBOR_PASSWORD}/g" ${HARBOR_CONFIG}
sed -i "s/password:.*/password: ${DEFAULT_HARBOR_PASSWORD}/g" ${HARBOR_CONFIG}
# Install Harbor
./install.sh
rm -f harbor.*.gz

# Sleep to wait for Harbor to be fully functional
sleep 90

# Login to harbor registry to be able to push images
docker login -u admin -p ${DEFAULT_HARBOR_PASSWORD} registry.rainpole.io/library

TKG_REPO=registry.tkg.vmware.run
#TKG_REPO=gcr.io/kubernetes-development-244305

LIST=(
${TKG_REPO}/antrea/antrea-debian:v0.9.3_vmware.1
${TKG_REPO}/azure-cloud-controller-manager:v0.5.1_vmware.2
${TKG_REPO}/azure-cloud-node-manager:v0.5.1_vmware.2
${TKG_REPO}/calico-all/cni-plugin:v3.11.3_vmware.1
${TKG_REPO}/calico-all/kube-controllers:v3.11.3_vmware.1
${TKG_REPO}/calico-all/node:v3.11.3_vmware.1
${TKG_REPO}/calico-all/pod2daemon:v3.11.3_vmware.1
${TKG_REPO}/ccm/manager:v1.2.1_vmware.1
${TKG_REPO}/cert-manager/cert-manager-cainjector:v0.16.1_vmware.1
${TKG_REPO}/cert-manager/cert-manager-controller:v0.16.1_vmware.1
${TKG_REPO}/cert-manager/cert-manager-webhook:v0.16.1_vmware.1
${TKG_REPO}/cluster-api/capd-manager:v0.3.10_vmware.1
${TKG_REPO}/cluster-api/capd-manager:v0.3.11-13-ga74685ee9_vmware.1
${TKG_REPO}/cluster-api/cluster-api-aws-controller:v0.6.2_vmware.1
${TKG_REPO}/cluster-api/cluster-api-aws-controller:v0.6.3_vmware.1
${TKG_REPO}/cluster-api/cluster-api-azure-controller:v0.4.8-47-gfbb2d55b_vmware.1
${TKG_REPO}/cluster-api/cluster-api-controller:v0.3.10_vmware.1
${TKG_REPO}/cluster-api/cluster-api-controller:v0.3.11-13-ga74685ee9_vmware.1
${TKG_REPO}/cluster-api/cluster-api-vsphere-controller:v0.7.1_vmware.1
${TKG_REPO}/cluster-api/kube-rbac-proxy:v0.4.1_vmware.2
${TKG_REPO}/cluster-api/kubeadm-bootstrap-controller:v0.3.10_vmware.1
${TKG_REPO}/cluster-api/kubeadm-bootstrap-controller:v0.3.11-13-ga74685ee9_vmware.1
${TKG_REPO}/cluster-api/kubeadm-control-plane-controller:v0.3.10_vmware.1
${TKG_REPO}/cluster-api/kubeadm-control-plane-controller:v0.3.11-13-ga74685ee9_vmware.1
${TKG_REPO}/cluster-autoscaler:v1.19.1_vmware.1
${TKG_REPO}/contour:v1.8.1_vmware.1
${TKG_REPO}/coredns:v1.6.7_vmware.6
${TKG_REPO}/coredns:v1.7.0_vmware.5
${TKG_REPO}/csi/csi-attacher:v2.0.0_vmware.2
${TKG_REPO}/csi/csi-livenessprobe:v1.1.0_vmware.8
${TKG_REPO}/csi/csi-node-driver-registrar:v1.2.0_vmware.2
${TKG_REPO}/csi/csi-provisioner:v2.0.0_vmware.1
${TKG_REPO}/csi/volume-metadata-syncer:v2.0.1_vmware.1
${TKG_REPO}/csi/vsphere-block-csi-driver:v2.0.1_vmware.1
${TKG_REPO}/dex:v2.22.0_vmware.2
${TKG_REPO}/envoy:v1.15.0_vmware.1
${TKG_REPO}/etcd:v3.4.13_vmware.4
${TKG_REPO}/etcd:v3.4.3_vmware.11
${TKG_REPO}/fluent-bit:v1.5.3_vmware.1
${TKG_REPO}/gangway:v3.2.0_vmware.2
${TKG_REPO}/grafana/grafana:v7.0.3_vmware.1
${TKG_REPO}/grafana/k8s-sidecar:v0.1.144_vmware.1
${TKG_REPO}/harbor/chartmuseum-photon:v2.0.2_vmware.1
${TKG_REPO}/harbor/clair-adapter-photon:v2.0.2_vmware.1
${TKG_REPO}/harbor/clair-photon:v2.0.2_vmware.1
${TKG_REPO}/harbor/harbor-core:v2.0.2_vmware.1
${TKG_REPO}/harbor/harbor-db:v2.0.2_vmware.1
${TKG_REPO}/harbor/harbor-jobservice:v2.0.2_vmware.1
${TKG_REPO}/harbor/harbor-log:v2.0.2_vmware.1
${TKG_REPO}/harbor/harbor-portal:v2.0.2_vmware.1
${TKG_REPO}/harbor/harbor-registryctl:v2.0.2_vmware.1
${TKG_REPO}/harbor/harbor-toolbox:v2.0.2_vmware.1
${TKG_REPO}/harbor/nginx-photon:v2.0.2_vmware.1
${TKG_REPO}/harbor/notary-server-photon:v2.0.2_vmware.1
${TKG_REPO}/harbor/notary-signer-photon:v2.0.2_vmware.1
${TKG_REPO}/harbor/prepare:v2.0.2_vmware.1
${TKG_REPO}/harbor/redis-photon:v2.0.2_vmware.1
${TKG_REPO}/harbor/registry-photon:v2.0.2_vmware.1
${TKG_REPO}/harbor/trivy-adapter-photon:v2.0.2_vmware.1
${TKG_REPO}/kapp-controller:v0.9.0_vmware.1
${TKG_REPO}/kind/node:v1.19.3_vmware.1
${TKG_REPO}/kube-apiserver:v1.18.10_vmware.1
${TKG_REPO}/kube-apiserver:v1.19.3_vmware.1
${TKG_REPO}/kube-controller-manager:v1.18.10_vmware.1
${TKG_REPO}/kube-controller-manager:v1.19.3_vmware.1
${TKG_REPO}/kube-proxy:v1.18.10_vmware.1
${TKG_REPO}/kube-proxy:v1.19.3_vmware.1
${TKG_REPO}/kube-scheduler:v1.18.10_vmware.1
${TKG_REPO}/kube-scheduler:v1.19.3_vmware.1
${TKG_REPO}/kube-vip:v0.2.0_vmware.1
${TKG_REPO}/pause:3.2
${TKG_REPO}/prometheus/alertmanager:v0.20.0_vmware.1
${TKG_REPO}/prometheus/cadvisor:v0.36.0_vmware.1
${TKG_REPO}/prometheus/configmap-reload:v0.3.0_vmware.1
${TKG_REPO}/prometheus/kube-state-metrics:v1.9.5_vmware.1
${TKG_REPO}/prometheus/prometheus:v2.18.1_vmware.1
${TKG_REPO}/prometheus/prometheus_node_exporter:v0.18.1_vmware.1
${TKG_REPO}/prometheus/pushgateway:v1.2.0_vmware.1
${TKG_REPO}/sonobuoy:v0.19.0_vmware.1
${TKG_REPO}/tanzu-connectivity/tanzu-connectivity-binder:v0.2.0_vmware.3
${TKG_REPO}/tanzu-connectivity/tanzu-connectivity-publisher:v0.2.0_vmware.3
${TKG_REPO}/tanzu-connectivity/tanzu-connectivity-registry:v0.2.0_vmware.3
${TKG_REPO}/tkg-connectivity/tanzu-registry-webhook:v1.2.0_vmware.2
${TKG_REPO}/tkg-connectivity/tkg-connectivity-operator:v1.2.0_vmware.2
${TKG_REPO}/tkg-extensions-templates:v1.2.0_vmware.1
${TKG_REPO}/tkg-telemetry:v1.2.0_vmware.1
${TKG_REPO}/tmc-extension-manager:v1.2.0_vmware.1
${TKG_REPO}/velero/data-manager-for-plugin:v1.0.2_vmware.1
${TKG_REPO}/velero/velero-plugin-for-aws:v1.1.0_vmware.1
${TKG_REPO}/velero/velero-plugin-for-microsoft-azure:v1.1.0_vmware.1
${TKG_REPO}/velero/velero-plugin-for-vsphere:v1.0.2_vmware.1
${TKG_REPO}/velero/velero-restic-restore-helper:v1.4.3_vmware.1
${TKG_REPO}/velero/velero:v1.4.3_vmware.1
)

newImageRepo="registry.rainpole.io\/library"
sourceDir="/root/.tkg"

/usr/local/bin/tkg get mc

# Fixes https://jira.eng.vmware.com/browse/TKG-3153
sed -i -e '400i\            - --default-fstype=ext4' /root/.tkg/providers/infrastructure-vsphere/v0.7.1/ytt/csi.lib.yaml

IGNORE=("registry.tkg.vmware.run/kind/node:v1.19.3_vmware.1" "registry.tkg.vmware.run/cert-manager/cert-manager-cainjector:v0.16.1_vmware.1" "registry.tkg.vmware.run/cert-manager/cert-manager-controller:v1.19.3_vmware.1" "registry.tkg.vmware.run/cert-manager/cert-manager-webhook:v0.16.1_vmware.1")

echo '> Start mirroring process'
for image in "${LIST[@]}"
do
    :
    image=${image//[$'\t\r\n ']}
    origImageRepo=$(echo "$image" | awk -F/ '{ print $1 }')
    imageDestination=$(echo -n "$image" | sed "s/$origImageRepo/$newImageRepo/g")
    #imageDestination=$(echo -n "$image" | sed "s/$origImageRepo/$newImageRepo/;s/kubernetes-development-244305\///g");
    echo "> Pushing $imageDestination"
    docker tag "$image" "$imageDestination"
    docker push "$imageDestination"

    # Leaves KIND image so pull isn't required for TKG init
    if [[ ! "${IGNORE[@]}" =~ "${imageDestination}" ]]; then
        docker rmi "$image"
        docker rmi "$imageDestination"
    else
        docker rmi "$image"
    fi
done

# Push K8s Demo Apps to local Harbor registry

DEMO_LIST=(
metallb/speaker:v0.9
metallb/controller:v0.9
mreferre/yelb-ui:0.3
mreferre/yelb-ui:0.6
mreferre/yelb-db:0.3
mreferre/yelb-db:0.5
mreferre/yelb-appserver:0.5
)

for image in "${DEMO_LIST[@]}"
do
    :
    image=${image//[$'\t\r\n ']}
    origImageRepo=$(echo "$image" | awk -F/ '{ print $1 }')
    imageDestination=$(echo -n "$image" | sed "s/$origImageRepo/$newImageRepo/g")
    echo "> Pushing $image $imageDestination"
    docker tag "$image" "$imageDestination"
    docker push "$imageDestination"
    docker rmi "$image"
    docker rmi "$imageDestination"
done

docker tag redis:4.0.2 registry.rainpole.io/library/redis:4.0.2
docker push registry.rainpole.io/library/redis:4.0.2
docker rmi redis:4.0.2
docker rmi registry.rainpole.io/library/redis:4.0.2

# Remove localhost entry for pre-setup
sed -i '/registry.rainpole.io/d' /etc/hosts

# Append custom repo to ensure TKG UI flow works
echo "TKG_CUSTOM_IMAGE_REPOSITORY: registry.rainpole.io/library" >> /root/.tkg/config.yaml