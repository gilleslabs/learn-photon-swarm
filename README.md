# Vagrant learn-photon-swarm

Vagrant learn-photon-swarm creates ready-to-go VMs for [Docker Photon Swarm] (https://github.com/vmware/photon/wiki/Install-and-Configure-a-Swarm-Cluster-with-DNS-Service-on-PhotonOS) evaluation/testing

The following is an overview of the ready-to-go VMs:

+ **manager1:** Swarm Manager cluster node with zookeeper ID 1 and wagl installed 
+ **manager2:** Swarm Manager cluster node with zookeeper ID 1 and wagl installed
+ **node1   :** Swarm node
+ **node2   :** another swarm node
+ **squid   :**  an Ubuntu (Ubuntu 14.04 Trusty Tahr) VMs serving as proxy for all other VMs

## Requirements

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Tested on 5.0.20, but should also work on 5.0.20+ release.
- [Vagrant](http://www.vagrantup.com/downloads.html). Tested on 1.7.4
- [Photon-vbguest plugin] (https://github.com/vmware/vagrant-guests-photon). Tested on v1.0.3
- [Packer] (https://www.packer.io/) - Tested with version in photon-packer-template folder
- [RoyalTS] (https://www.royalapplications.com/ts/win/features) - Optional
- Your workstation must have a direct internet connection (not via proxy - if your internet connection is behind a proxy, please check Virtualbox and Vagrant documentation to update Vagrantfile)

All VMs are provisioned using ubuntu/trusty64 (Ubuntu 14.04 Trusty Tahr) 

## VMs details

VM | vCPU/vRAM | IP Address| user/password | root / Administrator password |
---|---|---|---|---|
**manager1** | 2vCPU/2048 MB | 10.154.128.101 | Not Applicable | vagrant |
**manager2** | 2vCPU/2048 MB | 10.154.128.102 | Not Applicable | vagrant |
**node1** | 2vCPU/2048 MB | 10.154.128.103 | Not Applicable | vagrant |
**node2** | 2vCPU/2048 MB | 10.154.128.104 | Not applicable | vagrant |
**squid** | 2vCPU/2048 MB | 10.154.128.254 | vagrant/vagrant | vagrant |

+ **Recommended hardware :** Computer with Multi-core CPU and 16GB+ memory
+ **Note :** If your computer hardware is less than 16GB memory you should decrease vRAM in Vagrantfile, PhotonOS and Ubuntu should work fine with 512MB but with less performances

## Installation

#### Getting started:

Run the commands below:

	git clone https://github.com/gilleslabs/learn-photon-swarm
	cd learn-photon-swarm


#### Prepare photon Vagrant Box:

At the time of writing (July 23rd, 2016) the [vmware/photon box] (https://atlas.hashicorp.com/vmware/boxes/photon) is not working properly (issue with vagrant networking).
As a consequence we need first to create a working vagrant box (**this as to be done only once**)


###### Steps for creating photon vagrant box:

1. Run the command below:
	```
	cd photon-packer-template
	packer build -only=vagrant-virtualbox packer-photon.json
	```


2. Packer build should take about 25 minutes to complete depending on your hardware and internet connection speed. 

3. When build is completed import the box with below command:
	```
	vagrant box add photon
	```

#### Launching the whole environment:

1. Run the command below:

	```
	vagrant up
	```

2. The setup will take some time to finish (approximatively 15 minutes depending on your hardware). Sit back and enjoy!

3. When the setup is done you will be able to connect to any of the VMs using your favorite ssh client and credentials provided in [VMs details] (https://github.com/gilleslabs/learn-photon-swarm#vms-details) 

**Note :** if you use RoyalTS, the session folder contains a RoyalTS document already configured with VMs IP and credentials.

## Known issues

Sometimes ssh connections fail, just ping the target server and this should fix the issue.

## Credits

This project was totally inspired from [Install and Configure a Swarm Cluster with DNS Service on PhotonOS](https://github.com/vmware/photon/wiki/Install-and-Configure-a-Swarm-Cluster-with-DNS-Service-on-PhotonOS)
Packer photon templates has been customized from [Photon Packer Templates] (https://github.com/vmware/photon-packer-templates)

## MIT

Copyright (c) 2016 Gilles Tosi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE