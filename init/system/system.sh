#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/23

:<<MARK
MARK

# if ! declare -p VARI_GLOBAL &>/dev/null; then
  # declare -A VARI_GLOBAL;
# fi

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="MASTER"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" || true
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"

# ##################################################
# global variable[START]
VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"]="include vendor"
VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]="template"
VARI_GLOBAL["VERSION_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/init.version"
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedCommandInit(){
  local variAbleUnitFileURIList=${1}
  local variEtcBashrcReloadStatus=0
  rm -rf /usr/local/bin/"${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}."*
  for variAbleUnitFileUri in ${variAbleUnitFileURIList}; do
    variEachUnitFilename=$(basename ${variAbleUnitFileUri})
    variEachUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    if grep -q 'VARI_GLOBAL\["BUILTIN_BASH_EVNI"\]="MASTER"' ${variAbleUnitFileUri}; then
        # 基於當前環境的命令（即：vim /etc/bashrc）[START]
        pattern='alias '${variEachUnitCommand}'="source '${variAbleUnitFileUri}'"'
        if ! $(grep -qF "$pattern" /etc/bashrc); then
          echo $pattern >> /etc/bashrc
          [ $variEtcBashrcReloadStatus -eq 0 ] && echo 'source /etc/bashrc && omni.system init' >> ${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}
          variEtcBashrcReloadStatus=1
        else
          echo "[ /etc/bashrc ] $(grep -F "$pattern" /etc/bashrc)" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
        fi
        # 基於當前環境的命令（即：vim /etc/bashrc）[END]
    else
        # 基於派生環境的命令（即：ln -sf ./omni/.../example.sh /usr/local/bin/omni.example）[START]
        echo "ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachUnitCommand" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
        ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachUnitCommand
        # 基於派生環境的命令（即：ln -sf ./omni/.../example.sh /usr/local/bin/omni.example）[END]
    fi
  done
  return 0
}
function funcProtectedOptionInit(){
  local variAbleUnitFileURIList=${1}
  # 隔斷符號（echo $COMP_WORDBREAKS）"'><=;|&(:
  rm -rf /etc/bash_completion.d/${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}.*
  # inherit the public functions from builtin.sh[START]
  local variIncludeOptionList=""
  for variEachIncludeFuncName in $(grep -oP 'function \KfuncPublic\w+' "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/include/builtin/builtin.sh"); do
    # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[START]
    variOptionName=$(echo "$variEachIncludeFuncName" | sed 's/^funcPublic//')
    variOptionName=$(echo "$variOptionName" | awk '{print tolower(substr($0, 1, 1)) substr($0, 2)}')
    # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[END]
    variIncludeOptionList="$variIncludeOptionList $variOptionName"
  done
  # remove leading and trailing whitespace/移除首末空格
  variIncludeOptionList=$(echo ${variIncludeOptionList} | sed 's/^[ \t]*//;s/[ \t]*$//')
  echo "[ ${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/include/builtin.sh -> ${variIncludeOptionList} ]" >> ${VARI_GLOBAL["VERSION_URI"]}
  echo "[ ${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/include/builtin.sh -> ${variIncludeOptionList} ]" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  # inherit the public functions from builtin.sh[END]
  for variAbleUnitFileUri in ${variAbleUnitFileURIList}; do
    variEachUnitFilename=$(basename $variAbleUnitFileUri)
    variEachUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    variFuncNameCollection=$(grep -oP 'function \KfuncPublic\w+' "$variAbleUnitFileUri") || true
    [ -z "$variFuncNameCollection" ] && continue
    local variEachOptionList=""
    for variEachFuncName in $variFuncNameCollection; do
      # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[START]
      variOptionName=$(echo "$variEachFuncName" | sed 's/^funcPublic//')
      variOptionName=$(echo "$variOptionName" | awk '{print tolower(substr($0, 1, 1)) substr($0, 2)}')
      # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[END]
      variEachOptionList="$variEachOptionList $variOptionName"
    done
    # remove leading and trailing whitespace/移除首末空格
    variEachOptionList=$(echo $variEachOptionList | sed 's/^[ \t]*//;s/[ \t]*$//')
    # update init.version[START]
    grep -q 'VARI_GLOBAL\["BUILTIN_BASH_EVNI"\]="MASTER"' ${variAbleUnitFileUri} && variEachBashEvni="master" || variEachBashEvni="slave"
    echo "$variEachUnitCommand / ${variEachBashEvni} -> $variEachOptionList" >> ${VARI_GLOBAL["VERSION_URI"]}
    echo "$variEachUnitCommand / ${variEachBashEvni} -> $variEachOptionList" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    # update init.version[END]
    funcProtectedComplete "$variEachUnitCommand" "${variIncludeOptionList} ${variEachOptionList}"
  done
  # 「source /usr/share/bash-completion/bash_completion」成功返回：exit 1（待理解？）
  source /usr/share/bash-completion/bash_completion || true
  # pull public function list/自動補全選項列表[END]
  return 0
}

function funcProtectedComplete(){
  variCommand=$1
  variOptionList=$2
# 添加當前腳本的命令補全邏輯
echo '# 1按下「table」時執行提示，2_complete()執行完畢後觸發補全邏輯
_'${variCommand}'_complete() {
    local currentWord optionList
    currentWord="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=()
    case ${COMP_CWORD} in
        1)
            optionList="'${variOptionList}'"
            COMPREPLY=( $(compgen -W "${optionList}" -- "${currentWord}") )
            ;;
        *)
            return 0
            ;;
    esac
    return 0
}
# 啟動「交互終端」時執行一次
complete -F _'${variCommand}'_complete '${variCommand} > /etc/bash_completion.d/${variCommand}
  chmod +x /etc/bash_completion.d/${variCommand}
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicInit(){
  local variParameterDescList=("init mode，value：0/（default），1/refresh cache")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  variRefreshCache=${1:-0}
  echo '' > ${VARI_GLOBAL["VERSION_URI"]}
  if [ -z "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}" ] || [ ${variRefreshCache} -eq 1 ]; then
    variOmniRootPath="${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]%'/init/system'}"
    funcProtectedUpdateVariGlobalBuiltinValue "BUILTIN_OMNI_ROOT_PATH" ${variOmniRootPath}
  fi
  # pull *.sh list[START]
  # filter : ${VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"] && ${VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]}
  # find "/windows/code/backend/chunio/omni" \
  # -type d -path "/windows/code/backend/chunio/omni/vendor" -prune -o \
  # -type d -path "/windows/code/backend/chunio/omni/include" -prune -o \
  # -type d -regex ".*/template" -prune -o \
  # -type f -name "*.sh" -print
  local variFindCommand="find \"${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}\""
  for variEachIgnoreDirectory in ${VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"]}; do
      variFindCommand="$variFindCommand -type d -path \"${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/$variEachIgnoreDirectory\" -prune -o"
  done
  for variEachIgnoreDirectory in ${VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]}; do
      variFindCommand="$variFindCommand -type d -regex \".*/$variEachIgnoreDirectory\" -prune -o"
  done
  variFindCommand="$variFindCommand -type f -name \"*${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}\" -print"
  variAbleUnitFileURIList=$(eval "$variFindCommand" | sort -u)
  # pull *.sh list[END]
  funcProtectedCommandInit "${variAbleUnitFileURIList}"
  funcProtectedOptionInit "${variAbleUnitFileURIList}"
  return 0
}

