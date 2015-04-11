# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "ubuntu-12.04" do |ubuntu|
    ubuntu.vm.box = "hashicorp/precise64"
  end

  config.vm.define "fedora-21" do |fedora|
    fedora.vm.box = "hansode/fedora-21-server-x86_64"
  end

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
  
    # # Customize the amount of memory on the VM:
    # vb.memory = "1024"
  end
end
