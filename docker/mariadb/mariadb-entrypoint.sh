#!/bin/bash
set -o errexit  
set -o nounset
set -o pipefail

# MariaDB entrypoint script for Bitnami compatibility

echo "Starting MariaDB entrypoint..."

# Source setup script
source /opt/bitnami/scripts/mariadb/setup.sh

# Initialize database if needed
if [[ ! -d "/bitnami/mariadb/mysql" ]]; then
    echo "Initializing MariaDB database..."
    
    # Initialize the database
    mysql_install_db \
        --user=bitnami \
        --datadir=/bitnami/mariadb \
        --basedir=/usr \
        --defaults-file=/opt/bitnami/mariadb/conf/my.cnf
    
    echo "Database initialized"
fi

# Start MariaDB in the background for initial setup
echo "Starting MariaDB for initial configuration..."
mysqld_safe \
    --defaults-file=/opt/bitnami/mariadb/conf/my.cnf \
    --user=bitnami \
    --datadir=/bitnami/mariadb \
    --socket=/opt/bitnami/mariadb/tmp/mysql.sock \
    --pid-file=/opt/bitnami/mariadb/tmp/mysqld.pid &

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
timeout=60
while ! mysqladmin ping --socket=/opt/bitnami/mariadb/tmp/mysql.sock --silent 2>/dev/null; do
    timeout=$((timeout - 1))
    if [[ $timeout -eq 0 ]]; then
        echo "MariaDB startup timeout"
        exit 1
    fi
    sleep 1
done

echo "MariaDB started successfully"

# Configure MariaDB (only on first run)
if [[ ! -f "/bitnami/mariadb/.bitnami_configured" ]]; then
    echo "Configuring MariaDB..."
    
    # Set root password if provided
    if [[ -n "${MYSQL_ROOT_PASSWORD:-}" ]]; then
        mysql --socket=/opt/bitnami/mariadb/tmp/mysql.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
    fi
    
    # Create database if specified
    if [[ -n "${MYSQL_DATABASE:-}" ]]; then
        mysql --socket=/opt/bitnami/mariadb/tmp/mysql.sock -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    fi
    
    # Create user if specified
    if [[ -n "${MYSQL_USER:-}" && -n "${MYSQL_PASSWORD:-}" ]]; then
        mysql --socket=/opt/bitnami/mariadb/tmp/mysql.sock -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
        
        if [[ -n "${MYSQL_DATABASE:-}" ]]; then
            mysql --socket=/opt/bitnami/mariadb/tmp/mysql.sock -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%'; FLUSH PRIVILEGES;"
        fi
    fi
    
    # Create replication user if specified
    if [[ -n "${MARIADB_REPLICATION_USER:-}" && -n "${MARIADB_REPLICATION_PASSWORD:-}" ]]; then
        mysql --socket=/opt/bitnami/mariadb/tmp/mysql.sock -e "CREATE USER IF NOT EXISTS '${MARIADB_REPLICATION_USER}'@'%' IDENTIFIED BY '${MARIADB_REPLICATION_PASSWORD}';"
        mysql --socket=/opt/bitnami/mariadb/tmp/mysql.sock -e "GRANT REPLICATION SLAVE ON *.* TO '${MARIADB_REPLICATION_USER}'@'%'; FLUSH PRIVILEGES;"
    fi
    
    # Mark as configured
    touch /bitnami/mariadb/.bitnami_configured
    
    echo "MariaDB configuration completed"
fi

# Stop the background MariaDB to restart properly
echo "Stopping background MariaDB..."
mysqladmin --socket=/opt/bitnami/mariadb/tmp/mysql.sock shutdown

echo "MariaDB entrypoint completed"

# Execute the main command
exec "$@"