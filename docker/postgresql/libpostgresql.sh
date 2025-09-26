#!/bin/bash
# Bitnami libpostgresql.sh compatibility script

# PostgreSQL utility functions compatible with Bitnami scripts

# Source required libraries
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/postgresql-env.sh

# Function to check if PostgreSQL is running
is_postgresql_running() {
    local pid_file="${POSTGRESQL_TMP_DIR}/postgresql.pid"
    if [[ -f "$pid_file" ]]; then
        local pid="$(cat "$pid_file")"
        kill -0 "$pid" 2>/dev/null
    else
        false
    fi
}

# Function to check if PostgreSQL is not running
is_postgresql_not_running() {
    ! is_postgresql_running
}

# Function to start PostgreSQL
postgresql_start_bg() {
    local start_command=("$POSTGRESQL_BIN_DIR/postgres")
    start_command+=("-D" "$POSTGRESQL_DATA_DIR")
    start_command+=("-p" "$POSTGRESQL_PORT_NUMBER")
    
    info "Starting PostgreSQL in background"
    "${start_command[@]}" &
    local pid=$!
    echo "$pid" > "${POSTGRESQL_TMP_DIR}/postgresql.pid"
}

# Function to stop PostgreSQL
postgresql_stop() {
    local pid_file="${POSTGRESQL_TMP_DIR}/postgresql.pid"
    if [[ -f "$pid_file" ]]; then
        local pid="$(cat "$pid_file")"
        info "Stopping PostgreSQL"
        kill -TERM "$pid" 2>/dev/null || true
        rm -f "$pid_file"
    fi
}

# Function to execute SQL command
postgresql_execute() {
    local sql="$1"
    local database="${2:-postgres}"
    local user="${3:-$POSTGRESQL_USERNAME}"
    
    PGPASSWORD="$POSTGRESQL_PASSWORD" psql -h localhost -p "$POSTGRESQL_PORT_NUMBER" -U "$user" -d "$database" -c "$sql"
}

# Function to wait for PostgreSQL to be ready
wait_for_postgresql() {
    local max_tries=60
    local count=0
    
    info "Waiting for PostgreSQL to be ready"
    while [[ $count -lt $max_tries ]]; do
        if PGPASSWORD="$POSTGRESQL_PASSWORD" psql -h localhost -p "$POSTGRESQL_PORT_NUMBER" -U "$POSTGRESQL_USERNAME" -d postgres -c "SELECT 1;" >/dev/null 2>&1; then
            info "PostgreSQL is ready"
            return 0
        fi
        count=$((count + 1))
        sleep 1
    done
    
    error "PostgreSQL failed to become ready within $max_tries seconds"
    return 1
}

# Function to initialize PostgreSQL database
postgresql_initialize() {
    if is_dir_empty "$POSTGRESQL_DATA_DIR"; then
        info "Initializing PostgreSQL database"
        
        local initdb_args=("--username=$POSTGRESQL_USERNAME")
        initdb_args+=("--pgdata=$POSTGRESQL_DATA_DIR")
        initdb_args+=("--auth-host=md5")
        initdb_args+=("--auth-local=trust")
        
        if [[ -n "$POSTGRESQL_INITDB_ARGS" ]]; then
            read -r -a additional_args <<< "$POSTGRESQL_INITDB_ARGS"
            initdb_args+=("${additional_args[@]}")
        fi
        
        if [[ -n "$POSTGRESQL_INITDB_WALDIR" ]]; then
            initdb_args+=("--waldir=$POSTGRESQL_INITDB_WALDIR")
        fi
        
        PGPASSWORD="$POSTGRESQL_PASSWORD" "$POSTGRESQL_BIN_DIR/initdb" "${initdb_args[@]}"
        
        # Mark as initialized
        touch "${POSTGRESQL_TMP_DIR}/.initialized"
    else
        info "PostgreSQL database already initialized"
    fi
}

