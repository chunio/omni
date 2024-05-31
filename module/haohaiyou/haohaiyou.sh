#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

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

# global variable[END]
# ##################################################

# ##################################################
# protected function[START]

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicUnicorn(){
  cd /windows/code/backend/haohaiyou/gopath/src/unicorn
  pwd && du -sh && ls -alh
  return 0
}

function funcPublicHyperf(){
  # cd /windows/code/backend/haohaiyou/gopath/src/hyperf
  if ! docker ps | grep -q "hyperf"; then
      docker run --name hyperf -v /windows/code/backend/haohaiyou/gopath/src/skeleton:/data/project -w /data/project -p 9501:9501 -it --privileged -u root --entrypoint /bin/sh hyperf/hyperf:8.3-alpine-v3.19-swoole-5.1.3
  fi
  docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash
  # pwd && du -sh && ls -alh
  # return 0
}

# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"