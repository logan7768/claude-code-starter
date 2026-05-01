#!/usr/bin/env bash
set -euo pipefail
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$ROOT/claude-config"
echo "Claude Code Starter installer"
echo "Target: $CLAUDE_DIR"
# Fail-fast requirement checks
command -v jq >/dev/null || { echo "ERROR: jq required. Install via your package manager (apt/brew/etc)."; exit 1; }
command -v claude >/dev/null || echo "WARNING: claude CLI not found in PATH (will still install)"
# OS check
case "$OSTYPE" in
  darwin*|linux-gnu*) ;;
  *) echo "ERROR: This script is for Linux/Mac. Use install.ps1 on Windows."; exit 1 ;;
esac
# Backup existing
if [ -d "$CLAUDE_DIR" ] && [ -n "$(ls -A "$CLAUDE_DIR" 2>/dev/null)" ]; then
  read -p "$CLAUDE_DIR exists. Backup and replace? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
  mv "$CLAUDE_DIR" "$CLAUDE_DIR.backup.$(date +%s)"
fi
# Install
mkdir -p "$CLAUDE_DIR"
cp "$SOURCE_DIR/CLAUDE.md" "$CLAUDE_DIR/"
cp -r "$SOURCE_DIR/hooks" "$CLAUDE_DIR/"
cp -r "$SOURCE_DIR/skills" "$CLAUDE_DIR/"
cp "$SOURCE_DIR/settings.linux.json" "$CLAUDE_DIR/settings.json"
chmod +x "$CLAUDE_DIR/hooks/"*.sh
# Validate
echo
echo "Running hook tests..."
"$ROOT/tests/test-hooks.sh" || { echo "WARNING: some tests failed. Check output above."; exit 1; }
echo
echo "✓ Installed to $CLAUDE_DIR"
echo "  Run 'claude' and try '/memory' to verify."
echo "  Test the security hook with: rm -rf /etc (should be denied)."
echo "  Test the .env protection with: cat .env (should be denied)."
