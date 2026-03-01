# ─────────────────────────────────────────────
# LMArenaBridge - Dockerfile
# Base: Python 3.12 slim
# Puerto: 8000
# ─────────────────────────────────────────────

FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    wget \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements primero (cache layer)
COPY requirements.txt .

# Instalar dependencias Python
RUN pip install --no-cache-dir --upgrade pip --root-user-action=ignore && \
    pip install --no-cache-dir -r requirements.txt --root-user-action=ignore

# Pre-instalar browsers de Playwright + dependencias del sistema
# CRÍTICO: sin esto el contenedor crashea en el primer arranque
RUN playwright install-deps firefox 2>/dev/null || true && \
    playwright install firefox 2>/dev/null || \
    playwright install chromium 2>/dev/null || true

# Copiar el resto del proyecto
COPY . .

# Crear config.json por defecto si no existe
# Evita crash al arrancar sin configuración previa
RUN python -c "\
import json, os; \
path = 'config.json'; \
default = {'admin_password': 'changeme', 'api_keys': [], 'arena_tokens': [], 'rate_limit': 60, 'debug': False}; \
os.path.exists(path) or open(path, 'w').write(json.dumps(default, indent=2))"

EXPOSE 8000

HEALTHCHECK --interval=15s --timeout=5s --start-period=25s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "src/main.py"]
