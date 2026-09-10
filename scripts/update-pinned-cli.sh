#!/usr/bin/env bash
set -euo pipefail

# home.nix で pin している CLI のバージョンと hash を最新へ更新する。
# nix-update ではなく自前スクリプトなのは、対象の derivation が flake の
# packages output ではなく home.nix の let 束縛で、nix-update が解決できないため。

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
home_nix="$repo_root/home.nix"

target="all"
channel="stable"
run_build=1

usage() {
  cat <<'USAGE'
Usage: scripts/update-pinned-cli.sh [claude-code|codex|artifactshare|all] [--channel stable|latest] [--no-build]

  claude-code    Claude Code のみ更新
  codex          Codex CLI のみ更新
  artifactshare  Artifact Share CLI のみ更新
  all            すべて更新 (既定)

  --channel     Claude Code の追従チャネル (既定: stable)
  --no-build    nix build による検証を省略
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    claude-code | codex | artifactshare | all) target="$1" ;;
    --channel) channel="${2:?--channel には stable か latest を指定する}" && shift ;;
    --channel=*) channel="${1#*=}" ;;
    --no-build) run_build=0 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

case "$channel" in
  stable | latest) ;;
  *)
    echo "--channel は stable か latest のみ: $channel" >&2
    exit 1
    ;;
esac

# npm は artifactshare の依存 range を実バージョンへ解決するためだけに使う。
for cmd in curl jq nix npm perl; do
  command -v "$cmd" >/dev/null || {
    echo "$cmd が見つからない" >&2
    exit 1
  }
done

current_version() {
  sed -n "s/^[[:space:]]*$1 = \"\([^\"]*\)\";.*/\1/p" "$home_nix" | head -1
}

