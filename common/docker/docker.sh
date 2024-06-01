#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
docker update --restart=always redis
docker update --restart=no redis
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' redis
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" || true
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"

# ##################################################
# global variable[START]
VARI_GLOBAL["DOCKER_USERNAME"]=""
VARI_GLOBAL["DOCKER_PASSWORD"]=""
VARI_GLOBAL["SEPARATOR_LINE"]="--------------------------------------------------"
# global variable[END]
# ##################################################

# ##################################################
# private function[START]

# private function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicReleaseImage(){
  variParameterDescList=("image pattern（example : chunio/php:8370）")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=${1}
  variDockerUsername=$(funcProtectedPullEncryptEnvi "DOCKER_USERNAME")
  variDockerPassword=$(funcProtectedPullEncryptEnvi "DOCKER_PASSWORD")
  expect << EOF
  spawn docker login
  expect {
    "Username*" {
      send "${variDockerUsername}\r"
      exp_continue
    }
    "Password*" {
      send "${variDockerPassword}\r"
      exp_continue
    }
    "Login Succeeded" {
      exit
    }
    eof
  }
EOF
  # example: docker push chunio/php:8370
  docker push $variImagePattern
  return 0
}

function funcPublicAuto()
{
  local variParameterDescMulti=("action，value：1/enable（as：--restart=always），0/disable（as：--restart=no）" "container name（keyword）")
  funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variAction=${1}
  variContainerNameKeyword=${2}
  if [ ${variAction} -eq 1 ]; then
    variActionStatus="always";
    variActionLabel="enabled"
  else
    variActionStatus="no"
    variActionLabel="disabled"
  fi
  mapfile -t variContainerNameMulti < <(docker ps -a | grep "${variContainerNameKeyword}" | awk '{print $NF}')
  if [ -z "${variContainerNameMulti[*]}" ]; then
    echo "no container found with ${variContainerNameKeyword}"
  else
    for variEachContainerName in "${variContainerNameMulti[@]}"; do
      docker update --restart=${variActionStatus} ${variEachContainerName} > /dev/null
      echo "${variEachContainerName} has been ${variActionLabel} restart policy"
    done
  fi
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"