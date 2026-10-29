#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

case "$cwd" in
  "$HOME"|"$HOME"/*) cwd_display="~${cwd#"$HOME"}" ;;
  *) cwd_display="$cwd" ;;
esac

# ブランチ・ahead/behind・未コミットの有無を1回の git 呼び出しで取る。リポジトリ外では何も出さない。
git_part=""
git_status=$(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)
if [ -n "$git_status" ]; then
  branch=$(echo "$git_status" | awk '/^# branch.head /{print $3}')
  ahead_behind=$(echo "$git_status" | awk '/^# branch.ab /{a=substr($3,2); b=substr($4,2); s=""; if (a>0) s=s"↑"a; if (b>0) s=s"↓"b; print s}')
  dirty=""
  if echo "$git_status" | grep -qv '^#'; then
    dirty="*"
  fi
  git_part=" \033[35m \033[1m${branch}${dirty}\033[0m"
  if [ -n "$ahead_behind" ]; then
    git_part="${git_part} \033[33m${ahead_behind}\033[0m"
  fi
fi

ctx_part=""
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  if [ "$used_int" -ge 80 ]; then
    ctx_color="31"
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="33"
  else
    ctx_color="32"
  fi
  ctx_part=" | \033[${ctx_color}mctx:${used_int}%\033[0m"
fi

printf "\033[34m%s\033[0m%b | %s%b" "$cwd_display" "$git_part" "$model" "$ctx_part"
