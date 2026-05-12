#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: generate-formula.sh --owner OWNER --repo REPO --version VERSION --sha256 SHA256 --output PATH
EOF
}

OWNER=""
REPO=""
VERSION=""
SHA256=""
OUTPUT=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --owner)
      OWNER="${2:-}"
      shift 2
      ;;
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    --sha256)
      SHA256="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT="${2:-}"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 64
      ;;
  esac
done

if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$VERSION" ] || [ -z "$SHA256" ] || [ -z "$OUTPUT" ]; then
  usage >&2
  exit 64
fi

mkdir -p "$(dirname "$OUTPUT")"

cat > "$OUTPUT" <<EOF
class CodexImeGuard < Formula
  desc "IME guard for using Codex CLI Vim mode on macOS"
  homepage "https://github.com/$OWNER/$REPO"
  url "https://github.com/$OWNER/$REPO/archive/refs/tags/v#{version}.tar.gz"
  version "$VERSION"
  sha256 "$SHA256"
  license "MIT"

  depends_on xcode: :build

  def install
    system "swift", "build", "-c", "release", "--package-path", "platforms/macos"
    bin.install "platforms/macos/.build/release/codex-ime-guard"
  end

  service do
    run [opt_bin/"codex-ime-guard"]
    keep_alive true
    environment_variables CODEX_IME_GUARD_ASCII_SOURCE: "com.apple.keylayout.ABC"
    log_path var/"log/codex-ime-guard.log"
    error_log_path var/"log/codex-ime-guard.err.log"
  end

  test do
    assert_equal "codex-ime-guard #{version}", shell_output("#{bin}/codex-ime-guard --version").strip
  end
end
EOF
