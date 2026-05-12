# Codex CLI の Vim mode と日本語 IME を共存させるために codex-ime-guard を作った

## 公開前メモ

release asset の署名と検証手順は用意済み。

- 公開鍵: `docs/release/codex-ime-guard-release-signing.asc`
- fingerprint: `9739619A91539FEF747E16EBDA14888369CA904B`
- 検証手順: `docs/RELEASE_SIGNING.md`

ここから下が記事本文。

---

Codex CLI を Vim mode で使っていると、日本語 IME との相性で少し困る場面があります。

たとえば日本語でプロンプトを書いたあと、`Esc` で Normal mode に戻っても IME が日本語入力のままだと、`j` / `k` / `h` / `l` などの Vim 操作がそのまま入力文字になってしまいます。

毎回手動で英数入力に戻すのは地味に面倒です。

そこで、macOS 向けに `codex-ime-guard` という小さな常駐ツールを作りました。

## 作ったもの

`codex-ime-guard` は、Codex CLI の Vim mode を日本語 IME と併用しやすくするための macOS 常駐ツールです。

主な挙動は次の通りです。

- `Esc` を押したら英数入力に切り替える
- `Ctrl+Enter` を押したら送信後に英数入力へ戻す
- `i` / `a` / `o` などで Insert mode に入ると、直前の日本語入力ソースを復元する

つまり、Normal mode では英数、Insert mode では必要に応じて日本語、という状態をなるべく自然に保つためのツールです。

## なぜ必要だったか

Codex CLI では日本語で指示を書くことが多い一方、Vim mode の操作は英字キーが前提です。

日本語 IME が有効なまま Normal mode に戻ると、移動や編集のつもりで押したキーが入力として扱われてしまいます。

もちろん手動で IME を切り替えれば済む話ではあります。ただ、Codex CLI とのやり取りでは「日本語で書く」「Normal mode で移動する」「また日本語を書く」を短い間隔で繰り返すので、この切り替えがかなり目立ちます。

`codex-ime-guard` は、この部分だけを自動化するために作りました。

## インストール

現時点では macOS のみ対応しています。

Homebrew tap からインストールできます。

```sh
brew install ItsukiYoshida/tap/codex-ime-guard
brew services start codex-ime-guard
```

インストール後、macOS のアクセシビリティ権限を付与してください。

```text
System Settings > Privacy & Security > Accessibility
```

停止する場合は次の通りです。

```sh
brew services stop codex-ime-guard
```

## 対象アプリケーション

デフォルトでは、Terminal、iTerm2、WezTerm、Ghostty、Warp、Kitty、Alacritty、VS Code などを対象にしています。

対象アプリケーションは環境変数で変更できます。

```sh
CODEX_IME_GUARD_APPS=com.apple.Terminal,com.googlecode.iterm2
```

英数入力に切り替える入力ソースも変更できます。

```sh
CODEX_IME_GUARD_ASCII_SOURCE=com.apple.keylayout.ABC
```

## 実装について

実装は Swift です。

macOS の `CGEventTap` でキー入力を監視し、`TISSelectInputSource` を使って入力ソースを切り替えています。

通常起動時にはアクセシビリティ権限が必要ですが、Homebrew の Formula で安全に検証できるように、CLI として `--version` と `--help` も実装しています。

```sh
codex-ime-guard --version
codex-ime-guard --help
```

## 使ってみた感想

かなり小さいツールですが、Codex CLI を Vim mode で使うときの引っかかりはかなり減りました。

特に、日本語でプロンプトを書いたあとに `Esc` で戻って、そのまま Normal mode の操作に移れるのがよいです。

IME の状態を意識する回数が減るだけで、CLI 上での思考の流れが止まりにくくなります。

## 今後

現時点では macOS 向けの最小構成です。

今後やるなら、次のあたりを考えています。

- `.app` 配布用の Cask 対応
- Developer ID 署名と notarization
- 対象アプリケーション設定の改善
- Linux 版の検討

同じように Codex CLI の Vim mode と日本語 IME の組み合わせで困っている人がいれば、試してみてください。
