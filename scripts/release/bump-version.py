#!/usr/bin/env python3

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
VERSION_PATTERN = re.compile(r"^\d+\.\d+\.\d+$")
MAIN_SWIFT = REPO_ROOT / "platforms/macos/Sources/CodexImeGuard/main.swift"
CI_WORKFLOW = REPO_ROOT / ".github/workflows/ci.yml"
HOMEBREW_DOC = REPO_ROOT / "docs/HOMEBREW_TAP.md"


def main() -> int:
    current = read_current_version()
    bump = os.environ.get("VERSION_BUMP", "patch")
    custom = os.environ.get("CUSTOM_VERSION", "").strip()
    next_version = custom or increment_version(current, bump)

    if not VERSION_PATTERN.fullmatch(next_version):
        raise SystemExit(f"Unsupported target version: {next_version}")
    if next_version == current:
        raise SystemExit(f"Target version must differ from current version: {current}")

    tag = f"v{next_version}"
    if git_tag_exists(tag):
        raise SystemExit(f"Tag {tag} already exists.")

    replace_version(MAIN_SWIFT, current, next_version)
    replace_version(CI_WORKFLOW, current, next_version)
    replace_version(HOMEBREW_DOC, current, next_version)

    write_github_output("current", current)
    write_github_output("version", next_version)
    write_github_output("tag", tag)
    return 0


def read_current_version() -> str:
    text = MAIN_SWIFT.read_text(encoding="utf-8")
    match = re.search(r'private let appVersion = "(\d+\.\d+\.\d+)"', text)
    if not match:
        raise SystemExit(f"Could not find appVersion in {MAIN_SWIFT}")
    return match.group(1)


def increment_version(version: str, bump: str) -> str:
    if not VERSION_PATTERN.fullmatch(version):
        raise SystemExit(f"Unsupported current version: {version}")

    major, minor, patch = (int(part) for part in version.split("."))
    if bump == "major":
        return f"{major + 1}.0.0"
    if bump == "minor":
        return f"{major}.{minor + 1}.0"
    if bump == "patch":
        return f"{major}.{minor}.{patch + 1}"
    raise SystemExit(f"Unsupported version bump: {bump}")


def git_tag_exists(tag: str) -> bool:
    return (
        subprocess.run(
            ["git", "rev-parse", f"refs/tags/{tag}"],
            cwd=REPO_ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        ).returncode
        == 0
    )


def replace_version(path: Path, current: str, next_version: str) -> None:
    text = path.read_text(encoding="utf-8")
    updated = text.replace(current, next_version)
    if updated == text:
        raise SystemExit(f"{path} did not contain {current}")
    path.write_text(updated, encoding="utf-8")


def write_github_output(name: str, value: str) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        with Path(output_path).open("a", encoding="utf-8") as output:
            output.write(f"{name}={value}\n")
    else:
        print(f"{name}={value}", file=sys.stderr)


if __name__ == "__main__":
    raise SystemExit(main())
