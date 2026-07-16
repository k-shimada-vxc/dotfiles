# dotfiles

## macOS 環境を適用する

1. Nix をインストールする。

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. 新しいログインシェルを開く。

3. 初回のみ nix-darwin をインストールして構成を適用する。

```sh
sudo nix run github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild -- \
  switch --flake ~/dotfiles#VX-NT-0969
```

4. 2回目以降はインストール済みの `darwin-rebuild` を使う。

```sh
sudo darwin-rebuild switch --flake ~/dotfiles#VX-NT-0969
```

5. Node.js、Corepack、AWS CLI、SAM CLI の状態を確認する。

```sh
which node
node --version
corepack --version
pnpm --version
yarn --version
aws --version
sam --version
```

## 運用方針

- Node.js 本体は Nix で管理する。
- `pnpm` と `yarn` は Corepack 経由で利用する。
- Node 製 CLI の追加は、まず Nix パッケージで供給できるかを確認する。
- Volta の `install` / `pin` は使わない。
- AWS CLI と SAM CLI は nix-darwin の Homebrew モジュールで管理する。
- Homebrew パッケージの自動更新と未宣言パッケージの削除は行わない。
