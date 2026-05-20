#!/usr/bin/env python3
import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.database import Base, engine
from app.models import Task  # noqa: F401


async def main() -> None:
    # Safety net for local/demo environments where the DB volume may already
    # exist but the expected application tables are missing.
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())
