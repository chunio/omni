#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
MARK

# ##################################################
# global variable[START]
# [已驗證]純淨版本的「ubuntu」不支持「perl」
# VARI_GLOBAL["BUILTIN_START_TIME"]=$(perl -MTime::HiRes=time -e 'printf "%d\n", time * 1000')
VARI_GLOBAL["BUILTIN_START_TIME"]=$(date +%s)000
# ----------
# 每次執行動態獲取（即：共享內存）[START]
# enum : LINUX / DARWIN
VARI_GLOBAL["BUILTIN_UNAME"]=""
# enum : CENTOS / UBUNTU / MACOS
VARI_GLOBAL["BUILTIN_OS_DISTRO"]="" # 大寫字母
# enum : ZSH / BASH
VARI_GLOBAL["BUILTIN_SHELL_TYPE"]="" # 大寫字母
VARI_GLOBAL["BUILTIN_SHELLRC_URI"]=""
VARI_GLOBAL["BUILTIN_OMNIRC_URI"]=""
VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]=""
# 每次執行動態獲取（即：共享內存）[END]
# ----------
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
  local variCode=$1
  local variLine=$2
  if [ ${variCode} != 0 ] && [ ${variCode} != ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]} ]; then
      # tail -n 20 "${VARI_GLOBAL["BUILTIN_UNIT_COMMAND_URI"]}" >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
      echo "[ error（recover : ERR） / $(date '+%Y-%m-%d %H:%M:%S') ] line : $variLine / exit code : $variCode" >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  fi
  return 0
}

