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

`.github/workflows/release.yml` は、次のどちらかで release を作成します。

- GitHub Actions の `Release` workflow を手動実行し、`version_bump` または `custom_version` を指定する
- 既に作成済みの `v*.*.*` tag を push する

手動実行の場合、workflow は version bump commit と release tag を作成してから release 処理へ進みます。`version_bump` は `patch` / `minor` / `major` を選べます。

release workflow は次の処理を行います。

- `just check`
- `codex-ime-guard --version` と tag version の一致確認
- GitHub release tarball の SHA256 取得
- `Formula/codex-ime-guard.rb` 生成
- `brew audit --strict --formula`
- `brew install --build-from-source`
- `brew services start` / `brew services stop`
- release asset への GPG detached signature 作成
- GitHub Release 作成
- `ItsukiYoshida/homebrew-tap` への Formula push

tap 更新には、この repository の Actions secret `HOMEBREW_TAP_TOKEN` が必要です。token には `ItsukiYoshida/homebrew-tap` へ push できる権限を付与してください。

release asset の署名には、次の Actions secrets が必要です。

```text
RELEASE_GPG_PRIVATE_KEY
RELEASE_GPG_PASSPHRASE
```

署名 key と検証手順は [RELEASE_SIGNING.md](RELEASE_SIGNING.md) を参照してください。

tag を手動で作成する場合:

```sh
git tag v0.1.1
git push origin v0.1.1
```

ローカルで version bump だけ確認する場合:

```sh
VERSION_BUMP=patch scripts/release/bump-version.py
```

この script は次の version 記述を同期します。

- `platforms/macos/Sources/CodexImeGuard/main.swift`
- `.github/workflows/ci.yml`
- `docs/HOMEBREW_TAP.md`

## 手動 Formula 生成

release workflow と同じ Formula はローカルでも生成できます。

```sh
scripts/homebrew/generate-formula.sh \
  --owner ItsukiYoshida \
  --repo codex-ime-guard \
  --version 0.1.1 \
  --sha256 <sha256> \
  --output Formula/codex-ime-guard.rb
```

release tarball の SHA256:

```sh
curl -L https://github.com/ItsukiYoshida/codex-ime-guard/archive/refs/tags/v0.1.1.tar.gz | shasum -a 256
```

## 検証

Homebrew をローカル環境へ入れたくない場合は、次のように検証範囲を分けます。

- ローカル: Formula 生成と Ruby 構文確認まで行う
- GitHub Actions: `brew audit`、`brew install --build-from-source`、`brew services start` / `stop` を行う
- release workflow: publish 後に公開済み tap を改めて tap し、実際の利用者と同じ `ItsukiYoshida/tap/codex-ime-guard` から install できることを確認する

ローカルで Homebrew なしに確認できる範囲:

```sh
scripts/homebrew/generate-formula.sh \
  --owner ItsukiYoshida \
  --repo codex-ime-guard \
  --version 0.1.1 \
  --sha256 <sha256> \
  --output /tmp/codex-ime-guard.rb

ruby -c /tmp/codex-ime-guard.rb
```

実際の Homebrew 配布確認は、この repository の `.github/workflows/release.yml` に任せます。`v*.*.*` tag を push すると GitHub Actions の `macos-latest` runner 上で Homebrew を使って検証されるため、手元の macOS に Homebrew を入れる必要はありません。

Homebrew を入れている環境で手動確認する場合:

```sh
brew audit --strict --formula ItsukiYoshida/tap/codex-ime-guard
brew install --build-from-source ItsukiYoshida/tap/codex-ime-guard
codex-ime-guard --version
brew services start codex-ime-guard
brew services list
brew services stop codex-ime-guard
brew uninstall codex-ime-guard
```
