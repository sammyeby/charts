#!/bin/bash
# Keycloak setup script for Bitnami compatibility

set -o errexit
set -o nounset
set -o pipefail

# Source logging and environment
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/keycloak-env.sh

# Setup Bitnami directory structure and permissions
keycloak_setup_directories() {
    info "Setting up Keycloak directories..."
    
    # Create required directories
    mkdir -p "$KEYCLOAK_CONF_DIR"
    mkdir -p "$KEYCLOAK_DATA_DIR"
    mkdir -p "$KEYCLOAK_LOG_DIR"
    mkdir -p "$KEYCLOAK_TMP_DIR"
    mkdir -p "$KEYCLOAK_PROVIDERS_DIR"
    mkdir -p "$KEYCLOAK_THEMES_DIR"
    mkdir -p "$KEYCLOAK_VOLUME_DIR"
    
    # Set permissions
    chown -R keycloak:keycloak "$KEYCLOAK_BASE_DIR"
    chown -R keycloak:keycloak "$KEYCLOAK_VOLUME_DIR"
    
    # Create symbolic links for volume persistence
    if [[ ! -L "$KEYCLOAK_DATA_DIR" ]]; then
        rm -rf "$KEYCLOAK_DATA_DIR"
        ln -sf "$KEYCLOAK_VOLUME_DIR/data" "$KEYCLOAK_DATA_DIR"
    fi
    
    if [[ ! -L "$KEYCLOAK_CONF_DIR/keycloak.conf" ]]; then
        mkdir -p "$KEYCLOAK_VOLUME_DIR/conf"
        if [[ -f "$KEYCLOAK_CONF_DIR/keycloak.conf" ]]; then
            cp "$KEYCLOAK_CONF_DIR/keycloak.conf" "$KEYCLOAK_VOLUME_DIR/conf/"
        fi
        ln -sf "$KEYCLOAK_VOLUME_DIR/conf/keycloak.conf" "$KEYCLOAK_CONF_DIR/keycloak.conf"
    fi
    
    # Create log directory link
    if [[ ! -L "$KEYCLOAK_LOG_DIR" ]]; then
        rm -rf "$KEYCLOAK_LOG_DIR"
        mkdir -p "$KEYCLOAK_VOLUME_DIR/logs"
        ln -sf "$KEYCLOAK_VOLUME_DIR/logs" "$KEYCLOAK_LOG_DIR"
    fi
    
    info "Keycloak directories setup completed"
}

# Setup Keycloak configuration
keycloak_setup_configuration() {
    info "Setting up Keycloak configuration..."
    
    local keycloak_conf_file="$KEYCLOAK_CONF_DIR/keycloak.conf"
    
    # Create keycloak.conf if it doesn't exist
    if [[ ! -f "$keycloak_conf_file" ]]; then
        info "Creating keycloak.conf file..."
        
        cat > "$keycloak_conf_file" << EOF
# Keycloak configuration file
# This file is managed by Bitnami Keycloak setup

# Database configuration
EOF
        
        # Add database configuration if provided
        if [[ -n "${KC_DB:-}" ]]; then
            echo "db=${KC_DB}" >> "$keycloak_conf_file"
        fi
        
        if [[ -n "${KC_DB_URL_HOST:-}" ]]; then
            echo "db-url-host=${KC_DB_URL_HOST}" >> "$keycloak_conf_file"
        fi
        
        if [[ -n "${KC_DB_URL_PORT:-}" ]]; then
            echo "db-url-port=${KC_DB_URL_PORT}" >> "$keycloak_conf_file"
        fi
        
        if [[ -n "${KC_DB_URL_DATABASE:-}" ]]; then
            echo "db-url-database=${KC_DB_URL_DATABASE}" >> "$keycloak_conf_file"
        fi
        
        if [[ -n "${KC_DB_USERNAME:-}" ]]; then
            echo "db-username=${KC_DB_USERNAME}" >> "$keycloak_conf_file"
        fi
        
        # Hostname configuration
        if [[ -n "${KC_HOSTNAME:-}" ]]; then
            echo "hostname=${KC_HOSTNAME}" >> "$keycloak_conf_file"
        fi
        
        if [[ -n "${KC_HOSTNAME_ADMIN:-}" ]]; then
            echo "hostname-admin=${KC_HOSTNAME_ADMIN}" >> "$keycloak_conf_file"
        fi
        
        if [[ "${KC_HOSTNAME_STRICT:-}" == "true" ]]; then
            echo "hostname-strict=true" >> "$keycloak_conf_file"
        else
            echo "hostname-strict=false" >> "$keycloak_conf_file"
        fi
        
        # HTTP configuration
        if [[ "${KC_HTTP_ENABLED:-}" == "true" ]]; then
            echo "http-enabled=true" >> "$keycloak_conf_file"
        fi
        
        if [[ -n "${KC_HTTP_PORT:-}" ]]; then
            echo "http-port=${KC_HTTP_PORT}" >> "$keycloak_conf_file"
        fi
        
        if [[ -n "${KC_HTTPS_PORT:-}" ]]; then
            echo "https-port=${KC_HTTPS_PORT}" >> "$keycloak_conf_file"
        fi
        
        # Proxy configuration
        if [[ -n "${KC_PROXY:-}" ]]; then
            echo "proxy=${KC_PROXY}" >> "$keycloak_conf_file"
        fi
        
        # Logging configuration
        if [[ -n "${KC_LOG_LEVEL:-}" ]]; then
            echo "log-level=${KC_LOG_LEVEL}" >> "$keycloak_conf_file"
        fi
        
        # Cache configuration
        if [[ -n "${KC_CACHE:-}" ]]; then
            echo "cache=${KC_CACHE}" >> "$keycloak_conf_file"
        fi
        
        # Features configuration
        if [[ -n "${KC_FEATURES:-}" ]]; then
            echo "features=${KC_FEATURES}" >> "$keycloak_conf_file"
        fi
        
        if [[ -n "${KC_FEATURES_DISABLED:-}" ]]; then
            echo "features-disabled=${KC_FEATURES_DISABLED}" >> "$keycloak_conf_file"
        fi
        
        chown keycloak:keycloak "$keycloak_conf_file"
    fi
    
    info "Keycloak configuration setup completed"
}

# Setup admin user
keycloak_setup_admin_user() {
    if [[ -n "${KC_BOOTSTRAP_ADMIN_USERNAME:-}" ]] && [[ -n "${KC_BOOTSTRAP_ADMIN_PASSWORD:-}" ]]; then
        info "Admin user will be created automatically on first startup"
        info "Admin Username: ${KC_BOOTSTRAP_ADMIN_USERNAME}"
    else
        warn "No admin user credentials provided. Please set KEYCLOAK_ADMIN_USER and KEYCLOAK_ADMIN_PASSWORD"
    fi
}

# Main setup function
keycloak_setup() {
    info "Starting Keycloak setup..."
    
    keycloak_setup_directories
    keycloak_setup_configuration
    keycloak_setup_admin_user
    
    info "Keycloak setup completed successfully"
}

# Run setup
keycloak_setup