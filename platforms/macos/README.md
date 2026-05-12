# macOS 版

macOS 版 Codex IME Guard は、Codex CLI の Vim モードを日本語 IME と併用しやすくするための常駐アプリケーションです。

ターミナルアプリ上のキー入力を監視し、Vim モードの状態遷移に合わせて macOS の入力ソースを切り替えます。

- `Esc`: 現在の非 ASCII 入力ソースを記憶し、ABC に切り替える
- `i`, `a`, `o`, `Insert`: 記憶していた入力ソースへ戻す
- `Ctrl+Enter`: Codex に送信し、ABC に切り替える
- 通常の `Enter`: このアプリケーションでは処理しないため、IME の変換確定にそのまま使える

## 必要なもの

- macOS
- Swift ツールチェーン / Xcode Command Line Tools
- インストール済みアプリケーションへのアクセシビリティ権限

## Codex の設定

Codex の Vim モードを有効にし、入力内容の送信を `Ctrl+Enter` に割り当ててください。

```toml
[tui]
vim_mode_default = true

[tui.keymap.composer]
submit = "ctrl-enter"
```

この設定により、通常の `Enter` は IME の変換確定に使い続けられます。また、Codex IME Guard は実際のプロンプト送信を安定して検知できます。

## インストール

インストール手順は [docs/INSTALL.md](../../docs/INSTALL.md) を参照してください。

## 開発

```sh
swift build -c release --package-path platforms/macos
just check
```

このアプリケーションは CGEventTap を使用します。そのため、キー入力イベントを監視するにはアクセシビリティ権限が必要です。
