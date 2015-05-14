# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

$bootstrap = <<-SCRIPT
apt-get update -qq
apt-get install -y build-essential rubygems rpm
gem install fpm
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise64"

  config.vm.provision :shell, inline: $bootstrap
end

