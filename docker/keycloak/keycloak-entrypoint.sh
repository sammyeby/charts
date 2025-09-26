#!/bin/bash
# Keycloak entrypoint script for Bitnami compatibility

set -o errexit
set -o nounset
set -o pipefail

# For direct kc.sh commands, skip all setup
if [[ "${1:-}" == "/opt/keycloak/bin/kc.sh" ]] || [[ "${1:-}" == "kc.sh" ]] || [[ "${1:0:1}" == "-" ]]; then
    case "${1:-}" in
        "/opt/keycloak/bin/kc.sh")
            shift
            exec /opt/keycloak/bin/kc.sh "$@"
            ;;
        "kc.sh")
            shift
            exec /opt/keycloak/bin/kc.sh "$@"
            ;;
        *)
            # Arguments starting with -
            exec /opt/keycloak/bin/kc.sh "$@"
            ;;
    esac
fi

# Source logging and environment for full startup
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/keycloak-env.sh

# Print welcome message
print_welcome_page() {
    cat << 'EOF'

       ____  _ _                   _ 
      | __ )(_) |_ _ __   __ _ _ __ (_)
      |  _ \| | __| '_ \ / _` | '_ \| |
      | |_) | | |_| | | | (_| | | | | |
      |____/|_|\__|_| |_|\__,_|_| |_|_|

*** WELCOME TO KEYCLOAK ***

EOF
    info "Starting Keycloak ${KEYCLOAK_VERSION:-latest}"
    info "This is a Bitnami-compatible custom Keycloak image"
    
    # Print configuration summary
    info "Configuration Summary:"
    info "  * HTTP Port: ${KC_HTTP_PORT:-8080}"
    info "  * HTTPS Port: ${KC_HTTPS_PORT:-8443}"
    info "  * Database: ${KC_DB:-dev-file}"
    if [[ -n "${KC_DB_URL_HOST:-}" ]]; then
        info "  * Database Host: ${KC_DB_URL_HOST}:${KC_DB_URL_PORT:-5432}"
    fi
    if [[ -n "${KC_HOSTNAME:-}" ]]; then
        info "  * Hostname: ${KC_HOSTNAME}"
    fi
    info "  * Log Level: ${KC_LOG_LEVEL:-INFO}"
    info "  * Cache: ${KC_CACHE:-local}"
    info ""
}

# Function to run setup if needed
run_setup_if_needed() {
    if [[ ! -f "/bitnami/keycloak/.keycloak-setup-complete" ]]; then
        info "Running initial Keycloak setup..."
        /opt/bitnami/scripts/keycloak-setup.sh
        touch "/bitnami/keycloak/.keycloak-setup-complete" 2>/dev/null || true
        info "Initial setup completed"
    else
        info "Keycloak already initialized, skipping setup"
    fi
}

# Function to handle signals
signal_handler() {
    info "Received shutdown signal, gracefully stopping Keycloak..."
    exit 0
}

# Main entrypoint logic
main() {
    # Set up signal handlers
    trap signal_handler SIGTERM SIGINT
    
    # For direct kc.sh commands, skip setup
    if [[ "${1:-}" == "/opt/keycloak/bin/kc.sh" ]] || [[ "${1:-}" == "kc.sh" ]] || [[ "${1:0:1}" == "-" ]]; then
        # Handle direct commands without setup
        case "${1:-}" in
            "/opt/keycloak/bin/kc.sh")
                shift
                exec gosu keycloak /opt/keycloak/bin/kc.sh "$@"
                ;;
            "kc.sh")
                shift
                exec gosu keycloak /opt/keycloak/bin/kc.sh "$@"
                ;;
            *)
                # Arguments starting with -
                exec gosu keycloak /opt/keycloak/bin/kc.sh "$@"
                ;;
        esac
    fi
    
    # Print welcome page
    print_welcome_page
    
    # Run setup if needed
    run_setup_if_needed
    
    # Handle different commands
    case "${1:-}" in
        "keycloak-run.sh"|"")
            info "Starting Keycloak server..."
            exec /opt/bitnami/scripts/keycloak-run.sh
            ;;
        "/opt/keycloak/bin/kc.sh")
            # Skip setup for direct kc.sh commands
            shift
            exec gosu keycloak /opt/keycloak/bin/kc.sh "$@"
            ;;
        "kc.sh")
            # Skip setup for kc.sh commands  
            shift
            exec gosu keycloak /opt/keycloak/bin/kc.sh "$@"
            ;;
        *)
            if [[ "${1:0:1}" == "-" ]]; then
                # If argument starts with -, assume it's Keycloak arguments
                exec gosu keycloak /opt/keycloak/bin/kc.sh "$@"
            else
                # Execute the command as provided
                exec "$@"
            fi
            ;;
    esac
}

# Execute main function with all arguments
main "$@"