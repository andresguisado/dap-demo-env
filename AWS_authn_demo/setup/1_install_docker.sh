#!/bin/bash

# Install, enable, start, verify and cleanup docker package
sudo apt-get remove -qy docker docker-engine
sudo apt-get update -qy
sudo apt-get install -qy \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -qy docker-ce

###
# Also install Summon and create directory for providers
cd /tmp \
    && curl -LO https://github.com/cyberark/summon/releases/download/v0.6.7/summon-linux-amd64.tar.gz \
    && tar xzf summon-linux-amd64.tar.gz \
    && sudo mv summon /usr/local/bin/ \
    && rm summon-linux-amd64.tar.gz
