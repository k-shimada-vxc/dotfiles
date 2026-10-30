{
  stdenvNoCC,
  fetchurl,
  nodejs,
}:

let
  version = "0.22.0";
  # gunshi と zod は静的 import、undici は動的 import として外部 module のまま残る。
  # 依存 tarball を並べて node_modules を組み、npm の実行時解決に頼らない形に固定する。
  gunshiVersion = "0.37.2";
  undiciVersion = "8.10.2";
  zodVersion = "4.6.2";
  npmExecInvocation = "npm exec --yes --package=@artifactshare/cli -- artifactshare";
in
stdenvNoCC.mkDerivation {
  pname = "artifactshare-cli";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@artifactshare/cli/-/cli-${version}.tgz";
    hash = "sha256-UDWAkB4lTdTHLf4rYiMjA6deOeRZmAQrRQyNYnTZM/I=";
  };

  gunshiSrc = fetchurl {
    url = "https://registry.npmjs.org/gunshi/-/gunshi-${gunshiVersion}.tgz";
    hash = "sha256-kfVfEYQTildBa6Hg2gW6k+aAqcKH8dPuv0oACGE/Dgg=";
  };

  undiciSrc = fetchurl {
    url = "https://registry.npmjs.org/undici/-/undici-${undiciVersion}.tgz";
    hash = "sha256-dAY4rjLXjSZGpnJ5UONl+ia2+oeRP6CW5g7Ur+tGNKo=";
  };

  zodSrc = fetchurl {
    url = "https://registry.npmjs.org/zod/-/zod-${zodVersion}.tgz";
    hash = "sha256-7kaQFILCZLz4onCp/7Bxo+XnuigzSkyPqDt0BaicRSY=";
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    mkdir -p source gunshi undici zod
    tar -xzf "$src" -C source
    tar -xzf "$gunshiSrc" -C gunshi
    tar -xzf "$undiciSrc" -C undici
    tar -xzf "$zodSrc" -C zod

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/lib/node_modules/@artifactshare"
    cp -R source/package "$out/lib/node_modules/@artifactshare/cli"
    cp -R gunshi/package "$out/lib/node_modules/gunshi"
    cp -R undici/package "$out/lib/node_modules/undici"
    cp -R zod/package "$out/lib/node_modules/zod"

    cli="$out/lib/node_modules/@artifactshare/cli"

    # 実行時の Node.js を Nix 管理のものへ固定する。
    # Cursor 向けの cursor-acp-entry.js は bin に出さないので shebang も触らない。
    substituteInPlace "$cli/dist/index.js" \
      --replace-fail "#!/usr/bin/env node" "#!${nodejs}/bin/node"
    chmod +x "$cli/dist/index.js"

    # help・JSON の next_steps・同梱 skill が案内する `npm exec --yes` 経由の起動は、
    # 呼ぶたび最新版を取得して Nix で固定した版から外れる。案内文も PATH 上の
    # 固定版に揃え、agent がどこを読んでも同じ CLI に到達するようにする。
    # 文字列が入るファイルは版ごとに変わるので、ファイルを名指しせず全体を置換し、
    # 残っていないことを事後条件として確かめる。
    grep -rlF "${npmExecInvocation}" "$cli/dist" "$cli/skills" | while read -r file; do
      substituteInPlace "$file" --replace-fail "${npmExecInvocation}" "artifactshare"
    done
    if grep -rF "${npmExecInvocation}" "$cli/dist" "$cli/skills"; then
      echo "npm exec 経由の起動案内が残っている" >&2
      exit 1
    fi

    install -d "$out/bin"
    ln -s "$cli/dist/index.js" "$out/bin/artifactshare"

    runHook postInstall
  '';

  meta = {
    description = "Artifact Share CLI installed from npm";
    homepage = "https://artifactshare.com/connect";
    mainProgram = "artifactshare";
  };
}
