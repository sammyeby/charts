#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0
#
# Library for logging functions

# Constants
RESET='\033[0m'
RED='\033[38;5;1m'
GREEN='\033[38;5;2m'
YELLOW='\033[38;5;3m'
MAGENTA='\033[38;5;5m'
CYAN='\033[38;5;6m'

# Functions

########################
# Print to STDERR
# Arguments:
#   Message to print
# Returns:
#   None
#########################
stderr_print() {
    local bool="${BITNAMI_QUIET:-false}"
    shopt -s nocasematch
    if ! [[ "$bool" = 1 || "$bool" =~ ^(yes|true)$ ]]; then
        printf "%b\\n" "${*}" >&2
    fi
}

########################
# Log message
# Arguments:
#   Message to log
# Returns:
#   None
#########################
log() {
    local color_bool="${BITNAMI_COLOR:-true}"
    shopt -s nocasematch
    if [[ "$color_bool" = 1 || "$color_bool" =~ ^(yes|true)$ ]]; then
        stderr_print "${CYAN}${MODULE:-} ${MAGENTA}$(date "+%T.%2N ")${RESET}${*}"
    else
        stderr_print "${MODULE:-} $(date "+%T.%2N ")${*}"
    fi
}

########################
# Log an 'info' message
# Arguments:
#   Message to log
# Returns:
#   None
#########################
info() {
    local msg_color=""
    local color_bool="${BITNAMI_COLOR:-true}"
    shopt -s nocasematch
    if [[ "$color_bool" = 1 || "$color_bool" =~ ^(yes|true)$ ]];then
        msg_color="$GREEN"
    fi
    log "${msg_color}INFO ${RESET} ==> ${*}"
}

########################
# Log message
# Arguments:
#   Message to log
# Returns:
#   None
#########################
warn() {
    local msg_color=""
    local color_bool="${BITNAMI_COLOR:-true}"
    shopt -s nocasematch
    if [[ "$color_bool" = 1 || "$color_bool" =~ ^(yes|true)$ ]];then
        msg_color="$YELLOW"
    fi
    log "${msg_color}WARN ${RESET} ==> ${*}"
}

########################
# Log an 'error' message
# Arguments:
#   Message to log
# Returns:
#   None
#########################
error() {
    local msg_color=""
    local color_bool="${BITNAMI_COLOR:-true}"
    shopt -s nocasematch
    if [[ "$color_bool" = 1 || "$color_bool" =~ ^(yes|true)$ ]];then
        msg_color="$RED"
    fi
    log "${msg_color}ERROR${RESET} ==> ${*}"
}