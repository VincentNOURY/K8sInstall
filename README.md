# K8sInstall

## Context

After getting a lot of issues with kubernetes crashing on the master node, I finally found how to install it without crashing (for now).

So I made this script :
 - To remember how to install it later
 - To help other that might have the same issues

This script installs kubeadm and kubelet.
It might take some time to run, let it run.

## Disclaimer

Please use this script with caution if something goes wrong it might ruin your installation and you might need to reinstall the host OS. So be carefull with it.

I cannot be held accountable for any issues with the usage of this script.

This script is only meant to be run on debian OS (it might be ok for debian-based OS but it was only tested on debian 11).

## Usage


```shell
wget https://raw.githubusercontent.com/VincentNOURY/K8sInstall/main/script.sh
bash script.sh
```

## Known issues

- [ ] The script outputs a lot of useless informations
- [ ] The script does not contain any checks to ensure the installation is correct
- [ ] The script does not have a verbose mode
