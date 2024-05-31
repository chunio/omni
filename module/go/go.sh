#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="SLAVE"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" || true
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

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
#function funcPublicRebuildKratosEnviImage(){
#  # 構建鏡像[START]
#  variParameterDescList=("image pattern（example ：chunio/kratos:1220）")
#  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
#  variImagePattern=$1
#  docker rm -f ${VARI_GLOBAL["CONTAINER_NAME"]} 2> /dev/null
#  # docker run -d --privileged --name php8370 -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /windows:/windows --tmpfs /run --tmpfs /run/lock centos:7.9.2009 /sbin/init
#  # 鏡像不存在時自動執行：docker pull $variImageName
#  docker run -d --privileged --name ${VARI_GLOBAL["CONTAINER_NAME"]} -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /windows:/windows --tmpfs /run --tmpfs /run/lock -p 9502:8000 centos:7.9.2009 /sbin/init
#  docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash -c "cd ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]} && ./$(basename "${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]}") kratosEnvironmentInit;"
#  variContainerId=$(docker ps --filter "name=${VARI_GLOBAL["CONTAINER_NAME"]}" --format "{{.ID}}")
#  echo "docker commit $variContainerId $variImagePattern"
#  docker commit $variContainerId $variImagePattern
#  docker ps --filter "name=${VARI_GLOBAL["CONTAINER_NAME"]}"
#  docker images --filter "reference=${variImagePattern}"
#  echo "${FUNCNAME} ${VARI_GLOBAL["SUCCESS_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
#  echo "docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
#  return 0
#}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"