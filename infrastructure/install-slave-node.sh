#!/bin/bash

sudo apt-get update
sudo apt-get install -y \
    wget \
    libclass-methodmaker-perl   

wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.0/mysql-cluster-community-data-node_8.0.31-1ubuntu20.04_amd64.deb

sudo dpkg -i mysql-cluster-community-data-node_8.0.31-1ubuntu20.04_amd64.deb

sudo cat <<EOF > /etc/my.cnf
[mysql_cluster]
ndb-connectstring=10.0.0.10
EOF

mkdir -p /usr/local/mysql/data

sudo cat <<EOF > /etc/systemd/system/ndbd.service
[Unit]
Description=MySQL NDB Data Node Daemon
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndbd
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now ndbd