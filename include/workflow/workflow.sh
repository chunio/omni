#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
MARK

# ##################################################
if [[ ${VARI_GLOBAL["BUILTIN_BASH_EVNI"]} == "MASTER" ]]; then
  set +e
else
  # [set -e]：trap >> exit the bash
  # [set +e]：trap >> continue the bash
  # DEBUG : [當前棧段]每一命令執行時觸發
  # ERR : 任一命令（含：1自身腳本2函數內部）返回非0時觸發（除外：1/if區域棧段（含：exit ））
  # EXIT : 「exit」命令觸發
  # ...
  # $?:退出狀態（編碼），${FUNCNAME[1]}:函數名稱，${BASH_LINENO[0]}:[基於函數]行號，$LINENO:[基於腳本]行號
  trap 'funcProtectedErrRecover $? $LINENO' ERR
  trap 'funcProtectedExitRecover $? $LINENO' EXIT
  set -e
fi
# --------------------------------------------------
funcProtectedConstruct
funcProtectedCloudInit
funcProtectedLocalInit
# function route : 1 「first letter」lower >> upper，2prepend「funcPublic」
"funcPublic$(echo "${1}" | awk '{print toupper(substr($0, 1, 1)) substr($0, 2)}')" $2 $3 $4 $5 $6 $7 $8 $9 ${10}
funcProtectedDestruct
# the 「return」 command can only be used inside a function or within a script executed using the source command
# ##################################################