#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/../artifacts/versions.json"

if [ ! -f "$VERSIONS_FILE" ]; then
    echo "Error: versions.json not found at $VERSIONS_FILE"
    exit 1
fi

check_repo() {
    local name="$1"
    local repo="$2"

    local current_version
    current_version=$(jq -r --arg name "$name" '.[$name].version // "unknown"' "$VERSIONS_FILE")

    local auth_header=()
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        auth_header=(-H "Authorization: Bearer $GITHUB_TOKEN")
    elif [ -n "${GH_TOKEN:-}" ]; then
        auth_header=(-H "Authorization: Bearer $GH_TOKEN")
    fi

    local release_json
    release_json=$(curl -sL "${auth_header[@]}" "https://api.github.com/repos/$repo/releases/latest")

    local latest_version
    latest_version=$(echo "$release_json" | jq -r '.tag_name // empty')
    latest_version="${latest_version#v}"

    if [ -z "$latest_version" ]; then
        echo "[$name] Failed to fetch latest release from $repo"
        return 1
    fi

    echo "[$name]"
    echo "  Current version : $current_version"
    echo "  Latest release  : $latest_version"

    if [ "$current_version" = "$latest_version" ]; then
        echo "  Status          : Up to date"
    else
        echo "  Status          : Update available -> $latest_version"
    fi
    echo ""
}

echo "Checking for NyarchLinux App updates..."
echo ""

check_repo "NyarchAssistant" "NyarchLinux/NyarchAssistant"
check_repo "CatgirlDownloader" "NyarchLinux/CatgirlDownloader"
