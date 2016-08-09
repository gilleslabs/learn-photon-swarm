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
sudo sed -i -e 's/photon/node1/g' /etc/hosts
sudo sed -i -e 's/photon/node1/g' /etc/hostname
sudo hostname node1
sudo sed -i -e 's/# End \/etc\/systemd\/scripts\/iptables//g' /etc/systemd/scripts/iptables
sudo echo "# Allowing Docker remote access" >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p tcp --dport 2375 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p tcp --dport 2376 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p tcp --dport 2377 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p tcp --dport 7946 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p tcp --dport 4789 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p udp --dport 7946 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p udp --dport 4789 -j ACCEPT >> /etc/systemd/scripts/iptables
sudo echo iptables -t filter -A INPUT -s 10.154.128.0/24 -p icmp -j ACCEPT >> /etc/systemd/scripts/iptables
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
sudo tdnf install tar -y
sudo echo "Upgrading Docker" && source ~/.profile && cd ~/ && wget https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz && tar -xvzf docker-latest.tgz
sudo mv ~/docker/* /usr/bin/

#Setting up proxy stuff for docker

sudo mkdir /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/http-proxy.conf
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<COW
[Service]
Environment="HTTP_PROXY=http://10.154.128.254:3128/"
Environment="HTTPS_PROXY=http://10.154.128.254:3128/"
COW

###Remote access enable (docker)
sudo sed -i -e 's/daemon//g' /usr/lib/systemd/system/docker.service
sudo sed -i -e 's/\/usr\/bin\/docker/\/usr\/bin\/dockerd/g' /usr/lib/systemd/system/docker.service
sudo sed -i -e 's/--containerd \/run\/containerd.sock//g' /usr/lib/systemd/system/docker.service
sudo echo DOCKER_OPTS="$DOCKER_OPTS --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375" > /etc/default/docker
sudo systemctl daemon-reload && systemctl restart docker
sudo systemctl enable docker


sudo curl http://10.154.128.101/index.html | sed -n '/docker/,/2377/p' | (head -n3) > start.sh && chmod +x start.sh && ./start.sh


