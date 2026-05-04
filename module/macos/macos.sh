#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2026/05/03

:<<'MARK'
macOS 專用入口（對標 Linux 的 system.sh）
- 用戶級安裝，不需要 sudo
- alias / 命令鏈接 寫到 ~/.omni/
- ~/.zshrc 只增加一行引導：[ -f ~/.omni/omni.macos.sh ] && source ~/.omni/omni.macos.sh
- zsh 補全機制（不依賴 bash-completion）

依賴：
- bash 4+    （brew install bash）
- perl       （macOS 自帶）
- coreutils  （brew install coreutils，可選，僅當需要 GNU 工具時）
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="MASTER"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(perl -MCwd -le 'print Cwd::abs_path(shift)' "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(perl -MCwd -le 'print Cwd::abs_path(shift)' "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# global variable[START]
VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"]="include vendor"
VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]="template"
VARI_GLOBAL["VERSION_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/init.version.${VARI_GLOBAL["BUILTIN_OS_DISTRO"],,}" # 「${vari,,}」轉至小寫
VARI_GLOBAL["MOUNT_USERNAME"]=""
VARI_GLOBAL["MOUNT_PASSWORD"]=""

# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
# 要求：基於純淨係統（macos26.4.1/https://ipsw.me/）
# 人工執行
function funcProtectedManualInit(){
  return 0
}

function funcProtectedCloudInit() {
  return 0
}

# 創建用戶級目錄結構 + 主入口腳本 + ~/.zshrc 引導行






# protected function[END]
# ##################################################
