import random

from locust import HttpUser, between, events, task


class TaskApiUser(HttpUser):
    wait_time = between(1, 2)

    def on_start(self):
        self.task_ids = []
        self.create_task()

    def _remember_task(self, response):
        if response.status_code == 201:
            payload = response.json()
            self.task_ids.append(payload["id"])

    @task(4)
    def list_tasks(self):
        self.client.get("/tasks", name="GET /tasks")

    @task(3)
    def create_task(self):
        payload = {
            "title": f"locust-task-{random.randint(1, 100000)}",
            "description": "Generated during SRE load testing",
        }
        with self.client.post("/tasks", json=payload, name="POST /tasks", catch_response=True) as response:
            if response.status_code == 201:
                self._remember_task(response)
                response.success()
            else:
                response.failure(f"unexpected status: {response.status_code}")

    @task(2)
    def get_task(self):
        if not self.task_ids:
            self.create_task()
            return
        task_id = random.choice(self.task_ids)
        self.client.get(f"/tasks/{task_id}", name="GET /tasks/:id")

    @task(2)
    def cpu_stress_workload(self):
        self.client.get(
            "/work?delay=50&cpu_iterations=200000",
            name="GET /work (stress)",
        )

    @task(1)
    def update_task(self):
        if not self.task_ids:
            self.create_task()
            return
        task_id = random.choice(self.task_ids)
        payload = {"status": random.choice(["pending", "in_progress", "done"])}
        self.client.put(f"/tasks/{task_id}", json=payload, name="PUT /tasks/:id")


@events.quitting.add_listener
def on_quitting(environment, **kwargs):
    stats = environment.stats.total
    print("\n=== Load Test Summary ===")
    print(f"Total requests: {stats.num_requests}")
    print(f"Failures:       {stats.num_failures}")
    print(f"Avg latency:    {stats.avg_response_time:.0f}ms")
    print(f"p95 latency:    {stats.get_response_time_percentile(0.95):.0f}ms")
    print(f"p99 latency:    {stats.get_response_time_percentile(0.99):.0f}ms")
    print(f"RPS:            {stats.total_rps:.1f}")
