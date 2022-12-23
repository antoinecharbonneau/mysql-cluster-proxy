#!/bin/bash

# Installing dependencies and docker
sudo apt-get update
sudo apt-get install -y \
    mysql-server \
    wget \
    sysbench

wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar -zxvf sakila-db.tar.gz
sudo mysql < sakila-db/sakila-schema.sql
sudo mysql < sakila-db/sakila-data.sql