{
  lib,
  pkgs,
  pkgs-unstable,
  username,
  homeDirectory,
  gh-stack,
  humanlayer-skills,
  ...
}:

let
  nodejsPackage = pkgs.nodejs_22;

  artifactshareCli = pkgs.callPackage ./packages/artifactshare.nix { nodejs = nodejsPackage; };

  # 配布 SKILL.md は CLI を `npm exec --yes` で都度取得する前提で書かれており、
  # そのままでは Nix で固定した版と実行される版が食い違う。PATH 上の固定版を
  # 直接呼ぶ形へ書き換えて、skill と CLI のバージョンを一致させる。
  # Cursor 用の .mdc は同じ内容の別形式なので、SKILL.md だけを skill として配る。
  #
  # 社内インスタンスの upload endpoint は share 応答の URL を localhost で返す
  # （同じ artifact でも artifacts list の share_url は正しい）。応答をそのまま
  # 渡すと開けないリンクを手渡すことになるので、base URL と id から組む指示に変える。
  # 一括置換は substituteInPlace、文面の入れ替えは patch と、変更の性質で使い分ける。
  # patch は pristine な upstream に当てるため、置換より先に適用する。
  artifactshareSkill = pkgs.runCommandLocal "artifactshare-skill" { } ''
    mkdir -p "$out"
    cp ${artifactshareCli}/lib/node_modules/@artifactshare/cli/skills/artifactshare/SKILL.md "$out"/
    chmod +w "$out/SKILL.md"
    patch -p1 -F0 -d "$out" < ${./agents/patches/artifactshare-share-url.patch}
    substituteInPlace "$out/SKILL.md" \
      --replace-fail "npm exec --yes --package=@artifactshare/cli -- artifactshare" "artifactshare"
  '';

  managedAgentSkills = {
    "artifactshare" = artifactshareSkill;
    "code-drift-check" = ./agents/skills/code-drift-check;
    "code-meaning-check" = ./agents/skills/code-meaning-check;
    "design-doc" = ./agents/skills/design-doc;
    "explain-diff-html" = ./agents/skills/explain-diff-html;
    "explain-diff-notion" = ./agents/skills/explain-diff-notion;
    "gh-address-comments" = ./agents/skills/gh-address-comments;
    # `gh skill install` は gh 2.74 に未実装なので、配布元の skill ディレクトリを直接 Nix 管理する。
    "gh-stack" = gh-stack + "/skills/gh-stack";
    "git-commit" = ./agents/skills/git-commit;
    # 配布元は plugin 形式だが、plugin.json ごと取り込むと管理単位が skill と plugin で二重になる。
    # skill ディレクトリだけを指して、他の skill と同じ扱いに揃える。
    "show-me" = humanlayer-skills + "/plugins/show-me/skills/show-me";
  };

  managedSkillLinks =
    root:
    lib.mapAttrs' (
      name: source: lib.nameValuePair "${root}/${name}" { inherit source; }
    ) managedAgentSkills;

  codexCli = pkgs.callPackage ./packages/codex.nix { inherit (pkgs-unstable) codex; };
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.file =
    # 自作 skill は skill ディレクトリ単位で Nix 管理し、各ツールの標準パスへ配る。
    (managedSkillLinks ".agents/skills")
    // (managedSkillLinks ".claude/skills")
    // {
      # エージェント横断の指示は dotfiles 側を正本にし、各ツールの標準パスへ配る。
      ".codex/AGENTS.md".source = ./agents/instructions/common.md;
      ".claude/CLAUDE.md".source = ./agents/instructions/common.md;
      ".claude/statusline-command.sh".source = ./agents/claude/statusline-command.sh;

      # zsh プラグインは profile 直下ではなく固定のユーザー管理パスへ配置する。
      ".local/share/zsh/plugins/zsh-autosuggestions".source =
        "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      ".local/share/zsh/plugins/fast-syntax-highlighting".source =
        "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
    };

  # ~/.claude.json の installMethod が native のため、native インストールの配置先である
  # ~/.local/bin/claude を Nix 管理の版へ向ける。管理外のものは上書きせずに止める。
  home.activation.linkClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    claude_target="$HOME/.local/bin/claude"
    claude_managed="${pkgs-unstable.claude-code}/bin/claude"

    mkdir -p "$HOME/.local/bin"
    if [ -L "$claude_target" ]; then
      claude_current="$(readlink "$claude_target")"
      case "$claude_current" in
        /nix/store/*-claude-code-*/bin/claude)
          ln -sfn "$claude_managed" "$claude_target"
          ;;
        *)
          echo "Refusing to replace unmanaged claude symlink: $claude_current" >&2
          exit 1
          ;;
      esac
    elif [ -e "$claude_target" ]; then
      echo "Refusing to replace existing non-symlink claude: $claude_target" >&2
      exit 1
    else
      ln -s "$claude_managed" "$claude_target"
    fi
  '';

  # settings.json は Orca の hooks や /model などツール側も書き込むため、home.file で
  # 読み取り専用の symlink にはせず、dotfiles で決めたキーだけを既存の内容へ上書きマージする。
  # dotfiles から消したキーは前回の管理対象を記録しないと判別できないので、手で消す運用にする。
  home.activation.mergeClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    claude_settings="$HOME/.claude/settings.json"
    claude_managed_settings="${./agents/claude/settings.json}"

    mkdir -p "$HOME/.claude"
    if [ -e "$claude_settings" ]; then
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$claude_settings" "$claude_managed_settings" > "$claude_settings.tmp"
      mv "$claude_settings.tmp" "$claude_settings"
    else
      cp "$claude_managed_settings" "$claude_settings"
      chmod u+w "$claude_settings"
    fi
  '';

  # Node.js の実行基盤だけを固定し、pnpm / yarn は pkgs.corepack の shim から Corepack に委ねる。
  # bun はランタイム兼パッケージマネージャーで Corepack の管理対象外なので、単独パッケージとして固定する。
  home.packages = [
    artifactshareCli
    codexCli
    nodejsPackage
    pkgs.bat
    pkgs.bun
    pkgs.corepack
    pkgs.eza
    pkgs.fzf
    pkgs.nixfmt
    pkgs.openapi-generator-cli
    pkgs.python3
    pkgs.ripgrep
    pkgs.starship
    # 更新の速いコーディングエージェントは nixos-25.11 では upstream から大きく遅れるため、unstable から取る。
    pkgs-unstable.claude-code
    pkgs-unstable.opencode
  ]
  # Homebrew から移した CLI。nixos-25.11 では移行前の brew 版より古くなるものがあるため、
  # 個別に系統を選び分けず unstable に揃える。
  ++ (with pkgs-unstable; [
    awscli2
    curl
    deno
    docutils
    duckdb
    gh
    # 既定の go は 1.26 で、移行前の brew 版 1.27 より古いため minor を明示する。
    go_1_27
    golangci-lint
    graphviz
    groff
    jq
    mosh
    pgcli
    pipx
    postgresql_16
    python3Packages.cfn-lint
    # brew の rust は toolchain を1版に固定するため、プロジェクトごとに toolchain を切り替えられる rustup にする。
    rustup
    shellcheck
    tmux
    tree
    uv
    yq-go
  ]);
}
