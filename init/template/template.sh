#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 0000/00/00 00:00:00

:<<'MARK'
MARK

# ##################################################
# compatible && validator[START]
# 1/[non-zero length]zsh
if [ -n "$ZSH_VERSION" ]; then
  # 目的：調整語法至「bash」
  setopt NO_NOMATCH # 通配符號沒有匹配亦不報錯
  setopt KSH_ARRAYS # 數組索引從零開始
  setopt SH_WORD_SPLIT # 支持空格拆分變量
fi
# 2/[zero length]bash
if [ -z "$ZSH_VERSION" ]; then
  [ "${BASH_VERSION%%.*}" -ge 4 ] 2>/dev/null || { echo "[ required ] {bash 4.0+ || zsh}"; return 1 2>/dev/null || exit 1; }
fi
# compatible && validator[END]
# ##################################################

# archived version[START]
# declare -A VARI_GLOBAL
# VARI_GLOBAL["BUILTIN_BASH_ENVI"]="DETACH"
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 解析軟鏈
# VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
# source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/builtin/builtin.sh"
# source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/utility/utility.sh"
# source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true
# archived version[END]

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="DETACH"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)" # 不解軟鏈
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE:-$0}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# builtin variable[START]
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"