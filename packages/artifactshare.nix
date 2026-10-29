{
  stdenvNoCC,
  fetchurl,
  nodejs,
}:

let
  version = "0.13.3";
  # zod だけは bundle 済みで、gunshi は静的 import、undici は動的 import として
  # 外部 module のまま残る。依存 tarball を並べて node_modules を組み、
  # npm の実行時解決に頼らない形に固定する。
  gunshiVersion = "0.37.2";
  undiciVersion = "8.10.2";
in
stdenvNoCC.mkDerivation {
  pname = "artifactshare-cli";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@artifactshare/cli/-/cli-${version}.tgz";
    hash = "sha256-di0d2N/dh8vs9rWUB2JMsIMnJxSZ7SkMC4IAY3zHoz4=";
  };

  gunshiSrc = fetchurl {
    url = "https://registry.npmjs.org/gunshi/-/gunshi-${gunshiVersion}.tgz";
    hash = "sha256-kfVfEYQTildBa6Hg2gW6k+aAqcKH8dPuv0oACGE/Dgg=";
  };

  undiciSrc = fetchurl {
    url = "https://registry.npmjs.org/undici/-/undici-${undiciVersion}.tgz";
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
      --replace-fail "#!/usr/bin/env node" "#!${nodejs}/bin/node"

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
}
