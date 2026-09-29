{
  username,
  homeDirectory,
  ...
}:

{
  # Determinate Nix のデーモンと設定を維持し、nix-darwin との管理競合を避ける。
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    primaryUser = username;
    stateVersion = 6;
  };

  # sudo を Touch ID で認証する。tmux 配下では pam_reattach がないと指紋要求が届かないため併用する。
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  users.users.${username} = {
    name = username;
    home = homeDirectory;
  };

  homebrew = {
    enable = true;

    taps = [
      "ariga/tap"
      "hashicorp/tap"
      "homebrew/bundle"
      "homebrew/services"
      "stablyai/orca"
    ];

    # nixpkgs の aws-sam-cli は darwin でテストが落ちてバイナリキャッシュに無く、
    # 手元ビルドもテスト無効化の override が必要になるため Homebrew に残す。
    brews = [ "aws-sam-cli" ];

    casks = [
      "raycast"
      # homebrew/cask の `orca` は plotly 製の別アプリなので、tap 名から完全修飾する。
      # 本体は electron-updater が /Applications を書き換えるため、版の固定は行わない。
      "stablyai/orca/orca"
      "tableplus"
      "warp"
    ];

    # nixpkgs の atlas はソースからビルドした Community 版で、公式バイナリにある機能が欠けるため tap から入れる。
    # nixpkgs の terraform は unfree でバイナリキャッシュに無く、更新のたびに手元ビルドになるため tap から入れる。
    # nix-darwin 25.11 が未対応の trusted オプションは、formula単位でBrewfileへ補う。
    extraConfig = ''
      brew "ariga/tap/atlas", trusted: true
      brew "hashicorp/tap/terraform", trusted: true
    '';

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
