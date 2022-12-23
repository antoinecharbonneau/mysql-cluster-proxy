#!/bin/bash

apt-get update
apt-get install -y \
    python3-pip \
    git

git clone https://github.com/antoinecharbonneau/mysql-cluster-proxy.git

cd mysql-cluster-proxy/proxy/

pip3 install -r requirements.txt

cd /

echo "${SSH-KEY}" > /etc/key.pem
chmod 0600 /etc/key.pem

cat <<EOF > /etc/systemd/system/database-tunnel@.service
[Unit]
Description=Setup a remote tunnel to %I
After=network.target

[Service]
ExecStart=/usr/bin/ssh -i /etc/key.pem -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -nNT -R 3306:10.0.0.10:3306 ubuntu@%i
RestartSec=15
Restart=always
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
