#!/bin/bash

apt-get update
apt-get install -y \
    wget \
    libaio1 \
    libmecab2 \
    libclass-methodmaker-perl \
    libcommon-sense-perl \
    libjson-perl \
    libjson-xs-perl \
    libtypes-serialiser-perl \
    mecab-ipadic \
    mecab-ipadic-utf8 \
    mecab-utils \
    sysbench \
    git


wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.0/mysql-cluster-community-management-server_8.0.31-1ubuntu20.04_amd64.deb

dpkg -i mysql-cluster-community-management-server_8.0.31-1ubuntu20.04_amd64.deb

mkdir /var/lib/mysql-cluster
cat <<EOF > /var/lib/mysql-cluster/config.ini
[ndbd default]
NoOfReplicas=3

[ndb_mgmd]
hostname=10.0.0.10
datadir=/var/lib/mysql-cluster

[ndbd]
hostname=10.0.0.11
NodeId=2
datadir=/usr/local/mysql/data

[ndbd]
hostname=10.0.0.12
NodeId=3
datadir=/usr/local/mysql/data

[ndbd]
hostname=10.0.0.13
NodeId=4
datadir=/usr/local/mysql/data

[mysqld]
hostname=10.0.0.10
EOF

cat <<EOF > /etc/systemd/system/ndb_mgmd.service
[Unit]
Description=MySQL NDB Cluster Management Server
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ndb_mgmd

mkdir install/
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.0/mysql-cluster_8.0.31-1ubuntu20.04_amd64.deb-bundle.tar
tar -xf mysql-cluster_8.0.31-1ubuntu20.04_amd64.deb-bundle.tar -C install/

wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar -zxvf sakila-db.tar.gz

git clone https://github.com/antoinecharbonneau/mysql-cluster-proxy.git /home/ubuntu/mysql-cluster-proxy

cat <<EOF > /home/ubuntu/complete-install.sh
dpkg --auto-deconfigure -i /install/*.deb

cat <<EOL > /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
ndbcluster

[mysql_cluster]
ndb-connectstring=10.0.0.10
EOL

systemctl restart mysql

echo -n "Enter MySQL password: "
stty -echo
read password
stty echo

mysql -u root -p\$password < /sakila-db/sakila-schema.sql
mysql -u root -p\$password < /sakila-db/sakila-data.sql
mysql -u root -p\$password <<EOL
CREATE USER 'app'@'10.0.0.0/255.255.255.0' IDENTIFIED BY 'passw0rd';
GRANT ALL PRIVILEGES ON *.* TO 'app'@'10.0.0.0/255.255.255.0';
FLUSH PRIVILEGES;
CREATE DATABASE dbtest;
EOL

unset password

EOF

chmod +x /home/ubuntu/complete-install.sh