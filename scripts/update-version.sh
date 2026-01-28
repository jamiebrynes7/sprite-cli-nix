#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://sprites-binaries.t3.storage.dev"
PLATFORMS=("linux-amd64" "linux-arm64" "darwin-amd64" "darwin-arm64")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$REPO_ROOT/version.json"

# Fetch a URL, setting HTTP_CODE to the response status
http_fetch() {
    local url="$1" output="$2"
    HTTP_CODE=$(curl -sSL -w '%{http_code}' -o "$output" "$url" 2>/dev/null) || HTTP_CODE="000"
}

# Fetch latest version - try release.txt first, fall back to rc.txt
echo "Fetching latest version..."

VERSION=""
tmpfile=$(mktemp)

http_fetch "$BASE_URL/client/release.txt" "$tmpfile"
if [[ "$HTTP_CODE" == "200" ]]; then
    VERSION=$(tr -d '\r\n' < "$tmpfile")
fi

if [[ -z "$VERSION" ]]; then
    echo "No release version found, trying rc channel..."
    http_fetch "$BASE_URL/client/rc.txt" "$tmpfile"
    if [[ "$HTTP_CODE" == "200" ]]; then
        VERSION=$(tr -d '\r\n' < "$tmpfile")
    fi
fi

rm -f "$tmpfile"

if [[ -z "$VERSION" ]]; then
    echo "Error: Failed to fetch version from release or rc channels"
    exit 1
fi

echo "Latest version: $VERSION"

# Build the hashes JSON object
declare -A HASHES

for platform in "${PLATFORMS[@]}"; do
    url="$BASE_URL/client/$VERSION/sprite-$platform.tar.gz"
    echo "Computing hash for $platform..."

    hash=$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)
    sri_hash=$(nix hash convert --hash-algo sha256 --to sri "$hash")

    HASHES[$platform]="$sri_hash"
    echo "  $platform: $sri_hash"
done

# Write version.json
echo "Writing $VERSION_FILE..."
cat > "$VERSION_FILE" << EOF
{
  "version": "$VERSION",
  "hashes": {
    "linux-amd64": "${HASHES[linux-amd64]}",
    "linux-arm64": "${HASHES[linux-arm64]}",
    "darwin-amd64": "${HASHES[darwin-amd64]}",
    "darwin-arm64": "${HASHES[darwin-arm64]}"
  }
}
EOF

echo "Done! Updated to version $VERSION"
