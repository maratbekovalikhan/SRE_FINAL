import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app import app as flask_app


class AppTestCase(unittest.TestCase):
    def setUp(self):
        self.client = flask_app.test_client()

    def test_home_page(self):
        response = self.client.get("/")

        self.assertEqual(response.status_code, 200)
        self.assertIn(b"SRE Ecommerce Platform", response.data)

    def test_health_endpoint(self):
        response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()["status"], "healthy")

    def test_products_endpoint(self):
        response = self.client.get("/products")

        self.assertEqual(response.status_code, 200)
        body = response.get_json()

        self.assertIn("products", body)
        self.assertEqual(len(body["products"]), 3)

    def test_order_validation(self):
        response = self.client.post("/orders", json={})

        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.get_json())

    def test_metrics_endpoint(self):
        self.client.get("/health")
        response = self.client.get("/metrics")

        self.assertEqual(response.status_code, 200)
        self.assertIn(b"http_requests_total", response.data)


if __name__ == "__main__":
    unittest.main()
