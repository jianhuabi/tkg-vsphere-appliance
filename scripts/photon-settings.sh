#!/bin/bash -eux

##
## Misc configuration
##

echo '> Disable IPv6'
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

echo '> Applying latest Updates...'
sed -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/$releasever/g' /etc/yum.repos.d/*.repo
tdnf -y update photon-repos
tdnf clean all
tdnf makecache
tdnf -y update

echo '> Installing Additional Packages...'
tdnf install -y \
  logrotate \
  wget \
  unzip \
  git \
  nano \
  diffutils \
  bindutils \
  dnsmasq \
  tar

echo '> Creating directory for setup and demo scripts'
mkdir -p /root/setup
mkdir -p /root/demo

echo ' > Creating directory for Harbor Certificates...'
mkdir -p /etc/docker/certs.d/registry.rainpole.io/

echo ' > Downloading Harbor...'
HARBOR_VERSION=2.1.2
curl -L https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-offline-installer-v${HARBOR_VERSION}.tgz -o harbor-offline-installer-v${HARBOR_VERSION}.tgz
tar xvzf harbor-offline-installer*.tgz
rm -f harbor-offline-installer-v${HARBOR_VERSION}.tgz

echo '> Downloading docker-compose...'
DOCKER_COMPOSE_VERSION=1.27.4
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo '> Downloading kubectl...'
KUBECTL_VERSION=1.18.10
curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

echo ' Downloading Octant...'
OCTANT_VERSION=0.16.1
curl -L https://github.com/vmware-tanzu/octant/releases/download/v${OCTANT_VERSION}/octant_${OCTANT_VERSION}_Linux-64bit.rpm -o octant_${OCTANT_VERSION}_Linux-64bit.rpm
rpm -ivh octant_${OCTANT_VERSION}_Linux-64bit.rpm
rm -f octant_${OCTANT_VERSION}_Linux-64bit.rpm

echo ' Downloading TMC...'
TMC_VERSION=0.1.0-6867ad54
curl -L https://vmware.bintray.com/tmc/${TMC_VERSION}/linux/x64/tmc -o /usr/local/bin/tmc
chmod +x /usr/local/bin/tmc

echo ' Downloading helm...'
HELM_VERSION=3.3.4
wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
rm -f helm-v${HELM_VERSION}-linux-amd64.tar.gz
chmod +x linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64/

echo ' Downloading Kube-PS1...'
curl -L https://github.com/jonmosco/kube-ps1/archive/v0.7.0.zip -o v0.7.0.zip
unzip v0.7.0.zip -d /root/setup/
rm -f v0.7.0.zip

echo ' Setup bashrc profile...'
echo "alias k='kubectl'" >> /root/.bashrc
echo 'source /root/setup/kube-ps1-0.7.0/kube-ps1.sh' >> /root/.bashrc
echo "PS1='\[\e[1;31m\]\u@\h [ \[\e[0m\]\w\[\e[1;31m\] ] \[\e[0m\]\$(kube_ps1) # '" >> /root/.bashrc

cat > /root/.bash_profile << EOF

KUBE_PS1_SYMBOL_ENABLE=false
KUBE_PS1_PREFIX=""

# include .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
EOF

## K8S DEMO Apps

echo ' Setting up yelb demo...'
git clone https://github.com/lamw/tkg-demos.git /root/demo

echo '> Done'
