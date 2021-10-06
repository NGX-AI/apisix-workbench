#!/bin/bash
set -eux

# ENV clean up
rm -rf /root/*.cfg

# init ssh config
## copy vagrant ssh config to root
cp -a /home/vagrant/.ssh /root
chown -R root:root /root/.ssh

## enable ssh login for root
sed -ri 's/\s*#?\s*(PermitRootLogin)\s+.*$/\1 yes/g' /etc/ssh/sshd_config
sed -ri 's/\s*#?\s*(PasswordAuthentication)\s+.*$/\1 yes/g' /etc/ssh/sshd_config
systemctl restart sshd


# init system
yum install -y epel-release yum-utils
yum install -y make patch git gcc gcc-c++
yum install -y wget vim


## init system cert
yum install -y ca-certificates
update-ca-trust force-enable


# init docker
## config docke repo
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

## install docker engine
yum install -y docker-ce docker-ce-cli containerd.io

## launch docker service
systemctl enable --now docker

## install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
