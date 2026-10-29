{
  symlinkJoin,
  makeBinaryWrapper,
  codex,
}:

# config.toml は Codex 自身が更新する可変設定なので、wrapper で更新確認だけを無効化する。
# overrideAttrs で元の derivation に手を入れるとバイナリキャッシュに当たらず
# Rust のフルビルドになるため、ビルド済みの成果物を包むだけにする。
symlinkJoin {
  name = "codex-${codex.version}";
  paths = [ codex ];
  nativeBuildInputs = [ makeBinaryWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/codex" \
      --add-flags "-c check_for_update_on_startup=false"
  '';
}
