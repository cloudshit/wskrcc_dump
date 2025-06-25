from flask import Flask

app = Flask(__name__)

@app.route("/about")
def hello_world():
    return "The about page"
