# vagrant_M4_VMWare_Kind_BankCore
Kubernetes Cluster with Kind

# Vagrantfile M4 Users

Tested on MacBook Pro with Apple M4 processor, 

Install VMWare Fusion Pro for Mac v13.6.2
```
VMware_Fusion_V13.6.2.dmg
```
Install vagrant
```
brew install --cask vagrant
```
Install vagrant-vmware-desktop
```
vagrant plugin list
```
Search ubuntu image compatible with arm64 architecture
```
vagrant cloud search ubuntu --architecture arm64
``` 

Init Vagrantfile
```
vagrant init -m bento/ubuntu-24.04   

```
Validating Vagrant file
Installing the latest Docker, containerlab and KIND version (Review Vagrantfile)
Validating Vagrant box list

```
vagrant box list 
```
Run vagrant
```
vagrant up --provider=vmware_desktop
```
Accessing with ssh to nodes defined
```
vagrant ssh default

```
Use the deploy.sh for create the Kubernetes nodes

Use the topology.sh for create the Kubernetes topology



