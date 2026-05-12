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