function funcProtectedExitRecover(){
  local variCode=$1
  local variLine=$2
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
    local variCloudArchivedFilename="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}.cloud.tgz"
    omni.qiniu download "${variCloudArchivedFilename}" "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"
    tar -zxf "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variCloudArchivedFilename}" -C "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"
    mv "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cloud/"* "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}"
    rm -rf "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cloud"
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
  [ -n "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}" ] && return 0
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
  if [[ ${VARI_GLOBAL["BUILTIN_BASH_ENVI"]} = "SLATER" ]] && [[ "$0" = "bash" || "$0" = "-bash" || "$0" = "sh" || "$0" = "-sh" ]]; then
      echo "the run mode is prohibited"
      echo "example : "'${symbolLink}'" | /${VARI_GLOBAL["BASH_NAME"]} | ./${VARI_GLOBAL["BASH_NAME"]} | bash ${VARI_GLOBAL["BASH_NAME"]}"
      return 1
  fi
  # ----------
  mkdir -p "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}" "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"
  if [ ${VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]} != 0 ] && [ $(ls -1 "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | wc -l) -gt ${VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]} ]; then
    # ----------
    # rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/*.todo
    # rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/*.trace
    find "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" -maxdepth 1 -type f \( -name "*.todo" -o -name "*.trace" \) -exec rm -f {} \; 2>/dev/null
    # ----------
  fi
  touch "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}" "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}"
  local variStartTimeFormat=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M:%S", localtime($ARGV[0]/1000))' "${VARI_GLOBAL["BUILTIN_START_TIME"]}")
  funcProtectedTrace ":<<${variStartTimeFormat}"
  return 0
}

function funcProtectedDestruct() {
  # [已驗證]純淨版本的「ubuntu」不支持「perl」
  # variEndTime=$(perl -MTime::HiRes=time -e 'printf "%d\n", time * 1000')
  local variEndTime=$(date +%s)000
  local variExecuteTime=$((variEndTime - ${VARI_GLOBAL["BUILTIN_START_TIME"]}))
  local variHour=$((variExecuteTime / 3600000))
  local variMinute=$(((variExecuteTime % 3600000) / 60000))
  local variSecond=$(((variExecuteTime % 60000) / 1000))
  local variMillisecond=$((variExecuteTime % 1000))
  local variStartTimeFormat=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M:%S", localtime($ARGV[0]/1000))' "${VARI_GLOBAL["BUILTIN_START_TIME"]}")
  local variEndTimeFormat=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M:%S", localtime($ARGV[0]/1000))' "${variEndTime}")
  funcProtectedTrace "${variEndTimeFormat}"
  local variUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
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
  local variBuiltinShellType="BASH" # default
  local variBuiltinShellrcUri
  local variBuiltinOmnircUri
  if [ "$variUname" = "Linux" ]; then
    if [[ -f /etc/centos-release || -f /etc/redhat-release ]]; then
      variBuiltinOsDistro="CENTOS"
      variBuiltinOmnircUri="${HOME}/.omni.centos/omni.centos.sh"
    elif [ -f /etc/debian_version ]; then
      variBuiltinOsDistro="UBUNTU"
      variBuiltinOmnircUri="${HOME}/.omni.ubuntu/omni.ubuntu.sh"
    fi
    [ -n "$ZSH_VERSION" ] && variBuiltinShellType="ZSH"
    variBuiltinShellrcUri="${HOME}/.bashrc"
  elif [ "$variUname" = "Darwin" ]; then
    variBuiltinOsDistro="MACOS"
    variBuiltinShellType="ZSH"
    variBuiltinShellrcUri="${HOME}/.zshrc"
    variBuiltinOmnircUri="${HOME}/.omni.macos/omni.macos.sh"
  fi
  if [ ! -f "${variBuiltinOmnircUri}" ]; then
    mkdir -p "$(dirname "${variBuiltinOmnircUri}")"
    echo '#!/usr/bin/env bash' > "${variBuiltinOmnircUri}"
    chmod 755 "${variBuiltinOmnircUri}"
  fi
  source "${variBuiltinOmnircUri}" || true
  VARI_GLOBAL["BUILTIN_UNAME"]=$(echo "$variUname" | tr '[:lower:]' '[:upper:]')
  VARI_GLOBAL["BUILTIN_OS_DISTRO"]=${variBuiltinOsDistro}
  VARI_GLOBAL["BUILTIN_SHELL_TYPE"]=${variBuiltinShellType}
  VARI_GLOBAL["BUILTIN_SHELLRC_URI"]=${variBuiltinShellrcUri}
  VARI_GLOBAL["BUILTIN_OMNIRC_URI"]=${variBuiltinOmnircUri}
  return 0
}

# --------------------------------------------------
# call example :
# local variParameterDescMulti=("parameter1 desc1" "parameter2 desc2")
# funcProtectedCheckRequiredParameter 2 'variParameterDescMulti[@]' $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
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
  printf "%b\n" "${variParameterExplain}"
  if [[ "${variCheckLabel}" = "${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}" ]]; then
    return 1
  fi
  return 0
}

# --------------------------------------------------
# call example :
# local variParameterDescMulti=("parameter1 desc1" "parameter2 desc2")
# funcProtectedCheckOptionParameter 2 'variParameterDescMulti[@]'
# --------------------------------------------------
# parameter desc :
# variParameterDescList[@] ： 數組引用
# ${!2} ： 解除引用
# --------------------------------------------------
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
  printf "%b\n" "${variParameterExplain}"
  return 0
}

function funcProtectedPullEncryptEnvi(){
  # 1 check：the index of the encrypted value must exist in both $VARI_GLOBAL and $VARI_ENCRYPT
  # 2 return : $VARI_ENCRYPT["index"]
  local variIndex=$1
  if [[ -z "${VARI_ENCRYPT[${variIndex}]}" ]]; then
    echo "${VARI_GLOBAL[${variIndex}]}"
  else
    echo "${VARI_ENCRYPT[${variIndex}]}"
  fi
  return 0
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
  printf "\033[32m%s\033[0m\n" "$1"
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
# release to cloud/internet
function funcPublicReleaseCloud(){
  local variUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
  cd "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}"
  tar -cvzf "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variUnitCommand}.cloud.tgz" ./cloud
  echo "omni.qiniu upload ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variUnitCommand}.cloud.tgz"
  omni.qiniu upload "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variUnitCommand}.cloud.tgz"
  return 0
}
# public function[END]
# ##################################################