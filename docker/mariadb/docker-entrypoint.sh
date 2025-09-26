#!/bin/bash
set -eo pipefail

# MariaDB entrypoint with Bitnami environment variable compatibility
# Maps Bitnami-style variables to official MariaDB variables

echo "Starting MariaDB with Bitnami compatibility..."

# Map Bitnami environment variables to MariaDB equivalents
if [ -n "${MARIADB_ROOT_PASSWORD:-}" ]; then
    export MARIADB_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD}"
elif [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
    export MARIADB_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"
fi

if [ -n "${MARIADB_USER:-}" ]; then
    export MARIADB_USER="${MARIADB_USER}"
elif [ -n "${MYSQL_USER:-}" ]; then
    export MARIADB_USER="${MYSQL_USER}"
fi

if [ -n "${MARIADB_PASSWORD:-}" ]; then
    export MARIADB_PASSWORD="${MARIADB_PASSWORD}"
elif [ -n "${MYSQL_PASSWORD:-}" ]; then
    export MARIADB_PASSWORD="${MYSQL_PASSWORD}"
fi

if [ -n "${MARIADB_DATABASE:-}" ]; then
    export MARIADB_DATABASE="${MARIADB_DATABASE}"
elif [ -n "${MYSQL_DATABASE:-}" ]; then
    export MARIADB_DATABASE="${MYSQL_DATABASE}"
fi

# Handle allow empty password
if [ -n "${ALLOW_EMPTY_PASSWORD:-}" ] && [ "${ALLOW_EMPTY_PASSWORD}" = "yes" ]; then
    export MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1
fi

# Handle root access from anywhere
if [ -n "${MARIADB_ROOT_HOST:-}" ]; then
    export MARIADB_ROOT_HOST="${MARIADB_ROOT_HOST}"
fi

# Print mapped environment for debugging
echo "Environment variables mapped:"
echo "  MARIADB_DATABASE: ${MARIADB_DATABASE:-<not set>}"
echo "  MARIADB_USER: ${MARIADB_USER:-<not set>}"
echo "  MARIADB_ROOT_HOST: ${MARIADB_ROOT_HOST:-<not set>}"
echo "  MARIADB_ALLOW_EMPTY_ROOT_PASSWORD: ${MARIADB_ALLOW_EMPTY_ROOT_PASSWORD:-<not set>}"

# Execute the original MariaDB entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"