#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_NAME="${APP_NAME:-CodexImeGuard}"
APP_DISPLAY_NAME="${APP_DISPLAY_NAME:-Codex IME Guard}"
BUNDLE_ID="${BUNDLE_ID:-io.github.codex-ime-guard.CodexImeGuard}"
LAUNCH_AGENT_LABEL="${LAUNCH_AGENT_LABEL:-io.github.codex-ime-guard}"
VERSION="${VERSION:-1}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/Applications}"
APP_DIR="$INSTALL_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
BINARY_PATH="$MACOS_DIR/codex-ime-guard"
PLIST_PATH="$HOME/Library/LaunchAgents/$LAUNCH_AGENT_LABEL.plist"
ASCII_SOURCE="${CODEX_IME_GUARD_ASCII_SOURCE:-com.apple.keylayout.ABC}"
TARGET_APPS="${CODEX_IME_GUARD_APPS:-com.microsoft.VSCode,com.apple.Terminal,com.googlecode.iterm2,com.github.wez.wezterm,com.mitchellh.ghostty,dev.warp.Warp-Stable,dev.warp.Warp,net.kovidgoyal.kitty,org.alacritty,io.alacritty}"
STDOUT_LOG="${CODEX_IME_GUARD_STDOUT_LOG:-$HOME/Library/Logs/codex-ime-guard.log}"
STDERR_LOG="${CODEX_IME_GUARD_STDERR_LOG:-$HOME/Library/Logs/codex-ime-guard.err.log}"

mkdir -p "$MACOS_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"

swift build -c release --package-path "$ROOT_DIR/platforms/macos"
cp "$ROOT_DIR/platforms/macos/.build/release/codex-ime-guard" "$BINARY_PATH"

sed \
  -e "s|__BUNDLE_ID__|$BUNDLE_ID|g" \
  -e "s|__VERSION__|$VERSION|g" \
  "$ROOT_DIR/platforms/macos/resources/Info.plist" > "$CONTENTS_DIR/Info.plist"

codesign --force --deep --sign - --identifier "$BUNDLE_ID" "$APP_DIR"

sed \
  -e "s|__LAUNCH_AGENT_LABEL__|$LAUNCH_AGENT_LABEL|g" \
  -e "s|__APP_BINARY__|$BINARY_PATH|g" \
  -e "s|__ASCII_SOURCE__|$ASCII_SOURCE|g" \
  -e "s|__TARGET_APPS__|$TARGET_APPS|g" \
  -e "s|__STDOUT_LOG__|$STDOUT_LOG|g" \
  -e "s|__STDERR_LOG__|$STDERR_LOG|g" \
  "$ROOT_DIR/platforms/macos/templates/launch-agent.plist" > "$PLIST_PATH"

plutil -lint "$CONTENTS_DIR/Info.plist" "$PLIST_PATH"

if launchctl print "gui/$(id -u)/$LAUNCH_AGENT_LABEL" >/dev/null 2>&1; then
  launchctl bootout "gui/$(id -u)" "$PLIST_PATH" >/dev/null 2>&1 || true
fi

launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"
launchctl kickstart -k "gui/$(id -u)/$LAUNCH_AGENT_LABEL"

cat <<EOF
Installed $APP_DISPLAY_NAME

App:          $APP_DIR
LaunchAgent:  $PLIST_PATH
Bundle ID:    $BUNDLE_ID

Grant Accessibility permission to $APP_DISPLAY_NAME if macOS asks.
After changing BUNDLE_ID or rebuilding the app, macOS may require re-approval.
EOF
