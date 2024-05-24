#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20
# TODO : the execution method must be compatible with both single-directory and single-project（omni） based approaches

:<<MARK
MARK

# ##################################################
# interface variable[START]
VARI_START_TIME=$(date +%s%3N)
VARI_ROOT_ID="a000ac7b2867e2e68319b20d58e8203b.omni"
# 支持（run mode）：1絕對路徑2相對路徑3符號鏈接($0等于：/usr/local/bin/omni.interface)
# 僅適用於「source bash」[START]
VARI_BASH_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_BASH_NAME=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
# 僅適用於「source bash」[END]
# 僅適用於「fork bash」[START]
# VARI_BASH_PATH=$(dirname "$(readlink -f "$0")")
# VARI_BASH_NAME=$(basename "$(readlink -f "$0")")
# 僅適用於「fork bash」[END]
VARI_CLOUD_PATH=$VARI_BASH_PATH/cloud
VARI_RUNTIME_PATH=$VARI_BASH_PATH/runtime
# YYYYMMDD.HHMMSS.mmm
VARI_RUNTIME_FILENAME=$(echo $VARI_START_TIME | awk '{print strftime("%Y%m%d.%H%M%S", $1/1000) "." substr($1, length($1)-2)}')
VARI_TRACE_URI="${VARI_RUNTIME_PATH}/$VARI_RUNTIME_FILENAME.trace"
VARI_TODO_URI="${VARI_RUNTIME_PATH}/$VARI_RUNTIME_FILENAME.todo"
VARI_SEPARATOR_LINE="\n"
# interface variable[END]
# global variable[START]
# global variable[END]
# ##################################################

# [set -e]：任一命令（含：1自身腳本2函數內部）返回非0時（除外：if區域棧段），則立即觸發「break（as:exit）the bash」//習慣：單獨使用
# [set +e]：任一命令（含：1自身腳本2函數內部）返回非0時（除外：if區域棧段），則立即觸發「trap >> continue the bash」//習慣：搭配使用
# 如於當前環境執行時（如：source interface.sh），將持續影響
# trap 'funcPrivateRecover $LINENO $?' ERR
# set -e

# ##################################################
# interface function[START]
function funcPrivateConstruct() {
  # 禁止：於當前環境執行（如：source interface.sh）
  if [[ 0 == 1 ]] && [[ "$0" == "bash" || "$0" == "-bash" || "$0" == "sh" || "$0" == "-sh" ]]; then
      echo "the run mode is prohibited"
      echo "example : "'${symbolLink}'" | /$VARI_BASH_NAME | ./$VARI_BASH_NAME | bash $VARI_BASH_NAME"
      return 1
  fi
  mkdir -p $VARI_CLOUD_PATH $VARI_RUNTIME_PATH
  echo "--------------------------------------------------" >> $VARI_TRACE_URI
  echo "[ TRACE ]" >> $VARI_TRACE_URI
  echo "--------------------------------------------------" >> $VARI_TODO_URI
  echo "[ TODO ]" >> $VARI_TODO_URI
  return 0
}

# cloud resource init
function funcPrivateCloudInit() {
    return 0
}

# local environment init
function funcPrivateLocalInit(){
    return 0
}

function funcPrivateDestruct(){
  variEndTime=$(date +%s%3N)
  variExecuteTime=$((variEndTime - VARI_START_TIME))
  variHour=$((variExecuteTime / 3600000))
  variMinute=$(((variExecuteTime % 3600000) / 60000))
  variSecond=$(((variExecuteTime % 60000) / 1000))
  variMillisecond=$((variExecuteTime % 1000))
  echo "start : $(date -d @$((${VARI_START_TIME}/1000)) '+%Y-%m-%d %H:%M:%S').$(printf "%03d" $((${VARI_START_TIME}%1000)))" >> $VARI_TRACE_URI
  echo "end : $(date -d @$((${variEndTime}/1000)) '+%Y-%m-%d %H:%M:%S').$(printf "%03d" $((${variEndTime}%1000)))" >> $VARI_TRACE_URI
  echo "execute : ${variHour} hour ${variMinute} minute ${variSecond}.${variMillisecond} second" >> $VARI_TRACE_URI
  echo "--------------------------------------------------" >> $VARI_TRACE_URI
  echo "--------------------------------------------------" >> $VARI_TODO_URI
  cat $VARI_TRACE_URI && rm -rf $VARI_TRACE_URI
  cat $VARI_TODO_URI && rm -rf $VARI_TODO_URI
  return 0
}

# --------------------------------------------------

# TODO: catch the standard error output
function funcPrivateRecover() {
  echo $VARI_SEPARATOR_LINE >> $VARI_TRACE_URI
  echo "[error/recover/$(date '+%Y-%m-%d %H:%M:%S')] : panic occurred on line : $1 / exit code : $2" >> $VARI_TRACE_URI
  echo $VARI_SEPARATOR_LINE >> $VARI_TRACE_URI
  exit 1
}

function funcPrivatePullRootPath(){
    variRootIdUri=$(find / -name $VARI_ROOT_ID -print -quit 2>/dev/null)
    variRootPath=$(dirname $variRootIdUri)
    echo 'omni/root path : '$variRootPath >> $VARI_TRACE_URI
    echo $variRootPath
}

# release to cloud/internet
function funcPublicReleaseCloud(){
    echo "archived && upload"
    return 0
}

# interface function[END]
# ##################################################

# ##################################################
# extend function[START]
function funcPublicRoot(){
  echo $#
  cd /windows/code/backend/haohaiyou/gopath/src/unicorn/
  pwd && du -sh . && ll -ah
  return 0
}
# extend function[END]
# ##################################################

# ##################################################
funcPrivateConstruct
funcPrivateCloudInit
funcPrivateLocalInit
# function route : 1 「first letter」lower >> upper，2prepend「funcPublic」
"funcPublic$(echo "${1}" | awk '{print toupper(substr($0, 1, 1)) substr($0, 2)}')" $2 $3 $4 $5
funcPrivateDestruct
# the 「return」 command can only be used inside a function or within a script executed using the source command
# ##################################################