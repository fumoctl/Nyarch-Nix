#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSIONS_FILE="$REPO_ROOT/artifacts/versions.json"

if [ ! -f "$VERSIONS_FILE" ]; then
    echo "Error: versions.json not found at $VERSIONS_FILE"
    exit 1
fi

get_hash() {
    local url="$1"
    nix-prefetch-url --type sha256 "$url" 2>/dev/null || echo ""
}

update_repo() {
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

    local latest_tag
    latest_tag=$(echo "$release_json" | jq -r '.tag_name // empty')

    if [ -z "$latest_tag" ]; then
        echo "[$name] Failed to fetch latest release from $repo"
        return 1
    fi

    local latest_version="${latest_tag#v}"

    echo "[$name]"
    echo "  Current version: $current_version"
    echo "  Latest version : $latest_version (tag: $latest_tag)"

    local download_url="https://github.com/$repo/archive/refs/tags/${latest_tag}.tar.gz"

    echo "  Prefetching hash for $download_url..."
    local hash
    hash=$(get_hash "$download_url")

    if [ -z "$hash" ]; then
        echo "  Error: Failed to prefetch hash for $name"
        return 1
    fi

    echo "  Hash: $hash"

    local tmp_file
    tmp_file=$(mktemp)

    jq --arg name "$name" \
       --arg version "$latest_version" \
       --arg url "$download_url" \
       --arg hash "$hash" \
       '.[$name] = {
           version: $version,
           url: $url,
           hash: $hash
       }' "$VERSIONS_FILE" > "$tmp_file"

    mv "$tmp_file" "$VERSIONS_FILE"
    echo "  Updated $name successfully in versions.json"
    echo ""
}

echo "Updating NyarchLinux Apps in versions.json..."
echo ""

update_repo "NyarchAssistant" "NyarchLinux/NyarchAssistant"
update_repo "CatgirlDownloader" "NyarchLinux/CatgirlDownloader"

echo "Running nix flake check to verify changes..."
cd "$REPO_ROOT"
nix --extra-experimental-features "nix-command flakes" flake check

echo "All apps updated and flake check passed!"
