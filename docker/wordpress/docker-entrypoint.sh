#!/bin/bash
set -euo pipefail

# Map Bitnami environment variables to WordPress environment variables
export WORDPRESS_DB_HOST="${MARIADB_HOST:-${WORDPRESS_DB_HOST:-localhost}}"
export WORDPRESS_DB_NAME="${WORDPRESS_DATABASE_NAME:-${WORDPRESS_DB_NAME:-wordpress}}"
export WORDPRESS_DB_USER="${WORDPRESS_DATABASE_USER:-${WORDPRESS_DB_USER:-wordpress}}"
export WORDPRESS_DB_PASSWORD="${WORDPRESS_DATABASE_PASSWORD:-${WORDPRESS_DB_PASSWORD:-}}"

# WordPress admin user setup
export WORDPRESS_ADMIN_USER="${WORDPRESS_USERNAME:-${WORDPRESS_ADMIN_USER:-admin}}"
export WORDPRESS_ADMIN_PASSWORD="${WORDPRESS_PASSWORD:-${WORDPRESS_ADMIN_PASSWORD:-}}"
export WORDPRESS_ADMIN_EMAIL="${WORDPRESS_EMAIL:-${WORDPRESS_ADMIN_EMAIL:-admin@example.com}}"

# WordPress site configuration
export WORDPRESS_TITLE="${WORDPRESS_BLOG_NAME:-${WORDPRESS_TITLE:-WordPress Site}}"

# Set WordPress URL dynamically if not provided
if [ -z "${WORDPRESS_URL:-}" ]; then
    # Try to determine from environment or use localhost with Apache port
    WORDPRESS_URL="http://localhost:${APACHE_HTTP_PORT_NUMBER:-8080}"
fi
export WORDPRESS_URL

# Database connectivity will be handled by WordPress itself

# WordPress installation will be handled by the original WordPress entrypoint
# Admin user creation will happen automatically via environment variables

echo "Starting WordPress..."

# Call the original WordPress entrypoint with our command
exec docker-entrypoint.sh "$@"