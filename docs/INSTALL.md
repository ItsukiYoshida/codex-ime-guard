# インストール手順

現在インストールに対応しているのは macOS 版のみです。

## macOS

### Homebrew

Codex IME Guard は自前 Homebrew tap からインストールできます。

```sh
brew install ItsukiYoshida/tap/codex-ime-guard
brew services start codex-ime-guard
```

インストール後、次の場所で `codex-ime-guard` にアクセシビリティ権限を付与してください。

```text
システム設定 > プライバシーとセキュリティ > アクセシビリティ
```

停止・削除する場合:

```sh
brew services stop codex-ime-guard
brew uninstall codex-ime-guard
```

### ローカルビルド

```sh
./scripts/install.sh
```

インストーラは macOS 版 Swift Package をリリースビルドし、バックグラウンド専用のアプリケーションバンドルを `~/Applications` に配置します。その後、アドホック署名を行い、LaunchAgent に登録します。

インストール後、次の場所で `Codex IME Guard` にアクセシビリティ権限を付与してください。

```text
システム設定 > プライバシーとセキュリティ > アクセシビリティ
```

再ビルドした場合やバンドル ID を変更した場合は、macOS 側で再承認が必要になることがあります。

### 設定

インストーラは環境変数で設定を変更できます。

```sh
BUNDLE_ID=io.github.yourname.CodexImeGuard \
LAUNCH_AGENT_LABEL=io.github.yourname.codex-ime-guard \
CODEX_IME_GUARD_ASCII_SOURCE=com.apple.keylayout.ABC \
CODEX_IME_GUARD_APPS=com.apple.Terminal,com.googlecode.iterm2,com.github.wez.wezterm \
./scripts/install.sh
```

`CODEX_IME_GUARD_APPS` には、Codex IME Guard を有効にするアプリケーションのバンドル ID をカンマ区切りで指定します。

標準で対象になるアプリケーション:

- Terminal
- iTerm2
- WezTerm
- Ghostty
- Warp
- Kitty
- Alacritty
- VS Code

### アンインストール

```sh
./scripts/uninstall.sh
```

アンインストール後も、システム設定にアクセシビリティ権限の項目が残る場合があります。
