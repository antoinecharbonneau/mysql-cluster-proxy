#!/bin/bash

apt-get update
apt-get install -y \
    python3-pip \
    git

git clone https://github.com/antoinecharbonneau/mysql-cluster-proxy.git

cd mysql-cluster-proxy/proxy/

pip3 install -i requirements.txt
