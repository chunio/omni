#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
MARK

# ##################################################
# global variable[START]
VARI_GLOBAL["BUILTIN_START_TIME"]=$(perl -MTime::HiRes=time -e 'printf "%d\n", time * 1000')
# 每次執行動態獲取（即：共享內存）[START]
# enum : LINUX / DARWIN
VARI_GLOBAL["BUILTIN_UNAME"]=""
# enum : CENTOS / UBUNTU / MACOS
VARI_GLOBAL["BUILTIN_OS_DISTRO"]=""
VARI_GLOBAL["BUILTIN_SOURCE_URI"]=""
VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]=""
# 每次執行動態獲取（即：共享內存）[END]
VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]="sh"
VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]="omni"
VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]="${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/cloud"
VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]="${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/runtime"
# format :　YYYYMMDD.HHMMSS.mmm
VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]=$(echo "${VARI_GLOBAL["BUILTIN_START_TIME"]}" | TZ="Asia/Shanghai" perl -MPOSIX -lne 'print strftime("%Y%m%d.%H%M%S", localtime($_/1000)) . "." . substr($_, -3)')
VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.todo"
VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.trace"
VARI_GLOBAL["BUILTIN_UNIT_COMMAND_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.command"
VARI_GLOBAL["BUILTIN_SEPARATOR_LINE"]=""
VARI_GLOBAL["BUILTIN_TRUE_LABEL"]="SUCCEEDED"
VARI_GLOBAL["BUILTIN_FALSE_LABEL"]="FAILED"
VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]=200
# 0表示不限
VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]=10
VARI_GLOBAL["BUILTIN_CURRENT_OPTION"]=""
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedDebugRecover() {
  trap 'echo "[ ${LINENO} / $(date +%Y-%m-%d\ %H:%M:%S) ] : ${BASH_COMMAND}" >> "${VARI_GLOBAL["BUILTIN_UNIT_COMMAND_URI"]}"' DEBUG
  return 0
}

