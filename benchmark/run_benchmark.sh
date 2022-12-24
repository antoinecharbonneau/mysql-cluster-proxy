#!/bin/bash

sysbench oltp_read_write \
    --table-size=1000000 \
    --db-driver=mysql \
    --mysql-db=dbtest \
    --mysql-user=root \
    --mysql-password=${SQL_PASSWORD} \
    prepare
sysbench oltp_read_write \
    --threads=6 \
    --time=60 \
    --max-requests=0 \
    --db-driver=mysql \
    --mysql-db=dbtest \
    --mysql-user=root \
    --mysql-password=${SQL_PASSWORD} \
    run
sysbench oltp_read_write \
    --db-driver=mysql \
    --mysql-db=dbtest \
    --mysql-user=root \
    --mysql-password=${SQL_PASSWORD} \
    cleanup