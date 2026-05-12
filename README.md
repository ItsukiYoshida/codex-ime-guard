# Codex IME Guard

Codex IME Guard は、Codex CLI の Vim モードと日本語 IME を併用しやすくするためのプロジェクトです。

OS ごとに IME・入力イベント・常駐化の仕組みが異なるため、実装と配布資材はプラットフォーム別に分離しています。

## 対応状況

| OS | 状態 | 実装 |
| --- | --- | --- |
| macOS | 提供中 | [platforms/macos](platforms/macos/) |
| Linux | 未実装 | [platforms/linux](platforms/linux/) |

## ディレクトリ構成

```text
platforms/
  macos/
    Package.swift
    Sources/
    resources/
    templates/
  linux/
docs/
  INSTALL.md
scripts/
  install.sh
  uninstall.sh
  macos/
```

- `platforms/macos`: macOS 版の Swift Package、アプリ資材、LaunchAgent テンプレート
- `platforms/linux`: 将来の Linux 版実装用ディレクトリ。Swift Package は配置しない
- `docs/INSTALL.md`: インストール・アンインストール手順
- `scripts/install.sh` / `scripts/uninstall.sh`: OS を判定して OS 別スクリプトへ委譲する入口

## 開発

root の `Justfile` から macOS 版の build / format / lint を実行できます。

```sh
just fmt
just lint
just check
```

このリポジトリでは Swift の formatter / linter として、Swift ツールチェーンに含まれる `swift-format` を使用します。

## インストール

### Homebrew

Codex IME Guard は自前 Homebrew tap から配布します。

```sh
brew install ItsukiYoshida/tap/codex-ime-guard
brew services start codex-ime-guard
```

インストール後、次の場所で `codex-ime-guard` にアクセシビリティ権限を付与してください。

```text
System Settings > Privacy & Security > Accessibility
```

停止・削除する場合:

```sh
brew services stop codex-ime-guard
brew uninstall codex-ime-guard
```

### ローカルビルドからインストール

Homebrew を使わず、この checkout から直接インストールする場合は [docs/INSTALL.md](docs/INSTALL.md) を参照してください。

## Homebrew Tap の提供

リリース tag を push すると、GitHub Actions が release tarball の SHA256 を計算し、`ItsukiYoshida/homebrew-tap` の `Formula/codex-ime-guard.rb` を更新します。

tap の初期作成、リリース、検証手順は [docs/HOMEBREW_TAP.md](docs/HOMEBREW_TAP.md) を参照してください。
