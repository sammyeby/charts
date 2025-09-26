# Custom Bitnami-Compatible WordPress Image

This directory contains a custom WordPress Docker image that maintains compatibility with Bitnami Helm charts while using the official WordPress image as its base.

## Overview

When transitioning from Bitnami's WordPress image to the official WordPress image, several compatibility issues arise:

1. **Directory Structure**: Bitnami uses `/opt/bitnami/wordpress` while official image uses `/var/www/html`
2. **Environment Variables**: Bitnami expects `MARIADB_*` variables while official image uses `WORDPRESS_DB_*`
3. **User/Group**: Bitnami uses `bitnami:bitnami` (1001:1001) while official image uses `www-data`
4. **Port**: Bitnami serves on port 8080 while official image uses port 80
5. **Initialization Scripts**: Bitnami has specific setup and initialization routines

## Solution

This custom image solves these compatibility issues by:

- Creating the Bitnami directory structure (`/opt/bitnami/wordpress`)
- Adding environment variable mapping between Bitnami and WordPress formats
- Setting up the `bitnami` user and group with correct IDs
- Configuring Apache to serve on port 8080
- Providing Bitnami-compatible initialization scripts

## Files

- `Dockerfile` - Multi-stage build creating Bitnami-compatible WordPress image
- `setup.sh` - WordPress configuration and environment variable mapping
- `apache-setup.sh` - Apache configuration for port 8080 and WordPress
- `entrypoint.sh` - Main entrypoint script with database waiting and WordPress installation
- `wp-config-template.php` - WordPress configuration template with environment variable support

## Usage

### Building the Image

```bash
# Build with default WordPress version (6.8.2)
docker build -t ghcr.io/sammyeby/bitnami-wordpress:latest ./docker/wordpress

# Build with specific WordPress version
docker build --build-arg WORDPRESS_VERSION=6.8.2 -t ghcr.io/sammyeby/bitnami-wordpress:6.8.2 ./docker/wordpress
```

### Using with Helm Charts

Update your WordPress `values.yaml` to use the custom image:

```yaml
image:
  registry: ghcr.io
  repository: sammyeby/bitnami-wordpress
  tag: "6.8.2"
  digest: ""
  pullPolicy: IfNotPresent
```

### Environment Variables

The image supports both Bitnami and WordPress environment variable formats:

**Bitnami Format (preferred for compatibility):**

- `MARIADB_HOST` - Database host
- `MARIADB_PORT_NUMBER` - Database port (default: 3306)
- `MARIADB_DATABASE` - Database name
- `MARIADB_USER` - Database user
- `MARIADB_PASSWORD` - Database password

**WordPress Format (also supported):**

- `WORDPRESS_DB_HOST` - Database host
- `WORDPRESS_DB_NAME` - Database name
- `WORDPRESS_DB_USER` - Database user
- `WORDPRESS_DB_PASSWORD` - Database password

**Additional WordPress Configuration:**

- `WORDPRESS_USERNAME` - Admin username
- `WORDPRESS_PASSWORD` - Admin password
- `WORDPRESS_EMAIL` - Admin email
- `WORDPRESS_BLOG_NAME` - Site title/URL
- `WORDPRESS_TABLE_PREFIX` - Database table prefix (default: wp\_)
- `WORDPRESS_DEBUG` - Enable debug mode (true/false)

## GitHub Actions

The repository includes a GitHub Actions workflow (`.github/workflows/build-wordpress-image.yml`) that automatically:

1. Builds the image when changes are made to `docker/wordpress/`
2. Pushes to `ghcr.io/sammyeby/bitnami-wordpress`
3. Tags with WordPress version and `latest`
4. Supports multi-architecture builds (amd64, arm64)

## Benefits

1. **No Template Changes**: Use existing Bitnami Helm chart templates without modification
2. **Official WordPress Base**: Benefits from official WordPress security updates and maintenance
3. **Environment Variable Compatibility**: Supports both Bitnami and WordPress variable formats
4. **Automated Builds**: GitHub Actions automatically builds new versions
5. **Multi-Architecture**: Supports both x86_64 and ARM64 platforms

## Troubleshooting

### Database Connection Issues

- Ensure database is running and accessible
- Check database credentials in environment variables
- Verify network connectivity between WordPress and database pods

### Permission Issues

- The image runs as `bitnami` user (UID 1001)
- Ensure persistent volumes have correct ownership
- Check Kubernetes security contexts match expected user ID

### Port Issues

- The image serves on port 8080 (Bitnami default)
- Ensure your service and ingress configurations use port 8080
- For LoadBalancer services, map external port 80 to internal port 8080

## Updating WordPress Version

To update to a new WordPress version:

1. **Automatic**: Use GitHub Actions workflow dispatch with new version number
2. **Manual**: Update `WORDPRESS_VERSION` build arg in Dockerfile and rebuild

The image will automatically use the specified WordPress version as the base image.
