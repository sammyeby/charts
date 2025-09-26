# Custom Bitnami-Compatible PostgreSQL Image

This directory contains a custom PostgreSQL Docker image that maintains compatibility with Bitnami Helm charts while using the official PostgreSQL image as its base.

## Overview

The Bitnami PostgreSQL Helm chart expects several Bitnami-specific configurations:

1. **Directory Structure**: Bitnami uses `/opt/bitnami/postgresql/` and `/bitnami/postgresql` while official image uses `/var/lib/postgresql`
2. **User/Group**: Bitnami uses `bitnami:bitnami` (1001:1001) while official image uses `postgres`
3. **Configuration Path**: `/opt/bitnami/postgresql/conf/postgresql.conf` vs `/var/lib/postgresql/data/postgresql.conf`
4. **Scripts**: Bitnami expects `/opt/bitnami/scripts/libpostgresql.sh` and other utilities
5. **Environment Variables**: Uses `POSTGRESQL_*` variables and extended `POSTGRES_*` variables
6. **Replication**: Bitnami-specific replication features and configuration

## Solution

This custom image provides Bitnami compatibility by:

- Creating the Bitnami directory structure
- Setting up the `bitnami` user and group with correct IDs (1001:1001)
- Providing Bitnami-compatible scripts (`libfs.sh`, `liblog.sh`, `libpostgresql.sh`)
- Mapping environment variables between formats
- Supporting Bitnami replication features
- Maintaining PostgreSQL configuration compatibility

## Files

- `Dockerfile` - Multi-stage build creating Bitnami-compatible PostgreSQL image
- `libfs.sh` - Bitnami filesystem utility functions
- `liblog.sh` - Bitnami logging utility functions
- `postgresql-env.sh` - Environment variable mapping and configuration
- `libpostgresql.sh` - PostgreSQL utility functions for Bitnami compatibility
- `postgresql-setup.sh` - PostgreSQL configuration and setup script
- `postgresql-entrypoint.sh` - Main entrypoint script with database initialization
- `postgresql-run.sh` - PostgreSQL server startup script
- `build.sh` - Build script for local development

## Usage

### Building the Image

**Local Build:**

```bash
# Build with default PostgreSQL version (17.6-alpine)
docker build -t ghcr.io/sammyeby/bitnami-postgresql:latest .

# Build with specific PostgreSQL version
./build.sh 17.6-alpine
```

**GitHub Actions (Automated):**

- Images are automatically built and pushed to `ghcr.io/sammyeby/bitnami-postgresql` when changes are made to `docker/postgresql/`
- Manual builds can be triggered via GitHub Actions workflow dispatch with custom PostgreSQL version
- Multi-platform builds (linux/amd64, linux/arm64) with caching for faster builds

### Using with Helm Charts

Update your PostgreSQL `values.yaml` to use the custom image:

```yaml
image:
  registry: ghcr.io
  repository: sammyeby/bitnami-postgresql
  tag: "17.6-alpine"
  pullPolicy: IfNotPresent
```

### Environment Variables

The image supports both Bitnami and PostgreSQL environment variable formats:

**PostgreSQL Format (standard):**

- `POSTGRES_PASSWORD` - Superuser password
- `POSTGRES_DATABASE` - Database name to create
- `POSTGRES_USER` - User to create
- `POSTGRES_INITDB_ARGS` - Additional initdb arguments
- `POSTGRES_INITDB_WALDIR` - WAL directory location

**Bitnami Format (extended compatibility):**

- `POSTGRESQL_PASSWORD` - Superuser password
- `POSTGRESQL_DATABASE` - Database name to create
- `POSTGRESQL_USERNAME` - User to create
- `POSTGRESQL_POSTGRES_PASSWORD` - Postgres user password
- `POSTGRESQL_REPLICATION_MODE` - Replication mode (master/slave)
- `POSTGRESQL_REPLICATION_USER` - Replication user
- `POSTGRESQL_REPLICATION_PASSWORD` - Replication user password
- `POSTGRESQL_MASTER_HOST` - Master host for slave mode
- `POSTGRESQL_CLUSTER_APP_NAME` - Cluster application name

