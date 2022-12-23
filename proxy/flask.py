# from flask import Flask
import pymysql.cursors
import subprocess

master_ip = "10.0.0.10"
slave_ips = ["10.0.0.11", "10.0.0.12", "10.0.0.13"]

# app = Flask(__name__)

# @app.route("select")
def connect(target):
    subprocess.run(f"systemctl start database-tunnel@{target}")
    connection = pymysql.connect(
        host="localhost",
        user="root",
        password="passw0rd",
        database="sakila",
        cursorclass=pymysql.cursors.DictCursor
                                 )
    return connection
    
def disconnect(target):
    subprocess.run(f"systemctl stop database-tunnel@{target}")