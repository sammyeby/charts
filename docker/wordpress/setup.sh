#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# WordPress environment variable mapping for Bitnami compatibility
export WORDPRESS_DATABASE_HOST="${MARIADB_HOST:-$WORDPRESS_DB_HOST}"
export WORDPRESS_DATABASE_PORT_NUMBER="${MARIADB_PORT_NUMBER:-3306}"
export WORDPRESS_DATABASE_NAME="${MARIADB_DATABASE:-$WORDPRESS_DB_NAME}"
export WORDPRESS_DATABASE_USER="${MARIADB_USER:-$WORDPRESS_DB_USER}"
export WORDPRESS_DATABASE_PASSWORD="${MARIADB_PASSWORD:-$WORDPRESS_DB_PASSWORD}"

# Set WordPress configuration
if [[ ! -f "/opt/bitnami/wordpress/wp-config.php" ]]; then
    echo "Setting up WordPress configuration..."
    
    # Create wp-config.php from template
    envsubst < /opt/bitnami/scripts/wordpress/wp-config-template.php > /opt/bitnami/wordpress/wp-config.php
fi

# Ensure proper ownership
chown -R bitnami:bitnami /opt/bitnami/wordpress
chown -R bitnami:bitnami /bitnami/wordpress

echo "WordPress setup completed"