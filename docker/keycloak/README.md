# Bitnami-Compatible Keycloak Docker Image

This is a custom Docker image that provides full compatibility with Bitnami Keycloak Helm charts while using the official Keycloak image as the base. It includes all necessary Bitnami directory structures, scripts, and environment variables.

## 🎯 Purpose

The Bitnami Keycloak Helm chart expects specific directory structures, user configurations, and scripts that are not present in the official Keycloak image. This custom image bridges that gap by:

- Using the official `quay.io/keycloak/keycloak` image as the base
- Adding Bitnami-compatible directory structure (`/opt/bitnami/`)
- Providing environment variable mapping between Bitnami and native Keycloak
- Including initialization and runtime scripts for seamless integration
- Maintaining compatibility with existing Bitnami Helm chart configurations

## 🏗️ Image Details

- **Base Image**: `quay.io/keycloak/keycloak:26.3.5`
- **Registry**: `ghcr.io/sammyeby/bitnami-keycloak`
- **Tags**: `26.3.5`, `latest`
- **Platforms**: `linux/amd64`, `linux/arm64`
- **User**: `keycloak` (UID: 1001)

## 📦 What's Included

### Directory Structure

```
/opt/bitnami/
├── keycloak/
│   ├── bin/          # Symlink to /opt/keycloak/bin
│   ├── conf/         # Configuration directory
│   ├── data/         # Data directory (symlinked to volume)
│   ├── logs/         # Logs directory (symlinked to volume)
│   ├── providers/    # Custom providers
│   ├── themes/       # Custom themes
│   └── tmp/          # Temporary files
└── scripts/
    ├── liblog.sh           # Logging utilities
    ├── keycloak-env.sh     # Environment setup
    ├── keycloak-setup.sh   # Initial setup
    ├── keycloak-run.sh     # Runtime script
    └── keycloak-entrypoint.sh  # Main entrypoint
```

### Volume Mounts

```
/bitnami/keycloak/
├── data/         # Persistent data
├── conf/         # Configuration files
└── logs/         # Log files
```

## 🚀 Usage

### Basic Usage

```bash
docker run -d --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN_USER=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin123 \
  ghcr.io/sammyeby/bitnami-keycloak:26.3.5
```

### With External Database

```bash
docker run -d --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN_USER=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin123 \
  -e KEYCLOAK_DATABASE_VENDOR=postgresql \
  -e KEYCLOAK_DATABASE_HOST=postgres \
  -e KEYCLOAK_DATABASE_NAME=keycloak \
  -e KEYCLOAK_DATABASE_USER=keycloak \
  -e KEYCLOAK_DATABASE_PASSWORD=password \
  -v keycloak_data:/bitnami/keycloak \
  ghcr.io/sammyeby/bitnami-keycloak:26.3.5
```

### With Helm Chart

```yaml
# values.yaml
image:
  registry: ghcr.io
  repository: sammyeby/bitnami-keycloak
  tag: "26.3.5"

auth:
  adminUser: admin
  adminPassword: admin123

postgresql:
  enabled: true
  auth:
    postgresPassword: postgres
    username: keycloak
    password: password
    database: keycloak
```

## 🔧 Environment Variables

### Authentication

| Variable                       | Default   | Description               |
| ------------------------------ | --------- | ------------------------- |
| `KEYCLOAK_ADMIN_USER`          | `admin`   | Admin username            |
| `KEYCLOAK_ADMIN_PASSWORD`      | -         | Admin password (required) |
| `KEYCLOAK_MANAGEMENT_USER`     | `manager` | Management user           |
| `KEYCLOAK_MANAGEMENT_PASSWORD` | -         | Management password       |

### Database Configuration

| Variable                     | Default    | Description                                                   |
| ---------------------------- | ---------- | ------------------------------------------------------------- |
| `KEYCLOAK_DATABASE_VENDOR`   | `h2`       | Database type (postgresql, mysql, mariadb, oracle, mssql, h2) |
| `KEYCLOAK_DATABASE_HOST`     | -          | Database host                                                 |
| `KEYCLOAK_DATABASE_PORT`     | -          | Database port                                                 |
| `KEYCLOAK_DATABASE_NAME`     | `keycloak` | Database name                                                 |
| `KEYCLOAK_DATABASE_USER`     | -          | Database username                                             |
| `KEYCLOAK_DATABASE_PASSWORD` | -          | Database password                                             |
| `KEYCLOAK_DATABASE_SCHEMA`   | `public`   | Database schema                                               |

### Network Configuration

| Variable                   | Default | Description                                     |
| -------------------------- | ------- | ----------------------------------------------- |
| `KEYCLOAK_HTTP_PORT`       | `8080`  | HTTP port                                       |
| `KEYCLOAK_HTTPS_PORT`      | `8443`  | HTTPS port                                      |
| `KEYCLOAK_HOSTNAME`        | -       | Public hostname                                 |
| `KEYCLOAK_HOSTNAME_ADMIN`  | -       | Admin hostname                                  |
| `KEYCLOAK_HOSTNAME_STRICT` | `false` | Strict hostname checking                        |
| `KEYCLOAK_HTTP_ENABLED`    | `true`  | Enable HTTP                                     |
| `KEYCLOAK_PROXY`           | `none`  | Proxy mode (none, edge, reencrypt, passthrough) |

### SSL/TLS Configuration

