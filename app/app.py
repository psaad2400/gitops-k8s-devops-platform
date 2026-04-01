# from flask import Flask, jsonify
# import time
# import logging

# app = Flask(__name__)

# # Version (used for rollout updates)
# VERSION = "v1"

# # Logging setup
# logging.basicConfig(level=logging.INFO)

# @app.route('/')
# def home():
#     app.logger.info("Home endpoint hit")
#     return "DevOps Project Running 🚀"

# @app.route('/health')
# def health():
#     return jsonify(status="UP"), 200

# @app.route('/ready')
# def ready():
#     time.sleep(1)  # simulate readiness delay
#     return jsonify(status="READY"), 200

# @app.route('/version')
# def version():
#     return jsonify(version=VERSION), 200

# @app.route('/load')
# def load():
#     app.logger.info("Load endpoint triggered")
#     total = 0
#     for i in range(1000000):
#         total += i
#     return jsonify(result=total), 200

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5000)




from flask import Flask, jsonify
import time
import logging
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

# Static info metric — shows app version in Grafana
metrics.info('app_info', 'Application info', version='v1')

VERSION = "v1"

logging.basicConfig(level=logging.INFO)

@app.route('/')
def home():
    app.logger.info("Home endpoint hit")
    return "DevOps Project Running 🚀"

@app.route('/health')
def health():
    return jsonify(status="UP"), 200

@app.route('/ready')
def ready():
    time.sleep(1)
    return jsonify(status="READY"), 200

@app.route('/version')
def version():
    return jsonify(version=VERSION), 200

@app.route('/load')
def load():
    app.logger.info("Load endpoint triggered")
    total = 0
    for i in range(1000000):
        total += i
    return jsonify(result=total), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)