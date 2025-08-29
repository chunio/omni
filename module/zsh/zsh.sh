#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<'MARK'
# https://docs.github.com/en/code-security/secret-scanning/working-with-secret-scanning-and-push-protection/working-with-push-protection-from-the-command-line#removing-a-secret-introduced-by-an-earlier-commit-on-your-branch
working with push protection from the command line ：
0，git log
1，git rebase -i {$commitId}~1
2，[delete commit] dd && :wq
3，[check conflict] git status
4，[resolve conflict] git add module/conflict.file && git rebase --continue
5，git push origin main
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="MASTER"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# reset builtin variable[START]

# reset builtin variable[END]
# ##################################################

# ##################################################
# global variable[START]

# global variable[END]
# ##################################################

# ##################################################
# protected function[START]

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
#「ohmyzsh」沒有分支/標籤的概念，鼓勵用戶使用最新（支持：使用「commit id」鎖定版本）
function funcPublicReinit(){
  yum remove -y zsh 2> /dev/null
  yum install -y gcc make ncurses-devel
  # yum install -y fontconfig
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  wget https://sourceforge.net/projects/zsh/files/zsh/5.8/zsh-5.8.tar.xz
  # 安裝「nerdfonts字體」[START]
  # wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  # wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  # wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  # wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
  # mkdir -p /usr/share/fonts/nerdfonts
  # mv MesloLGS*.ttf /usr/share/fonts/nerdfonts/
  # chmod 644 /usr/share/fonts/nerdfonts/*.ttf
  # fc-cache -fv
  # fc-list | grep -i meslo
  # 安裝「nerdfonts字體」[END]
  # cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}
  rm -rf /usr/local/src/zsh-5.8 && tar -xf zsh-5.8.tar.xz -C /usr/local/src/ && cd /usr/local/src/zsh-5.8
  ./configure --prefix=/usr/local/zsh --enable-multibyte
  make -j$(nproc) && make install
  ln -s /usr/local/zsh/bin/zsh /usr/bin/zsh
  zsh --version
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  cat << 'EOF' > ~/.zshrc
export ZSH="$HOME/.oh-my-zsh"
# 關閉「powerlevel10k」首次運行嚮導
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
export POWERLEVEL9K_CONFIG_FILE="$HOME/.p10k.zsh"
[[ -r "${POWERLEVEL9K_CONFIG_FILE:-$HOME/.p10k.zsh}" ]] && source "${POWERLEVEL9K_CONFIG_FILE:-$HOME/.p10k.zsh}"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
# 加載/使用「自動補全」模塊[START]
autoload -U compinit bashcompinit
compinit
bashcompinit
# 加載/使用「自動補全」模塊[END]
source $ZSH/oh-my-zsh.sh
EOF
  chmod 644 ~/.zshrc
  cat << 'EOF' > ~/.p10k.zsh
# 彩虹顏色：紅(X)/橙/黃/綠(X)/藍/靛/紫
# [one line] os/icon → [ user@host directory ] → git/branch → time(+exec)
# 臨時關閉[zsh]別名/通配[START]
# 避免影響加載配置
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases' ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob' ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'
# 臨時關閉[zsh]別名/通配[END]
() {
  emulate -L zsh -o extended_glob
  # 清空舊的「powerlevel10k」變量，避免影響加載配置
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  # 要求：zsh >= 5.1
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return
  #【一】段落顏色[START]
  #（1）common
  typeset -g P10K_COLOR_CRUST="#11111b"           # 深色前景（黑色）
  typeset -g P10K_COLOR_TEXT="#cdd6f4"            # 淺色前景（灰色）
  typeset -g P10K_COLOR_SURFACE0="#313244"        # 提示背景（灰色）
  #（2）unit
  # ----------
  typeset -g P10K_COLOR_OS_BG="#ffffff"           # 白色背景
  typeset -g P10K_COLOR_OS_FG="$P10K_COLOR_CRUST" # 深色字體
  # ----------
  typeset -g P10K_COLOR_CONTEXT_BG="#ff7e00"      # 橙色背景
  typeset -g P10K_COLOR_CONTEXT_FG="#ffffff"      # 白色字體
  # ----------
  typeset -g P10K_COLOR_VCS_BG="#facc15"          # 黃色背景
  typeset -g P10K_COLOR_VCS_FG="#ffffff"          # 白色字體
  # ----------
  typeset -g P10K_COLOR_TIME_BG="#0061ff"         # 藍色背景
  typeset -g P10K_COLOR_TIME_FG="#ffffff"         # 白色字體
  # ----------
  #【一】段落顏色[START]
  #【二】段落排序[START]
  # 內建段落：os_icon vcs
  # 自定段落：context_segment time_segment（注意：「[段落名稱]custom_segment」與「[段落顏色]POWERLEVEL9K_CUSTOM_SEGMENT_*」存在對應關係，需同時變更）
  typeset -ga P10K_LEFT_ORDER=(os_icon context_segment vcs time_segment) # 左側排序
  typeset -ga P10K_RIGHT_ORDER=() # 右側排序
  #【二】段落排序[END]
  #【三】段落佈局[START]
  #（0）core layout
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=("${P10K_LEFT_ORDER[@]}")
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("${P10K_RIGHT_ORDER[@]}")
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false # 單行提示，禁止自動換行
  typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false # RPROMPT，禁止另起一行
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3 # 圖標字體
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_BACKGROUND=$P10K_COLOR_SURFACE0
  # 移除左右段落分隔符（目的：使其貼合）[START]
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  # 移除左右段落分隔符（目的：使其貼合）[END]
  #（1）os/icon
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$P10K_COLOR_OS_BG
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$P10K_COLOR_OS_FG
  #（2）[ user@host directory ]
  typeset -g POWERLEVEL9K_CONTEXT_SEGMENT_BACKGROUND=$P10K_COLOR_CONTEXT_BG
  typeset -g POWERLEVEL9K_CONTEXT_SEGMENT_FOREGROUND=$P10K_COLOR_CONTEXT_FG
  typeset -g POWERLEVEL9K_CONTEXT_SEGMENT_LEFT_WHITESPACE=0
  typeset -g POWERLEVEL9K_CONTEXT_SEGMENT_RIGHT_WHITESPACE=0
  function prompt_context_segment() {
    emulate -L zsh
    #「%1~」表示顯示最後一級目錄
    #「%~」表示顯示完整路徑
    p10k segment -t '[%n@%m %1~]'
  }
  #（3）git/branch
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$P10K_COLOR_VCS_BG
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$P10K_COLOR_VCS_BG
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$P10K_COLOR_VCS_BG
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=$P10K_COLOR_VCS_BG
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$P10K_COLOR_VCS_BG
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$P10K_COLOR_VCS_FG
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$P10K_COLOR_VCS_FG
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='' # 移除「?」圖標
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='' # 移除分支圖標，僅顯示分支名稱
  typeset -g POWERLEVEL9K_VCS_PREFIX=''
  typeset -g POWERLEVEL9K_VCS_LEFT_WHITESPACE=0
  typeset -g POWERLEVEL9K_VCS_RIGHT_WHITESPACE=0
  # [git]當分支名稱大於32字節時，則折中省略
  function funcGitBranchNameFormatter() {
    # 將函數執行環境切至「zsh」原生語義（即：離開函數自動還原）
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then typeset -g variGitBranchName=$P9K_CONTENT; return; fi
    local variResult=''
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"
      variResult="${branch//\%/%%}"
    fi
    typeset -g variGitBranchName=$variResult
  }
  functions -M funcGitBranchNameFormatter 2>/dev/null
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((funcGitBranchNameFormatter(1)))+${variGitBranchName}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  #（4）time(+exec)
  # 大於等於3秒時，顯示花費時間，示例：HH:MM:SS  ?s
  autoload -Uz add-zsh-hook
  typeset -gF 3 __p_start=0 __p_last_dur=0
  add-zsh-hook preexec _p_timer_start
  add-zsh-hook precmd  _p_timer_stop
  function _p_timer_start() { __p_start=$EPOCHREALTIME }
  function _p_timer_stop()  {
    if (( __p_start > 0 )); then
      __p_last_dur=$(( EPOCHREALTIME - __p_start ))
      __p_start=0
    fi
  }
  function prompt_time_segment() {
    emulate -L zsh
    local -F 2 d=${__p_last_dur:-0}
    local variOutput="%D{%H:%M:%S}"
    if (( d >= 3 )); then
      local variSecond=$(( int(d + 0.5) ))
      variOutput+="  ${variSecond}s"
    fi
    p10k segment -t "${variOutput}"
  }
  typeset -g POWERLEVEL9K_TIME_SEGMENT_BACKGROUND=$P10K_COLOR_TIME_BG
  typeset -g POWERLEVEL9K_TIME_SEGMENT_FOREGROUND=$P10K_COLOR_TIME_FG
  typeset -g POWERLEVEL9K_TIME_SEGMENT_LEFT_WHITESPACE=0
  typeset -g POWERLEVEL9K_TIME_SEGMENT_RIGHT_WHITESPACE=0
  #【三】段落佈局[END]
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  (( ! $+functions[p10k] )) || p10k reload
}
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
EOF
  chmod 644 ~/.p10k.zsh
  echo "/usr/bin/zsh" >> /etc/shells
  chsh -s $(which zsh)
  # zsh
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"