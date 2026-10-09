# Local Bandit (SAST for Python) image
FROM python:3.11-slim

RUN pip install --no-cache-dir "bandit[toml]==1.9.4"

WORKDIR /src
ENTRYPOINT ["bandit"]
CMD ["--help"]
