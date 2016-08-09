
	################     Installing Docker            ###################
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo touch /etc/apt/sources.list.d/docker.list
sudo rm /etc/apt/sources.list.d/docker.list
sudo echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list
sudo apt-get update -y
sudo apt-get purge lxc-docker
sudo apt-cache policy docker-engine
sudo apt-get upgrade
sudo apt-get install linux-image-extra-$(uname -r) -y
sudo apt-get install docker-engine -y
sudo echo DOCKER_OPTS=\"--host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375\" > /etc/default/docker
sudo service docker start
sudo groupadd docker
sudo usermod -aG docker vagrant
	################     Installing Docker-Compose            ###################
sudo apt-get -y install python-pip
sudo pip install docker-compose
	################     Updating host and ufw                ###################
	
sudo hostname 'squid.example.com'
echo "127.0.1.1 10.154.128.254 squid" | sudo tee -a /etc/hosts
sudo ufw --force enable
sudo sed -i 's|DEFAULT_FORWARD_POLICY="DROP"|DEFAULT_FORWARD_POLICY="ACCEPT"|g' /etc/default/ufw
sudo ufw --force reload
sudo ufw allow 22/tcp
sudo ufw allow 2375/tcp
sudo ufw allow 2376/tcp
sudo ufw allow 3128/tcp
sudo ufw allow 80/tcp

sudo docker run --name squid -d --restart=always --publish 3128:3128 --volume /srv/docker/squid/cache:/var/spool/squid3 sameersbn/squid