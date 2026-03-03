#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

INSTALL_DIR="/usr/local/bin"
SWIFTFORMAT_VERSION="0.60.0"
SWIFTFORMAT_BIN="$INSTALL_DIR/swiftformat"
SWIFTFORMAT_URL="https://github.com/nicklockwood/SwiftFormat/releases/download/${SWIFTFORMAT_VERSION}/swiftformat_linux.zip"

# Install SwiftFormat if not already installed or version mismatch
if [ ! -f "$SWIFTFORMAT_BIN" ] || ! "$SWIFTFORMAT_BIN" --version 2>/dev/null | grep -q "^${SWIFTFORMAT_VERSION}$"; then
  echo "Installing SwiftFormat ${SWIFTFORMAT_VERSION}..."
  TMP_DIR=$(mktemp -d)
  curl -fsSL "$SWIFTFORMAT_URL" -o "$TMP_DIR/swiftformat_linux.zip"
  unzip -q "$TMP_DIR/swiftformat_linux.zip" -d "$TMP_DIR"
  install -m 755 "$TMP_DIR/swiftformat_linux" "$SWIFTFORMAT_BIN"
  rm -rf "$TMP_DIR"
  echo "SwiftFormat ${SWIFTFORMAT_VERSION} installed."
else
  echo "SwiftFormat ${SWIFTFORMAT_VERSION} already installed."
fi
