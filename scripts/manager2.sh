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
sudo echo "export https_proxy=http://10.154.128.254:8000/" >> /etc/profile
sudo echo "export http_proxy=http://10.154.128.254:8000/" >> /etc/profile
sudo echo "#End /etc/profile" >> /etc/profile 
sudo echo "export https_proxy=http://10.154.128.254:8000/" > ~/.profile
sudo echo "export http_proxy=http://10.154.128.254:8000/" >> ~/.profile


# Adding proxy support for tdnf
sudo echo proxy=http://10.154.128.254:8000 >> /etc/tdnf/tdnf.conf

#Upgrading docker

sudo tdnf install docker -y

#Setting up proxy stuff for docker

sudo mkdir /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/http-proxy.conf
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<COW
[Service]
Environment="HTTP_PROXY=http://10.154.128.254:8000/"
Environment="HTTPS_PROXY=http://10.154.128.254:8000/"
COW

#Start docker and enable it to be started at boot time
sudo systemctl enable docker

###Remote access enable (docker)

sudo echo DOCKER_OPTS="$DOCKER_OPTS --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375" > /etc/default/docker
systemctl daemon-reload && systemctl restart docker


sudo tdnf install wget -y
sudo tdnf install tar -y

#### Setting up zookeeper (to be studied tdnf installation of zookeeper instead)

###OpenJDK not installed by default

sudo tdnf install openjdk -y



sudo mkdir -p /opt/swarm && cd /opt/swarm && source /etc/profile && wget http://apache.mivzakim.net/zookeeper/stable/zookeeper-3.4.8.tar.gz
sudo tar -xf zookeeper-3.4.8.tar.gz && mv zookeeper-3.4.8 zookeeper
sudo mkdir /var/lib/zookeeper

sudo tee /opt/swarm/zookeeper/conf/zoo.cfg<<CAT
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/var/lib/zookeeper
clientPort=2181
server.1=10.154.128.101:2888:3888
server.2=10.154.128.102:2888:3888
CAT

sudo echo 2 > /var/lib/zookeeper/myid

sudo tee /etc/systemd/system/zookeeper.service<<DOG
[Unit]
Description=Apache ZooKeeper
After=network.target
 
[Service]
Environment="JAVA_HOME=/var/opt/OpenJDK-1.8.0.92-bin"
WorkingDirectory=/opt/swarm/zookeeper
ExecStart=/bin/bash -c "/opt/swarm/zookeeper/bin/zkServer.sh start-foreground"
Restart=on-failure
RestartSec=20
User=root
Group=root
 
[Install]
WantedBy=multi-user.target
DOG

sudo tdnf install netcat -y
sudo systemctl enable zookeeper
sudo systemctl start zookeeper


##### After zookeeper ok on both hosts

##### Setting up swarm
sudo docker run -d --name=manager2 -p 8888:2375 swarm manage --replication --advertise 10.154.128.102:8888 zk://10.154.128.101,10.154.128.102/swarm
sudo docker run -d --name=dns -p 53:53/udp --link manager2:swarm ahmet/wagl wagl --swarm tcp://swarm:2375


