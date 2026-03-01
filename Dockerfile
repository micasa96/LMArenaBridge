FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git wget gnupg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip --root-user-action=ignore && \
    pip install --no-cache-dir -r requirements.txt --root-user-action=ignore

RUN playwright install-deps firefox 2>/dev/null || true && \
    playwright install firefox 2>/dev/null || \
    playwright install chromium 2>/dev/null || true

COPY . .

# FIX: config.json con headless=true para Docker (sin display X11)
RUN python -c "
import json, os
path = 'config.json'
default = {
    'admin_password': 'changeme',
    'api_keys': [],
    'arena_tokens': [],
    'rate_limit': 60,
    'debug': False,
    'camoufox_proxy_headless': True,
    'camoufox_fetch_headless': True
}
if not os.path.exists(path):
    open(path, 'w').write(json.dumps(default, indent=2))
else:
    try:
        cfg = json.load(open(path))
        cfg['camoufox_proxy_headless'] = True
        cfg['camoufox_fetch_headless'] = True
        open(path, 'w').write(json.dumps(cfg, indent=2))
    except Exception:
        open(path, 'w').write(json.dumps(default, indent=2))
"

EXPOSE 8000

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health || exit 1

CMD ["python", "-m", "src.main"]