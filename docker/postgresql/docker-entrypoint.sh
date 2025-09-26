#!/bin/bash
set -eo pipefail

# PostgreSQL entrypoint with Bitnami environment variable compatibility
# Maps Bitnami-style variables to official PostgreSQL variables

echo "Starting PostgreSQL with Bitnami compatibility..."

# Map Bitnami environment variables to PostgreSQL equivalents
if [ -n "${POSTGRESQL_USERNAME:-}" ]; then
    export POSTGRES_USER="${POSTGRESQL_USERNAME}"
elif [ -n "${POSTGRES_USER:-}" ]; then
    export POSTGRES_USER="${POSTGRES_USER}"
fi

if [ -n "${POSTGRESQL_PASSWORD:-}" ]; then
    export POSTGRES_PASSWORD="${POSTGRESQL_PASSWORD}"
elif [ -n "${POSTGRES_PASSWORD:-}" ]; then
    export POSTGRES_PASSWORD="${POSTGRES_PASSWORD}"
fi

if [ -n "${POSTGRESQL_DATABASE:-}" ]; then
    export POSTGRES_DB="${POSTGRESQL_DATABASE}"
elif [ -n "${POSTGRES_DB:-}" ]; then
    export POSTGRES_DB="${POSTGRES_DB}"
fi

# Handle PostgreSQL admin user
if [ -n "${POSTGRESQL_POSTGRES_PASSWORD:-}" ]; then
    export POSTGRES_PASSWORD="${POSTGRESQL_POSTGRES_PASSWORD}"
fi

# Handle allow empty password
if [ -n "${ALLOW_EMPTY_PASSWORD:-}" ] && [ "${ALLOW_EMPTY_PASSWORD}" = "yes" ]; then
    export POSTGRES_HOST_AUTH_METHOD=trust
fi

# Ensure we have the password for the user
if [ -n "${POSTGRESQL_PASSWORD:-}" ] && [ -n "${POSTGRESQL_USERNAME:-}" ]; then
    export POSTGRES_PASSWORD="${POSTGRESQL_PASSWORD}"
    export POSTGRES_USER="${POSTGRESQL_USERNAME}"
fi

# Handle PostgreSQL host authentication method
if [ -n "${POSTGRESQL_ENABLE_LDAP:-}" ] && [ "${POSTGRESQL_ENABLE_LDAP}" = "yes" ]; then
    export POSTGRES_HOST_AUTH_METHOD=ldap
fi

# Print mapped environment for debugging
echo "Environment variables mapped:"
echo "  POSTGRES_DB: ${POSTGRES_DB:-<not set>}"
echo "  POSTGRES_USER: ${POSTGRES_USER:-<not set>}"
echo "  POSTGRES_HOST_AUTH_METHOD: ${POSTGRES_HOST_AUTH_METHOD:-<not set>}"

# Execute the original PostgreSQL entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"