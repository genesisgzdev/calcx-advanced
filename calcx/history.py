from __future__ import annotations

from pathlib import Path


class History:
    def __init__(self, path: Path, limit: int = 1000):
        self.path, self.limit = path, limit
        self.entries: list[str] = []
        if path.is_file():
            self.entries = path.read_text(encoding="utf-8").splitlines()[-limit:]

    def add(self, expression: str, result: str) -> None:
        self.entries.append(f"{expression} = {result}")
        self.entries = self.entries[-self.limit:]
        self.path.parent.mkdir(parents=True, exist_ok=True)
        temporary = self.path.with_suffix(self.path.suffix + ".tmp")
        temporary.write_text("\n".join(self.entries) + ("\n" if self.entries else ""), encoding="utf-8")
        temporary.replace(self.path)

    def clear(self) -> None:
        self.entries.clear()
        if self.path.exists(): self.path.unlink()
