from flask import Flask
import logging

app = Flask(__name__)
logging.basicConfig(
  level=logging.ERROR
)

@app.route('/healthcheck', methods=['GET'])
def healthcheck():
  try:
    return 'ok', 200
  except Exception as ex:
    logging.error(ex)
    return 'error', 500

@app.route('/blue', methods=['GET'])
def get_blue():
  try:
    value = {'color': 'blue'}

    return 'blue', 200
  except Exception as ex:
    logging.error(ex)
    return 'error', 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
