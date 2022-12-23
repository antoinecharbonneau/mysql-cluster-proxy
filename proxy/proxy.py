from flask import Flask, request, abort, make_response
import pymysql.cursors
import subprocess
import random
from sshtunnel import open_tunnel

master_ip = "10.0.0.10"
slave_ips = ["10.0.0.11", "10.0.0.12", "10.0.0.13"]

app = Flask(__name__)

@app.route("/<strategy>", methods=['POST'])
@app.route("/<strategy>/", methods=['POST'])
def handle_get_request(strategy):
    query = request.data.decode("ascii")
    if request.content_type != "application/sql":
        response = make_response("Invalid content type. Please use application/sql")
        response.status_code = 406
        abort(response)
    if not query.lower().startswith("select"):
        response = make_response("Invalid request, please make a select statement to use strategies.")
        response.status_code = 400
        abort(response)
    
    print(f"{request.remote_addr} - {query}")
    
    if strategy == "master":
        print(f"{request.remote_addr} - Direct-hit strategy")
        response = request_master(query)
    else:
        response = request_slave(query, strategy)
        
    if response == -1:
        response = make_response("Could not reach server in a timely fashion. Please try again later")
        response.status_code = 503
        abort(response)
        
    if response == -2:
        response = make_response("Bad SQL request.")
        response.status_code = 400
        abort(response)
    
    return {i: response[i] for i in range(len(response))}

@app.route("/", methods=['POST'])
def handle_generic_request():
    if request.content_type != "application/sql":
        response = make_response("Invalid content type. Please use application/sql")
        response.status_code = 406
        abort(response)
        
    query = request.data.decode("ascii")
    print(f"{request.remote_addr} - {query}")
    print(f"{request.remote_addr} - Direct-hit strategy")
    response = request_master(query)
    
    if response == -2:
        response = make_response("Bad SQL request.")
        response.status_code = 400
        abort(response)
    
    return {i: response[i] for i in range(len(response))}

def connect(target):
    local_port = 3306 + random.randrange(0, 10)
    tunnel = open_tunnel(
        target,
        ssh_username="ubuntu",
        ssh_pkey="/etc/key.pem",
        remote_bind_address=("10.0.0.10", 3306),
        local_bind_address=("127.0.0.1", local_port)
    )
    tunnel.start()
    connection = pymysql.connect(
        host="127.0.0.1",
        user="app",
        port=local_port,
        password="passw0rd",
        database="sakila",
        cursorclass=pymysql.cursors.DictCursor
    )
    return tunnel, connection

def disconnect(tunnel):
    tunnel.stop()

def parse_fping(row: str):
    words = row.split()
    ip = words[0]
    delay = words[3][1::]
    return float(delay), ip

def request_master(sql: str):
    connection = pymysql.connect(
        host="10.0.0.10",
        user="app",
        port=3306,
        password="passw0rd",
        database="sakila",
        cursorclass=pymysql.cursors.DictCursor
    )
    with connection:
        with connection.cursor() as cursor:
            try:
                cursor.execute(sql)
            except pymysql.err.ProgrammingError:
                return -2
            result = cursor.fetchall()
    return result

def request_slave(sql: str, request_method: str):
    if request_method == "random":
        target = slave_ips[random.randrange(0, len(slave_ips))]
        print(f"{request.remote_addr} - Random strategy, served by {target}")
    else:
        # find ping and choose service with least ping
        command = ["/usr/bin/fping", "-e", "-t", "1000"]
        command.extend(slave_ips)
        output = subprocess.check_output(command).decode('ascii').split("\n")[:3]
        delays = []
        if len(output) == 0:
            # Servers couldn't be reach in a timely fashion
            return -1
        for row in output:
            delays.append(parse_fping(row))
        target = min(delays)[1]
        print(f"{request.remote_addr} - Latency strategy, served by {target}")
        
    tunnel, connection = connect(target)
    with connection:
        with connection.cursor() as cursor:
            try:
                cursor.execute(sql)
            except pymysql.err.ProgrammingError:
                return -2
            result = cursor.fetchall()
    disconnect(tunnel)
    return result
