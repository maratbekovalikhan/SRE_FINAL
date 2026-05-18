import os
import random
import time

from flask import Flask, jsonify, render_template, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

app = Flask(__name__)

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency', ['endpoint'])
ORDERS_TOTAL = Counter('orders_total', 'Total orders placed', ['status'])
CPU_WORK_ITERATIONS = int(os.getenv("CPU_WORK_ITERATIONS", "0"))


def simulate_cpu_work():
    checksum = 0
    for i in range(CPU_WORK_ITERATIONS):
        checksum += (i * i) % 97
    return checksum

@app.before_request
def start_timer():
    request.start_time = time.time()

@app.after_request
def record_metrics(response):
    latency = time.time() - request.start_time
    REQUEST_COUNT.labels(method=request.method, endpoint=request.path, status=response.status_code).inc()
    REQUEST_LATENCY.labels(endpoint=request.path).observe(latency)
    return response

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "ecommerce-api"})


@app.route("/")
def home():
    return render_template("index.html")


@app.route('/products')
def products():
    simulate_cpu_work()
    return jsonify({"products": [
        {"id": 1, "name": "Laptop", "price": 999.99, "stock": 50},
        {"id": 2, "name": "Phone", "price": 499.99, "stock": 100},
        {"id": 3, "name": "Headphones", "price": 149.99, "stock": 200},
    ]})

@app.route('/orders', methods=['POST'])
def create_order():
    simulate_cpu_work()
    data = request.get_json() or {}
    if not data.get('product_id') or not data.get('quantity'):
        ORDERS_TOTAL.labels(status='failed').inc()
        return jsonify({"error": "product_id and quantity required"}), 400
    order_id = random.randint(10000, 99999)
    ORDERS_TOTAL.labels(status='success').inc()
    return jsonify({"order_id": order_id, "status": "confirmed", "product_id": data['product_id']}), 201

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv("PORT", "5000")))