require_semver() {
  [[ "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    echo "$1: 取得したバージョンが不正: $2" >&2
    exit 1
  }
}

prefetch_hash() {
  nix store prefetch-file --json --hash-type sha256 "$1" | jq -r '.hash'
}

replace_version() {
  ATTR="$1" VER="$2" perl -pi -e 's/^(\s*\Q$ENV{ATTR}\E = ").*(";)$/$1$ENV{VER}$2/' "$home_nix"
  [[ "$(current_version "$1")" == "$2" ]] || {
    echo "$1 の置換に失敗した" >&2
    exit 1
  }
}

# 対象の url 行の直後にある hash 行だけを置換する。旧 hash 値そのものを検索キーに
# すると、同じ値が別の pin にも現れた場合に無関係な行を壊すため url を文脈に使う。
replace_hash_after_url() {
  URL="$1" HASH="$2" perl -0pi -e '
    my $url = quotemeta($ENV{URL});
    s/(url = "$url";\s*\n\s*hash = ")[^"]*(")/$1$ENV{HASH}$2/;
  ' "$home_nix"
  grep -q "$2" "$home_nix" || {
    echo "hash の置換に失敗した: $1" >&2
    exit 1
  }
}

# url 文字列中の ${...} は home.nix 側の Nix 補間なので、shell では展開させない。
# shellcheck disable=SC2016
update_claude_code() {
  local latest current
  latest="$(curl -fsSL "https://downloads.claude.ai/claude-code-releases/$channel")"
  require_semver claude-code "$latest"
  current="$(current_version claudeCodeVersion)"

  if [[ "$latest" == "$current" ]]; then
    echo "claude-code: $current は最新 ($channel)"
    return 1
  fi

  echo "claude-code: $current -> $latest ($channel)"
  replace_hash_after_url \
    'https://downloads.claude.ai/claude-code-releases/${claudeCodeVersion}/darwin-arm64/claude' \
    "$(prefetch_hash "https://downloads.claude.ai/claude-code-releases/$latest/darwin-arm64/claude")"
  replace_version claudeCodeVersion "$latest"
}

# shellcheck disable=SC2016
update_codex() {
  local latest current
  latest="$(curl -fsSL https://registry.npmjs.org/@openai/codex/latest | jq -r '.version')"
  require_semver codex "$latest"
  current="$(current_version codexCliVersion)"

  if [[ "$latest" == "$current" ]]; then
    echo "codex: $current は最新"
    return 1
  fi

  echo "codex: $current -> $latest"
  replace_hash_after_url \
    'https://registry.npmjs.org/@openai/codex/-/codex-${codexCliVersion}.tgz' \
    "$(prefetch_hash "https://registry.npmjs.org/@openai/codex/-/codex-$latest.tgz")"
  replace_hash_after_url \
    'https://registry.npmjs.org/@openai/codex/-/codex-${codexCliVersion}-darwin-arm64.tgz' \
    "$(prefetch_hash "https://registry.npmjs.org/@openai/codex/-/codex-$latest-darwin-arm64.tgz")"
  replace_version codexCliVersion "$latest"
}

# CLI が宣言する range を実バージョンへ解決し、変わっていれば pin を差し替える。
# 対象は CLI が bundle しない依存だけで、range 据え置きなら何もしない。
update_artifactshare_dep() {
  local name="$1" attr="$2" url_template="$3" manifest="$4"
  local range resolved current

  range="$(jq -r ".dependencies.\"$name\"" <<<"$manifest")"
  resolved="$(npm view "$name@$range" version --json | jq -r 'if type == "array" then .[-1] else . end')"
  require_semver "$name" "$resolved"
  current="$(current_version "$attr")"

  [[ "$resolved" == "$current" ]] && return 0

  echo "artifactshare $name: $current -> $resolved"
  replace_hash_after_url "$url_template" \
    "$(prefetch_hash "https://registry.npmjs.org/$name/-/$name-$resolved.tgz")"
  replace_version "$attr" "$resolved"
}

# shellcheck disable=SC2016
update_artifactshare() {
  local latest current manifest
  latest="$(curl -fsSL https://registry.npmjs.org/@artifactshare/cli/latest | jq -r '.version')"
  require_semver artifactshare "$latest"
  current="$(current_version artifactshareCliVersion)"

  if [[ "$latest" == "$current" ]]; then
    echo "artifactshare: $current は最新"
    return 1
  fi

  manifest="$(curl -fsSL "https://registry.npmjs.org/@artifactshare/cli/$latest")"

  echo "artifactshare: $current -> $latest"
  replace_hash_after_url \
    'https://registry.npmjs.org/@artifactshare/cli/-/cli-${artifactshareCliVersion}.tgz' \
    "$(prefetch_hash "https://registry.npmjs.org/@artifactshare/cli/-/cli-$latest.tgz")"
  replace_version artifactshareCliVersion "$latest"

  update_artifactshare_dep gunshi artifactshareGunshiVersion \
    'https://registry.npmjs.org/gunshi/-/gunshi-${artifactshareGunshiVersion}.tgz' "$manifest"
  update_artifactshare_dep undici artifactshareUndiciVersion \
    'https://registry.npmjs.org/undici/-/undici-${artifactshareUndiciVersion}.tgz' "$manifest"
}

updated=0
if [[ "$target" == "all" || "$target" == "claude-code" ]]; then
  update_claude_code && updated=1
fi
if [[ "$target" == "all" || "$target" == "codex" ]]; then
  update_codex && updated=1
fi
if [[ "$target" == "all" || "$target" == "artifactshare" ]]; then
  update_artifactshare && updated=1
fi

if [[ "$updated" -eq 0 ]]; then
  echo "更新なし"
  exit 0
fi

git -C "$repo_root" --no-pager diff --stat -- home.nix

if [[ "$run_build" -eq 0 ]]; then
  echo "nix build は省略した"
  exit 0
fi

host="$(nix eval --raw "$repo_root#darwinConfigurations" --apply 'c: builtins.head (builtins.attrNames c)')"
echo "nix build で検証する: $host"
nix build --no-link "$repo_root#darwinConfigurations.$host.system"

cat <<EOF

検証まで完了した。適用は以下を手動で実行する。
  sudo darwin-rebuild switch --flake $repo_root#$host
EOF
