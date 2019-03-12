#!/bin/bash

### Your default information
SUDO_USER='widiastono'
TIMEZONE='Asia/Jakarta'
PORT_SSH=2277
export DEBIAN_FRONTEND=noninteractive

### ID Repo
if ! grep -q '### ID Repo' /etc/apt/sources.list
then
	echo "### ID Repo" >> /etc/apt/sources.list
	sed -i '8r apt-sources.list' /etc/apt/sources.list
else
	echo -e "ID Repo updated"
fi

### disable uneeded services
service exim4 stop
update-rc.d -f exim4 remove
service rpcbind stop
update-rc.d -f rpcbind remove

### update & upgrade debian
apt-get update -y
apt-get upgrade -y

### install needed application
apt-get install net-tools ntp sysstat iptraf traceroute tcptraceroute pktstat bwm-ng whois httperf mailutils lynx \
nast dsniff build-essential tcpdump sudo curl vim -y

### adding SUDO_USER to sudo group
if [ `grep -c $SUDO_USER /etc/passwd` -eq 0 ]; then
  useradd $SUDO_USER
fi
usermod -a -G sudo $SUDO_USER


### setup ntp client
if ! grep -q '### ID NTP' /etc/ntp.conf
then
	echo "### ID NTP" >> /etc/ntp.conf
	sed -i '18r ntp-id.conf' /etc/ntp.conf
else
	echo -e "ntp config updated"
fi

mv /etc/localtime /etc/localtime.old
ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime


### setup ssh server
sed -i 's/#Port 22$/Port '$PORT_SSH'/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin without-password/PermitRootLogin no/' /etc/ssh/sshd_config
if ! grep -q 'UseDNS no' /etc/ssh/sshd_config
then
	echo 'UseDNS no' >> /etc/ssh/sshd_config
fi

### quagga
cp apt-quagga.list /etc/apt/sources.list
apt update -y 
apt install quagga -y

### vlan
cp apt-sources.list /etc/apt/sources.list
apt update -y 
apt install vlan -y 
