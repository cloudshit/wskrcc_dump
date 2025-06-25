from flask import Flask, request, jsonify, abort
import datetime
import logging

app = Flask(__name__)

class KSTFormatter(logging.Formatter):
    def formatTime(self, record, datefmt=None):
        kst_now = datetime.datetime.utcnow() + datetime.timedelta(hours=9)
        if datefmt:
            return kst_now.strftime(datefmt)
        return kst_now.strftime('%Y-%m-%d %H:%M:%S,%f')[:-3]

access_log_format = '%(asctime)s - - %(client_ip)s %(port)s %(method)s %(path)s %(status)s'
access_log_formatter = KSTFormatter(access_log_format)

access_log_handler = logging.FileHandler('/logs/app.log')
access_log_handler.setFormatter(access_log_formatter)

access_log = logging.getLogger('access')
access_log.setLevel(logging.INFO)
access_log.addHandler(access_log_handler)

@app.after_request
def after_request(response):
    extra = {
        'client_ip': request.remote_addr,
        'port': request.environ['SERVER_PORT'],
        'method': request.method,
        'path': request.path,
        'status': response.status_code
    }
    access_log.info('', extra=extra)
    return response

@app.route('/2xx', methods=['GET'])
def get_2xx():
    try:
        ret = {"status": "200"}
        return jsonify(ret), 200
    except Exception as e:
        app.logger.error(e)
        abort(500)

@app.route('/3xx', methods=['GET'])
def get_3xx():
    try:
        ret = {"status": "300"}
        return jsonify(ret), 300
    except Exception as e:
        app.logger.error(e)
        abort(500)

@app.route('/4xx', methods=['GET'])
def get_4xx():
    try:
        ret = {"status": "400"}
        return jsonify(ret), 400
    except Exception as e:
        app.logger.error(e)
        abort(500)

@app.route('/5xx', methods=['GET'])
def get_5xx():
    try:
        ret = {"status": "500"}
        return jsonify(ret), 500
    except Exception as e:
        app.logger.error(e)
        abort(500)

@app.route('/healthz', methods=['GET'])
def get_healthz():
    try:
        ret = {"status": "ok"}
        return jsonify(ret), 200
    except Exception as e:
        app.logger.error(e)
        abort(500)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)