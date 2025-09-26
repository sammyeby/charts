# Custom Bitnami-Compatible MariaDB Image

This directory contains a custom MariaDB Docker image that maintains compatibility with Bitnami Helm charts while using the official MariaDB image as its base.

## Overview

The Bitnami MariaDB Helm chart expects several Bitnami-specific configurations:

1. **Directory Structure**: Bitnami uses `/opt/bitnami/mariadb/` and `/bitnami/mariadb` while official image uses `/var/lib/mysql`
2. **User/Group**: Bitnami uses `bitnami:bitnami` (1001:1001) while official image uses `mysql`
3. **Configuration Path**: `/opt/bitnami/mariadb/conf/my.cnf` vs `/etc/mysql/my.cnf`
4. **Scripts**: Bitnami expects `/opt/bitnami/scripts/libfs.sh` and other utilities
5. **Environment Variables**: Uses `MARIADB_*` variables instead of `MYSQL_*`

## Solution

This custom image provides Bitnami compatibility by:

- Creating the Bitnami directory structure
- Setting up the `bitnami` user and group with correct IDs (1001:1001)
- Providing Bitnami-compatible scripts (`libfs.sh`)
- Mapping environment variables between formats
- Maintaining MariaDB configuration compatibility

## Files

- `Dockerfile` - Multi-stage build creating Bitnami-compatible MariaDB image
- `libfs.sh` - Bitnami filesystem utility functions
- `mariadb-setup.sh` - MariaDB configuration and setup script
- `mariadb-entrypoint.sh` - Main entrypoint script with database initialization
- `mariadb-run.sh` - MariaDB server startup script
- `build.sh` - Build script for local development

## Usage

### Building the Image

**Local Build:**
```bash
# Build with default MariaDB version (12.0.2-ubi)
docker build -t ghcr.io/sammyeby/bitnami-mariadb:latest .

# Build with specific MariaDB version
./build.sh 12.0.2-ubi
```

**GitHub Actions (Automated):**
- Images are automatically built and pushed to `ghcr.io/sammyeby/bitnami-mariadb` when changes are made to `docker/mariadb/`
- Manual builds can be triggered via GitHub Actions workflow dispatch with custom MariaDB version
- Multi-platform builds (linux/amd64, linux/arm64) with caching for faster builds

### Using with Helm Charts

Update your MariaDB `values.yaml` to use the custom image:

```yaml
image:
  registry: ghcr.io
  repository: sammyeby/bitnami-mariadb
  tag: "12.0.2-ubi"
  pullPolicy: IfNotPresent
```

### Environment Variables

The image supports both Bitnami and MySQL environment variable formats:

**Bitnami Format (preferred for compatibility):**

- `MARIADB_ROOT_PASSWORD` - Root user password
- `MARIADB_DATABASE` - Database name to create
- `MARIADB_USER` - User to create
- `MARIADB_PASSWORD` - Password for the user
- `MARIADB_REPLICATION_USER` - Replication user
- `MARIADB_REPLICATION_PASSWORD` - Replication user password

**MySQL Format (also supported):**

- `MYSQL_ROOT_PASSWORD` - Root user password
- `MYSQL_DATABASE` - Database name to create
- `MYSQL_USER` - User to create
- `MYSQL_PASSWORD` - Password for the user

## Directory Structure

The image maintains compatibility with Bitnami paths:

- `/opt/bitnami/mariadb/conf/` - Configuration files
- `/opt/bitnami/mariadb/logs/` - Log files
- `/opt/bitnami/mariadb/tmp/` - Temporary files and sockets
- `/bitnami/mariadb/` - Data directory (symlinked to `/var/lib/mysql`)
- `/opt/bitnami/scripts/` - Bitnami-compatible scripts

## Benefits

1. **No Template Changes**: Use existing Bitnami MariaDB Helm chart templates without modification
2. **Official MariaDB Base**: Benefits from official MariaDB security updates and maintenance
3. **Environment Variable Compatibility**: Supports both Bitnami and MySQL variable formats
4. **Script Compatibility**: Provides expected Bitnami utility functions
5. **User ID Compatibility**: Uses UID/GID 1001 as expected by Bitnami charts

## Troubleshooting

### Permission Issues

- The image runs as `bitnami` user (UID 1001)
- Ensure persistent volumes have correct ownership
- Check Kubernetes security contexts match expected user ID

### Configuration Issues

- Configuration is at `/opt/bitnami/mariadb/conf/my.cnf`
- Logs are available at `/opt/bitnami/mariadb/logs/`
- Socket file is at `/opt/bitnami/mariadb/tmp/mysql.sock`

### Database Initialization

- Database is initialized automatically on first run
- Root password is set from `MARIADB_ROOT_PASSWORD`
- Custom database and user are created if specified

## Updating MariaDB Version

To update to a new MariaDB version:

1. Update `MARIADB_VERSION` build arg in Dockerfile
2. Rebuild: `./build.sh NEW_VERSION`
3. Update Helm chart values to use new tag

The image will automatically use the specified MariaDB version as the base image.
