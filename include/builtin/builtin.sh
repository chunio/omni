#!/bin/bash

# interface : 2.0.0
# author : zengweitao@gmail.com
# datetime : 2024/05/20
# memo : the function call order is not sensitive in the one shell

:<<MARK
MARK

# ##################################################
# global variable[START]
# initialize the associative array（cannot be combined into one line of code）
# declare -A VARI_GLOBAL
# if [[ ${#VARI_GLOBAL[@]} -eq 0 ]]; then
VARI_GLOBAL["BUILTIN_START_TIME"]=$(date +%s%3N)
# [/bin/bash]環境狀態，值：SLAVE/fork（default），MASTER/source
VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]="/windows/code/backend/chunio/omni"
VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]="omni"
VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]="sh"
# 支持（run mode）：1絕對路徑2相對路徑3符號鏈接($0等于：/usr/local/bin/omni.interface)
# 僅適用於「source bash」[START]
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
# VARI_GLOBAL["BASH_NAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
# 僅適用於「source bash」[END]
# 僅適用於「fork bash」[START]
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "$0")")
# VARI_GLOBAL["BASH_NAME"]=$(basename "$(readlink -f "$0")")
# 僅適用於「fork bash」[END]
VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]="${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/cloud"
VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]="${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/runtime"
# YYYYMMDD.HHMMSS.mmm
# VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]=$(echo "${VARI_GLOBAL["BUILTIN_START_TIME"]}" | awk '{print strftime("%Y%m%d.%H%M%S", $1/1000) "." substr($1, length($1)-2)}')
VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]=$(echo "${VARI_GLOBAL["BUILTIN_START_TIME"]}" | awk 'BEGIN{ TZ="Asia/Shanghai" } {print strftime("%Y%m%d.%H%M%S", $1/1000) "." substr($1, length($1)-2)}')
VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.trace"
VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.todo"
VARI_GLOBAL["BUILTIN_UNIT_COMMAND_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.command"
VARI_GLOBAL["BUILTIN_SEPARATOR_LINE"]=""
VARI_GLOBAL["BUILTIN_TRUE_LABEL"]="succeeded"
VARI_GLOBAL["BUILTIN_FALSE_LABEL"]="failed"
VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]=200
# 「VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]=0」表示不限
VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]=10
# fi
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedDebugRecover() {
  trap 'echo "[ ${LINENO} / $(date +%Y-%m-%d\ %H:%M:%S) ] : ${BASH_COMMAND}" >> "${VARI_GLOBAL["BUILTIN_UNIT_COMMAND_URI"]}"' DEBUG
  return 0
}

function funcProtectedErrRecover() {
  # include : 1/exit code，2/return code
  variCode=$1
  variLine=$2
  if [ ${variCode} != 0 ] && [ ${variCode} != ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]} ]; then
      # tail -n 20 "${VARI_GLOBAL["BUILTIN_UNIT_COMMAND_URI"]}" >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
      echo "[ error（recover : ERR） / $(date '+%Y-%m-%d %H:%M:%S') ] line : $variLine / exit code : $variCode" >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  fi
  return 0
}

function funcProtectedExitRecover(){
  variCode=$1
  variLine=$2
  if [ ${variCode} != 0 ] && [ ${variCode} != ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]} ]; then
    echo "[ error（recover : EXIT） / $(date '+%Y-%m-%d %H:%M:%S') ] line : $variLine / exit code : $variCode"
  fi
  # tail -n 20 ${VARI_GLOBAL["COMAND_URI"]}
  return 0
}

