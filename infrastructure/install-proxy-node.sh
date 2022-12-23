#!/bin/bash

apt-get update
apt-get install -y \
    python3-pip \
    git \
    fping \
    curl \
    python3-flask

echo "${SSH-KEY}" > /etc/key.pem
chmod 0600 /etc/key.pem

git clone https://github.com/antoinecharbonneau/mysql-cluster-proxy.git

cd mysql-cluster-proxy/proxy/

pip3 install -r requirements.txt

FLASK_APP=proxy.py flask run