function funcPublicArchiveUnit(){
  local variParameterDescList=("unit name（limited to the ./omni/module/*）" "save to [ the path ]")
  funcProtectedCheckRequiredParameter 2 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variUnitName=${1}
  variSaveToThePath=${2}
  variArchiveCommand=omni.${variUnitName}
  # [ ${variSaveToThePath} == "/" ] && variSaveToThePath=""
  variArchivePath=${variSaveToThePath}/${variArchiveCommand}
  rm -rf ${variArchivePath} ${variSaveToThePath}/${variArchiveCommand}.tgz
  mkdir -p ${variArchivePath}/module
  /usr/bin/cp -rf "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}"/{common,include,init} ${variArchivePath}
  /usr/bin/cp -rf "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}"/module/${variUnitName} ${variArchivePath}/module
  # flush the useless data[START]
  find ${variArchivePath} -type f -name "encrypt.envi" -exec truncate -s 0 {} \;
  variRuntimePathList=$(find ${variArchivePath} -type d -name "runtime")
  for variEachRuntimePath in ${variRuntimePathList}; do
    rm -rf "${variEachRuntimePath:?}"/*
  done
  # flush the useless data[END]
  echo "[root@localhost /]# tar -xvf ${variArchiveCommand}.tgz" >> ${variArchivePath}/README.md
  echo "[root@localhost /]# ./${variArchiveCommand}/init/system/system.sh init && source /etc/bashrc" >> ${variArchivePath}/README.md
  echo "[root@localhost /]# omni.system version" >> ${variArchivePath}/README.md
  echo '[root@localhost /]# # example : [ input ] '${variArchiveCommand}' >> \table' >> ${variArchivePath}/README.md
  tar -czvf ${variSaveToThePath}/${variArchiveCommand}.tgz ${variArchivePath}
  rm -rf ${variSaveToThePath}/${variArchiveCommand}
  return 0
}

function funcPublicVersion(){
  cat ${VARI_GLOBAL["VERSION_URI"]} >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"