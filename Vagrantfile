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



Vagrant.configure(2) do |config|

	##### Squid VM provisioning ######
	
	config.vm.define "squid" do |squid|
        squid.vm.box = "ubuntu/trusty64"
			config.vm.provider "virtualbox" do |v|
				v.cpus = 2
				v.memory = 2048
			end
        squid.vm.network "private_network", ip: "10.154.128.254"
		squid.vm.provision :shell, path: "./scripts/squid-2.sh"
	end
	
	##### Manager1 VM provisioning ######
	
	config.vm.define "manager1" do |manager1|
        manager1.vm.box = "photon"
		manager1.vm.synced_folder ".", "/vagrant", disabled: true
			config.vm.provider "virtualbox" do |v|
				v.cpus = 2
				v.memory = 2048
			end
		manager1.vm.network "private_network", ip: "10.154.128.101"
		manager1.vm.provision "shell", path: "./scripts/manager1-2.sh" 
		
	end
	
	##### Manager2 VM provisioning ######
	
	config.vm.define "manager2" do |manager2|
        manager2.vm.box = "photon"
		manager2.vm.synced_folder ".", "/vagrant", disabled: true
			config.vm.provider "virtualbox" do |v|
				v.cpus = 2
				v.memory = 2048
			end
		manager2.vm.network "private_network", ip: "10.154.128.102"
		manager2.vm.provision "shell", path: "./scripts/manager2-2.sh" 
		
	end

	##### Node1 VM provisioning ######
	
	config.vm.define "node1" do |node1|
        node1.vm.box = "photon"
		node1.vm.synced_folder ".", "/vagrant", disabled: true
			config.vm.provider "virtualbox" do |v|
				v.cpus = 2
				v.memory = 2048
			end
		node1.vm.network "private_network", ip: "10.154.128.103"
		node1.vm.provision "shell", path: "./scripts/node1-2.sh" 
		
	end
	
	##### Node2 VM provisioning ######
	
	config.vm.define "node2" do |node2|
        node2.vm.box = "photon"
		node2.vm.synced_folder ".", "/vagrant", disabled: true
			config.vm.provider "virtualbox" do |v|
				v.cpus = 2
				v.memory = 2048
			end
		node2.vm.network "private_network", ip: "10.154.128.104"
		node2.vm.provision "shell", path: "./scripts/node2-2.sh" 
		
	end
end