# ##################################################
# interface function[START]
function funcProtectedConstruct() {
  # 禁止：於當前環境執行（如：source interface.sh）
  if [[ ${VARI_GLOBAL["BUILTIN_BASH_EVNI"]} == "SLATER" ]] && [[ "$0" == "bash" || "$0" == "-bash" || "$0" == "sh" || "$0" == "-sh" ]]; then
      echo "the run mode is prohibited"
      echo "example : "'${symbolLink}'" | /${VARI_GLOBAL["BASH_NAME"]} | ./${VARI_GLOBAL["BASH_NAME"]} | bash ${VARI_GLOBAL["BASH_NAME"]}"
      return 1
  fi
  mkdir -p "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}" "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"
  if [ ${VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]} != 0 ] && [ $(ls -1 "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | wc -l) -gt ${VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]} ]; then
    rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/*
    #  variKeepList=("$(basename ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]})" "$(basename ${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]})")
    #  for variTempFile in ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/*; do
    #    if [[ ! " ${variKeepList[*]} " =~ " $variTempFile " ]]; then
    #      rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variTempFile}
    #    fi
    #  done
  fi
  touch ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]} ${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}
  variStartTimeFormat="$(date -d @$((${VARI_GLOBAL["BUILTIN_START_TIME"]}/1000)) '+%Y-%m-%d %H:%M:%S')"
  funcProtectedTrace ":<<${variStartTimeFormat}"
  return 0
}

# cloud resource init
function funcProtectedCloudInit() {
    return 0
}

# local environment init
function funcProtectedLocalInit(){
    return 0
}

function funcProtectedDestruct() {
  variEndTime=$(date +%s%3N)
  variExecuteTime=$((variEndTime - ${VARI_GLOBAL["BUILTIN_START_TIME"]}))
  variHour=$((variExecuteTime / 3600000))
  variMinute=$(((variExecuteTime % 3600000) / 60000))
  variSecond=$(((variExecuteTime % 60000) / 1000))
  variMillisecond=$((variExecuteTime % 1000))
  variStartTimeFormat="$(date -d @$((${VARI_GLOBAL["BUILTIN_START_TIME"]}/1000)) '+%Y-%m-%d %H:%M:%S')"
  variEndTimeFormat="$(date -d @$((${variEndTime}/1000)) '+%Y-%m-%d %H:%M:%S')"
  funcProtectedTrace "${variEndTimeFormat}"
  echo "--------------------------------------------------"
  echo "[ trace : ${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.trace ]"
  if [[ -s "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}" ]]; then
    cat "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  fi
  rm -rf "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  echo "--------------------------------------------------"
  if [[ -s "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}" ]]; then
    echo "[ todo : ${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.todo ]"
    cat "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}"
  else
    echo "[ todo : no action is required ]"
  fi
  rm -rf "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}"
  echo "--------------------------------------------------"
  # printf "start   : %s.%03d\n" "$(date -d @$((${VARI_GLOBAL["BUILTIN_START_TIME"]}/1000)) '+%Y-%m-%d %H:%M:%S')" $((${VARI_GLOBAL["BUILTIN_START_TIME"]}%1000))
  # printf "end     : %s.%03d\n" "$(date -d @$((${variEndTime}/1000)) '+%Y-%m-%d %H:%M:%S')" $((${variEndTime}%1000))
  # echo "start : $(date -d @$((${VARI_GLOBAL["BUILTIN_START_TIME"]}/1000)) '+%Y-%m-%d %H:%M:%S')"
  # echo "end   : $(date -d @$((${variEndTime}/1000)) '+%Y-%m-%d %H:%M:%S')"
  echo "[ duration : ${variHour} hour ${variMinute} minute ${variSecond}.${variMillisecond} second ]"
  echo "--------------------------------------------------"
  return 0
}

# --------------------------------------------------

function funcProtectedCheckRequiredParameter() {
  variRequiredNum=$1
  # --------------------------------------------------
  # call example :
  # local variParameterDescList=("parameter1 desc1" "parameter2 desc2")
  # funcProtectedCheckRequiredParameter 2 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  # --------------------------------------------------
  # parameter desc :
  # variParameterDescList[@] ： 數組引用
  # ${!2} ： 解除引用
  # --------------------------------------------------
  variParameterDescList=("${!2}")
  variCurrentNum=$3
  # 檢查結果，值：0失敗，1成功（默認）
  variCheckLabel=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
  # 重置至終端默認
  COLOR_RESET='\033[0m'
  # 背景綠色，字體黑色
  COLOR_GREEN_BLACK='\033[42;30m'
  if [[ $variCurrentNum -lt $variRequiredNum ]]; then
    variCheckLabel=${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}
  fi
  variParameterExplain=$(printf "%s" ":<<PARAMETER [ $variCheckLabel ]\n")
    variParameterExplain+=$(printf "%s\n" "$variRequiredNum parameter(s) is/are required :")
  for (( i=0; i<${#variParameterDescList[@]}; i++ )); do
    variParameterExplain+=$(printf "\n%s" "${COLOR_GREEN_BLACK}\$$((i+1)) : ${variParameterDescList[$i]}${COLOR_RESET}")
  done
  variParameterExplain+=$(printf "\n%s\n" "PARAMETER")
  echo -e "$variParameterExplain" # >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  if [[ $variCheckLabel == ${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]} ]]; then
      return 1
  else
      return 0
  fi
}

function funcProtectedCheckOptionParameter() {
  variRequiredNum=$1
  # --------------------------------------------------
  # call example :
  # local variParameterDescList=("parameter1 desc1" "parameter2 desc2")
  # funcProtectedCheckOptionParameter 2 variParameterDescList[@]
  # --------------------------------------------------
  # parameter desc :
  # variParameterDescList[@] ： 數組引用
  # ${!2} ： 解除引用
  # --------------------------------------------------
  variParameterDescList=("${!2}")
  # 檢查結果，值：0失敗，1成功（默認）
  variCheckLabel="option"
  # 重置至終端默認
  COLOR_RESET='\033[0m'
  # 背景綠色，字體黑色
  COLOR_GREEN_BLACK='\033[42;30m'
  variParameterExplain=$(printf "%s" ":<<PARAMETER [ $variCheckLabel ]\n")
  variParameterExplain+=$(printf "%s\n" "$variRequiredNum parameter(s) is/are required :")
  for (( i=0; i<${#variParameterDescList[@]}; i++ )); do
    variParameterExplain+=$(printf "\n%s" "${COLOR_GREEN_BLACK}\$$((i+1)) : ${variParameterDescList[$i]}${COLOR_RESET}")
  done
  variParameterExplain+=$(printf "\n%s\n" "PARAMETER")
  echo -e "$variParameterExplain" # >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  return 0
}

function funcProtectedPullEncryptEnvi(){
  # 1 check：the index of the encrypted value must exist in both $VARI_GLOBAL and $VARI_ENCRYPT
  # 2 return : $VARI_ENCRYPT["index"]
  variIndex=$1
  if [[ -z "${VARI_ENCRYPT[${variIndex}]}" ]]; then
    echo ${VARI_GLOBAL[${variIndex}]}
  else
    echo ${VARI_ENCRYPT[${variIndex}]}
  fi
  return 0
}

# $VARI_GLOBAL >> string
# TODO : to be debugged
function funcProtectedSerializeVariGlobal() {
  echo ${VARI_GLOBAL["BUILTIN_START_TIME"]}
  local variString=""
  for variIndex in "${!VARI_GLOBAL[@]}"; do
    local variValue="${VARI_GLOBAL[$variIndex]}"
    # handle single quote
    variValue="${variValue//\'/\'\\\'\'}"
    variString+="${variIndex}='${variValue}';"
  done
  echo "${variString}"
}

# string >> [refresh]$VARI_GLOBAL
# TODO : to be debugged
function funcProtectedDeserializeVariGlobal() {
  local variSerialize="$1"
  IFS=';'
  read -ra variArray <<< "$variSerialize"
  # 遍歷「variArray」,將「每個元素」以等號分割（左邊/下標，右邊/鍵值（且：移除單引號）)
  for variItem in "${variArray[@]}"; do
      IFS='=' read -r variIndex variValue <<< "$variItem"
      VARI_GLOBALE["$variIndex"]="${variValue//\'}"
      # echo "$variIndex : ${VARI_GLOBALE[$variIndex]}"
  done
}

# only applicable for adding a single line record
function funcProtectedTrace(){
  echo "${1}" >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  return 0
}

# only applicable for adding a single line record
function funcProtectedTodo(){
  echo "${1}" >> "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}"
  return 0
}

function funcProtectedUpdateVariGlobalBuiltinValue() {
  local variIndex=${1}
  local variValue=${2}
  if [ ${variIndex} == "BUILTIN_OMNI_ROOT_PATH" ]; then
    variOmniRootPath=${variValue}
  else
    variOmniRootPath=${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}
  fi
  local variBuiltinUri="${variOmniRootPath}/include/builtin/builtin.sh"
  local variNewRecord='VARI_GLOBAL["'${variIndex}'"]="'${variValue}'"'
  sed -i "/^VARI_GLOBAL\[\"BUILTIN_OMNI_ROOT_PATH\"\]=/c$variNewRecord" ${variBuiltinUri}
  return 0
}

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
# release to cloud/internet
function funcPublicReleaseCloud(){
  variUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
  cd ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}
  tar -czf /${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variUnitCommand}.cloud.tgz ./cloud
  ${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/common/qiniu/qiniu.sh upload "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variUnitCommand}.cloud.tgz"
  return 0
}

# public function[END]
# ##################################################