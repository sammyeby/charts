#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# MariaDB setup script for Bitnami compatibility

# Source libfs functions
source /opt/bitnami/scripts/libfs.sh

echo "Setting up MariaDB for Bitnami compatibility..."

# Environment variable mapping for Bitnami compatibility
export MYSQL_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD:-}"
export MYSQL_DATABASE="${MARIADB_DATABASE:-}"
export MYSQL_USER="${MARIADB_USER:-}"
export MYSQL_PASSWORD="${MARIADB_PASSWORD:-}"

# Handle password files (Bitnami style)
if [[ -f "${MARIADB_ROOT_PASSWORD_FILE:-}" ]]; then
    export MYSQL_ROOT_PASSWORD="$(cat "$MARIADB_ROOT_PASSWORD_FILE")"
fi

if [[ -f "${MARIADB_PASSWORD_FILE:-}" ]]; then
    export MYSQL_PASSWORD="$(cat "$MARIADB_PASSWORD_FILE")"
fi

# Ensure required directories exist
ensure_dir_exists "/opt/bitnami/mariadb/conf" bitnami bitnami
ensure_dir_exists "/opt/bitnami/mariadb/logs" bitnami bitnami
ensure_dir_exists "/opt/bitnami/mariadb/tmp" bitnami bitnami
ensure_dir_exists "/bitnami/mariadb" bitnami bitnami
ensure_dir_exists "/var/lib/mysql" bitnami bitnami

# Create MariaDB configuration if it doesn't exist
if [[ ! -f "/opt/bitnami/mariadb/conf/my.cnf" ]]; then
    cat > /opt/bitnami/mariadb/conf/my.cnf << 'EOF'
[mysqld]
user = bitnami
port = 3306
bind-address = 0.0.0.0
datadir = /bitnami/mariadb
socket = /opt/bitnami/mariadb/tmp/mysql.sock
pid-file = /opt/bitnami/mariadb/tmp/mysqld.pid
log-error = /opt/bitnami/mariadb/logs/mysqld.log
character-set-server = UTF8
collation-server = utf8_general_ci
plugin_dir = /usr/lib/mysql/plugin
basedir = /usr
tmpdir = /opt/bitnami/mariadb/tmp

# InnoDB Configuration
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit = 1
innodb_flush_method = O_DIRECT

# Query Cache Configuration (disabled by default in MariaDB 10.2+)
query_cache_type = 0
query_cache_size = 0

# Connection Configuration
max_connections = 151
max_connect_errors = 100
max_allowed_packet = 16M

# Buffer Configuration
key_buffer_size = 256M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 16K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

# Logging
log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 10
max_binlog_size = 100M

[mysql]
default-character-set = utf8

[mysqldump]
default-character-set = utf8

[client]
default-character-set = utf8
socket = /opt/bitnami/mariadb/tmp/mysql.sock
EOF
fi

# Link system config to Bitnami location if needed
if [[ ! -L "/etc/mysql/my.cnf" ]]; then
    ln -sf /opt/bitnami/mariadb/conf/my.cnf /etc/mysql/my.cnf
fi

echo "MariaDB setup completed"