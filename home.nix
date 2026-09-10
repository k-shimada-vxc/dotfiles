{
  lib,
  pkgs,
  username,
  homeDirectory,
  inspired-mino-design-skills,
  gh-stack,
  pr-lens,
  humanlayer-skills,
  ...
}:

let
  nodejsPackage = if builtins.hasAttr "nodejs_22" pkgs then pkgs.nodejs_22 else pkgs.nodejs;

  inspiredMinoSkillsRoot = inspired-mino-design-skills + "/.agents/skills";

  # 配布 package には test / build 設定も同梱されるため、skill として読ませる SKILL.md と
  # references だけを取り出す。ディレクトリごと配ると skill 直下に無関係なファイルが並ぶ。
  prLensSkill = pkgs.runCommandLocal "pr-lens-skill" { } ''
    mkdir -p "$out"
    cp -R ${pr-lens}/packages/agent-skill/SKILL.md \
      ${pr-lens}/packages/agent-skill/references \
      "$out"/
  '';

  artifactshareCliVersion = "0.13.3";
  # zod だけは bundle 済みで、gunshi は静的 import、undici は動的 import として
  # 外部 module のまま残る。依存 tarball を並べて node_modules を組み、
  # npm の実行時解決に頼らない形に固定する。
  artifactshareGunshiVersion = "0.37.2";
  artifactshareUndiciVersion = "8.10.2";
  artifactshareCli = pkgs.stdenvNoCC.mkDerivation {
    pname = "artifactshare-cli";
    version = artifactshareCliVersion;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@artifactshare/cli/-/cli-${artifactshareCliVersion}.tgz";
      hash = "sha256-di0d2N/dh8vs9rWUB2JMsIMnJxSZ7SkMC4IAY3zHoz4=";
    };

    gunshiSrc = pkgs.fetchurl {
      url = "https://registry.npmjs.org/gunshi/-/gunshi-${artifactshareGunshiVersion}.tgz";
      hash = "sha256-kfVfEYQTildBa6Hg2gW6k+aAqcKH8dPuv0oACGE/Dgg=";
    };

    undiciSrc = pkgs.fetchurl {
      url = "https://registry.npmjs.org/undici/-/undici-${artifactshareUndiciVersion}.tgz";
      hash = "sha256-dAY4rjLXjSZGpnJ5UONl+ia2+oeRP6CW5g7Ur+tGNKo=";
    };

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack

      mkdir -p source gunshi undici
      tar -xzf "$src" -C source
      tar -xzf "$gunshiSrc" -C gunshi
      tar -xzf "$undiciSrc" -C undici

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      install -d "$out/lib/node_modules/@artifactshare"
      cp -R source/package "$out/lib/node_modules/@artifactshare/cli"
      cp -R gunshi/package "$out/lib/node_modules/gunshi"
      cp -R undici/package "$out/lib/node_modules/undici"

      # 実行時の Node.js を Nix 管理のものへ固定する。
      substituteInPlace "$out/lib/node_modules/@artifactshare/cli/dist/index.js" \
        --replace-fail "#!/usr/bin/env node" "#!${nodejsPackage}/bin/node"

      # help と JSON の next_steps が案内する `npm exec --yes` 経由の起動は、
      # 呼ぶたび最新版を取得して Nix で固定した版から外れる。案内文も PATH 上の
      # 固定版に揃え、agent がどこを読んでも同じ CLI に到達するようにする。
      substituteInPlace "$out/lib/node_modules/@artifactshare/cli/dist/index.js" \
        --replace-fail "npm exec --yes --package=@artifactshare/cli -- artifactshare" "artifactshare"
      chmod +x "$out/lib/node_modules/@artifactshare/cli/dist/index.js"

      install -d "$out/bin"
      ln -s "$out/lib/node_modules/@artifactshare/cli/dist/index.js" "$out/bin/artifactshare"

      runHook postInstall
    '';

    meta = {
      description = "Artifact Share CLI installed from npm";
      homepage = "https://artifactshare.com/connect";
      mainProgram = "artifactshare";
    };
  };

  # 配布 SKILL.md は CLI を `npm exec --yes` で都度取得する前提で書かれており、
  # そのままでは Nix で固定した版と実行される版が食い違う。PATH 上の固定版を
  # 直接呼ぶ形へ書き換えて、skill と CLI のバージョンを一致させる。
  # Cursor 用の .mdc は同じ内容の別形式なので、SKILL.md だけを skill として配る。
  artifactshareSkill = pkgs.runCommandLocal "artifactshare-skill" { } ''
    mkdir -p "$out"
    cp ${artifactshareCli}/lib/node_modules/@artifactshare/cli/skills/artifactshare/SKILL.md "$out"/
    chmod +w "$out/SKILL.md"
    substituteInPlace "$out/SKILL.md" \
      --replace-fail "npm exec --yes --package=@artifactshare/cli -- artifactshare" "artifactshare"
  '';

  managedAgentSkills = {
    "artifactshare" = artifactshareSkill;
    "code-drift-check" = ./agents/skills/code-drift-check;
    "code-meaning-check" = ./agents/skills/code-meaning-check;
    "explain-diff-html" = ./agents/skills/explain-diff-html;
    "explain-diff-notion" = ./agents/skills/explain-diff-notion;
    "gh-address-comments" = ./agents/skills/gh-address-comments;
    # `gh skill install` は gh 2.74 に未実装なので、配布元の skill ディレクトリを直接 Nix 管理する。
    "gh-stack" = gh-stack + "/skills/gh-stack";
    "git-commit" = ./agents/skills/git-commit;
    "grilling" = ./agents/skills/grilling;
    "notion-pb-to-design-doc" = ./agents/skills/notion-pb-to-design-doc;
    # skill 本体は markdown だけで、実処理は SKILL.md が呼ぶ pr-lens CLI 側にある。
    "pr-lens" = prLensSkill;
    # 配布元は plugin 形式だが、plugin.json ごと取り込むと管理単位が skill と plugin で二重になる。
    # skill ディレクトリだけを指して、他の skill と同じ扱いに揃える。
    "show-me" = humanlayer-skills + "/plugins/show-me/skills/show-me";
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

  claudeCodeVersion = "2.1.250";
  claudeCode = pkgs.stdenvNoCC.mkDerivation {
    pname = "claude-code";
    version = claudeCodeVersion;

    src = pkgs.fetchurl {
      url = "https://downloads.claude.ai/claude-code-releases/${claudeCodeVersion}/darwin-arm64/claude";
      hash = "sha256-UG1zYqnGJTBgRIeanZHY8zvS7vljaBtWvjKV21/j40s=";
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

  codexCliVersion = "0.153.4";
  codexCli = pkgs.stdenvNoCC.mkDerivation {
    pname = "openai-codex";
    version = codexCliVersion;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@openai/codex/-/codex-${codexCliVersion}.tgz";
      hash = "sha256-/QQmPBrfodKFxsCthql8q1CNMBLunquAqZ93PMSy+zo=";
    };

    codexDarwinArm64Src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@openai/codex/-/codex-${codexCliVersion}-darwin-arm64.tgz";
      hash = "sha256-U10wG0kTGr/aMmT5WfsN76QLvDBpdtmN28FcQkY2xVw=";
    };

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

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
      # config.toml は Codex 自身が更新する可変設定なので、Nix 管理版の wrapper で更新確認だけを無効化する。
      makeWrapper "$out/lib/node_modules/@openai/codex/bin/codex.js" "$out/bin/codex" \
        --add-flags "-c check_for_update_on_startup=false"

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
  # bun はランタイム兼パッケージマネージャーで Corepack の管理対象外なので、単独パッケージとして固定する。
  home.packages = [
    artifactshareCli
    claudeCode
    codexCli
    nodejsPackage
    pkgs.bat
    pkgs.bun
    pkgs.eza
    pkgs.fzf
    pkgs.nixfmt
    pkgs.python3
    pkgs.ripgrep
    pkgs.starship
  ]
  ++ lib.optional (builtins.hasAttr "corepack" pkgs) pkgs.corepack
  # Nix で供給できる CLI だけを宣言し、未収録のものは次段で個別に判断する。
  ++ lib.optional (builtins.hasAttr "openapi-generator-cli" pkgs) pkgs."openapi-generator-cli";
}
