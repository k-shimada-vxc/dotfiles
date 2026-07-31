{
  lib,
  username,
  homeDirectory,
  ...
}:

{
  # Determinate Nix のデーモンと設定を維持し、nix-darwin との管理競合を避ける。
  nix.enable = false;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
      ];
  };

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
      "anomalyco/tap"
      "ariga/tap"
      "hashicorp/tap"
      "homebrew/bundle"
      "homebrew/services"
    ];

    brews = [
      "aws-sam-cli"
      "awscli"
      "cfn-lint"
      "curl"
      "deno"
      "docutils"
      "duckdb"
      "gh"
      "go"
      "golangci-lint"
      "graphviz"
      "groff"
      "jq"
      "mosh"
      "pgcli"
      "pipx"
      {
        name = "postgresql@16";
        link = true;
      }
      "rust"
      "shellcheck"
      "tmux"
      "tree"
      "uv"
      "yq"
    ];

    casks = [
      "raycast"
      "tableplus"
      "warp"
    ];

    # nix-darwin 25.11 が未対応の trusted オプションは、formula単位でBrewfileへ補う。
    extraConfig = ''
      brew "anomalyco/tap/opencode", trusted: true
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
