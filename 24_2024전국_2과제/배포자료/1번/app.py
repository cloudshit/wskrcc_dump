from flask import Flask, request
import logging
import time
import os

app = Flask(__name__)

log_dir = 'log'
log_file = 'app.log'

if not os.path.exists(log_dir):
    os.makedirs(log_dir)

formatter = logging.Formatter('%(message)s')

file_handler = logging.FileHandler(os.path.join(log_dir, log_file))
file_handler.setFormatter(formatter)

logger = logging.getLogger('customLogger')
logger.setLevel(logging.INFO)

logger.addHandler(file_handler)

def log_request_info():
    client_ip = request.remote_addr
    timestamp = time.strftime('%d/%b/%Y:%H:%M:%S %z')
    method = request.method
    path = request.path
    protocol = request.environ.get('SERVER_PROTOCOL')
    status_code = 200
    user_agent = request.headers.get('User-Agent')

    log_message = (f'{client_ip} - [{timestamp}] "{method} {path} {protocol}" '
                   f'{status_code} "{user_agent}"')

    logger.info(log_message)

@app.route('/log', methods=['GET'])
def log_request():
    log_request_info()
    return "Log entry created", 200

@app.route('/healthcheck', methods=['GET'])
def healthcheck():
    log_request_info()
    return "status: ok", 200

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
