#!/bin/bash
# Bitnami libfs.sh compatibility script
# Provides file system utility functions expected by Bitnami templates

# Function to check if directory is empty
is_dir_empty() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        return 0  # Directory doesn't exist, consider it empty
    fi
    
    # Check if directory has any files (including hidden ones)
    if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
        return 0  # Directory is empty
    else
        return 1  # Directory is not empty
    fi
}

# Function to ensure directory exists
ensure_dir_exists() {
    local dir="$1"
    local user="${2:-bitnami}"
    local group="${3:-bitnami}"
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chown "$user:$group" "$dir"
    fi
}

# Function to copy files with ownership
copy_with_ownership() {
    local src="$1"
    local dest="$2"
    local user="${3:-bitnami}"
    local group="${4:-bitnami}"
    
    cp -r "$src" "$dest"
    chown -R "$user:$group" "$dest"
}

# Export functions for use in other scripts
export -f is_dir_empty
export -f ensure_dir_exists  
export -f copy_with_ownership

echo "libfs.sh loaded successfully"