# Function to configure PostgreSQL
postgresql_configure() {
    local config_file="$POSTGRESQL_DATA_DIR/postgresql.conf"
    local hba_file="$POSTGRESQL_DATA_DIR/pg_hba.conf"
    
    info "Configuring PostgreSQL"
    
    # Basic configuration
    echo "listen_addresses = '*'" >> "$config_file"
    echo "port = $POSTGRESQL_PORT_NUMBER" >> "$config_file"
    echo "unix_socket_directories = '$POSTGRESQL_TMP_DIR'" >> "$config_file"
    echo "logging_collector = on" >> "$config_file"
    echo "log_directory = '$POSTGRESQL_LOG_DIR'" >> "$config_file"
    
    # Configure authentication
    echo "host all all 0.0.0.0/0 md5" >> "$hba_file"
    echo "host replication all 0.0.0.0/0 md5" >> "$hba_file"
}

# Function to create user and database
postgresql_create_user_database() {
    if [[ -n "$POSTGRESQL_DATABASE" ]] && [[ "$POSTGRESQL_DATABASE" != "postgres" ]]; then
        info "Creating database: $POSTGRESQL_DATABASE"
        postgresql_execute "CREATE DATABASE \"$POSTGRESQL_DATABASE\";" "postgres" "postgres"
    fi
    
    if [[ -n "$POSTGRESQL_USERNAME" ]] && [[ "$POSTGRESQL_USERNAME" != "postgres" ]]; then
        info "Creating user: $POSTGRESQL_USERNAME"
        postgresql_execute "CREATE USER \"$POSTGRESQL_USERNAME\" WITH PASSWORD '$POSTGRESQL_PASSWORD';" "postgres" "postgres"
        
        if [[ -n "$POSTGRESQL_DATABASE" ]]; then
            postgresql_execute "GRANT ALL PRIVILEGES ON DATABASE \"$POSTGRESQL_DATABASE\" TO \"$POSTGRESQL_USERNAME\";" "postgres" "postgres"
        fi
    fi
}

# Function to setup replication
postgresql_setup_replication() {
    if [[ "$POSTGRESQL_REPLICATION_MODE" == "master" ]]; then
        info "Setting up PostgreSQL master for replication"
        
        # Create replication user
        if [[ -n "$POSTGRESQL_REPLICATION_USER" ]]; then
            postgresql_execute "CREATE USER \"$POSTGRESQL_REPLICATION_USER\" WITH REPLICATION PASSWORD '$POSTGRESQL_REPLICATION_PASSWORD';" "postgres" "postgres"
        fi
        
        # Configure replication settings
        echo "wal_level = replica" >> "$POSTGRESQL_DATA_DIR/postgresql.conf"
        echo "max_wal_senders = 3" >> "$POSTGRESQL_DATA_DIR/postgresql.conf"
        echo "wal_keep_segments = 64" >> "$POSTGRESQL_DATA_DIR/postgresql.conf"
        
    elif [[ "$POSTGRESQL_REPLICATION_MODE" == "slave" ]]; then
        info "Setting up PostgreSQL slave for replication"
        
        if [[ -n "$POSTGRESQL_MASTER_HOST" ]]; then
            # Configure standby settings
            echo "hot_standby = on" >> "$POSTGRESQL_DATA_DIR/postgresql.conf"
            
            # Create recovery configuration
            cat > "$POSTGRESQL_DATA_DIR/recovery.conf" << EOF
standby_mode = 'on'
primary_conninfo = 'host=$POSTGRESQL_MASTER_HOST port=$POSTGRESQL_MASTER_PORT_NUMBER user=$POSTGRESQL_REPLICATION_USER password=$POSTGRESQL_REPLICATION_PASSWORD'
EOF
        fi
    fi
}

# Export functions for use in other scripts
export -f is_postgresql_running
export -f is_postgresql_not_running
export -f postgresql_start_bg
export -f postgresql_stop
export -f postgresql_execute
export -f wait_for_postgresql
export -f postgresql_initialize
export -f postgresql_configure
export -f postgresql_create_user_database
export -f postgresql_setup_replication