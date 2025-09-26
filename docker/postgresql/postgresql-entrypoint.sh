#!/bin/bash
# PostgreSQL entrypoint script for Bitnami compatibility

set -e

# Source required libraries
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/postgresql-env.sh
. /opt/bitnami/scripts/libpostgresql.sh

# Function to print welcome message
print_welcome() {
    print_welcome_page
    info "PostgreSQL $($POSTGRESQL_BIN_DIR/postgres --version | awk '{print $3}')"
    info "Starting PostgreSQL with Bitnami compatibility"
}

# Function to handle initialization
handle_initialization() {
    # Run setup script
    /opt/bitnami/scripts/postgresql/setup.sh
    
    # Initialize database if needed
    if is_dir_empty "$POSTGRESQL_DATA_DIR" || [[ ! -f "${POSTGRESQL_TMP_DIR}/.initialized" ]]; then
        info "Database not initialized. Initializing..."
        postgresql_initialize
        
        # Start PostgreSQL temporarily for configuration
        postgresql_start_bg
        wait_for_postgresql
        
        # Configure PostgreSQL
        postgresql_configure
        
        # Create user and database
        postgresql_create_user_database
        
        # Setup replication if configured
        if [[ -n "$POSTGRESQL_REPLICATION_MODE" ]]; then
            postgresql_setup_replication
        fi
        
        # Stop temporary PostgreSQL instance
        postgresql_stop
        
        # Mark as initialized
        touch "${POSTGRESQL_TMP_DIR}/.initialized"
        
        info "Database initialization completed"
    else
        info "Database already initialized"
    fi
}

# Function to handle password updates
handle_password_update() {
    # Check if password update is requested
    if [[ -f "${POSTGRESQL_SECRETS_DIR}/password-update" ]]; then
        info "Password update requested"
        
        # Start PostgreSQL temporarily
        postgresql_start_bg
        wait_for_postgresql
        
        # Update passwords
        if [[ -n "$POSTGRESQL_PASSWORD" ]]; then
            postgresql_execute "ALTER USER \"$POSTGRESQL_USERNAME\" WITH PASSWORD '$POSTGRESQL_PASSWORD';"
        fi
        
        if [[ -n "$POSTGRESQL_POSTGRES_PASSWORD" ]]; then
            postgresql_execute "ALTER USER postgres WITH PASSWORD '$POSTGRESQL_POSTGRES_PASSWORD';"
        fi
        
        # Stop temporary PostgreSQL instance
        postgresql_stop
        
        # Remove password update marker
        rm -f "${POSTGRESQL_SECRETS_DIR}/password-update"
        
        info "Password update completed"
    fi
}

# Function to execute custom scripts
execute_custom_scripts() {
    local scripts_dir="/docker-entrypoint-initdb.d"
    
    if [[ -d "$scripts_dir" ]] && [[ -n "$(ls -A "$scripts_dir" 2>/dev/null)" ]]; then
        info "Executing custom initialization scripts"
        
        # Start PostgreSQL temporarily if not running
        if is_postgresql_not_running; then
            postgresql_start_bg
            wait_for_postgresql
            local stop_after=true
        fi
        
        # Execute scripts
        for script in "$scripts_dir"/*.sh "$scripts_dir"/*.sql; do
            if [[ -f "$script" ]]; then
                info "Executing script: $(basename "$script")"
                case "$script" in
                    *.sh)
                        bash "$script"
                        ;;
                    *.sql)
                        postgresql_execute "$(cat "$script")"
                        ;;
                esac
            fi
        done
        
        # Stop PostgreSQL if we started it
        if [[ "$stop_after" == "true" ]]; then
            postgresql_stop
        fi
        
        info "Custom scripts execution completed"
    fi
}

# Main entrypoint logic
main() {
    print_welcome
    
    # Handle arguments
    if [[ "$1" == "/opt/bitnami/scripts/postgresql/run.sh" ]] || [[ "$1" == "postgres" ]] || [[ -z "$1" ]]; then
        # Starting PostgreSQL server
        handle_initialization
        handle_password_update
        execute_custom_scripts
        
        # Pass control to run script
        exec /opt/bitnami/scripts/postgresql/run.sh
    else
        # Execute custom command
        exec "$@"
    fi
}

# Run main function
main "$@"