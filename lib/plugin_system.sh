#!/bin/bash
# Plugin System for CalcX Advanced
# Allows dynamic loading of functionality

# ==============================================================================
# PLUGIN CONFIGURATION
# ==============================================================================

PLUGIN_DIR="${PLUGIN_DIR:-$(dirname "$(dirname "${BASH_SOURCE[0]}")")/plugins}"
PLUGIN_CACHE="/tmp/calcx_plugin_cache_$$"

# ==============================================================================
# PLUGIN DISCOVERY
# ==============================================================================

discover_plugins() {
    if [ ! -d "$PLUGIN_DIR" ]; then
        return 1
    fi

    find "$PLUGIN_DIR" -name "*.plugin.sh" -type f 2>/dev/null
}

list_plugins() {
    local -a plugins=()
    while IFS= read -r plugin; do
        plugins+=("$(basename "$plugin" .plugin.sh)")
    done < <(discover_plugins)

    if [ ${#plugins[@]} -eq 0 ]; then
        echo "No plugins found"
        return 1
    fi

    echo "Available plugins:"
    for plugin in "${plugins[@]}"; do
        echo "  - $plugin"
    done
}

# ==============================================================================
# PLUGIN LOADING
# ==============================================================================

load_plugin() {
    local plugin_name="$1"
    local plugin_file="$PLUGIN_DIR/${plugin_name}.plugin.sh"

    if [ ! -f "$plugin_file" ]; then
        echo "Error: Plugin '$plugin_name' not found" >&2
        return 1
    fi

    # Validate plugin before loading
    if ! validate_plugin "$plugin_file"; then
        echo "Error: Plugin '$plugin_name' failed validation" >&2
        return 1
    fi

    # Source the plugin
    source "$plugin_file"

    # Call plugin initialization if exists
    if declare -f "${plugin_name}_init" >/dev/null 2>&1; then
        "${plugin_name}_init"
    fi

    echo "$plugin_file" >> "$PLUGIN_CACHE"
    echo "Plugin '$plugin_name' loaded successfully"
}

unload_plugin() {
    local plugin_name="$1"

    # Call plugin cleanup if exists
    if declare -f "${plugin_name}_cleanup" >/dev/null 2>&1; then
        "${plugin_name}_cleanup"
    fi

    # Remove from cache
    if [ -f "$PLUGIN_CACHE" ]; then
        grep -v "${plugin_name}.plugin.sh" "$PLUGIN_CACHE" > "${PLUGIN_CACHE}.tmp" 2>/dev/null
        mv "${PLUGIN_CACHE}.tmp" "$PLUGIN_CACHE" 2>/dev/null
    fi

    echo "Plugin '$plugin_name' unloaded"
}

load_all_plugins() {
    local -a plugins=()
    while IFS= read -r plugin; do
        local plugin_name=$(basename "$plugin" .plugin.sh)
        load_plugin "$plugin_name"
    done < <(discover_plugins)
}

# ==============================================================================
# PLUGIN VALIDATION
# ==============================================================================

validate_plugin() {
    local plugin_file="$1"

    # Check if file is readable
    if [ ! -r "$plugin_file" ]; then
        return 1
    fi

    # Basic security check - no dangerous commands
    if grep -qE "(rm -rf|dd |mkfs|format)" "$plugin_file" 2>/dev/null; then
        echo "Error: Plugin contains potentially dangerous commands" >&2
        return 1
    fi

    # Check for required metadata
    if ! grep -q "# PLUGIN_NAME:" "$plugin_file" 2>/dev/null; then
        echo "Warning: Plugin missing PLUGIN_NAME metadata"
    fi

    return 0
}

get_plugin_info() {
    local plugin_file="$1"

    echo "Plugin Information:"
    grep "^# PLUGIN_" "$plugin_file" 2>/dev/null | sed 's/^# //'
}

# ==============================================================================
# PLUGIN EXECUTION
# ==============================================================================

call_plugin_function() {
    local plugin_name="$1"
    local function_name="$2"
    shift 2

    local full_function_name="${plugin_name}_${function_name}"

    if ! declare -f "$full_function_name" >/dev/null 2>&1; then
        echo "Error: Function '$function_name' not found in plugin '$plugin_name'" >&2
        return 1
    fi

    "$full_function_name" "$@"
}

# ==============================================================================
# CLEANUP
# ==============================================================================

cleanup_plugins() {
    if [ -f "$PLUGIN_CACHE" ]; then
        while IFS= read -r plugin_file; do
            local plugin_name=$(basename "$plugin_file" .plugin.sh)
            unload_plugin "$plugin_name"
        done < "$PLUGIN_CACHE"
        rm -f "$PLUGIN_CACHE"
    fi
}

# Register cleanup on exit
trap cleanup_plugins EXIT

export -f discover_plugins list_plugins load_plugin unload_plugin load_all_plugins
export -f validate_plugin get_plugin_info call_plugin_function cleanup_plugins
