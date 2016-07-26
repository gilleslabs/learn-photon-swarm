# -*- mode: ruby -*-
# vi: set ft=ruby :

################################################################################################################
#                                                                                                              #
# Vagrantfile for provisioning ready-to-go Squid Proxy for learn-photon-swarm								   #                                                                                                              #
# Author: Gilles Tosi                                                                                          #
#                                                                                                              #
# The up-to-date version and associated dependencies/project documentation is available at:                    #
#                                                                                                              #
# https://github.com/gilleslabs/learn-photon-swarm                                                             #
#                                                                                                              #
################################################################################################################



######################################################################################################
#                                                                                                    #
#      Setup of $squid variable which will be used for squid VM Shell inline provisioning            #
#                                                                                                    #
######################################################################################################



$squid = <<SQUID

################     Installing Squid            ###################

sudo apt-get update
sudo apt-get apt-get install -y squid-deb-proxy avahi-utils
sudo cp /vagrant/squid-deb-proxy.conf /etc/squid-deb-proxy/squid-deb-proxy.conf
sudo restart squid-deb-proxy
sudo apt-get install -y squid-deb-proxy-client
sudo apt-get install -y language-pack-en
SQUID

Vagrant.configure(2) do |config|

	config.vm.define "squid" do |squid|
        squid.vm.box = "ubuntu/trusty64"
			config.vm.provider "virtualbox" do |v|
				v.cpus = 2
				v.memory = 2048
			end
        squid.vm.network "private_network", ip: "10.154.128.254"
		squid.vm.provision :shell, inline: $squid
	end
end