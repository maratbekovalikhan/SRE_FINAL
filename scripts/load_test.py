#!/usr/bin/env python3
import argparse
import json
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed


def hit(base_url, path, timeout):
    started = time.perf_counter()
    try:
        with urllib.request.urlopen(f"{base_url.rstrip('/')}{path}", timeout=timeout) as response:
            response.read()
            status = response.status
    except urllib.error.HTTPError as exc:
        status = exc.code
    except Exception:
        status = 0

    return status, time.perf_counter() - started


def main():
    parser = argparse.ArgumentParser(description="Simple built-in load test for the capstone app.")
    parser.add_argument("--url", default="http://127.0.0.1:8000", help="Base URL of the service")
    parser.add_argument(
        "--path",
        default="/work?delay=15&cpu_iterations=60000",
        help="Request path used for each load-test request",
    )
    parser.add_argument("--requests", type=int, default=200, help="Total number of requests")
    parser.add_argument("--concurrency", type=int, default=20, help="Number of concurrent workers")
    parser.add_argument("--timeout", type=float, default=30.0, help="Per-request timeout in seconds")
    args = parser.parse_args()

    started = time.perf_counter()
    successes = 0
    failures = 0
    latencies = []

    with ThreadPoolExecutor(max_workers=args.concurrency) as pool:
        futures = [pool.submit(hit, args.url, args.path, args.timeout) for _ in range(args.requests)]
        for future in as_completed(futures):
            status, latency = future.result()
            latencies.append(latency)
            if 200 <= status < 400:
                successes += 1
            else:
                failures += 1

    total_time = time.perf_counter() - started
    latencies.sort()
    p95_index = max(0, int(len(latencies) * 0.95) - 1)
    p99_index = max(0, int(len(latencies) * 0.99) - 1)

    summary = {
        "url": args.url,
        "path": args.path,
        "requests": args.requests,
        "concurrency": args.concurrency,
        "successes": successes,
        "failures": failures,
        "duration_seconds": round(total_time, 2),
        "requests_per_second": round(args.requests / total_time, 2) if total_time else 0,
        "p95_ms": round(latencies[p95_index] * 1000, 2) if latencies else 0,
        "p99_ms": round(latencies[p99_index] * 1000, 2) if latencies else 0,
    }
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
