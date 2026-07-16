{
  lib,
  pkgs,
  username,
  homeDirectory,
  inspired-mino-design-skills,
  ...
}:

let
  nodejsPackage = if builtins.hasAttr "nodejs_22" pkgs then pkgs.nodejs_22 else pkgs.nodejs;

  inspiredMinoSkillsRoot = inspired-mino-design-skills + "/.agents/skills";

  managedAgentSkills = {
    "gh-address-comments" = ./agents/skills/gh-address-comments;
    "git-commit" = ./agents/skills/git-commit;
    "go-test-quality-check" = ./agents/skills/go-test-quality-check;
    "notion-pb-to-design-doc" = ./agents/skills/notion-pb-to-design-doc;
  }
  // lib.genAttrs [
    "mino-architecture-quality-strategy"
    "mino-core"
    "mino-design-by-contract"
    "mino-domain-model-completeness"
    "mino-interface-implementation-separation"
    "mino-problem-framing"
    "mino-reproducible-development"
  ] (name: inspiredMinoSkillsRoot + "/${name}");

  managedSkillLinks =
    root:
    lib.mapAttrs' (
      name: source:
      lib.nameValuePair "${root}/${name}" {
        inherit source;
        force = true;
      }
    ) managedAgentSkills;

  claudeCodeVersion = "2.1.204";
  claudeCode = pkgs.stdenvNoCC.mkDerivation {
    pname = "claude-code";
    version = claudeCodeVersion;

    src = pkgs.fetchurl {
      url = "https://downloads.claude.ai/claude-code-releases/${claudeCodeVersion}/darwin-arm64/claude";
      hash = "sha256-Fne2dZW2JRFW1iYA3IXUBw7Dhbct0LB+c3QqVgMJUsM=";
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

    installPhase = ''
      runHook preInstall

      install -D -m 0755 "$src" "$out/bin/claude"

      # Claude Code の更新と補助コマンド解決を Nix 管理へ寄せる。
      wrapProgram "$out/bin/claude" \
        --set DISABLE_AUTOUPDATER 1 \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --set USE_BUILTIN_RIPGREP 0 \
        --prefix PATH : ${
          lib.makeBinPath [
            pkgs.procps
            pkgs.ripgrep
          ]
        }

      runHook postInstall
    '';

    meta = {
      description = "Agentic coding tool that lives in your terminal";
      homepage = "https://github.com/anthropics/claude-code";
      license = lib.licenses.unfree;
      mainProgram = "claude";
      platforms = [ "aarch64-darwin" ];
    };
  };

  codexCliVersion = "0.144.4";
  codexCli = pkgs.stdenvNoCC.mkDerivation {
    pname = "openai-codex";
    version = codexCliVersion;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@openai/codex/-/codex-${codexCliVersion}.tgz";
      hash = "sha256-YTqtswvktqbapFy9CG9dSoRja82MA2UQwQZGS9CH8ZM=";
    };

    codexDarwinArm64Src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@openai/codex/-/codex-${codexCliVersion}-darwin-arm64.tgz";
      hash = "sha256-UmMBj60neE4e4+v6o6rgo7vw7dkZAGiwnbn78oy/pI4=";
    };

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack

      mkdir -p source platform
      tar -xzf "$src" -C source
      tar -xzf "$codexDarwinArm64Src" -C platform

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      install -d "$out/lib/node_modules/@openai"
      cp -R source/package "$out/lib/node_modules/@openai/codex"
      cp -R platform/package "$out/lib/node_modules/@openai/codex-darwin-arm64"

      # npm 版の wrapper を使いつつ、実行時の Node.js は Nix 管理のものへ固定する。
      substituteInPlace "$out/lib/node_modules/@openai/codex/bin/codex.js" \
        --replace-fail "#!/usr/bin/env node" "#!${nodejsPackage}/bin/node"

      chmod +x "$out/lib/node_modules/@openai/codex/bin/codex.js"
      chmod +x "$out/lib/node_modules/@openai/codex-darwin-arm64/vendor/aarch64-apple-darwin/bin/codex"

      install -d "$out/bin"
      ln -s "$out/lib/node_modules/@openai/codex/bin/codex.js" "$out/bin/codex"

      runHook postInstall
    '';

    meta = {
      description = "OpenAI Codex CLI installed from npm";
      homepage = "https://github.com/openai/codex";
      license = lib.licenses.asl20;
      mainProgram = "codex";
      platforms = [ "aarch64-darwin" ];
    };
  };
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
      ".codex/AGENTS.md" = {
        source = ./agents/instructions/common.md;
        force = true;
      };
      ".claude/CLAUDE.md".source = ./agents/instructions/common.md;

      ".codex/skills/gh-address-comments" = {
        source = managedAgentSkills."gh-address-comments";
        force = true;
      };

      # zsh プラグインは profile 直下ではなく固定のユーザー管理パスへ配置する。
      ".local/share/zsh/plugins/zsh-autosuggestions".source =
        "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      ".local/share/zsh/plugins/fast-syntax-highlighting".source =
        "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
    };

  # Corepack の shim をユーザー管理ディレクトリへ置き、pnpm / yarn を即利用できるようにする。
  home.activation.enableCorepack = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v corepack >/dev/null 2>&1; then
      mkdir -p "$HOME/.local/bin"
      corepack enable --install-directory "$HOME/.local/bin"
    fi
  '';

  # 既存の standalone installer 由来 symlink だけを Nix 管理の Claude Code へ移行する。
  home.activation.linkClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    claude_target="$HOME/.local/bin/claude"
    claude_managed="${claudeCode}/bin/claude"

    mkdir -p "$HOME/.local/bin"
    if [ -L "$claude_target" ]; then
      claude_current="$(readlink "$claude_target")"
      case "$claude_current" in
        "$HOME/.local/share/claude/versions/"*|/nix/store/*-claude-code-*/bin/claude)
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

  # Node.js の実行基盤だけを固定し、パッケージマネージャーは Corepack に委ねる。
  home.packages = [
    claudeCode
    codexCli
    nodejsPackage
    pkgs.bat
    pkgs.eza
    pkgs.fzf
    pkgs.ripgrep
    pkgs.starship
  ]
  ++ lib.optional (builtins.hasAttr "corepack" pkgs) pkgs.corepack
  # Nix で供給できる CLI だけを宣言し、未収録のものは次段で個別に判断する。
  ++ lib.optional (builtins.hasAttr "openapi-generator-cli" pkgs) pkgs."openapi-generator-cli";
}
