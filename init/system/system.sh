#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/23

:<<MARK
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="MASTER"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" || true
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"

# ##################################################
# global variable[START]
VARI_GLOBAL["ABLE_MASTER_BASH_ENVI_UNIF_FILE_LIST"]="system.sh haohaiyou.sh"
VARI_GLOBAL["IGNORE_SYMBOL_LINK_UNIT_FILE_LIST"]="template.sh"
# auto prepend $variOmniRootPath[START]
VARI_GLOBAL["IGNORE_SYMBOL_LINK_DIRECTORY_LIST"]="include vendor"
# auto prepend $variOmniRootPath[END]
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
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
  variParameterDescList=("init mode，value：0/cache，1/real time（default）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  variCacheButton=${1:-1}
  [ ${variCacheButton} -eq 1 ] && variOmniRootPath=$(funcProtectedPullOmniRootPath) || variOmniRootPath=${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}
  # 基於當前環境的命令（即：source bash）[START]
  variMasterBashEnviUnitFileUriList=()
  variSourceEtcBashrcStatus=0
  for variEachAbleMasterBashEnviFilename in ${VARI_GLOBAL["ABLE_MASTER_BASH_ENVI_UNIF_FILE_LIST"]}; do
    # 字符串拼接（待理解）：variMasterBashEnviUnitFileUriList+=$(find ${variOmniRootPath} -name ${variEachAbleMasterBashEnviFilename} -print -quit)
    variEachMasterBashEnviUnitFileUri=$(find "${variOmniRootPath}" -name "${variEachAbleMasterBashEnviFilename}" -print -quit)
    if [ -n "$variEachMasterBashEnviUnitFileUri" ]; then
      variMasterBashEnviUnitFileUriList+=("$variEachMasterBashEnviUnitFileUri")
      # --------------------------------------------------
      variEachPath=$(dirname $variEachMasterBashEnviUnitFileUri)
      variEachFilename=$(basename $variEachMasterBashEnviUnitFileUri)
      variEachCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
      pattern='alias '${variEachCommand}'="source '${variEachMasterBashEnviUnitFileUri}'"'
      if ! $(grep -qF "$pattern" /etc/bashrc); then
        echo $pattern >> /etc/bashrc
        variSourceEtcBashrcStatus=1
      else
        echo "/etc/bashrc : $(grep -F "$pattern" /etc/bashrc)" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
      fi
      # --------------------------------------------------
    fi
  done
  # 腳本結束，是否需要執行「source /etc/bashrc」，值：0無需執行（默認），1需要執行
  if [ $variSourceEtcBashrcStatus -eq 1 ]; then
      echo 'source /etc/bashrc' >> ${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}
  fi
  # 基於當前環境的命令（即：source bash）[END]
  # --------------------------------------------------
  # 基於派生環境的命令（即：fork bash）[START]
  variFindCommand="find \"$variOmniRootPath\""
  # 在循环中自适应地追加排除目录
  for variEachExclueSymbolicLinkDirectory in ${VARI_GLOBAL["IGNORE_SYMBOL_LINK_DIRECTORY_LIST"]}; do
      variFindCommand="$variFindCommand -type d -path \"$variOmniRootPath/$variEachExclueSymbolicLinkDirectory\" -prune -o"
  done
  # 追加查找文件的条件
  # example : find "/windows/code/backend/chunio/omni" -type d -path "/windows/code/backend/chunio/omni/vendor" -prune -o -type d -path "/windows/code/backend/chunio/omni/internal" -prune -o -type f -name "*.sh" -print
  variFindCommand="$variFindCommand -type f -name \"*${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}\" -print"
  # echo "find command : $variFindCommand" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  variAbleUnitFileURIList=$(eval "$variFindCommand" | sort -u)
  # pull *.sh list/自動補全主要命令[START]
  # 隔斷符號（echo $COMP_WORDBREAKS）"'><=;|&(:
  rm -rf /usr/local/bin/${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}*
  for variAbleUnitFileUri in ${variAbleUnitFileURIList}; do
    # --------------------------------------------------
    # filter ${VARI_GLOBAL["ABLE_MASTER_BASH_ENVI_UNIF_FILE_LIST"]}
    for variEachMasterBashEnviUnitFile in ${VARI_GLOBAL["ABLE_MASTER_BASH_ENVI_UNIF_FILE_LIST"]}; do
      if [[ $(basename ${variAbleUnitFileUri}) == ${variEachMasterBashEnviUnitFile} ]]; then
        # 2：[跳過的]循環層級
        continue 2
      fi
    done
    for variEachSymbolLinkUnitFile in ${VARI_GLOBAL["IGNORE_SYMBOL_LINK_UNIT_FILE_LIST"]}; do
      if [[ $(basename ${variAbleUnitFileUri}) == ${variEachSymbolLinkUnitFile} ]]; then
        # 2：[跳過的]循環層級
        continue 2
      fi
    done
    # --------------------------------------------------
    # 將工程目錄中「xxxx.sh」後綴的腳本文件軟鏈至/usr/local/bin/omni.xxxx[START]
    variEachFilename=$(basename $variAbleUnitFileUri)
    variEachCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    # 將工程目錄中「xxxx.sh」後綴的腳本文件軟鏈至/usr/local/bin/omni.xxxx[END]
    echo "ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachCommand" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachCommand
  done
  # echo -e "current : VARI_CACAHE_URI_RESULT=(\n$(echo $variExecFileURIList | tr ' ' '\n' | sed 's/^/  /')\n)" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  # pull *.sh list/自動補全主要命令[END]
  # --------------------------------------------------
  # pull public function list/自動補全選項列表[START]
  rm -rf /etc/bash_completion.d/${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}.*
  for variAbleUnitFileUri in ${variAbleUnitFileURIList}; do
    # 將工程目錄中「xxxx.sh」後綴的腳本文件軟鏈至/usr/local/bin/omni.xxxx[START]
    variEachFilename=$(basename $variAbleUnitFileUri)
    variEachCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    # 將工程目錄中「xxxx.sh」後綴的腳本文件軟鏈至/usr/local/bin/omni.xxxx[END]
    # --------------------------------------------------
    variFuncNameCollection=$(grep -oP 'function \KfuncPublic\w+' "$variAbleUnitFileUri") || true
    [ -z "$variFuncNameCollection" ] && continue
    variEachOptionList=""
    for variEachFuncName in $variFuncNameCollection; do
      # 選項處理：1remove「funcPublic」 ，2「first letter」upper >> lower[START]
      variOptionName=$(echo "$variEachFuncName" | sed 's/^funcPublic//')
      variOptionName=$(echo "$variOptionName" | awk '{print tolower(substr($0, 1, 1)) substr($0, 2)}')
      # 選項處理：1remove「funcPublic」 ，2「first letter」upper >> lower[END]
      variEachOptionList="$variEachOptionList $variOptionName"
    done
    # remove leading and trailing whitespace/移除首末空格
    variEachOptionList=$(echo $variEachOptionList | sed 's/^[ \t]*//;s/[ \t]*$//')
    echo "$variEachCommand -> $variEachOptionList" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    funcProtectedComplete "$variEachCommand" "$variEachOptionList"
  done
  if [ $variSourceEtcBashrcStatus -eq 1 ]; then
    echo "source /usr/share/bash-completion/bash_completion" >> ${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}
  fi
  # 「source /usr/share/bash-completion/bash_completion」成功返回：exit 1（待理解？）
  source /usr/share/bash-completion/bash_completion || true
  # pull public function list/自動補全選項列表[END]
  # 基於派生環境的命令（即：fork bash）[END]
  # --------------------------------------------------
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"