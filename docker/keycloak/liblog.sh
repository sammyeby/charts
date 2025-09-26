#!/bin/bash
# Bitnami liblog.sh compatibility script for Keycloak

# Logging utility functions compatible with Bitnami scripts

# Color codes (only set if not already defined)
if [[ -z "${LOG_COLOR_RED:-}" ]]; then
    readonly LOG_COLOR_RED='\033[0;31m'
    readonly LOG_COLOR_GREEN='\033[0;32m'
    readonly LOG_COLOR_YELLOW='\033[1;33m'
    readonly LOG_COLOR_BLUE='\033[0;34m'
    readonly LOG_COLOR_RESET='\033[0m'
fi

# Function to print info messages
info() {
    echo -e "${LOG_COLOR_BLUE}INFO ${LOG_COLOR_RESET} ==> $*"
}

# Function to print warning messages
warn() {
    echo -e "${LOG_COLOR_YELLOW}WARN ${LOG_COLOR_RESET} ==> $*"
}

# Function to print error messages
error() {
    echo -e "${LOG_COLOR_RED}ERROR${LOG_COLOR_RESET} ==> $*" >&2
}

# Function to print debug messages
debug() {
    if [[ "${BITNAMI_DEBUG:-false}" == "true" ]]; then
        echo -e "${LOG_COLOR_GREEN}DEBUG${LOG_COLOR_RESET} ==> $*"
    fi
}

# Function to print success messages
print_welcome_page() {
    info "Welcome to Keycloak"
}

# Export functions for use in other scripts
export -f info
export -f warn
export -f error
export -f debug
export -f print_welcome_page