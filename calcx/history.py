from __future__ import annotations

import os
import contextlib
from pathlib import Path


@contextlib.contextmanager
def _exclusive_lock(path: Path):
    """Serialize history readers/writers across CalcX processes."""
    path.parent.mkdir(parents=True, exist_ok=True)
    handle = path.open("a+", encoding="utf-8")
    try:
        if os.name == "nt":
            import msvcrt
            handle.seek(0)
            msvcrt.locking(handle.fileno(), msvcrt.LK_LOCK, 1)
        else:
            import fcntl
            fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
        yield
    finally:
        if os.name == "nt":
            import msvcrt
            handle.seek(0)
            msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
        else:
            import fcntl
            fcntl.flock(handle.fileno(), fcntl.LOCK_UN)
        handle.close()


class History:
    def __init__(self, path: Path, limit: int = 1000):
        self.path, self.limit = path, limit
        self.entries: list[str] = []
        if path.is_file():
            self.entries = path.read_text(encoding="utf-8").splitlines()[-limit:]

    def add(self, expression: str, result: str) -> None:
        lock = self.path.with_suffix(self.path.suffix + ".lock")
        with _exclusive_lock(lock):
            current = self.path.read_text(encoding="utf-8").splitlines()[-self.limit:] if self.path.is_file() else []
            current.append(f"{expression} = {result}")
            self.entries = current[-self.limit:]
            temporary = self.path.with_name(f".{self.path.name}.{os.getpid()}.tmp")
            temporary.write_text("\n".join(self.entries) + "\n", encoding="utf-8")
            temporary.replace(self.path)

    def clear(self) -> None:
        lock = self.path.with_suffix(self.path.suffix + ".lock")
        with _exclusive_lock(lock):
            self.entries.clear()
            if self.path.exists(): self.path.unlink()
