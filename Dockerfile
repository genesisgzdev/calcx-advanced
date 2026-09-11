FROM python:3.12-slim

WORKDIR /app
COPY pyproject.toml README.md LICENSE ./
COPY calcx ./calcx
COPY calcx.sh ./calcx.sh

USER nobody
ENV PYTHONPATH=/app
ENV CALCX_HISTORY=/tmp/calcx-history
ENTRYPOINT ["python", "-m", "calcx"]
