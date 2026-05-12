#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-CodexImeGuard}"
LAUNCH_AGENT_LABEL="${LAUNCH_AGENT_LABEL:-io.github.codex-ime-guard}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/Applications}"
APP_DIR="$INSTALL_DIR/$APP_NAME.app"
PLIST_PATH="$HOME/Library/LaunchAgents/$LAUNCH_AGENT_LABEL.plist"

launchctl bootout "gui/$(id -u)" "$PLIST_PATH" >/dev/null 2>&1 || true
rm -rf "$APP_DIR" "$PLIST_PATH"

cat <<EOF
Uninstalled Codex IME Guard

Removed:
- $APP_DIR
- $PLIST_PATH

Accessibility permission entries may remain in System Settings.
EOF
