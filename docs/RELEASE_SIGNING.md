# Release Signing

Codex IME Guard の release asset は、専用の OpenPGP key で署名します。

## Public Key

公開鍵:

```text
docs/release/codex-ime-guard-release-signing.asc
```

Fingerprint:

```text
9739619A91539FEF747E16EBDA14888369CA904B
```

Key identity:

```text
Codex IME Guard Release Signing <plusion00@icloud.com>
```

## GitHub Actions Secrets

Release workflow は、次の Actions secrets を使って release asset に detached signature を作成します。

```text
RELEASE_GPG_PRIVATE_KEY
RELEASE_GPG_PASSPHRASE
```

ローカルで生成した secret material は `.release-secrets/` に保存しています。このディレクトリは `.gitignore` で除外しています。

GitHub secrets に登録する値:

```sh
gh secret set RELEASE_GPG_PRIVATE_KEY < .release-secrets/release-gpg-private-key.asc
gh secret set RELEASE_GPG_PASSPHRASE < .release-secrets/release-gpg-passphrase.txt
```

## Release Assets

`v*.*.*` tag の release workflow は次の署名付き asset を作成します。

```text
codex-ime-guard.rb
codex-ime-guard.rb.asc
SHA256SUMS
SHA256SUMS.asc
```

`SHA256SUMS` には GitHub release tarball と generated Formula の SHA256 を記録します。

## Verification

公開鍵を import します。

```sh
gpg --import docs/release/codex-ime-guard-release-signing.asc
gpg --fingerprint 9739619A91539FEF747E16EBDA14888369CA904B
```

Release asset を検証します。

```sh
gpg --verify SHA256SUMS.asc SHA256SUMS
gpg --verify codex-ime-guard.rb.asc codex-ime-guard.rb
shasum -a 256 --check SHA256SUMS
```

GitHub の tag archive を検証する場合は、`SHA256SUMS` に記録されている tarball URL と同じ tag archive を取得してから `shasum` を実行してください。
