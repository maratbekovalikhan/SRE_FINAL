VENV=app/.venv
PYTHON=$(VENV)/bin/python
PIP=$(VENV)/bin/pip

.PHONY: setup run test smoke docker-up docker-down

setup:
	python3 -m venv $(VENV)
	$(PIP) install -r app/requirements.txt

run:
	mkdir -p .tmp
	TMPDIR=$(PWD)/.tmp PORT=8000 $(PYTHON) app/app.py

test:
	$(PYTHON) -m unittest discover -s app/tests -p 'test_*.py' -v

smoke:
	$(PYTHON) -c 'import sys; sys.path.insert(0, "app"); from app import app; client = app.test_client(); assert client.get("/").status_code == 200; assert client.get("/health").get_json()["status"] == "healthy"; assert client.get("/products").status_code == 200; assert client.post("/orders", json={}).status_code == 400; assert client.get("/metrics").status_code == 200; print("smoke test passed")'

docker-up:
	docker compose up --build -d

docker-down:
	docker compose down
