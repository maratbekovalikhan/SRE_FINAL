from locust import HttpUser, task, between, events
import random, json

class EcommerceUser(HttpUser):
    """Simulates real e-commerce user behaviour."""
    wait_time = between(1, 3)

    @task(5)
    def browse_products(self):
        """Most common action: browsing product catalog."""
        self.client.get("/products", name="GET /products")

    @task(2)
    def place_order(self):
        """Place an order for a random product."""
        product_id = random.randint(1, 3)
        quantity = random.randint(1, 5)
        payload = {"product_id": product_id, "quantity": quantity}
        self.client.post(
            "/orders",
            json=payload,
            name="POST /orders"
        )

    @task(1)
    def health_check(self):
        """Simulate monitoring pings."""
        self.client.get("/health", name="GET /health")


@events.quitting.add_listener
def on_quitting(environment, **kwargs):
    """Print final stats on exit."""
    stats = environment.stats.total
    print(f"\n=== Load Test Summary ===")
    print(f"Total requests: {stats.num_requests}")
    print(f"Failures:       {stats.num_failures}")
    print(f"Avg latency:    {stats.avg_response_time:.0f}ms")
    print(f"p95 latency:    {stats.get_response_time_percentile(0.95):.0f}ms")
    print(f"p99 latency:    {stats.get_response_time_percentile(0.99):.0f}ms")
    print(f"RPS:            {stats.current_rps:.1f}")
