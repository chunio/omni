#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="MASTER"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"

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
function funcProtectedCloudInit() {
    variQshellPath=$(command -v ab) || true
    if [ -z "${variQshellPath}" ];then
        yum install -y httpd-tools
    fi
    return 0
}

function funcProtectedLocalInit(){
  ulimit -n 102400
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicAb(){
  # go install github.com/rakyll/hey@latest
  local variParameterDescMulti=("request total/請求總數" "concurrency unit/[同一時刻]並發數量" "api（example : http://xxxx.com/xxxx?xxxx=xxxx）")
  funcProtectedCheckRequiredParameter 3 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variRequestTotal=${1}
  variConcurrencyUnit=${2}
  variApi=${3}
  echo "ab -n ${variRequestTotal} -c ${variConcurrencyUnit} -l -p ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/post.txt -T 'application/json' ${variApi}"
  ab -n ${variRequestTotal} -c ${variConcurrencyUnit} -p ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/post.txt -T 'application/json' "${variApi}"
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"