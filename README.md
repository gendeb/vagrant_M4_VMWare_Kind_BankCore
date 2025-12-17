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
Use the Vagrantfile, it defines: Image for Ubuntu, v.cpus and v.memory, Docker, Containerlab and KIND


Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202510.26.0"
  config.vm.hostname = "core-bank"
  config.vm.synced_folder ".", "/vagrant", disabled: true

Once that you get in the VM using vagrant ssh into VMGuest you should run
Use the deploy.sh for create the Kubernetes nodes

```
chmod +x deploy.sh
./deploy.sh
```
this shell is using kind-cluster.yaml and manifests/all.yaml

To validate the cluster is running properly
```
kind get clusters
kubectl cluster-info
kubectl get nodes
```
to get the kubernetes services are the namespaces
```
kubectl get svc --all-namespaces
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep control-plane
```
How to list and map everything inside the cluster
```
kubectl get all -A
```

Use the topology.sh for create the Kubernetes topology







