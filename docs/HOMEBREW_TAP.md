# Homebrew Tap 提供手順

Codex IME Guard は `ItsukiYoshida/homebrew-tap` で Formula を提供します。

## Tap リポジトリ

Homebrew の tap 名は GitHub repository 名の `homebrew-` prefix を外して解決されます。

```text
GitHub repository: ItsukiYoshida/homebrew-tap
Homebrew tap:      ItsukiYoshida/tap
Formula path:      Formula/codex-ime-guard.rb
```

利用者向けのインストール手順:

```sh
brew install ItsukiYoshida/tap/codex-ime-guard
brew services start codex-ime-guard
```

## 初期作成

tap repository が存在しない場合は作成します。

```sh
gh repo create ItsukiYoshida/homebrew-tap --public --description "Homebrew tap for Codex IME Guard"
```

## 自動更新

`v*.*.*` tag を push すると `.github/workflows/release.yml` が次の処理を行います。

- `just check`
- `codex-ime-guard --version` と tag version の一致確認
- GitHub release tarball の SHA256 取得
- `Formula/codex-ime-guard.rb` 生成
- `brew audit --strict --formula`
- `brew install --build-from-source`
- `brew services start` / `brew services stop`
- GitHub Release 作成
- `ItsukiYoshida/homebrew-tap` への Formula push

tap 更新には、この repository の Actions secret `HOMEBREW_TAP_TOKEN` が必要です。token には `ItsukiYoshida/homebrew-tap` へ push できる権限を付与してください。

tag 例:

```sh
git tag v0.1.0
git push origin v0.1.0
```

## 手動 Formula 生成

release workflow と同じ Formula はローカルでも生成できます。

```sh
scripts/homebrew/generate-formula.sh \
  --owner ItsukiYoshida \
  --repo codex-ime-guard \
  --version 0.1.0 \
  --sha256 <sha256> \
  --output Formula/codex-ime-guard.rb
```

release tarball の SHA256:

```sh
curl -L https://github.com/ItsukiYoshida/codex-ime-guard/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
```

## 検証

```sh
brew audit --strict --formula ItsukiYoshida/tap/codex-ime-guard
brew install --build-from-source ItsukiYoshida/tap/codex-ime-guard
codex-ime-guard --version
brew services start codex-ime-guard
brew services list
brew services stop codex-ime-guard
brew uninstall codex-ime-guard
```
