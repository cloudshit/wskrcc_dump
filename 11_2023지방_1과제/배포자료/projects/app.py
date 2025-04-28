from flask import Flask

app = Flask(__name__)

@app.route("/projects")
def hello_world():
    return "The projects page"
