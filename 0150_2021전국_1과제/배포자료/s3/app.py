#!/usr/bin/python3
from flask import Flask, abort, request, jsonify
import logging

logging.basicConfig(
  format = '%(asctime)s %(levelname)s %(message)s',
  datefmt = '%Y-%m-%d %H:%M:%S',
  filename = "/var/log/app/app.log",
  level = logging.INFO
)

app = Flask(__name__)

@app.route('/v1/color', methods=['GET'])
def get_color():
  try:
    color_name = request.args['name']
    color_hash = request.args['hash']

    ret = {'code': '', 'name': ''}

    if color_name == 'red':
        ret['code'] = 'f34a07'
        ret['name'] = 'orange'
    elif color_name == 'blue':
        ret['code'] = '71f0f9'
        ret['name'] = 'sky'
    else:
        ret['code'] = 'ff00ff'
        ret['name'] = 'pink'

    return jsonify(ret), 200
  except Exception as e:
    logging.error(e)
    abort(500)

@app.route('/health', methods=['GET'])
def get_health():
  try:
    ret = {'status': 'ok'}

    return jsonify(ret), 200
  except Exception as e:
    logging.error(e)
    abort(500)

if __name__ == "__main__":
  app.run(host='0.0.0.0', port=8080)
