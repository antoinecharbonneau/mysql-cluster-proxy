#!/bin/bash

# Installing dependencies and docker
sudo apt-get update
sudo apt-get install -y \
    mysql-server \
    wget \
    sysbench \
    git

wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar -zxvf sakila-db.tar.gz
sudo mysql < sakila-db/sakila-schema.sql
sudo mysql < sakila-db/sakila-data.sql
sudo mysql <<EOF
CREATE USER 'app'@'localhost' IDENTIFIED BY 'passw0rd';
GRANT ALL PRIVILEGES ON *.* TO 'app'@'localhost';
FLUSH PRIVILEGES;
CREATE DATABASE dbtest;
EOF

git clone https://github.com/antoinecharbonneau/mysql-cluster-proxy.git /home/ubuntu/