| Variable                              | Default | Description                |
| ------------------------------------- | ------- | -------------------------- |
| `KEYCLOAK_HTTPS_CERTIFICATE_FILE`     | -       | HTTPS certificate file     |
| `KEYCLOAK_HTTPS_CERTIFICATE_KEY_FILE` | -       | HTTPS certificate key file |
| `KEYCLOAK_HTTPS_KEYSTORE_FILE`        | -       | HTTPS keystore file        |
| `KEYCLOAK_HTTPS_KEYSTORE_PASSWORD`    | -       | HTTPS keystore password    |
| `KEYCLOAK_HTTPS_TRUSTSTORE_FILE`      | -       | HTTPS truststore file      |
| `KEYCLOAK_HTTPS_TRUSTSTORE_PASSWORD`  | -       | HTTPS truststore password  |

### Advanced Configuration

| Variable                     | Default              | Description              |
| ---------------------------- | -------------------- | ------------------------ |
| `KEYCLOAK_LOG_LEVEL`         | `INFO`               | Log level                |
| `KEYCLOAK_CACHE`             | `local`              | Cache mode               |
| `KEYCLOAK_FEATURES`          | -                    | Enabled features         |
| `KEYCLOAK_FEATURES_DISABLED` | -                    | Disabled features        |
| `KEYCLOAK_JAVA_OPTS`         | `-Xms512m -Xmx1024m` | Java options             |
| `KEYCLOAK_EXTRA_ARGS`        | -                    | Extra Keycloak arguments |

## 🏗️ Building

### Prerequisites

- Docker
- For pushing: Docker logged in to GitHub Container Registry

### Build Script

```bash
cd docker/keycloak
./build.sh
```

### Manual Build

```bash
docker build \
  --build-arg KEYCLOAK_VERSION=26.3.5 \
  -t ghcr.io/sammyeby/bitnami-keycloak:26.3.5 \
  -t ghcr.io/sammyeby/bitnami-keycloak:latest \
  .
```

## 🔍 Architecture

### Multi-Stage Build

1. **Base Stage**: Official Keycloak image with system updates
2. **Final Stage**: Bitnami compatibility layer with:
   - User and group creation (keycloak:1001)
   - Directory structure setup
   - Script installation and permissions
   - Symlink creation for compatibility

### Script Flow

1. **keycloak-entrypoint.sh**: Main entrypoint, handles initialization
2. **keycloak-setup.sh**: One-time setup (directories, config)
3. **keycloak-env.sh**: Environment variable mapping
4. **keycloak-run.sh**: Runtime execution with build optimization
5. **liblog.sh**: Logging utilities for consistency

### Environment Variable Mapping

Bitnami variables are automatically mapped to native Keycloak variables:

- `KEYCLOAK_ADMIN_USER` → `KC_BOOTSTRAP_ADMIN_USERNAME`
- `KEYCLOAK_DATABASE_HOST` → `KC_DB_URL_HOST`
- `KEYCLOAK_HTTP_PORT` → `KC_HTTP_PORT`
- And many more...

## 🧪 Testing

### Basic Test

```bash
docker run --rm ghcr.io/sammyeby/bitnami-keycloak:26.3.5 \
  /opt/keycloak/bin/kc.sh --version
```

### Integration Test

```bash
# Start with admin user
docker run -d --name keycloak-test \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN_USER=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin123 \
  ghcr.io/sammyeby/bitnami-keycloak:26.3.5

# Wait for startup
sleep 30

# Test admin endpoint
curl -f http://localhost:8080/admin/

# Cleanup
docker rm -f keycloak-test
```

## 📁 File Structure

```bash
docker/keycloak/
├── Dockerfile              # Multi-stage build definition
├── build.sh                # Build script
├── README.md               # This file
├── keycloak-entrypoint.sh  # Main entrypoint script
├── keycloak-setup.sh       # Initial setup script
├── keycloak-env.sh         # Environment configuration
├── keycloak-run.sh         # Runtime script
└── liblog.sh              # Logging utilities
```

## 🔄 CI/CD

The image is automatically built and pushed using GitHub Actions when changes are made to the `docker/keycloak/` directory. The workflow:

1. Builds for multiple platforms (linux/amd64, linux/arm64)
2. Runs comprehensive tests
3. Performs security scanning with Trivy
4. Pushes to GitHub Container Registry
5. Updates documentation

## 🤝 Compatibility

This image is designed to be a drop-in replacement for the official Bitnami Keycloak image in Helm chart deployments. It maintains:

- ✅ User ID compatibility (1001)
- ✅ Directory structure compatibility
- ✅ Environment variable compatibility
- ✅ Script interface compatibility
- ✅ Volume mount compatibility
- ✅ Network configuration compatibility

## 🛠️ Troubleshooting

### Common Issues

**Image doesn't start**

- Check admin password is set: `KEYCLOAK_ADMIN_PASSWORD`
- Verify database connectivity if using external DB
- Check logs: `docker logs <container-name>`

**Database connection issues**

- Ensure database is running and accessible
- Verify database credentials
- Check database vendor configuration

**Permission issues**

- Ensure volumes are writable by UID 1001
- Check SELinux/AppArmor policies if applicable

### Debug Mode

Enable debug logging:

```bash
docker run -e BITNAMI_DEBUG=true ghcr.io/sammyeby/bitnami-keycloak:26.3.5
```

## 📄 License

This custom image configuration is provided under the same license terms as the original Keycloak project. The Dockerfile and scripts are available for modification and redistribution.

## 🙋 Support

For issues related to this custom image:

1. Check the troubleshooting section above
2. Review container logs for detailed error information
3. Ensure environment variables are correctly configured
4. Verify volume permissions and database connectivity

For Keycloak-specific issues, refer to the [official Keycloak documentation](https://www.keycloak.org/documentation).
