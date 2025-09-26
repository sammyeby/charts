#!/bin/bash
# Keycloak run script for Bitnami compatibility

set -o errexit
set -o nounset
set -o pipefail

# Source logging and environment
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/keycloak-env.sh

# Function to build Keycloak configuration
keycloak_build_configuration() {
    info "Building Keycloak configuration..."
    
    local build_args=()
    
    # Add database password if provided
    if [[ -n "${KC_DB_PASSWORD:-}" ]]; then
        build_args+=("--db-password=${KC_DB_PASSWORD}")
    fi
    
    # Build the configuration
    if [[ ${#build_args[@]} -gt 0 ]]; then
        info "Running: /opt/keycloak/bin/kc.sh build ${build_args[*]}"
        /opt/keycloak/bin/kc.sh build "${build_args[@]}"
    else
        info "Running: /opt/keycloak/bin/kc.sh build"
        /opt/keycloak/bin/kc.sh build
    fi
    
    info "Keycloak configuration built successfully"
}

# Function to run Keycloak
keycloak_run() {
    info "Starting Keycloak server..."
    
    local run_args=("start")
    
    # Add optimized flag for production
    run_args+=("--optimized")
    
    # Add database password if provided (for runtime)
    if [[ -n "${KC_DB_PASSWORD:-}" ]]; then
        run_args+=("--db-password=${KC_DB_PASSWORD}")
    fi
    
    # Add any extra arguments
    if [[ -n "${KEYCLOAK_EXTRA_ARGS:-}" ]]; then
        # Split extra args into array
        IFS=' ' read -ra EXTRA_ARGS_ARRAY <<< "$KEYCLOAK_EXTRA_ARGS"
        run_args+=("${EXTRA_ARGS_ARRAY[@]}")
    fi
    
    info "Running: /opt/keycloak/bin/kc.sh ${run_args[*]}"
    
    # Set Java options
    if [[ -n "${KEYCLOAK_JAVA_OPTS:-}" ]]; then
        export JAVA_OPTS="$KEYCLOAK_JAVA_OPTS"
    fi
    
    # Execute Keycloak (already running as keycloak user)
    exec /opt/keycloak/bin/kc.sh "${run_args[@]}"
}

# Function to handle database initialization
keycloak_wait_for_database() {
    if [[ -n "${KC_DB_URL_HOST:-}" ]] && [[ "${KC_DB:-}" != "dev-file" ]]; then
        info "Waiting for database to be ready..."
        
        local db_host="${KC_DB_URL_HOST}"
        local db_port="${KC_DB_URL_PORT:-5432}"
        local max_attempts=30
        local attempt=1
        
        while [[ $attempt -le $max_attempts ]]; do
            if timeout 5 bash -c "echo > /dev/tcp/${db_host}/${db_port}" 2>/dev/null; then
                info "Database is ready"
                return 0
            fi
            
            warn "Database not ready (attempt $attempt/$max_attempts). Waiting 5 seconds..."
            sleep 5
            ((attempt++))
        done
        
        error "Database is not ready after $max_attempts attempts"
        return 1
    fi
}

# Function to check if Keycloak needs to be built
keycloak_needs_build() {
    # Check if build artifacts exist
    if [[ ! -d "/opt/keycloak/lib/quarkus" ]]; then
        return 0  # Needs build
    fi
    
    # Check if configuration has changed (simplified check)
    local conf_file="$KEYCLOAK_CONF_DIR/keycloak.conf"
    local build_marker="/opt/keycloak/.build-complete"
    
    if [[ -f "$conf_file" ]] && [[ -f "$build_marker" ]]; then
        if [[ "$conf_file" -nt "$build_marker" ]]; then
            return 0  # Config newer than build
        fi
    else
        return 0  # No build marker
    fi
    
    return 1  # No build needed
}

# Main execution
main() {
    info "Starting Keycloak with Bitnami compatibility..."
    
    # Wait for database if configured
    keycloak_wait_for_database
    
    # Build configuration if needed
    if keycloak_needs_build; then
        keycloak_build_configuration
        touch "/opt/keycloak/.build-complete"
    else
        info "Keycloak configuration already built, skipping build step"
    fi
    
    # Start Keycloak
    keycloak_run
}

# Execute main function
main "$@"