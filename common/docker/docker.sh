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
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

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
# 網絡不佳:「Head "https://registry-1.docker.io/v2/chunio/php/blobs/sha256:fa89db0e0fce3d0c80948c0b4c13e53da6ea4e33c89a4c1013ac2b1cc1b4b6ce": EOF」
function funcPublicReleaseImage(){
  variParameterDescList=("image pattern（example : chunio/php:8.3.24）")
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

function funcPublicSetAuto()
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

function funcPublicShowAutoList(){
  docker ps -aq | xargs -r docker inspect --format='{{.Name}}: {{.HostConfig.RestartPolicy.Name}}' | grep 'always'
  return 0
}

function funcPublicRemoveAll(){
  docker rm -f $(docker ps -aq)
  return 0
}

function funcPublicStopAll(){
  docker stop $(docker ps -aq)
  return 0
}

function funcPublicExec(){
  variParameterDescMulti=("container name" "[ command ]")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variContainerName=${1}
  variCommand=${2:-/bin/bash}
  docker exec -it ${variContainerName} ${variCommand}
  return 0
}

function funcPublicDevelopmentEnvironmentInit(){
  variParameterDescMulti=("status，value：1/build，0/clean")
  funcProtectedCheckOptionParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variStatus=${1:-1}
  docker rm -f $(docker ps -aq) 2> /dev/null || true
  docker network ls --format '{{.Name}}' | grep -Ev '^(bridge|host|none)$' | xargs -r docker network rm
  if [ ${variStatus} -eq 1 ]; then
    omni.mysql runNode
    omni.redis runNode
    omni.mongo runNode
    omni.clickhouse runNode 
    omni.kafka runNode
    omni.apollo runNode 0602
  fi
  docker ps -a
  return 0
}

function funcPublicMatchKill() {
    local variParameterDescList=("container name/keyword")
    funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
    local variKeyword=$1
    local variContainerList=$(docker ps -q --filter "name=${variKeyword}")
    if [ -z "${variContainerList}" ]; then
        echo "not found : ${variKeyword}"
        return 0
    fi
    docker ps --filter "name=$keyword" --format "{{.ID}}\t{{.Names}}"
    docker rm -f ${variContainerList}
    return 0    
}

# image pattern : <namespace>/<repository>:<tag>
function funcPublicBuildSystemdUbuntuImage() {
    cat > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/systemd.ubuntu.dockerfile << 'EOF'
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ENV container=docker
# 安裝「systemd 」
RUN apt update && \
    apt install -y --no-install-recommends dbus systemd systemd-sysv && \
    apt clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
# 清理「systemd 」的次要服務
RUN rm -f /etc/systemd/system/*.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/multi-user.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl*
# 屏蔽「systemd」於容器中存在問題的相關服務
RUN systemctl mask \
    getty@.service \
    systemd-udevd.service \
    console-getty.service \
    systemd-logind.service \
    systemd-remount-fs.service \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount
# 創建「systemd」必需目錄
RUN mkdir -p /run/systemd && \
    echo 'docker' > /run/systemd/container
# 設置「systemd」運行級別
RUN systemctl set-default multi-user.target
VOLUME ["/sys/fs/cgroup", "/windows"]
WORKDIR /
CMD ["/sbin/init"]
EOF
  docker builder prune --all -f
  docker build -f ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/systemd.ubuntu.dockerfile -t "systemd.ubuntu" .
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"