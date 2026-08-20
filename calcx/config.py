from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path


class ConfigError(ValueError):
    """Raised when an environment or config-file value is invalid."""


@dataclass(frozen=True)
class Config:
    precision: int = 28
    history_limit: int = 1000
    color: bool = True
    history_file: Path = Path.home() / ".local/state/calcx/history"

    @classmethod
    def load(cls, precision: int | None = None) -> "Config":
        root = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "calcx"
        values: dict[str, str] = {}
        path = root / "config.env"
        if path.is_file():
            for line in path.read_text(encoding="utf-8").splitlines():
                if line.strip() and not line.lstrip().startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    values[key.strip()] = value.strip()
        try:
            selected_precision = precision if precision is not None else int(os.environ.get("CALCX_PRECISION", values.get("PRECISION", 28)))
            selected_history_limit = int(os.environ.get("CALCX_HISTORY_LIMIT", values.get("HISTORY_LIMIT", 1000)))
        except (TypeError, ValueError) as exc:
            raise ConfigError("invalid numeric configuration; check CALCX_PRECISION and CALCX_HISTORY_LIMIT") from exc
        history = os.environ.get("CALCX_HISTORY", values.get("HISTORY_FILE", str(cls.history_file)))
        return cls(max(1, min(selected_precision, 1000)), max(1, selected_history_limit), history_file=Path(history).expanduser())
