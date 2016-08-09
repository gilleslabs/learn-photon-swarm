#First doing the iptables stuff
sudo mv /etc/systemd/network/10-dhcp-en.network /etc/systemd/network/10-static-eth0.network
sudo tee /etc/systemd/network/10-static-eth0.network <<BUG
[Match]
Name=eth0

[Network]
Address=10.0.2.15/24
BUG
sudo systemctl restart systemd-networkd.service
sudo ip route delete default
sudo ip route
sudo sed -i -e 's/photon/manager1/g' /etc/hosts
sudo sed -i -e 's/photon/manager1/g' /etc/hostname
sudo hostname manager2
sudo sed -i -e 's/# End \/etc\/systemd\/scripts\/iptables//g' /etc/systemd/scripts/iptables
sudo echo "# Allowing Docker remote access" >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p tcp --dport 2375 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p tcp --dport 2376 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo "# Allowing Zookeeper" >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT  -p tcp --dport 2888 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT  -p tcp --dport 3888 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT  -p tcp --dport 2181 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p icmp -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p udp --dport 53 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo "# End /etc/systemd/scripts/iptables" >> /etc/systemd/scripts/iptables
sudo systemctl restart iptables

sudo sed -i -e 's/# End \/etc\/profile//g' /etc/profile
sudo echo "#Enabling Proxy" >> /etc/profile
sudo echo "export https_proxy=http://10.154.128.254:3128/" >> /etc/profile
sudo echo "export http_proxy=http://10.154.128.254:3128/" >> /etc/profile
sudo echo "#End /etc/profile" >> /etc/profile 
sudo echo "export https_proxy=http://10.154.128.254:3128/" > ~/.profile
sudo echo "export http_proxy=http://10.154.128.254:3128/" >> ~/.profile


# Adding proxy support for tdnf
sudo echo proxy=http://10.154.128.254:3128 >> /etc/tdnf/tdnf.conf

#Upgrading docker
sudo tdnf install wget -y
sudo wget https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz
sudo tar -xvzf docker-latest.tgz
sudo mv docker/* /usr/bin/

#Setting up proxy stuff for docker

sudo mkdir /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/http-proxy.conf
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<COW
[Service]
Environment="HTTP_PROXY=http://10.154.128.254:3128/"
Environment="HTTPS_PROXY=http://10.154.128.254:3128/"
COW

#Start docker and enable it to be started at boot time
sudo systemctl enable docker

###Remote access enable (docker)

sudo echo DOCKER_OPTS="$DOCKER_OPTS --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375" > /etc/default/docker
systemctl daemon-reload && systemctl restart docker


#### Setting up zookeeper container

docker run -d -e MYID=2 -e SERVERS=10.154.128.101,10.154.128.102 -v /var/lib/zookeeper:/tmp/zookeeper --name=zookeeper --net=host --restart=always mesoscloud/zookeeper:3.4.8-ubuntu-14.04

sudo tdnf install netcat -y


##### Setting up swarm
sudo docker run -d --name=manager2 -p 8888:2375 swarm manage --replication --advertise 10.154.128.102:8888 zk://10.154.128.101,10.154.128.102/swarm

#Setting up DNS on Manager 2
sudo docker run -d --name=dns -p 53:53/udp --link manager2:swarm ahmet/wagl wagl --swarm tcp://swarm:2375

##### Setting up DNS only for Manager1  
sudo docker -H=10.154.128.101:2375 run -d --name=dns -p 53:53/udp --link manager1:swarm ahmet/wagl wagl --swarm tcp://swarm:2375



