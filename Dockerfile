FROM python:3.12-slim

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Dependencias del sistema (para Camoufox / Chrome headless si se usa)
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
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copiar el resto del proyecto
COPY . .

# Exponer puerto de la API
EXPOSE 8000

# Comando de arranque
CMD ["python", "src/main.py"]
