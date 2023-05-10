#!/bin/bash
SEP="========================================"

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"


function check_perms() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "$RED[ERROR] Please run as root$NC"
        exit
    fi
}



function kubectl_install() {
    echo -e "$GREEN[INFO] Downloading kubectl binary$NC"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    echo -e "$GREEN[INFO] Installing kubectl binary$NC"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    echo -e "$GREEN[INFO] Checking kubectl version$NC"
    kubectl version --client
    echo -e "$GREEN[INFO] Cleaning up$NC"
    rm kubectl
}

function docker_install() {
    echo -e "$GREEN[INFO] Installing docker$NC"

    echo -e "$GREEN[INFO] Installing dependencies$NC"
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y ca-certificates curl gnupg > /dev/null 2>&1

    echo -e "$GREEN[INFO] Adding docker's official GPG key$NC"
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update > /dev/null 2>&1

    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1

    echo -e "$GREEN[INFO] Checking docker version$NC"
    docker --version

    echo -e "$GREEN[INFO] Docker installed successfully$NC"
}


function cri_dockerd() {
    echo -e "$GREEN[INFO] Installing cri-dockerd$NC"

    echo -e "$GREEN[INFO] Installing dependencies$NC"

    sudo apt-get install -y git golang > /dev/null 2>&1

    echo -e "$GREEN[INFO] Cloning repo$NC"
    git clone https://github.com/Mirantis/cri-dockerd.git

    echo -e "$GREEN[INFO] Installing cri-dockerd$NC"

    

    cd cri-dockerd
    mkdir bin
    go build -o bin/cri-dockerd
    mkdir -p /usr/local/bin
    install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
    cp -a packaging/systemd/* /etc/systemd/system
    sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
    
    echo -e "$GREEN[INFO] Enabling cri-dockerd$NC"

    systemctl daemon-reload
    systemctl enable cri-docker.service
    systemctl enable --now cri-docker.socket

    echo -e "$GREEN[INFO] Cleaning up$NC"
    
    cd ..
    rm -rf cri-dockerd

    echo -e "$GREEN[INFO] cri-dockerd Installed$NC"
}

function kube_core_install() {
    echo -e "$GREEN[INFO] Installing kubeadm, kubelet and kubectl$NC"

    echo -e "$GREEN[INFO] Installing dependencies$NC"

    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y apt-transport-https ca-certificates curl > /dev/null 2>&1

    echo -e "$GREEN[INFO] Adding kubernetes' official GPG key$NC"

    sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    echo -e "$GREEN[INFO] Installing kubeadm, kubelet and kubectl$NC"

    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y kubelet kubeadm kubectl > /dev/null 2>&1
    sudo apt-mark hold kubelet kubeadm kubectl
    
    echo -e "$GREEN[INFO] kubeadm, kubelet and kubectl Installed$NC"
}

function move_containerd() {
    echo -e "$GREEN[INFO] Moving containerd$NC"

    mv /var/run/containerd/containerd.sock .
}

function main() {
    echo -e "$GREEN[INFO] Welcome to the k8s installation script$NC"
    check_perms

    echo $SEP
    kubectl_install
    echo $SEP

    echo $SEP
    docker_install
    echo $SEP

    echo $SEP
    cri_dockerd
    echo $SEP

    echo $SEP
    kube_core_install
    echo $SEP

    echo $SEP
    move_containerd
    echo $SEP

    echo $SEP
    echo $SEP
    echo $SEP
    echo -e "$GREEN[INFO] Installation complete$NC"
    echo -e "$GREEN[INFO] If this is the Master node please run the following
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16

    and keep the join command for your worker nodes the run (on the master node)"

    echo '
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml
    watch kubectl get pods -n calico-system


    and wait for the pods to be ready'

    echo -e "$NC"

    echo -e "$GREEN[INFO] If this is a worker node please run the kubeadm join comamnd from the master node$NC"
}

main | tee kubernetes_install.log