**Password Files (Kubernetes Secrets):**

- `POSTGRES_PASSWORD_FILE` - Path to password file
- `POSTGRES_POSTGRES_PASSWORD_FILE` - Path to postgres password file
- `POSTGRES_REPLICATION_PASSWORD_FILE` - Path to replication password file

## Directory Structure

The image maintains compatibility with Bitnami paths:

- `/opt/bitnami/postgresql/conf/` - Configuration files
- `/opt/bitnami/postgresql/logs/` - Log files
- `/opt/bitnami/postgresql/tmp/` - Temporary files and sockets
- `/opt/bitnami/postgresql/secrets/` - Secret files directory
- `/opt/bitnami/postgresql/certs/` - Certificate files directory
- `/bitnami/postgresql/data/` - Data directory (symlinked to `/var/lib/postgresql/data`)
- `/opt/bitnami/scripts/` - Bitnami-compatible scripts

## Replication Support

The image supports PostgreSQL replication with Bitnami-compatible configuration:

### Master Configuration

```yaml
env:
  - name: POSTGRES_REPLICATION_MODE
    value: "master"
  - name: POSTGRES_REPLICATION_USER
    value: "replicator"
  - name: POSTGRES_REPLICATION_PASSWORD
    value: "replication_password"
```

### Slave Configuration

```yaml
env:
  - name: POSTGRES_REPLICATION_MODE
    value: "slave"
  - name: POSTGRES_MASTER_HOST
    value: "postgresql-primary"
  - name: POSTGRES_REPLICATION_USER
    value: "replicator"
  - name: POSTGRES_REPLICATION_PASSWORD
    value: "replication_password"
```

## Benefits

1. **No Template Changes**: Use existing Bitnami PostgreSQL Helm chart templates without modification
2. **Official PostgreSQL Base**: Benefits from official PostgreSQL security updates and maintenance
3. **Environment Variable Compatibility**: Supports both Bitnami and PostgreSQL variable formats
4. **Script Compatibility**: Provides expected Bitnami utility functions
5. **User ID Compatibility**: Uses UID/GID 1001 as expected by Bitnami charts
6. **Replication Support**: Full support for Bitnami replication features
7. **LDAP Integration**: Supports PostgreSQL LDAP authentication configuration

## Troubleshooting

### Permission Issues

- The image runs as `bitnami` user (UID 1001)
- Ensure persistent volumes have correct ownership
- Check Kubernetes security contexts match expected user ID

### Configuration Issues

- Configuration is at `/opt/bitnami/postgresql/conf/postgresql.conf`
- Logs are available at `/opt/bitnami/postgresql/logs/`
- Socket file is at `/opt/bitnami/postgresql/tmp/.s.PGSQL.5432`

### Database Initialization

- Database is initialized automatically on first run
- Superuser password is set from `POSTGRES_PASSWORD`
- Custom database and user are created if specified

### Replication Issues

- Ensure replication user has correct permissions
- Check master/slave connectivity and authentication
- Verify WAL settings for replication

## Updating PostgreSQL Version

To update to a new PostgreSQL version:

1. Update `POSTGRESQL_VERSION` build arg in Dockerfile
2. Rebuild: `./build.sh NEW_VERSION`
3. Update Helm chart values to use new tag

The image will automatically use the specified PostgreSQL version as the base image.

## LDAP Configuration

The image supports LDAP authentication compatible with Bitnami charts:

```yaml
env:
  - name: POSTGRESQL_ENABLE_LDAP
    value: "yes"
  - name: POSTGRESQL_LDAP_SERVER
    value: "ldap.example.com"
  - name: POSTGRESQL_LDAP_PORT
    value: "389"
  - name: POSTGRESQL_LDAP_BASE_DN
    value: "dc=example,dc=com"
```

## Security Context

Compatible with Bitnami chart security contexts:

```yaml
securityContext:
  fsGroup: 1001
  runAsUser: 1001
  runAsGroup: 1001
  runAsNonRoot: true
```
