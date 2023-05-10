# K8sInstall

## Context

After getting a lot of issues with kubernetes crashing on the master node, I finally found how to install it without crashing (for now).

So I made this script :
 - To remember how to install it later
 - To help other that might have the same issues

This script installs kubeadm and kubelet.
It might take some time to run, let it run.

## Disclaimer

⚠️ Please use this script with caution if something goes wrong it might ruin your installation and you might need to reinstall the host OS. So be carefull with it.

⚠️ This script moves containerd.sock to /root to avoid conflicts, so if you need containerd running DO NOT USE THIS SCRIPT.

⚠️ This script is only meant to be run on debian OS (it might be ok for debian-based OS but it was only tested on debian 11).

I cannot be held accountable for any issues with the usage of this script.

## Usage

```bash
curl -L https://raw.githubusercontent.com/VincentNOURY/K8sInstall/main/script.sh | bash
```
OR
```bash
wget https://raw.githubusercontent.com/VincentNOURY/K8sInstall/main/script.sh
bash script.sh
```

## Miscelaneous informations

This script uses [cri-dockerd](https://github.com/Mirantis/cri-dockerd) and is based on the [official k8s documentation](https://kubernetes.io/docs/tasks/tools) (at the time of writing) and [official docker documentation](https://docs.docker.com/engine/install/debian).

Especially these steps (in this order) :
 - [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux)
 - [Install Docker](https://docs.docker.com/engine/install/debian)
 - [Install cri-dockerd](https://github.com/Mirantis/cri-dockerd)
 - [Installing kubeadm, kubelet and kubectl](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)
 - [Calico documentation](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)
 - Moving containerd.sock -> /root to avoid conflicts with cri-dockerd (Because I couldn't find how to specify it when using kubeadm init 😅)

## Known issues

- [ ] The script outputs a lot of useless informations
- [ ] The script does not contain any checks to ensure the installation is correct
- [ ] The script does not have a verbose mode


## Issues

If you find anything problematic with this script or if it doesn't work anymore please open an issue with the OS you are using, a screenshot of the error message and any usefull information.
