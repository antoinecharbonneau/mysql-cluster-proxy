# from flask import Flask
import pymysql

master_ip = "10.0.0.10"
slave_ips = ["10.0.0.11", "10.0.0.12", "10.0.0.13"]

# app = Flask(__name__)

# @app.route("select")
def select():
    