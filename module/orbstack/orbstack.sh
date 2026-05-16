#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 0000/00/00 00:00:00

:<<'MARK'
MARK

# ##################################################
# compatible && validator[START]
# [zero length]bash
if [ -z "$ZSH_VERSION" ]; then
  [ "${BASH_VERSION%%.*}" -ge 4 ] 2>/dev/null || { echo "[ required ] {bash 4.0+ || zsh}"; return 1 2>/dev/null || exit 1; }
fi
# compatible && validator[END]
# ##################################################

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="DETACH"
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"][START]
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 解釋軟鏈
if [ "${VARI_GLOBAL["BUILTIN_BASH_ENVI"]}" = "SOURCE" ];then
  VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)" # 不解軟鏈
fi
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"][END]
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE:-$0}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

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
function funcPublicServiceReinit(){
  return 0
}

function funcPublicTemplateReadmeMdUpsert(){
  cat > /README.md <<EOF
#　sudo -i
cd /Users/zengweitao/archived/workspace/repository/chunio
chmod -R 777 ./omni 2> /dev/null
./omni/init/system/system.sh init 1
source /root/.omni.ubuntu/omni.ubuntu.sh
omni.system proxy 1 7897
omni.docker deveEnviReinit 0 0
EOF
  echo "--------------------------------------------------"
  cat /README.md
  echo "--------------------------------------------------"
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"