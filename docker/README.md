# Custom Bitnami-Compatible Docker Images

This directory contains minimal, Bitnami-compatible Docker images that serve as drop-in replacements for official Bitnami images.

## Image Overview

| Service    | Base Image        | Size                | Bitnami Compatibility |
| ---------- | ----------------- | ------------------- | --------------------- |
| WordPress  | `wordpress:6.8.2` | 736MB (+2MB)        | ✅ Full               |
| MariaDB    | `mariadb:12.0.2`  | 332MB (-42% vs UBI) | ✅ Full               |
| PostgreSQL | `postgres:17`     | 440MB (+2MB)        | ✅ Full               |

## Version Management

### Current Versions

- **WordPress**: `6.8.2` → `6.8.2-minimal`
- **MariaDB**: `12.0.2` → `12.0.2-minimal`
- **PostgreSQL**: `17` → `17-minimal`

### Upgrading Base Image Versions

#### Method 1: Manual Workflow Trigger (Recommended)

1. Go to GitHub Actions → Select workflow (e.g., "Build and Push Custom WordPress Image")
2. Click "Run workflow"
3. Enter new version (e.g., `6.8.3` for WordPress)
4. The workflow will build and push both `6.8.3` and `6.8.3-minimal` tags

#### Method 2: Update Workflow Defaults

1. Edit the workflow file (e.g., `.github/workflows/build-wordpress-image.yml`)
2. Update the `default:` value in the `workflow_dispatch` input
3. Commit and push - this triggers automatic build

#### Method 3: Update Dockerfile Default

1. Edit the Dockerfile (e.g., `docker/wordpress/Dockerfile`)
2. Update the `ARG WORDPRESS_VERSION=6.8.2` line
3. Commit and push - this triggers automatic build

### Chart Updates

After upgrading base images, update the Helm charts:

1. **Chart.yaml**: Update chart version (e.g., `27.1.0` → `27.2.0`)
2. **values.yaml**: Update image tag (e.g., `6.8.2-minimal` → `6.8.3-minimal`)

## Architecture

### Minimal Design Principles

- Single-stage builds (no complex multi-stage)
- Minimal package additions (only `gettext-base`)
- Maximum reuse of official image functionality
- Environment variable compatibility layer only

### Bitnami Compatibility Features

- **User/Group**: bitnami (1001:1001)
- **Directory Structure**: `/opt/bitnami/*`, `/bitnami/*`
- **Environment Variables**: Full mapping (e.g., `MARIADB_HOST` → `WORDPRESS_DB_HOST`)
- **Port Configuration**: Standard Bitnami ports (8080 for HTTP)

## Local Testing

```bash
# WordPress + MariaDB
docker compose -f docker-compose-test-simple.yml up -d

# PostgreSQL + Keycloak
docker compose -f docker-compose-test-keycloak.yml up -d
```

## Production Deployment

All images are automatically built and pushed to `ghcr.io/sammyeby/bitnami-*` with both versioned and `-minimal` tags for maximum compatibility with existing Bitnami Helm charts.
