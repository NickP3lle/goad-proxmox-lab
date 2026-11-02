#!/usr/bin/env bash
# Clone upstream GOAD at the pinned commit and apply this repo's patches.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-./GOAD}"
git clone https://github.com/Orange-Cyberdefense/GOAD.git "$DEST"
git -C "$DEST" checkout "$(cat "$REPO_DIR/patches/UPSTREAM_COMMIT")"
git -C "$DEST" am "$REPO_DIR"/patches/*.patch
