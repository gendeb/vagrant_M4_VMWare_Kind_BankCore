# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202510.26.0"
  config.vm.hostname = "core-bank"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "vmware_desktop" do |v|
    v.cpus = 4
    v.memory = 10240
    v.linked_clone = true
    v.gui = false
    v.vmx["vhv.enable"] = "TRUE"
    v.vmx["ethernet0.pcislotnumber"] = "160"
    v.vmx["board-id.reflectHost"] = "TRUE"
    v.vmx["hw.model.reflectHost"] = "TRUE"
    v.vmx["smc.present"] = "TRUE"
    v.vmx["ich7m.present"] = "FALSE"
  end

  config.vm.provision "shell", inline: <<-SHELL
    set -euo pipefail
    echo "Installing latest Docker Engine..."
    curl -fsSL https://get.docker.com | sh
    echo "Installing latest Kind (Kubernetes IN Docker)..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-arm64
    chmod +x kind
    mv kind /usr/local/bin/kind
    echo "Installing latest kubectl..."
    curl -LO https://dl.k8s.io/release/v1.32.0/bin/linux/arm64/kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    echo "Installing latest Containerlab..."
    bash -c "$(curl -sL https://get.containerlab.dev)"
    # Add vagrant user to docker group
    sudo usermod -aG docker vagrant
    echo "Setup complete! Run 'vagrant reload' once to activate Docker group."
    echo "After reload, try: kind create cluster --name test-cluster"
  SHELL

  config.vm.provision "shell", inline: "echo 'All done! Run: vagrant reload && vagrant ssh'", run: "once"
end
