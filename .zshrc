#### zsh設定
#################################  HISTORY  #################################
# history
HISTFILE=$HOME/.zsh-history # 履歴を保存するファイル
HISTSIZE=100000             # メモリ上に保存する履歴のサイズ
SAVEHIST=1000000            # 上述のファイルに保存する履歴のサイズ

# share .zshhistory
setopt inc_append_history   # 実行時に履歴をファイルにに追加していく
setopt share_history        # 履歴を他のシェルとリアルタイム共有する

#################################  COMPLEMENT  #################################
# enable completion
fpath+=~/.zfunc
autoload -Uz compinit && compinit

# 補完候補をそのまま探す -> 小文字を大文字に変えて探す -> 大文字を小文字に変えて探す
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'

### 補完方法毎にグループ化する。
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''

### 補完侯補をメニューから選択する。
### select=2: 補完候補を一覧から選択する。補完候補が2つ以上なければすぐに補完する。
zstyle ':completion:*:default' menu select=2

### 補完候補に色を付ける。
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

### 環境変数の補完
setopt AUTO_PARAM_KEYS

#################################  OTHERS  #################################
# automatically change directory when dir name is typed
setopt auto_cd

# disable ctrl+s, ctrl+q
setopt no_flow_control

# ビープを無効にする
setopt no_beep
setopt no_hist_beep
setopt no_list_beep

############################ 設定読み込み ####################################
SCRIPT_DIR=$HOME/dotfiles
source $SCRIPT_DIR/zsh/plugins.zsh


########################## alias and environment #############################
#grep
alias grep="rg"

# eza
alias exa='eza'
alias e='eza --icons --git'
alias l=e
alias ls=e
alias ea='eza -a --icons --git'
alias la=ea
alias ee='eza -aahl --icons --git'
alias ll=ee
alias et='eza -T -L 3 -a -I "node_modules|.git|.cache" --icons'
alias lt=et
alias eta='eza -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
alias lta=eta

# git
alias gf='git fetch'
alias gfap='git fetch --all --prune'
alias gco="git checkout"

# escape_json
alias ej='escape_json'


# cdでディレクトリ移動したとき自動でlsする
chpwd() {
  if [[ $(pwd) != $HOME ]] ;
  then;
  ls
  fi
}

# fzf設定
if [[ $(command -v fzf) ]]; then
  source <(fzf --zsh)
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'
fi


### starship ###
if [[ $(command -v starship) ]]; then
  eval "$(starship init zsh)"
  export STARSHIP_CONFIG=$SCRIPT_DIR/starship.toml
fi

### go ###
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
# export GOROOT="$(brew --prefix golang)/libexec"

source /Users/k-shimada/.docker/init-zsh.sh || true # Added by Docker Desktop

# Added by Antigravity
export PATH="/Users/k-shimada/.antigravity/antigravity/bin:$PATH"
