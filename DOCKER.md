# Docker Deployment Guide

## Overview

This document explains how to build, run, and deploy the LM Arena Bridge using Docker containers.

## Prerequisites

- Docker Engine >= 20.10
- Docker Compose >= 1.28 (for compose usage)
- At least 2GB of free disk space for the image

## Building the Image

### Manual Build

To build the Docker image manually:

```bash
docker build -t lmarenabridge .
```

### Multi-platform Build

To build for multiple platforms (useful for sharing):

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t lmarenabridge .
```

## Running with Docker Compose

### Quick Start

1. Create your environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` to customize settings:
   ```bash
   PORT=8000
   ADMIN_PASSWORD=your_secure_password_here
   LM_BRIDGE_DISABLE_USERSCRIPT_PROXY=false
   ```

3. Start the service:
   ```bash
   docker-compose up -d
   ```

### Production Deployment

For production deployments, consider using a reverse proxy like nginx:

```yaml
version: '3.8'
services:
  lmarenabridge:
    image: ghcr.io/cloudwaddie/lmarenabridge:latest
    container_name: lmarenabridge
    restart: unless-stopped
    environment:
      - PORT=8000
      - ADMIN_PASSWORD=your_secure_production_password
      - LM_BRIDGE_DISABLE_USERSCRIPT_PROXY=false
    volumes:
      - ./config.json:/app/config.json:rw
      - ./models.json:/app/models.json:rw
    networks:
      - web
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.lmarenabridge.rule=Host(`your-domain.com`)"
      - "traefik.http.routers.lmarenabridge.tls=true"

networks:
  web:
    external: true
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8000` | Port to run the server on |
| `ADMIN_PASSWORD` | `admin` | Password for the admin dashboard (IMPORTANT: Change this for production!) |
| `LM_BRIDGE_DISABLE_USERSCRIPT_PROXY` | `false` | Disable the userscript proxy functionality |

## Security Considerations

### Admin Password

**IMPORTANT**: The default admin password is "admin". For security reasons:

1. Always set a strong `ADMIN_PASSWORD` environment variable in production
2. The password can also be set in the `config.json` file
3. After first login, you can change the password through the dashboard
4. Consider restricting network access to the dashboard port

### Other Security Measures

- **Configuration Files**: Mount your config.json as a volume to persist authentication tokens
- **Network Security**: Run in a private network when possible
- **Updates**: Regularly update the image to get security patches
- **Resource Limits**: Consider setting resource limits in production

## Volumes

Mount these volumes to persist configuration:

- `/app/config.json`: Authentication tokens and API keys
- `/app/models.json`: Available models configuration

## Ports

- `8000`: Main application port (configurable via `PORT` environment variable)

## Health Checks

The Docker image includes a built-in health check that verifies the dashboard is accessible:

```bash
curl -f http://localhost:8000/dashboard
```

## GitHub Container Registry

The image is published to GitHub Container Registry. To pull the latest version:

```bash
docker pull ghcr.io/cloudwaddie/lmarenabridge:latest
```

For specific versions:
```bash
docker pull ghcr.io/cloudwaddie/lmarenabridge:v1.0.0
```

## Building for Different Architectures

The Docker image supports multi-architecture builds:

```bash
# For ARM64 (Apple Silicon, Raspberry Pi, etc.)
docker buildx build --platform linux/arm64 -t lmarenabridge:arm64 .

# For AMD64 (Intel/AMD x86_64)
docker buildx build --platform linux/amd64 -t lmarenabridge:amd64 .
```

## Troubleshooting

### Container Won't Start

Check logs:
```bash
docker logs lmarenabridge
```

### Health Check Failing

Verify the application is responding:
```bash
docker exec lmarenabridge curl localhost:8000/dashboard
```

### Permission Issues

Ensure mounted volumes have correct permissions:
```bash
sudo chown -R $(id -u):$(id -g) ./config.json ./models.json
```

## Development with Docker

For development, you can mount the source code:

```bash
docker run -it --rm \
  -p 8000:8000 \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/config.json:/app/config.json \
  -e PORT=8000 \
  -e ADMIN_PASSWORD=admin \
  lmarenabridge
```

## Versioning Strategy

The Docker images follow semantic versioning:

- Git tags `vX.Y.Z` produce versioned images: `ghcr.io/cloudwaddie/lmarenabridge:X.Y.Z`
- The `main` branch produces the `latest` tag
- Pull requests produce temporary tags with commit SHA