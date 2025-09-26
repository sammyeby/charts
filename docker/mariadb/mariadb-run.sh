#!/bin/bash
set -o errexit
set -o nounset  
set -o pipefail

# MariaDB run script for Bitnami compatibility

echo "Starting MariaDB server..."

# Start MariaDB with Bitnami-compatible paths
exec mysqld_safe \
    --defaults-file=/opt/bitnami/mariadb/conf/my.cnf \
    --user=bitnami \
    --datadir=/bitnami/mariadb \
    --socket=/opt/bitnami/mariadb/tmp/mysql.sock \
    --pid-file=/opt/bitnami/mariadb/tmp/mysqld.pid