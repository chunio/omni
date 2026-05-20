#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 0000/00/00 00:00:00

:<<'MARK'
MARK

# required[START]
# zero length
if [ -z "$ZSH_VERSION" ]; then
  [ "${BASH_VERSION%%.*}" -ge 4 ] 2>/dev/null || { echo "[ required ] {bash 4.0+ || zsh}"; return 1 2>/dev/null || exit 1; }
fi
# required[END]

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="SOURCE"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)" # 不解軟鏈
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE:-$0}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

funcProtectedConstruct # 二次執行（目的：提前獲取係統信息）

# ##################################################
# global variable[START]
variBuiltinOsDistroLower=$(echo "${VARI_GLOBAL["BUILTIN_OS_DISTRO"]}" | tr '[:upper:]' '[:lower:]')
VARI_GLOBAL["OMNI_ENVI_PATH"]="${HOME}/.omni.${variBuiltinOsDistroLower}.envi" # 項目配置
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]

# protected function[END]
# ##################################################

# ##################################################
# public function[START]

# clash:7897
# v2rayn:10809（設置 >> 參數設置 >> 開啟「允許來自局域網的連接」）
# 驗證方法：curl https://www.google.com
# [臨時]禁用代理：env -i curl https://www.google.com
# [臨時]啟用代理：curl -x http://127.0.0.1:7897 https://www.google.com
# [MACOS]{brew && docker}幾乎基於「http(s)」 # TODO:待驗證？
function funcPublicProxy() {
  local variParameterDescMulti=(
    "domain : enum（0/127.0.0.1，1/host.docker.internal）, example.com"
    "port : 0/disable, 7897/clash, 10809/v2ray"
  )
  funcProtectedCheckRequiredParameter 2 'variParameterDescMulti[@]' $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variProxyDomain=${1:-"0"}
  case ${variProxyDomain} in
    "0") variProxyDomain="127.0.0.1" ;; # 本機
    "1") variProxyDomain="host.docker.internal" ;; # docker/orbstack
    *) ;; # custom
  esac
  local variProxyPort=${2:-0}
  if ! [[ "${variProxyPort}" =~ ^[0-9]+$ ]]; then
    variProxyPort=0
  fi
  local variProxyOrigin="< NIL >"
  local variNoProxyMulti="127.0.0.1,localhost,${variProxyDomain},.local,.orb.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
  if [ "${variProxyPort}" -gt 0 ]; then
    variProxyOrigin="http://${variProxyDomain}:${variProxyPort}"
    #（1）shell http && https[START]
    sed -i '' -E '/^export (http_proxy|https_proxy|all_proxy|no_proxy|HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|NO_PROXY)=/d' "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
    {
      echo "export http_proxy=\"${variProxyOrigin}\""
      echo "export https_proxy=\"${variProxyOrigin}\""
      echo "export all_proxy=\"${variProxyOrigin}\""
      echo "export no_proxy=\"${variNoProxyMulti}\""
      echo "export HTTP_PROXY=\"${variProxyOrigin}\""
      echo "export HTTPS_PROXY=\"${variProxyOrigin}\""
      echo "export ALL_PROXY=\"${variProxyOrigin}\""
      echo "export NO_PROXY=\"${variNoProxyMulti}\""
    } >> "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
    #（1）shell http && https[END]
  else
    #（1）shell http && https[START]
    sed -i '' -E '/^export (http_proxy|https_proxy|all_proxy|no_proxy|HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|NO_PROXY)=/d' "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
    unset http_proxy https_proxy all_proxy no_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
    #（1）shell http && https[END]
  fi
  source "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
  {
    echo "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]} successfully modified"
    echo "{http(s)} successfully updated : ${variProxyOrigin}"
  } >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"