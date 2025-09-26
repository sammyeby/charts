#!/bin/bash
# Bitnami libfs.sh compatibility script for PostgreSQL

# Filesystem utility functions compatible with Bitnami scripts

# Function to ensure directory exists
ensure_dir_exists() {
    local dir="$1"
    [[ -d "$dir" ]] || mkdir -p "$dir"
}

# Function to ensure user owns directory
ensure_user_has_write_permissions() {
    local user="$1"
    local dir="$2"
    chown -R "$user":"$user" "$dir"
}

# Function to check if directory is empty
is_dir_empty() {
    local dir="$1"
    [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]
}

# Function to check if file exists
is_file_writable() {
    local file="$1"
    [[ -w "$file" ]]
}

# Function to get file owner
get_file_owner() {
    local file="$1"
    stat -c '%U' "$file" 2>/dev/null || echo "bitnami"
}

# Function to copy with permissions
copy_with_permissions() {
    local src="$1"
    local dest="$2"
    cp -a "$src" "$dest"
}

# Function to create symlink
create_symlink() {
    local target="$1"
    local link="$2"
    ln -sf "$target" "$link"
}

# Function to set file permissions
set_file_permissions() {
    local file="$1"
    local permissions="$2"
    chmod "$permissions" "$file"
}

# Export functions for use in other scripts
export -f ensure_dir_exists
export -f ensure_user_has_write_permissions
export -f is_dir_empty
export -f is_file_writable
export -f get_file_owner
export -f copy_with_permissions
export -f create_symlink
export -f set_file_permissions