function funcProtectedErrorRecover() {
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
function funcProtectedSyncQiniu() {
  mkdir -p "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}"
  if [ -z "$(ls -A "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}")" ]; then
    variCloudArchivedFilename="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}.cloud.tgz"
    omni.qiniu download ${variCloudArchivedFilename} ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
    tar -zxf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variCloudArchivedFilename} -C ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
    mv ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cloud/* ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}
    rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cloud
  fi
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

function funcProtectedConstruct() {
  # [ -n "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}" ] && return 0
  # --------------------------------------------------
  # 動態獲取項目目錄[START]
  local variOmniRootMarkedFile=".3aa53cec161c587e51555bdfa5c56eff"
  local variBuiltinOmniRootPath=""
  local variCurrentScript=""
  if [ -n "$ZSH_VERSION" ]; then
    # zsh
    eval 'variCurrentScript="${(%):-%x}"'
  else
    # bash/無下標時，獲取數組首個元素
    variCurrentScript="${BASH_SOURCE}"
  fi
  local variBuiltinAbsolutePath="$(cd "$(dirname "${variCurrentScript}")" && pwd)/$(basename "${variCurrentScript}")"
  local variCurrentPath=$(dirname "${variBuiltinAbsolutePath}")
  while [ "${variCurrentPath}" != "/" ] && [ -n "${variCurrentPath}" ]; do
    if [ -f "${variCurrentPath}/${variOmniRootMarkedFile}" ]; then
      variBuiltinOmniRootPath="${variCurrentPath}"
      break
    fi
    variCurrentPath=$(dirname "${variCurrentPath}") # 向上一層
  done
  if [ -z "${variBuiltinOmniRootPath}" ]; then
    echo "cannot find omni root marker file '${variOmniRootMarkedFile}'" >&2
    return 1
  fi
  VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]="${variBuiltinOmniRootPath}"
  # 動態獲取項目目錄[END]
  # --------------------------------------------------
  funcProtectedUnameInit
  # --------------------------------------------------
  mkdir -p "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}"
  mkdir -p "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"
  if ! [ -f "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" ]; then
    cat <<ENCRYPTENVI >> ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi
#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : $(date '+%Y-%m-%d %H:%M:%S')

:<<MARK
MARK

declare -A VARI_ENCRYPT
ENCRYPTENVI
  fi
  # ----------
  # 禁止：於當前環境執行（如：source interface.sh）
  if [[ ${VARI_GLOBAL["BUILTIN_BASH_ENVI"]} == "SLATER" ]] && [[ "$0" == "bash" || "$0" == "-bash" || "$0" == "sh" || "$0" == "-sh" ]]; then
      echo "the run mode is prohibited"
      echo "example : "'${symbolLink}'" | /${VARI_GLOBAL["BASH_NAME"]} | ./${VARI_GLOBAL["BASH_NAME"]} | bash ${VARI_GLOBAL["BASH_NAME"]}"
      return 1
  fi
  # ----------
  mkdir -p "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}" "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"
  if [ ${VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]} != 0 ] && [ $(ls -1 "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | wc -l) -gt ${VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]} ]; then
    rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/*.todo
    rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/*.trace
  fi
  touch "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}" "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}"
  variStartTimeFormat=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M:%S", localtime($ARGV[0]/1000))' "${VARI_GLOBAL["BUILTIN_START_TIME"]}")
  funcProtectedTrace ":<<${variStartTimeFormat}"
  return 0
}

function funcProtectedDestruct() {
  variEndTime=$(perl -MTime::HiRes=time -e 'printf "%d\n", time * 1000')
  variExecuteTime=$((variEndTime - ${VARI_GLOBAL["BUILTIN_START_TIME"]}))
  variHour=$((variExecuteTime / 3600000))
  variMinute=$(((variExecuteTime % 3600000) / 60000))
  variSecond=$(((variExecuteTime % 60000) / 1000))
  variMillisecond=$((variExecuteTime % 1000))
  variStartTimeFormat=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M:%S", localtime($ARGV[0]/1000))' "${VARI_GLOBAL["BUILTIN_START_TIME"]}")
  variEndTimeFormat=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M:%S", localtime($ARGV[0]/1000))' "${variEndTime}")
  funcProtectedTrace "${variEndTimeFormat}"
  variUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
  echo "// ${variUnitCommand} ${VARI_GLOBAL["BUILTIN_CURRENT_OPTION"]} ..."
  echo "--------------------------------------------------"
  echo "[ trace : ${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.trace ]"
  if [[ -s "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}" ]]; then
    cat "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  fi
  rm -rf "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  echo "--------------------------------------------------"
  if [[ -s "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}" ]]; then
    echo -e "\033[31m[ TODO : ${VARI_GLOBAL["BUILTIN_UNIT_TEMP_FILENAME"]}.todo ]\033[0m"
    cat "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}"
  else
    echo "[ TODO : -- ]"
  fi
  rm -rf "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}"
  echo "--------------------------------------------------"
  echo "[ duration : ${variHour} hour ${variMinute} minute ${variSecond}.${variMillisecond} second ]"
  echo "--------------------------------------------------"
  return 0
}

function funcProtectedUnameInit() {
  local variUname=$(uname)
  local variBuiltinOsDistro
  local variBuiltinSourceUri
  if [ "$variUname" = "Linux" ]; then
    if [[ -f /etc/centos-release || -f /etc/redhat-release ]]; then
      variBuiltinOsDistro="CENTOS"
      variBuiltinSourceUri="${HOME}/.omni.centos.envi/omni.centos.sh"
    elif [ -f /etc/debian_version ]; then
      variBuiltinOsDistro="UBUNTU"
      variBuiltinSourceUri="${HOME}/.omni.ubuntu.envi/omni.ubuntu.sh"
    fi
  elif [ "$variUname" = "Darwin" ]; then
    variBuiltinOsDistro="MACOS"
    variBuiltinSourceUri="${HOME}/.omni.macos.envi/omni.macos.sh"
  fi
  if [ ! -f "${variBuiltinSourceUri}" ]; then
    mkdir -p "$(dirname "${variBuiltinSourceUri}")"
    echo '#!/usr/bin/env bash' > "${variBuiltinSourceUri}"
    chmod 755 "${variBuiltinSourceUri}"
  fi
  source ${variBuiltinSourceUri} || true
  VARI_GLOBAL["BUILTIN_UNAME"]=$(echo "$variUname" | tr '[:lower:]' '[:upper:]')
  VARI_GLOBAL["BUILTIN_OS_DISTRO"]=${variBuiltinOsDistro}
  VARI_GLOBAL["BUILTIN_SOURCE_URI"]=${variBuiltinSourceUri}
  return 0
}

# --------------------------------------------------

function funcProtectedCheckRequiredParameter_History() {
  variRequiredNum=$1
  # --------------------------------------------------
  # call example :
  # local variParameterDescMulti=("parameter1 desc1" "parameter2 desc2")
  # funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
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
  variParameterExplain+=$(printf "%s\n" "$variRequiredNum parameter(s) is(are) required :")
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

# --------------------------------------------------
# call example :
# local variParameterDescMulti=("parameter1 desc1" "parameter2 desc2")
# funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
# --------------------------------------------------
# parameter desc :
# variParameterDescList[@] ： 數組引用
# ${!2} ： 解除引用
# --------------------------------------------------
function funcProtectedCheckRequiredParameter() {
  local variRequiredNum=$1
  local variArrayName=$2
  local variCurrentNum=$3
  # 使用「eval/展開」替代「bash/專屬的${!2}」[START]
  local localParameterDescList=()
  eval "localParameterDescList=(\"\${$variArrayName}\")"
  # 使用「eval/展開」替代「bash/專屬的${!2}」[END]
  # 檢查結果，值：false失敗，true成功（默認）
  local variCheckLabel=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
  # 重置至終端默認
  local COLOR_RESET='\033[0m'
  # 背景綠色，字體黑色
  local COLOR_GREEN_BLACK='\033[42;30m'
  if [[ ${variCurrentNum} -lt ${variRequiredNum} ]]; then
    variCheckLabel=${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}
  fi
  local variParameterExplain
  variParameterExplain=$(printf "%s" ":<<PARAMETER [ ${variCheckLabel} ]\n")
  variParameterExplain+=$(printf "%s\n" "${variRequiredNum} parameter(s) is(are) required :")
  # 使用「for...in...」遍歷，以免「bash」與「zsh」的索引差異[START]
  local variIndex=1
  local variEachParameterDesc=""
  for variEachParameterDesc in "${localParameterDescList[@]}"; do
    variParameterExplain+=$(printf "\n%s" "${COLOR_GREEN_BLACK}\$${variIndex} : ${variEachParameterDesc}${COLOR_RESET}")
    ((variIndex++))
  done
  # 使用「for...in...」遍歷，以免「bash」與「zsh」的索引差異[END]
  variParameterExplain+=$(printf "\n%s\n" "PARAMETER")
  echo -e "${variParameterExplain}"
  if [[ "${variCheckLabel}" == "${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}" ]]; then
    return 1
  fi
  return 0
}

# --------------------------------------------------
# call example :
# local variParameterDescMulti=("parameter1 desc1" "parameter2 desc2")
# funcProtectedCheckOptionParameter 2 variParameterDescMulti[@]
# --------------------------------------------------
# parameter desc :
# variParameterDescList[@] ： 數組引用
# ${!2} ： 解除引用
# --------------------------------------------------
function funcProtectedCheckOptionParameter_History() {
  variRequiredNum=$1
  variParameterDescList=("${!2}")
  # 檢查結果，值：0失敗，1成功（默認）
  variCheckLabel="option"
  # 重置至終端默認
  COLOR_RESET='\033[0m'
  # 背景綠色，字體黑色
  COLOR_GREEN_BLACK='\033[42;30m'
  variParameterExplain=$(printf "%s" ":<<PARAMETER [ $variCheckLabel ]\n")
  variParameterExplain+=$(printf "%s\n" "$variRequiredNum parameter(s) is(are) required :")
  for (( i=0; i<${#variParameterDescList[@]}; i++ )); do
    variParameterExplain+=$(printf "\n%s" "${COLOR_GREEN_BLACK}\$$((i+1)) : ${variParameterDescList[$i]}${COLOR_RESET}")
  done
  variParameterExplain+=$(printf "\n%s\n" "PARAMETER")
  echo -e "$variParameterExplain" # >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  return 0
}

function funcProtectedCheckOptionParameter() {
  local variRequiredNum=$1
  local variArrayName=$2
  # 使用「eval/展開」替代「bash/專屬的${!2}」[START]
  local localParameterDescList=()
  eval "localParameterDescList=(\"\${$variArrayName}\")"
  # 使用「eval/展開」替代「bash/專屬的${!2}」[END]
  # 檢查結果，值：0失敗，1成功（默認）
  local variCheckLabel="option"
  # 重置至終端默認
  local COLOR_RESET='\033[0m'
  # 背景綠色，字體黑色
  local COLOR_GREEN_BLACK='\033[42;30m'
  local variParameterExplain=$(printf "%s" ":<<PARAMETER [ $variCheckLabel ]\n")
  variParameterExplain+=$(printf "%s\n" "$variRequiredNum parameter(s) is(are) required :")
  # 使用「for...in...」遍歷，以免「bash」與「zsh」的索引差異[START]
  local variIndex=1
  local variEachParameterDesc=""
  for variEachParameterDesc in "${localParameterDescList[@]}"; do
    variParameterExplain+=$(printf "\n%s" "${COLOR_GREEN_BLACK}\$${variIndex} : ${variEachParameterDesc}${COLOR_RESET}")
    ((variIndex++))
  done
  # 使用「for...in...」遍歷，以免「bash」與「zsh」的索引差異[END]
  variParameterExplain+=$(printf "\n%s\n" "PARAMETER")
  echo -e "$variParameterExplain"
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

function funcProtectedEchoGreen(){
  echo -e "\033[32m$1\033[0m"
  return 0
}

# 已廢棄
function funcProtectedUpdateVariGlobalBuiltinValue_Disable() {
  local variIndex=${1}
  local variValue=${2}
  if [ ${variIndex} == "BUILTIN_OMNI_ROOT_PATH" ]; then
    variBuiltinOmniRootPath=${variValue}
  else
    variBuiltinOmniRootPath=${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}
  fi
  local variBuiltinUri="${variBuiltinOmniRootPath}/internal/builtin/builtin.sh"
  local variNewRecord='VARI_GLOBAL["'${variIndex}'"]="'${variValue}'"'
  #「sed -i」工作原理（非原子操作，有文件誤刪的風險）：
  # 1創建「臨時文件」（sedBF4iTk）
  # 2修改「臨時文件」（sedBF4iTk）
  # 3刪除「目標文件」（builtin.sh）
  # 4將「臨時文件」重命名至「目標文件」（sedBF4iTk -> builtin.sh）
  sed -i "/^VARI_GLOBAL\[\"${variIndex}\"\]=/c$variNewRecord" ${variBuiltinUri}
  VARI_GLOBAL["${variIndex}"]="${variValue}"
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
  tar -cvzf /${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variUnitCommand}.cloud.tgz ./cloud
  echo "omni.qiniu upload ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variUnitCommand}.cloud.tgz"
  omni.qiniu upload "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variUnitCommand}.cloud.tgz"
  return 0
}
# public function[END]
# ##################################################