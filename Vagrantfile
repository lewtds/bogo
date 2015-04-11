# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "ubuntu-12.04" do |ubuntu|
    ubuntu.vm.box = "hashicorp/precise64"
  end

  config.vm.define "fedora-21" do |fedora|
    fedora.vm.box = "hansode/fedora-21-server-x86_64"

script = <<SCRIPT
timedatectl set-local-rtc 0

CORE_DEPS="vala gtk2-devel gtk3-devel python3-devel"
TEST_DEPS="openbox xdotool dbus-x11 xorg-x11-server-Xvfb"
TEST_APPS="gvim geany libreoffice-writer inkscape terminator"
UTILS="byobu psmisc"

yum install -y $CORE_DEPS $TEST_DEPS $TEST_APPS $UTILS
yes | pip3 install bogo
SCRIPT

    fedora.vm.provision "shell", inline: script
  end

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
  
    # # Customize the amount of memory on the VM:
    # vb.memory = "1024"
  end
end
