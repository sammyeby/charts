# Custom Bitnami-Compatible Docker Images

This repository contains custom Docker images that provide full compatibility with Bitnami Helm charts while using official upstream images as their base. These images eliminate Bitnami licensing dependencies while maintaining 100% functionality.

## Available Images

### 🐳 WordPress Image

- **Registry**: `ghcr.io/sammyeby/bitnami-wordpress`
- **Base**: Official WordPress 6.8.2
- **Size**: ~435MB (vs 734MB official Bitnami)
- **Chart**: `bitnami/wordpress`

### 🗄️ MariaDB Image

- **Registry**: `ghcr.io/sammyeby/bitnami-mariadb`
- **Base**: Official MariaDB 12.0.2-ubi
- **Size**: Optimized build
- **Chart**: `bitnami/mariadb`

### 🐘 PostgreSQL Image

- **Registry**: `ghcr.io/sammyeby/bitnami-postgresql`
- **Base**: Official PostgreSQL 17.6-alpine
- **Size**: Optimized build
- **Chart**: `bitnami/postgresql`

## 🚀 Automated Builds

Both images are automatically built and published via GitHub Actions:

### Triggers

- **Push to main**: Builds when files in `docker/*/` directories change
- **Pull Requests**: Builds for testing (no publish)
- **Manual Dispatch**: Allows custom version builds via GitHub UI

### Features

- **Multi-platform**: linux/amd64, linux/arm64
- **Caching**: GitHub Actions cache for faster builds
- **Versioning**: Automatic tagging with version numbers and `latest`
- **Security**: Images published to GitHub Container Registry

### Workflow Files

- `.github/workflows/build-wordpress-image.yml`
- `.github/workflows/build-mariadb-image.yml`
- `.github/workflows/build-postgresql-image.yml`

## 🛠️ Development

### Local Building

**WordPress:**

```bash
cd docker/wordpress
./build.sh [version]  # defaults to 6.8.2
```

**MariaDB:**

```bash
cd docker/mariadb
./build.sh [version]  # defaults to 12.0.2-ubi
```

**PostgreSQL:**

```bash
cd docker/postgresql
./build.sh [version]  # defaults to 17.6-alpine
```

### Testing Images

**WordPress:**

```bash
docker run -p 8080:8080 \
  -e WORDPRESS_DATABASE_HOST=mariadb \
  -e WORDPRESS_DATABASE_NAME=wordpress \
  -e WORDPRESS_DATABASE_USER=wordpress \
  -e WORDPRESS_DATABASE_PASSWORD=password \
  ghcr.io/sammyeby/bitnami-wordpress:6.8.2
```

**MariaDB:**

```bash
docker run -p 3306:3306 \
  -e MARIADB_ROOT_PASSWORD=rootpassword \
  -e MARIADB_DATABASE=wordpress \
  -e MARIADB_USER=wordpress \
  -e MARIADB_PASSWORD=password \
  ghcr.io/sammyeby/bitnami-mariadb:12.0.2-ubi
```

**PostgreSQL:**

```bash
docker run -p 5432:5432 \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DATABASE=testdb \
  -e POSTGRES_USER=testuser \
  ghcr.io/sammyeby/bitnami-postgresql:17.6-alpine
```

## 📦 Using with Helm Charts

### WordPress Chart (`bitnami/wordpress`)

```yaml
image:
  registry: ghcr.io
  repository: sammyeby/bitnami-wordpress
  tag: "6.8.2"
  pullPolicy: IfNotPresent

mariadb:
  image:
    registry: ghcr.io
    repository: sammyeby/bitnami-mariadb
    tag: "12.0.2-ubi"
    pullPolicy: IfNotPresent
```

### MariaDB Chart (`bitnami/mariadb`)

```yaml
image:
  registry: ghcr.io
  repository: sammyeby/bitnami-mariadb
  tag: "12.0.2-ubi"
  pullPolicy: IfNotPresent
```

### PostgreSQL Chart (`bitnami/postgresql`)

```yaml
image:
  registry: ghcr.io
  repository: sammyeby/bitnami-postgresql
  tag: "17.6-alpine"
  pullPolicy: IfNotPresent
```

## 🔧 Compatibility Features

Both images maintain full Bitnami compatibility:

### Directory Structure

- `/opt/bitnami/` - Bitnami application directory
- `/bitnami/` - Data directory
- Proper symlinks and permissions

### User Management

- `bitnami:bitnami` user/group (1001:1001)
- Correct ownership and permissions
- Security context compatibility

### Scripts & Environment Variables

- All expected Bitnami scripts (`libfs.sh`, etc.)
- Environment variable mapping
- Initialization and startup scripts

### Configuration Paths

- **WordPress**: `/opt/bitnami/wordpress/wp-config.php`
- **MariaDB**: `/opt/bitnami/mariadb/conf/my.cnf`
- **Apache**: Port 8080 (WordPress)
- **MariaDB**: Port 3306 with socket compatibility

## 🔍 Troubleshooting

### Permission Issues

```bash
# Check user ID in pod
kubectl exec -it <pod> -- id

# Should show:
# uid=1001(bitnami) gid=1001(bitnami) groups=1001(bitnami)
```

### Image Pull Issues

```bash
# Verify image exists
docker pull ghcr.io/sammyeby/bitnami-wordpress:6.8.2
docker pull ghcr.io/sammyeby/bitnami-mariadb:12.0.2-ubi
```

### Log Analysis

```bash
# WordPress logs
kubectl logs <wordpress-pod> -c wordpress

# MariaDB logs
kubectl logs <mariadb-pod> -c mariadb
```

## 📋 Updating Versions

### Update WordPress Version

1. Edit `docker/wordpress/Dockerfile` - update `ARG WORDPRESS_VERSION`
2. Edit `docker/wordpress/build.sh` - update default version
3. Update `bitnami/wordpress/values.yaml` - update image tag
4. Commit changes - GitHub Actions will build automatically

### Update MariaDB Version

1. Edit `docker/mariadb/Dockerfile` - update `ARG MARIADB_VERSION`
2. Edit `docker/mariadb/build.sh` - update default version
3. Update `bitnami/mariadb/values.yaml` - update image tag
4. Commit changes - GitHub Actions will build automatically

### Manual Workflow Dispatch

You can trigger manual builds with custom versions:

1. Go to GitHub Actions tab
2. Select "Build and Push Custom [WordPress/MariaDB] Image"
3. Click "Run workflow"
4. Enter custom version (optional)
5. Click "Run workflow"

## 🎯 Benefits

1. **Cost Effective**: No Bitnami licensing fees
2. **Security**: Based on official upstream images
3. **Size Optimized**: Smaller than official Bitnami images
4. **Maintenance**: Automatic security updates from upstream
5. **Compatibility**: Drop-in replacement for Bitnami images
6. **CI/CD Ready**: Automated builds and publishing
7. **Multi-platform**: Supports both x86_64 and ARM64

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes to `docker/*/` directories
4. Test locally with build scripts
5. Submit pull request
6. Automated builds will test your changes

## 📜 License

This project follows the same licensing as the base Bitnami Helm charts (Apache 2.0).
