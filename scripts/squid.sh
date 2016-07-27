sudo apt-get update
sudo apt-get install squid-deb-proxy -y
sudo apt-get install avahi-utils -y
sudo cp /vagrant/squid-deb-proxy.conf /etc/squid-deb-proxy/squid-deb-proxy.conf
sudo restart squid-deb-proxy
sudo apt-get install -y squid-deb-proxy-client
sudo apt-get install -y language-pack-en