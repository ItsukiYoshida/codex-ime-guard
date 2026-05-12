#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$(uname -s)" in
  Darwin)
    exec "$ROOT_DIR/scripts/macos/install.sh" "$@"
    ;;
  Linux)
    echo "codex-ime-guard: Linux install is not implemented yet." >&2
    exit 1
    ;;
  *)
    echo "codex-ime-guard: unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac
