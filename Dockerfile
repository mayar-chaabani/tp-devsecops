# ---- Stage 1: build ----------------------------------------------------------
# Installs the dependencies. Nothing from this stage reaches production except
# the installed packages (no pip cache, no build files).
FROM python:3.11-slim AS build

COPY requirements.txt .
# Production dependencies only: test tools live in requirements-dev.txt
RUN pip install --no-cache-dir --target /deps -r requirements.txt

# ---- Stage 2: runtime --------------------------------------------------------
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/deps

# 1. Apply the Debian security fixes released since the base image was built.
# 2. Remove the packaging tools: nothing is installed at runtime, and an
#    attacker can't use pip to pull in tools.
# 3. Create an unprivileged user with no login shell.
RUN apt-get update && apt-get upgrade -y --no-install-recommends     && rm -rf /var/lib/apt/lists/*     && pip uninstall -y pip setuptools wheel \
    && useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY --from=build /deps /deps
# Only the application code: no tests, scripts, docs or migrations.
# Files are owned by root, so the app can't modify its own code.
COPY app ./app
# The only writable folder: profile picture uploads
RUN mkdir -p uploads/profile_pictures && chown -R appuser:appuser uploads

USER 10001
EXPOSE 8000

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
