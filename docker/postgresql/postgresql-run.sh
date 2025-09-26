#!/bin/bash
# PostgreSQL run script for Bitnami compatibility

set -e

# Source required libraries
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/postgresql-env.sh
. /opt/bitnami/scripts/libpostgresql.sh

# Function to prepare PostgreSQL for startup
prepare_postgresql() {
    info "Preparing PostgreSQL for startup"
    
    # Ensure data directory is ready
    if [[ ! -f "$POSTGRESQL_DATA_DIR/PG_VERSION" ]]; then
        error "PostgreSQL data directory is not initialized"
        exit 1
    fi
    
    # Create PID file directory
    ensure_dir_exists "$(dirname "${POSTGRESQL_TMP_DIR}/postgresql.pid")"
    
    # Ensure socket directory exists and is writable
    ensure_dir_exists "$POSTGRESQL_TMP_DIR"
    ensure_user_has_write_permissions "bitnami" "$POSTGRESQL_TMP_DIR"
    
    # Clean up any existing PID file
    rm -f "${POSTGRESQL_TMP_DIR}/postgresql.pid"
}

# Function to start PostgreSQL server
start_postgresql() {
    info "Starting PostgreSQL server"
    
    local start_command=("$POSTGRESQL_BIN_DIR/postgres")
    
    # Basic arguments
    start_command+=("-D" "$POSTGRESQL_DATA_DIR")
    start_command+=("-p" "$POSTGRESQL_PORT_NUMBER")
    start_command+=("-k" "$POSTGRESQL_TMP_DIR")
    
    # Configuration file
    if [[ -f "$POSTGRESQL_CONF_DIR/postgresql.conf" ]]; then
        start_command+=("-c" "config_file=$POSTGRESQL_CONF_DIR/postgresql.conf")
    fi
    
    # HBA configuration file
    if [[ -f "$POSTGRESQL_DATA_DIR/pg_hba.conf" ]]; then
        start_command+=("-c" "hba_file=$POSTGRESQL_DATA_DIR/pg_hba.conf")
    fi
    
    # Log configuration
    start_command+=("-c" "logging_collector=on")
    start_command+=("-c" "log_directory=$POSTGRESQL_LOG_DIR")
    start_command+=("-c" "log_filename=postgresql-%Y-%m-%d_%H%M%S.log")
    
    # Unix socket configuration
    start_command+=("-c" "unix_socket_directories=$POSTGRESQL_TMP_DIR")
    
    # Shared preload libraries
    if [[ -n "${POSTGRESQL_SHARED_PRELOAD_LIBRARIES:-}" ]]; then
        start_command+=("-c" "shared_preload_libraries='$POSTGRESQL_SHARED_PRELOAD_LIBRARIES'")
    fi
    
    # Additional configuration
    if [[ -n "${POSTGRESQL_EXTRA_FLAGS:-}" ]]; then
        read -r -a extra_flags <<< "$POSTGRESQL_EXTRA_FLAGS"
        start_command+=("${extra_flags[@]}")
    fi
    
    # Debug information
    if [[ "${BITNAMI_DEBUG:-false}" == "true" ]]; then
        debug "PostgreSQL start command: ${start_command[*]}"
    fi
    
    # Start PostgreSQL
    info "PostgreSQL is starting..."
    exec "${start_command[@]}"
}

# Function to handle shutdown signals
handle_shutdown() {
    info "Received shutdown signal"
    
    if [[ -f "${POSTGRESQL_TMP_DIR}/postgresql.pid" ]]; then
        local pid="$(cat "${POSTGRESQL_TMP_DIR}/postgresql.pid")"
        info "Stopping PostgreSQL (PID: $pid)"
        kill -TERM "$pid" 2>/dev/null || true
        
        # Wait for PostgreSQL to stop gracefully
        local count=0
        while [[ $count -lt 30 ]] && kill -0 "$pid" 2>/dev/null; do
            sleep 1
            count=$((count + 1))
        done
        
        if kill -0 "$pid" 2>/dev/null; then
            warn "PostgreSQL did not stop gracefully, forcing shutdown"
            kill -KILL "$pid" 2>/dev/null || true
        fi
        
        rm -f "${POSTGRESQL_TMP_DIR}/postgresql.pid"
    fi
    
    info "PostgreSQL stopped"
    exit 0
}

# Set up signal handlers
trap 'handle_shutdown' SIGTERM SIGINT

# Main execution
main() {
    prepare_postgresql
    start_postgresql
}

# Run main function
main