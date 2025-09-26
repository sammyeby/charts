#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# Source setup scripts
source /opt/bitnami/scripts/wordpress/setup.sh
source /opt/bitnami/scripts/apache/setup.sh

# Wait for database if needed
if [[ -n "${WORDPRESS_DATABASE_HOST:-}" ]]; then
    echo "Waiting for database connection..."
    timeout=60
    while ! mysqladmin ping -h"$WORDPRESS_DATABASE_HOST" -P"${WORDPRESS_DATABASE_PORT_NUMBER:-3306}" -u"$WORDPRESS_DATABASE_USER" -p"$WORDPRESS_DATABASE_PASSWORD" --silent; do
        timeout=$((timeout - 1))
        if [[ $timeout -eq 0 ]]; then
            echo "Database connection timeout"
            exit 1
        fi
        sleep 1
    done
    echo "Database connection established"
fi

# Install WordPress if not already installed
if [[ ! -f "/opt/bitnami/wordpress/wp-config.php" ]] || ! wp core is-installed --path=/opt/bitnami/wordpress 2>/dev/null; then
    echo "Installing WordPress..."
    
    if [[ -n "${WORDPRESS_USERNAME:-}" ]] && [[ -n "${WORDPRESS_PASSWORD:-}" ]]; then
        wp core install \
            --path=/opt/bitnami/wordpress \
            --url="${WORDPRESS_BLOG_NAME:-http://localhost}" \
            --title="${WORDPRESS_BLOG_NAME:-My WordPress Site}" \
            --admin_user="${WORDPRESS_USERNAME}" \
            --admin_password="${WORDPRESS_PASSWORD}" \
            --admin_email="${WORDPRESS_EMAIL:-admin@example.com}" \
            --allow-root
    fi
fi

# Start Apache in foreground
echo "Starting Apache..."
exec apache2ctl -D FOREGROUND