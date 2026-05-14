#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<'MARK'
# --------------------------------------------------
cd /Users/zengweitao/archived/workspace/repository/chunio/omni && find . -type f -exec dos2unix {} \;
/Users/zengweitao/archived/workspace/repository/chunio/omni/init/system/system.sh init 1
# --------------------------------------------------
# [示例]將當前腳本的目標函數[聲明/定義]拷貝至遠端 && 執行函數
# about : funcProtectedTemplate
function funcPublicTemplate() {
    ssh -t root@xxxx 'bash -s' <<EOF
$(typeset -f funcProtectedTemplate)
funcProtectedTemplate
exec \$SHELL
EOF
}
# --------------------------------------------------
# [批量]模糊删除（替換：customKeywork）
EVAL "local cursor='0'; local deleted=0; repeat local result=redis.call('SCAN',cursor,'MATCH','*customKeywork*'); cursor=result[1]; for _,key in ipairs(result[2]) do redis.call('DEL',key); deleted=deleted+1; end; until cursor=='0'; return deleted" 0
# [導出]HAsh/field/value
redis-cli -h ${IP} -p ${PORT} -a ${PASSWORD} HGETALL unicorn:HASH:Temp:2025-01-12:SKADNETWORK:ALGORIX > /Users/zengweitao/archived/workspace/runtime/temp.txt
# [統計]文件大小
du -ch /mnt/volume1/unicorn/runtime/bid-request-20250220* | grep total$
# --------------------------------------------------
# [騰訊雲]磁盤管理[START]
# 僅適用於「ext4」文件係統類型（查看：df -T /）
# （1）係統磁盤/擴容
# 查看磁盤信息（含：1分區結構，2掛載信息）
lsblk
yum install -y cloud-utils-growpart
growpart /dev/vda 1
resize2fs /dev/vda1
df -h /dev/vda1
# ----------
#（2A）數據磁盤/掛載
mkdir -p /mnt/datadisk0/unicorn/runtime && mkdir -p /mnt/volume1/unicorn/runtime
mount --bind /mnt/datadisk0/unicorn/runtime /mnt/volume1/unicorn/runtime
df -h /mnt/volume1/unicorn/runtime
mount | grep runtime
# ----------
#（2B）數據磁盤/擴容
# 查看磁盤信息（含：1分區結構，2掛載信息）
lsblk
resize2fs /dev/vdb
df -h /mnt/datadisk0
# [騰訊雲]磁盤管理[END]
# --------------------------------------------------
scp root@170.106.165.51:/Users/zengweitao/archived/workspace/runtime/profile001.svg .
# --------------------------------------------------
# TODO:[SingletonGoroutine.go]添加每日定時任務：find /var/spool/postfix/maildrop -type f -delete
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="SOURCE"
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"][START]
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 解釋軟鏈
if [ "${VARI_GLOBAL["BUILTIN_BASH_ENVI"]}" = "SOURCE" ];then
  VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)" # 不解軟鏈
fi
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"][END]
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE:-$0}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# global variable[START]
VARI_GLOBAL["BASTION_ACCOUNT"]=""
VARI_GLOBAL["BASTION_IP"]=""
VARI_GLOBAL["BASTION_PORT"]=""
VARI_GLOBAL["PADDLEWAVER_CLOUD_SLICE"]=""
VARI_GLOBAL["HOST_MACHINE_WORKSPACE_PATH"]="/Users/zengweitao/archived/workspace"
VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]="/workspace"
# 0 declare 顯式聲明，支持指定數據類型（否則：字符串（default））
# 1 declare -a 索引數組
# 2 declare -A 關聯數組
# 2 declare -p 打印變量
# 2 declare -P 用於打印關聯數組
# 使用隨機名稱以避免「VARI_GLOBAL[BUILTIN_BASH_ENVI]=MASTER」時，變量衝突
declare -a VARI_B40BC66C185E49E93B95239A8365AC4A
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedOmniReinit(){
  # git[START]
  if ! command -v git &> /dev/null; then
    local variOperatingSystem=""
    [ -f /etc/os-release ] && variOperatingSystem=$(. /etc/os-release && echo "${ID}")
    case "${variOperatingSystem}" in
      "centos"|"rhel"|"rocky"|"almalinux")
        yum install -y git
        ;;
      "ubuntu"|"debian")
        apt-get update && apt-get install -y git
        ;;
      *)
        yum install -y git 2>/dev/null || apt-get update && apt-get install -y git 2>/dev/null
        ;;
    esac
  fi
  # git[END]
  # omni.system init[START]
  mkdir -p "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime"
  if [ -d "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/.git" ]; then
    cd "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni"
  else
    rm -rf "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni"
    mkdir -p "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio"
    cd "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio"
    git clone https://github.com/chunio/omni.git
    cd ./omni
  fi
  echo "[ omni ] git fetch origin ..."
  git fetch origin
  echo "[ omni ] git fetch origin finished"
  echo "[ omni ] git reset --hard origin/main ..."
  git reset --hard origin/main
  echo "[ omni ] git reset --hard origin/main finished"
  chmod 777 -R .
  ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/init/system/system.sh init 1
  # omni.system init[END]
  return 0
}

  # --------------------------------------------------
  # call example :
  # funcProtectedCloudSelector
  # local variBastionAccount=$(funcProtectedPullEncryptEnvi "BASTION_ACCOUNT")
  # local variBastionIp=$(funcProtectedPullEncryptEnvi "BASTION_IP")
  # local variBastionPort=$(funcProtectedPullEncryptEnvi "BASTION_PORT")
  # for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
  #   variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
  #   variEachModule=$(echo ${variEachValue} | awk '{print $2}')
  #   variEachService=$(echo ${variEachValue} | awk '{print $3}')
  #   variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
  #   variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
  #   variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
  #   variEachIp=$(echo ${variEachValue} | awk '{print $7}')
  #   variEachPort=$(echo ${variEachValue} | awk '{print $8}')
  #   variEachOs=$(echo ${variEachValue} | awk '{print $9}')
  #   variEachDesc=$(echo ${variEachValue} | awk '{print $10}')
  # done
  # return 0
  # --------------------------------------------------
function funcProtectedCloudSelector() {
  VARI_B40BC66C185E49E93B95239A8365AC4A=() # 防御性的
  tar -czf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh 
  # 未使用「local」關鍵字的變量皆全局變量
  local variFirstIndexSlice=(
    "01 COMMON --"
    "02 PADDLEWAVER --"
    "03 YONE --"
  )
  local variSecondIndexSlice=(
    "01 SKELETON include:php/go({adx&&dsp}SingletonGoroutine)"
    "02 ADX --"
    "03 DSP --"
  )
  printf "%-15s %-15s %-15s\n" "INDEX" "CLOUD" "DESC"
  for variEachValue in "${variFirstIndexSlice[@]}"; do
    variEachIndex=$(echo "$variEachValue" | awk '{print $1}')
    variEachCloud=$(echo "$variEachValue" | awk '{print $2}')
    variEachDesc=$(echo "$variEachValue" | awk '{print $3}')
    printf "%-15s %-15s %-15s\n" "$variEachIndex" "$variEachCloud" "$variEachDesc"
  done
  echo -n "enter the index : "
  read variSelectedCloudIndex
  local -a variSelectedCloudSlice
  case $variSelectedCloudIndex in
    01) variSelectedCloudSlice=("${VARI_ENCRYPT_IPTABLE_CLOUD_SLICE[@]}") ;;
    02) variSelectedCloudSlice=("${VARI_ENCRYPT_PADDLEWAVER_CLOUD_SLICE[@]}") ;;
    03) variSelectedCloudSlice=("${VARI_ENCRYPT_YONE_CLOUD_SLICE[@]}") ;;
    *) echo "invalid selection : ${variSelectedCloudIndex}"; return 1 ;;
  esac
  # ----------
  if [[ ${variSelectedCloudIndex} == "01" ]]; then
    variSelectedModuleName="--" 
  else
    printf "%-15s %-15s %-15s\n" "INDEX" "MODULE" "DESC"
    for variEachValue in "${variSecondIndexSlice[@]}"; do
      variEachIndex=$(echo "$variEachValue" | awk '{print $1}')
      variEachModule=$(echo "$variEachValue" | awk '{print $2}')
      variEachDesc=$(echo "$variEachValue" | awk '{print $3}')
      printf "%-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachDesc"
    done
    echo -n "enter the index : "
    read variSelectedModuleIndex
    case $variSelectedModuleIndex in
      01) variSelectedModuleName="SKELETON" ;;
      02) variSelectedModuleName="ADX" ;;
      03) variSelectedModuleName="DSP" ;;
      *) echo "invalid selection : ${variSelectedModuleIndex}"; return 1 ;;
    esac
  fi
  # ----------
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" \
    "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "OS" "DESC"
  local variCheckAllSlice
  declare -A variSelectedCloudMap
  for variEachValue in "${variSelectedCloudSlice[@]}"; do
    [[ $variEachValue == \#* ]] && continue
    variEachIndex=$(echo "$variEachValue" | awk '{print $1}')
    variEachModule=$(echo "$variEachValue" | awk '{print $2}')
    variEachService=$(echo "$variEachValue" | awk '{print $3}')
    variEachLabel=$(echo "$variEachValue" | awk '{print $4}')
    variEachDomain=$(echo "$variEachValue" | awk '{print $5}')
    variEachRegion=$(echo "$variEachValue" | awk '{print $6}')
    variEachIp=$(echo "$variEachValue" | awk '{print $7}')
    variEachPort=$(echo "$variEachValue" | awk '{print $8}')
    variEachOs=$(echo "$variEachValue" | awk '{print $9}')
    variEachDesc=$(echo "$variEachValue" | awk '{print $10}')
    [[ $variEachModule != $variSelectedModuleName* ]] && continue
    variCheckAllSlice="${variCheckAllSlice} $(echo $variEachValue | awk '{print $1}')"
    variSelectedCloudMap[$variEachIndex]="$variEachValue"
    printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachOs" "$variEachDesc"
  done
  echo -n "enter the index ( 0:當前頁面的全部 / 支持多個,空格間隔 ) : "
  read -a variInputIndexSlice
  local -a variSelectIndexSlice
  #「10#${variInputIndexSlice}」将八進制（如：09）轉換至十進制
  if [[ 10#${variInputIndexSlice} -eq 0 ]]; then
    variSelectIndexSlice=(${variCheckAllSlice})
  else
    variSelectIndexSlice=(${variInputIndexSlice[@]})
  fi
  echo "index : ${variSelectIndexSlice[*]}"
  read -p "input「confirm」to continue : " variInput
  if [[ "$variInput" != "confirm" ]]; then
    return 1
  fi
  for variEachIndex in "${variSelectIndexSlice[@]}"; do
    if [[ -n "${variSelectedCloudMap[$variEachIndex]}" ]]; then
      VARI_B40BC66C185E49E93B95239A8365AC4A+=("${variSelectedCloudMap[$variEachIndex]}")
    fi
  done
  length=${#VARI_B40BC66C185E49E93B95239A8365AC4A[@]}
  if [[ ${length} -eq 0 ]]; then
    echo "invalid selection"
    return 1
  fi 
  # printf '%s\n' "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicRebuildImage(){
  # 構建鏡像[START]
  variParameterDescList=("image pattern（default ：chunio/go:1.25.0（ <namespace>/<repository>:<tag>））" "image main（default : Go1250Main）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=${1-"chunio/go:1.25.0"}
  variImageMain=${2-"Go1250Main"}
  # 習慣:中間橫線，原因：兼容DNS/主機名稱
  variContainerName="chunio-go-1.25.0"
  docker builder prune --all -f
  docker rm -f ${variContainerName} 2> /dev/null
  docker rmi -f $variImagePattern 2> /dev/null
  docker stop $(docker ps -aq)
  # 鏡像不存在時自動執行：docker pull $variImageName
  # DEBUG_LABEL[START]
  # [unsystemd] docker run -d --name ${variContainerName} -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /Users:/Users -p 80:80 ubuntu:24.04 sleep infinity
  # [centos] docker run -d --privileged --name ${variContainerName} -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /Users:/Users --tmpfs /run --tmpfs /run/lock -p 80:80 centos:7.9 /sbin/init
  omni.docker buildSystemdUbuntuImage
  docker run -d \
    --privileged \
    --name ${variContainerName} \
    --tmpfs /tmp \
    --tmpfs /run \
    --tmpfs /run/lock \
    --cgroupns=host \
    -v /Users:/Users \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    systemd.ubuntu /sbin/init
  # DEBUG_LABEL[END]
  docker exec -it ${variContainerName} /bin/bash -c "cd ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]} && ./$(basename "${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]}") rebuildImage_${variImageMain};"
  variContainerId=$(docker ps --filter "name=${variContainerName}" --format "{{.ID}}")
  echo "docker commit $variContainerId $variImagePattern"
  docker commit $variContainerId $variImagePattern
  docker ps --filter "name=${variContainerName}"
  docker images --filter "reference=${variImagePattern}"
  echo "${FUNCNAME} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "docker exec -it ${variContainerName} /bin/bash" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}

# from : funcPublicRebuildImage()
# 運行於容器內部
function funcPublicRebuildImage_Go1250Main(){
  # 減少容器特有/安全性的警告信息[START]
  # 禁止彈出交互窗口，默認配置完成安裝
  export DEBIAN_FRONTEND=noninteractive
  #「invoke-rc.d」依賴運行級別，一個使用於啟動/停止/管理係統服務的腳本
  # invoke-rc.d: could not determine current runlevel
  # invoke-rc.d: policy-rc.d denied execution of start.
  cat <<EOF > /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
  chmod +x /usr/sbin/policy-rc.d
  # No schema files found: doing nothing.
  # 減少容器特有/安全性的警告信息[END]
  apt-get update
  #「dialog」支持文本界面對話框體 (TUI/text-based user interface)
  #「apt-utils」提供「apt」使用的輔助工具
  apt-get install -y --no-install-recommends dialog apt-utils ca-certificates
  apt-get install -y git wget curl make graphviz
  # claude code install[START]
  # 允許安裝「man」幫助手冊[START]
  # 解决警告x22：update-alternatives: warning: skip creation of /usr/share/man/man1/js.1.gz because associated file /usr/share/man/man1/nodejs.1.gz (of link group js) doesn't exist
  sed -i 's/^path-exclude=\/usr\/share\/man/#path-exclude=\/usr\/share\/man/' /etc/dpkg/dpkg.cfg.d/excludes || true
  sed -i 's/^path-exclude=\/usr\/share\/doc/#path-exclude=\/usr\/share\/doc/' /etc/dpkg/dpkg.cfg.d/excludes || true
  # 允許安裝「man」幫助手冊[END]
  apt-get install -y npm && npm install -g @anthropic-ai/claude-code
  # windows[START]
  # powershell >> irm https://claude.ai/install.ps1 | iex
  # powershell >> [System.Environment]::SetEnvironmentVariable("http_proxy", "http://127.0.0.1:10809", "User")
  # powershell >> [System.Environment]::SetEnvironmentVariable("https_proxy", "http://127.0.0.1:10809", "User")
  # manual >> 配置「[搜尋路徑]C:\Users\zengweitao\.local\bin」至「system variables.Path」
  # windows[END]
  # 取消代理[START]
  # powershell >> [System.Environment]::SetEnvironmentVariable("http_proxy", $null, "User")
  # powershell >> [System.Environment]::SetEnvironmentVariable("https_proxy", $null, "User")
  # 取消代理[END]
  # claude code install[END]
  # wget https://go.dev/dl/go1.25.0.linux-amd64.tar.gz -O ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/go1.25.0.linux-amd64.tar.gz
  tar -xvf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/go1.25.0.linux-amd64.tar.gz -C /usr/local
  variDockerMachineWorkspacePath="/workspace"
  mkdir -p ${variDockerMachineWorkspacePath}
  mkdir -p ${variDockerMachineWorkspacePath}/golang/{gopath,gocache}
  mkdir -p ${variDockerMachineWorkspacePath}/golang/gopath{/bin,/pkg,/src}
  cat <<GOENVLINUX > ${variDockerMachineWorkspacePath}/golang/go.env.linux
CGO_ENABLED=0
GO111MODULE=on
GOTOOLCHAIN=auto
GOPATH=${variDockerMachineWorkspacePath}/golang/gopath
GOBIN=${variDockerMachineWorkspacePath}/golang/gopath/bin
GOCACHE=${variDockerMachineWorkspacePath}/golang/gocache
GOMODCACHE=${variDockerMachineWorkspacePath}/golang/gopath/pkg/mod
GOROOT=/usr/local/go
GOSUMDB=sum.golang.google.cn
GOPROXY=https://goproxy.cn,direct
GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
GOENVLINUX
  cat <<ETCBASHRC >> /etc/bashrc
export PATH=$PATH:/usr/local/go/bin:${variDockerMachineWorkspacePath}/golang/gopath/bin
export GOENV=${variDockerMachineWorkspacePath}/golang/go.env.linux
ETCBASHRC
  #  mkdir -p ${variDockerMachineWorkspacePath}/chunio
  #  git clone https://github.com/chunio/omni.git
  #  cd ${variDockerMachineWorkspacePath}/chunio/omni
  #  chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
  cp -rf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/bin/* ${variDockerMachineWorkspacePath}/golang/gopath/bin/
  ulimit -n 102400
  return 0
}

:<<'MARK'
「chunio/php:haohaiyou」封裝日誌：
docker rm -f skeleton
docker rm -f chunio-php-haohaiyou
docker rmi -f chunio/php:haohaiyou
docker run -d \
  --privileged \
  --name chunio-php-haohaiyou \
  --tmpfs /tmp \
  --tmpfs /run \
  --tmpfs /run/lock \
  --cgroupns=host \
  -v /Users:/Users \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  chunio/php:8.3.24 /sbin/init
docker exec -it chunio-php-haohaiyou /bin/bash
# ----------
root@${variContainerId}:/# apt-get update
root@${variContainerId}:/# apt-get install -y python3 python3-pip python3-venv
root@${variContainerId}:/# pip3 install Pillow --break-system-packages
root@${variContainerId}:/# pip3 install playwright --break-system-packages
root@${variContainerId}:/# playwright install
root@${variContainerId}:/# playwright install-deps
root@${variContainerId}:/# apt clean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
root@${variContainerId}:/# history -c
root@${variContainerId}:/# exit
# ----------
docker commit $(docker ps --filter "name=chunio-php-haohaiyou" --format "{{.ID}}") chunio/php:haohaiyou
MARK
function funcPublicSkeleton(){
  variImagePattern=${1:-"chunio/php:haohaiyou"}
  variContainerName="skeleton"
  variHostMachineProjectPath="${VARI_GLOBAL["HOST_MACHINE_WORKSPACE_PATH"]}/repository/haohaiyou/skeleton"
  # variImagePattern=${1:-"hyperf/hyperf:8.3-alpine-v3.19-swoole-5.1.3"}
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/usr/bin/env bash
# 會被「docker run」中指定命令覆蓋
return 0
ENTRYPOINTSH
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variContainerName}:
    image: ${variImagePattern}
    container_name: ${variContainerName}
    # 開啟VPN/代理[START]
    environment:
      - HTTP_PROXY=http://host.docker.internal:7897
      - HTTPS_PROXY=http://host.docker.internal:7897
      - NO_PROXY=localhost,127.0.0.1,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    # extra_hosts:
    #   - "host.docker.internal:host-gateway"
    # 開啟VPN/代理[END]
    volumes:
      - /mnt/mac/Users:/Users
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    working_dir: ${variHostMachineProjectPath}
    networks:
      - common
    ports:
      - "9501:9501"
    # entrypoint: ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
    # 啟動進程關閉時，則容器退出
    command: ["tail", "-f", "/dev/null"]
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f skeleton 2> /dev/null
  docker compose -p ${variContainerName} down -v 2> /dev/null
  docker compose -p ${variContainerName} up --build -d
  docker update --restart=always ${variContainerName}
  docker ps -a | grep ${variContainerName}
  cd ${variHostMachineProjectPath}
  docker exec -it ${variContainerName} /bin/bash
  return 0
}

#「chunio/go:1.22.4」基於「golang:1.22.4」進行調整：
# cat /etc/os-release
# ##################################################
# PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
# NAME="Debian GNU/Linux"
# VERSION_ID="12"
# VERSION="12 (bookworm)"
# VERSION_CODENAME=bookworm
# ID=debian
# HOME_URL="https://www.debian.org/"
# SUPPORT_URL="https://www.debian.org/support"
# BUG_REPORT_URL="https://bugs.debian.org/"
# ##################################################
# apt-get update
# apt-get install -y graphviz
# apt-get install -y vim
function funcPublicUnicorn()
{
  local variContainerName="unicorn"
  local variHostMachineEnviPath="${VARI_GLOBAL["HOST_MACHINE_WORKSPACE_PATH"]}/application/golang/source"
  local variHostMachineProjectPath="${VARI_GLOBAL["HOST_MACHINE_WORKSPACE_PATH"]}/repository/haohaiyou/unicorn"
  mkdir -p ${variHostMachineEnviPath}/{gopath,gocache}
  mkdir -p ${variHostMachineEnviPath}/gopath/{bin,pkg,src}
  mkdir -p ${variHostMachineEnviPath}/gopath/bin/{darwin,linux,windows}
  mkdir -p ${variHostMachineEnviPath}/gocache/{darwin,linux,windows}
  # rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/usr/bin/env bash
# 會被「docker run」中指定命令覆蓋
touch /etc/bashrc
chmod 644 /etc/bashrc
# 禁止「return」
# return 0
ENTRYPOINTSH
  # rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux
  cat <<GOENVLINUX > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux
CGO_ENABLED=0
GO111MODULE=on
GOTOOLCHAIN=auto
GOPATH=${variHostMachineEnviPath}/gopath
GOBIN=${variHostMachineEnviPath}/gopath/bin/linux
GOMODCACHE=${variHostMachineEnviPath}/gopath/pkg/mod
GOCACHE=${variHostMachineEnviPath}/gocache/linux
GOROOT=/usr/local/go
GOSUMDB=sum.golang.google.cn
GOPROXY=https://goproxy.cn,direct
GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
GOENVLINUX
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variContainerName}:
    image: chunio/go:1.25.0
    container_name: ${variContainerName}
    environment:
      # - HTTP_PROXY=http://192.168.255.1:10809
      # - HTTPS_PROXY=http://192.168.255.1:10809
      - HTTP_PROXY=http://host.docker.internal:7897
      - HTTPS_PROXY=http://host.docker.internal:7897
      - NO_PROXY=localhost,127.0.0.1,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
      - GOENV=/go.env.linux
      - PATH=$PATH:/usr/local/go/bin:${variHostMachineEnviPath}/gopath/bin/linux
    volumes:
      - /mnt/mac/Users:/Users
      # - /mnt:/mnt
      # - ${BUILTIN_UNIT_CLOUD_PATH}/bin:${variHostMachineEnviPath}/gopath/bin
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux:/go.env.linux
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    working_dir: ${variHostMachineProjectPath}
    networks:
      - common
    # 僅適用於「linux」[START]
    # extra_hosts:
    #   - "host.docker.internal:host-gateway"
    # 僅適用於「linux」[END]
    ports:
      - "2345:2345"
      - "8000:8000"
      - "8001:8001"
    # entrypoint: ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
    # 啟動進程關閉時，則容器退出
    command: ["tail", "-f", "/dev/null"]
    # 解決提示：connections are not authenticated nor encrypted[START]
    cap_add:
      - SYS_PTRACE
    security_opt:
      - seccomp=unconfined
    # 解決提示：connections are not authenticated nor encrypted[END]
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f ${variContainerName} 2> /dev/null
  docker compose -p ${variContainerName} down -v 2> /dev/null
  docker compose -p ${variContainerName} up --build -d
  docker update --restart=always ${variContainerName}
  docker ps -a | grep ${variContainerName}
  cd ${variHostMachineProjectPath}
  docker exec -it ${variContainerName} /bin/bash
  return 0
}

function funcPublicCloudIndex(){
  funcProtectedCloudSelector
  local variBastionAccount=$(funcProtectedPullEncryptEnvi "BASTION_ACCOUNT")
  local variBastionIp=$(funcProtectedPullEncryptEnvi "BASTION_IP")
  local variBastionPort=$(funcProtectedPullEncryptEnvi "BASTION_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    echo "===================================================================================================="
    echo ">> [ SLAVE ] ${variEachSlaveValue} ..."
    echo "===================================================================================================="
    rm -rf /root/.ssh/known_hosts
    echo "ssh -o StrictHostKeyChecking=no -J ${variBastionAccount}@${variBastionIp}:${variBastionPort} root@${variEachIp} -p ${variEachPort}"
    # 配置一層[SSH]秘鑰
    # ssh -o StrictHostKeyChecking=no -J ${variBastionAccount}@${variBastionIp}:${variBastionPort} root@${variEachIp} -p ${variEachPort}
    # 配置二層[SSH]秘鑰
    ssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -p ${variBastionPort} ${variBastionAccount}@${variBastionIp}" root@${variEachIp} -p ${variEachPort}
    return 0
  done
  return 0
}

# 依賴：雲服務器後台配置「SSH」
function funcPublicCloudBastionReinit() {
  local variBastionAccount=$(funcProtectedPullEncryptEnvi "BASTION_ACCOUNT")
  local variBastionIp=$(funcProtectedPullEncryptEnvi "BASTION_IP")
  local variBastionPort=$(funcProtectedPullEncryptEnvi "BASTION_PORT")
  # 重啟保留（區別：「/tmp」重啟清空）
  local variScpPath="/var/tmp"
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  # 兼容：係統重裝[START]
  ssh-keygen -R ${variBastionIp} 2>/dev/null
  ssh-keygen -R "[${variBastionIp}]:${variBastionPort}" 2>/dev/null
  # 兼容：係統重裝[END]
  scp -P ${variBastionPort} -o StrictHostKeyChecking=no ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz ${variBastionAccount}@${variBastionIp}:${variScpPath}/
  scp -P ${variBastionPort} -o StrictHostKeyChecking=no ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/encrypt.envi ${variBastionAccount}@${variBastionIp}:${variScpPath}/
  ssh -o StrictHostKeyChecking=no -p ${variBastionPort} ${variBastionAccount}@${variBastionIp} "sudo bash -s" <<BASTIONEOF
    # --------------------------------------------------
    export DEBIAN_FRONTEND=noninteractive
    # --------------------------------------------------
    # ssh[START]
    tar -xzvf ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
    /usr/bin/mv ~/.ssh/ssh/* ~/.ssh
    rm -rf ~/.ssh/ssh
    touch ~/.ssh/config
    sed -i '/^StrictHostKeyChecking/d' ~/.ssh/config 2>/dev/null
    echo "StrictHostKeyChecking no" >> ~/.ssh/config
    # 追加密鑰（haohaiyou_cicd/對應權限：雲服務器/代碼倉庫）[START]
    touch ~/.ssh/authorized_keys
    sed -i "\|\$(cat ~/.ssh/id_rsa.pub)|d" ~/.ssh/authorized_keys 2>/dev/null
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    # 追加密鑰（haohaiyou_cicd/對應權限：雲服務器/代碼倉庫）[END]
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/*
    chown \$(whoami):\$(whoami) ~/.ssh/*
    # ssh[END]
    # --------------------------------------------------
    # git[START]
    if ! command -v git &> /dev/null; then
      variOperatingSystem=""
      [ -f /etc/os-release ] && variOperatingSystem=\$(. /etc/os-release && echo "\${ID}")
      case "\${variOperatingSystem}" in
        "centos"|"rhel"|"rocky"|"almalinux")
          yum install -y git
          ;;
        "ubuntu"|"debian")
          apt-get update && apt-get install -y git
          ;;
        *)
          yum install -y git 2>/dev/null || apt-get update && apt-get install -y git 2>/dev/null
          ;;
      esac
    fi
    # git[END]
    # --------------------------------------------------
    # omni.system init[START]
    mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime
    if [ -d "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/.git" ]; then
      cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
    else
      rm -rf ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
      mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
      cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
      git clone https://github.com/chunio/omni.git
      cd ./omni
    fi
    echo "[ omni ] git fetch origin ..."
    git fetch origin
    echo "[ omni ] git fetch origin finished"
    echo "[ omni ] git reset --hard origin/main ..."
    git reset --hard origin/main
    echo "[ omni ] git reset --hard origin/main finished"
    chmod 777 -R .
    ./init/system/system.sh init
    [ -f ~/.bashrc ] && source ~/.bashrc
    # omni.system init[END]
    # --------------------------------------------------
    /usr/bin/cp -rf ${variScpPath}/encrypt.envi ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/
    omni.haohaiyou cloudCoscliReinit
    omni.haohaiyou cloudTccliReinit
BASTIONEOF
  return 0
}

function funcPublicCloudIptableReinit(){
  funcProtectedCloudSelector
  local variBastionAccount=$(funcProtectedPullEncryptEnvi "BASTION_ACCOUNT")
  local variBastionIp=$(funcProtectedPullEncryptEnvi "BASTION_IP")
  local variBastionPort=$(funcProtectedPullEncryptEnvi "BASTION_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    rm -rf /root/.ssh/known_hosts
    ssh -o StrictHostKeyChecking=no -A -p ${variBastionPort} -t ${variBastionAccount}@${variBastionIp} <<BASTIONEOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
      rm -rf /root/.ssh/known_hosts
      scp -P ${variEachPort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachIp}:/
      ssh -o StrictHostKeyChecking=no -A -p ${variEachPort} -t root@${variEachIp} <<'SLAVEEOF'
        # --------------------------------------------------
        # （1）ssh init[START]
        tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
        mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
        echo "StrictHostKeyChecking no" > ~/.ssh/config
        chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
        # （1）ssh init[END]
        # --------------------------------------------------
        # （2）omni.system init[START]
        if ! command -v git &> /dev/null; then
            yum install -y git
        fi
        mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime
        if [ -d "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni" ]; then
          cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
          echo "[ omni ] git fetch origin ..."
          git fetch origin
          echo "[ omni ] git fetch origin finished"
          echo "[ omni ] git reset --hard origin/main ..."
          git reset --hard origin/main
          echo "[ omni ] git reset --hard origin/main finished"
          chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
        else
          mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio && cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
          git clone https://github.com/chunio/omni.git
          cd ./omni && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
        fi
        #（2）omni.system init[END]
        # --------------------------------------------------
        # （3）slave main[START]
        case ${variEachRegion} in
          "SINGAPORE")
            variLanSlice=(
              "redis/skeleton/paddlewaver/envi 172.22.0.42 11110"
              "redis/adx/paddlewaver/common 172.22.0.2 11210"
              "redis/adx/paddlewaver/table 172.22.0.96 11220"
              "redis/dsp/paddlewaver/common 172.22.0.38 11310"
              "redis/dsp/paddlewaver/table 172.22.0.17 11320"
              "redis/dsp/paddlewaver/cluster 172.22.0.33 6379"
              # ----------
              "redis/skeleton/yone/envi 172.22.0.34 21110"
              "redis/adx/yone/common 172.22.0.14 21210"
              "redis/adx/yone/table 172.22.0.59 21220"
              "redis/dsp/yone/common 172.22.0.27 21310"
              "redis/dsp/yone/table 172.22.0.82 21320"
              # ----------
              "clickhouse/mix/mix/http 172.22.0.20 8123"
              "clickhouse/mix/mix/tcp 172.22.0.20 9000"
              "clickhouse/mix/mix/mysql 172.22.0.20 9004"
            )
            ;;
          "USEAST")
            variLanSlice=(
              "redis/skeleton/paddlewaver/envi 10.0.0.27 12110"
              "redis/adx/paddlewaver/common 10.0.0.12 12210"
              "redis/adx/paddlewaver/table 10.0.0.5 12220"
              "redis/dsp/paddlewaver/common 10.0.0.47 12310"
              "redis/dsp/paddlewaver/table 10.0.0.42 12320"
              # ----------
              "redis/skeleton/yone/common 10.0.0.16 22110"
              "redis/adx/yone/common 10.0.0.6 22210"
              "redis/adx/yone/common 10.0.0.11 22220"
              "redis/dsp/yone/common 10.0.0.3 22310"
              "redis/dsp/yone/table 10.0.0.2 22320"
            )
            ;;
          *)
            echo "error : lan not found"
            exit 1
            ;;
        esac
        # declare -p variLanSlice
        # 3A/清空規則
        iptables -t nat -F
        iptables -F FORWARD
        iptables -P FORWARD ACCEPT
        # 3B/追加規則
        for variEachLan in "\${variLanSlice[@]}"; do
          read -r variEachLabel variEachIP variEachPort <<< "\${variEachLan}"
          echo 1 > /proc/sys/net/ipv4/ip_forward
          iptables -t nat -A PREROUTING -p tcp --dport \${variEachPort} -j DNAT --to-destination \${variEachIP}:\${variEachPort}
          iptables -t nat -A POSTROUTING -d \${variEachIP} -p tcp --dport \${variEachPort} -j MASQUERADE
          # iptables -t nat -A POSTROUTING -d \${variEachIP} -p tcp --dport \${variEachPort} -j SNAT --to-source 172.22.0.45
        done
        # 3C/查看規則
        iptables -t nat -L -n -v
        # （3）slave main[END]
        # --------------------------------------------------
SLAVEEOF
BASTIONEOF
  done
  return 0
}

function funcPublicCloudSkeletonReinit() {
  local variParameterDescMulti=("branch : main（default），feature/zengweitao/...")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variBranchName=${1}
  # slave variable[START]
  # systemctl reload crond
  variCrontabEnviUri="/var/spool/cron/root"
  # slave variable[END]
  funcProtectedCloudSelector
  local variBastionAccount=$(funcProtectedPullEncryptEnvi "BASTION_ACCOUNT")
  local variBastionIp=$(funcProtectedPullEncryptEnvi "BASTION_IP")
  local variBastionPort=$(funcProtectedPullEncryptEnvi "BASTION_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    rm -rf /root/.ssh/known_hosts
    ssh -o StrictHostKeyChecking=no -A -p ${variBastionPort} -t ${variBastionAccount}@${variBastionIp} <<BASTIONEOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
        rm -rf /root/.ssh/known_hosts
        scp -P ${variEachPort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachIp}:/
        ssh -o StrictHostKeyChecking=no -p ${variEachPort} -t root@${variEachIp} <<SLAVEEOF
          # --------------------------------------------------
          # （1）ssh init[START]
          tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
          mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
          echo "StrictHostKeyChecking no" > ~/.ssh/config
          chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
          # （1）ssh init[END]
          # --------------------------------------------------
          # （2）omni.system init[START]
          if ! command -v git &> /dev/null; then
              yum install -y git
          fi
          mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime
          if [ -d "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni" ]; then
            cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
          else
            mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
            cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
            git clone https://github.com/chunio/omni.git
            cd ./omni
          fi
          echo "[ omni ] git fetch origin ..."
          git fetch origin
          echo "[ omni ] git fetch origin finished"
          echo "[ omni ] git reset --hard origin/main ..."
          git reset --hard origin/main
          echo "[ omni ] git reset --hard origin/main finished"
          chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
          #（2）omni.system init[END]
          # --------------------------------------------------
          #（3）slave main[START]
          docker rm -f skeleton 2> /dev/null
          if [ -d "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/haohaiyou/gopath/src/skeleton" ]; then
            cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/haohaiyou/gopath/src/skeleton
            echo "[ skeleton ] git fetch origin ..."
            git fetch origin
            echo "[ skeleton ] git fetch origin finished"
            # ----------
            echo "[ skeleton ] git reset --hard origin/${variBranchName} ..."
            git reset --hard origin/${variBranchName}
            echo "[ skeleton ] git reset --hard origin/${variBranchName} finished"
            # ----------
          else
            mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/haohaiyou/gopath/src && cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/haohaiyou/gopath/src
            git clone git@github.com:chunio/skeleton.git && cd skeleton
            git checkout ${variBranchName}
          fi
          chmod 777 -R .
          echo "/usr/bin/cp -rf .env.production.${variEachDomain}.${variEachRegion} .env"
          /usr/bin/cp -rf .env.production.${variEachDomain}.${variEachRegion} .env
          sed -i "s/^APP_SERVICE=.*/APP_SERVICE=${variEachService}/" .env
          rm -rf runtime/container
          expect -c '
          set timeout -1
          spawn ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/haohaiyou.sh skeleton
          expect "skeleton"
          send "composer install\r"
          expect "skeleton"
          send "composer dump-autoload -o --no-dev\r"
          expect "skeleton"
          send "nohup php bin/hyperf.php start > ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/skeleton.log 2>&1 &\r"
          expect "skeleton"
          send "exit\r"
          expect eof
          '
          # crontab[START]
          if grep -Fq "cloudSkeletonHourlyCrontab" "${variCrontabEnviUri}"; then
            sed -i '/cloudSkeletonHourlyCrontab/d' "${variCrontabEnviUri}"
          fi
          echo "0 * * * * ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/haohaiyou.sh cloudSkeletonHourlyCrontab" >> "${variCrontabEnviUri}"
          cat "${variCrontabEnviUri}"
          systemctl reload crond
          # crontab[END]
          #（3）slave main[END]
          # --------------------------------------------------
SLAVEEOF
BASTIONEOF
  done
  return 0
}


function funcPublicCloudSkeletonHourlyCrontab(){
  rm -rf /workspace/repository/haohaiyou/gopath/src/skeleton/core.*
  return 0
}

# 將「80」端口轉發至「9501」端口
# cd /workspace/repository/chunio/omni && git fetch origin && git reset --hard origin/main && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
function funcPublicCloudSkeletonPaddlewaverProxy(){
  local variParameterDescList=("domain")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  local variDomain=${1:-"paddlewaver"}
  local variModuleName="skeleton"
  local variCurrentIp=$(hostname -I | awk '{print $1}')
  cat <<LOCALSKELETONCONF > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://${variCurrentIp}:9501;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        # 超時限制（否則默認：60s）[START]
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
        # 超時限制（否則默認：60s）[END]
    }
}
LOCALSKELETONCONF
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variModuleName}-nginx:
    image: nginx:1.27.0
    container_name: ${variModuleName}-nginx
    volumes:
      - ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}:${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "80:80"
    networks:
      - common
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f skeleton-nginx
  docker compose down -v
  docker compose -p ${variModuleName} up --build -d
  docker ps -a | grep ${variModuleName}
  return 0
}

# 將「80/443」端口轉發至「9501」端口
# cd /workspace/repository/chunio/omni && git fetch origin && git reset --hard origin/main && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
function funcPublicCloudSkeletonYoneProxy(){
  # local variParameterDescList=("domain")
  # funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  local variDomain=${1:-"skeleton.y-one.co.jp"}
  local variModuleName="skeleton"
  local variCurrentIp=$(hostname -I | awk '{print $1}')
  cat <<LOCALSKELETONCONF > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf
# 80[START]
server {
    listen 80;
    server_name ${variDomain};
    #「Let’s Encrypt」挑戰認證[START]
    location ^~ /.well-known/acme-challenge/ {
        root /etc/nginx/webroot;
        default_type "text/plain";
        allow all;
    }
    #「Let’s Encrypt」挑戰認證[END]
    # return 301 https://\$server_name\$request_uri;
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
# 80[END]
# 443[START]
server {
    listen 443 ssl http2;
    server_name ${variDomain};
    # 證書配置[START]
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_prefer_server_ciphers off;
    # 證書配置[END]
    # 採集日誌[START]
    access_log ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variDomain}_access.log main;
    error_log  ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variDomain}_error.log warn;
    # 採集日誌[END]
    location / {
        # [CORS/同源策略]預檢響應[START]
        if (\$request_method = 'OPTIONS') {
            # add_header 'Access-Control-Allow-Origin' '*' always;
            # add_header 'Access-Control-Allow-Credentials' 'false' always;
            add_header 'Access-Control-Allow-Origin' 'https://www.y-one.co.jp' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,Xauth' always;
            add_header 'Access-Control-Max-Age' 86400 always;
            # add_header 'Content-Length' 0;
            return 204;
        }
        # [CORS/同源策略]預檢響應[END]
        # [CORS/同源策略]標準響應[START]
        # add_header 'Access-Control-Allow-Origin' '*' always;
        # add_header 'Access-Control-Allow-Credentials' 'false' always;
        add_header 'Access-Control-Allow-Origin' 'https://www.y-one.co.jp' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,Xauth' always;
        # add_header 'Access-Control-Expose-Headers' 'custom' always;
        # [CORS/同源策略]標準響應[END]
        proxy_pass http://${variCurrentIp}:9501;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        # 超時限制（否則默認：60s）[START]
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
        # 超時限制（否則默認：60s）[END]
    }
}
# 443[END]
LOCALSKELETONCONF
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variModuleName}-nginx:
    image: nginx:1.27.0
    container_name: ${variModuleName}-nginx
    volumes:
      - ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}:${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf:/etc/nginx/conf.d/default.conf
      - /usr/local/nginx/certbot/webroot:/etc/nginx/webroot:rw
      - /usr/local/nginx/certbot/config/live/skeleton.y-one.co.jp/fullchain.pem:/etc/nginx/ssl/fullchain.pem:ro
      - /usr/local/nginx/certbot/config/live/skeleton.y-one.co.jp/privkey.pem:/etc/nginx/ssl/privkey.pem:ro
    ports:
      - "80:80"
      - "443:443"
    networks:
      - common
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f skeleton-nginx
  docker compose down -v
  docker compose -p ${variModuleName} up --build -d
  docker ps -a | grep ${variModuleName}
  return 0
}

:<<'MARK'
[依賴]係統預裝：
ssh（[backend]include：haohaiyou_cicd / zengweitao_yx044r26）
omni.haohaiyou cloudPodReinit
MARK
function funcPublicCloudPodReinit(){
  local variBastionAccount=$(funcProtectedPullEncryptEnvi "BASTION_ACCOUNT")
  local variBastionIp=$(funcProtectedPullEncryptEnvi "BASTION_IP")
  local variBastionPort=$(funcProtectedPullEncryptEnvi "BASTION_PORT")
  local variSlaveAccount="ubuntu"
  local variSlaveIp="101.32.126.179"
  local variSlavePort="22"
  local variScpPath="/var/tmp"
  ssh -o StrictHostKeyChecking=no -A -p ${variBastionPort} -T ${variBastionAccount}@${variBastionIp} <<BASTIONEOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variSlaveIp} ..."
      echo "===================================================================================================="
      rm -rf ~/.ssh/known_hosts
      scp -P ${variSlavePort} -o StrictHostKeyChecking=no ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz ${variSlaveAccount}@${variSlaveIp}:${variScpPath}/
      scp -P ${variSlavePort} -o StrictHostKeyChecking=no ${variScpPath}/encrypt.envi ${variSlaveAccount}@${variSlaveIp}:${variScpPath}/
      ssh -o StrictHostKeyChecking=no -A -p ${variSlavePort} -T ${variSlaveAccount}@${variSlaveIp} "sudo bash -s" <<SLAVEEOF
        # --------------------------------------------------
        # envi[START]
        # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
        export DEBIAN_FRONTEND=noninteractive
        # envi[END]
        # --------------------------------------------------
        # ssh init[START]
        tar -xzvf ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
        mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
        touch ~/.ssh/config
        sed -i '/^StrictHostKeyChecking/d' ~/.ssh/config
        echo "StrictHostKeyChecking no" >> ~/.ssh/config
        # 需三重轉義，原因：雙層未加引號的「heredoc」會導致變量被解釋兩次
        chmod 600 ~/.ssh/* && chown \\\$(whoami):\\\$(whoami) ~/.ssh/*
        # ssh init[END]
        # --------------------------------------------------
        # omni.system init[START]
        if ! command -v git &> /dev/null; then
          apt-get update && apt-get install -y git
        fi
        mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime
        if [ -d "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/.git" ]; then
          cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
        else
          rm -rf ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
          mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
          cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
          git clone https://github.com/chunio/omni.git
          cd ./omni
        fi
        # ----------
        echo "[ omni ] git fetch origin ..."
        git fetch origin
        echo "[ omni ] git fetch origin finished"
        # ----------
        echo "[ omni ] git reset --hard origin/main ..."
        git reset --hard origin/main
        echo "[ omni ] git reset --hard origin/main finished"
        # ----------
        chmod 777 -R .
        ./init/system/system.sh init
        [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
        [ -f /etc/bashrc ] && source /etc/bashrc
        # omni.system init[END]
        # --------------------------------------------------
        /usr/bin/cp -rf ${variScpPath}/encrypt.envi ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/
        ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/haohaiyou.sh cloudCoscliReinit
        ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/haohaiyou.sh cloudTccliReinit
        # --------------------------------------------------
        history -c
SLAVEEOF
BASTIONEOF
  return 0
}


:<<'MARK'
兼容：centos && ubuntu
MARK
function funcPublicCloudUnicornReinit() {
  local variParameterDescMulti=(
    "module : dsp，adx"
    "branch : main，feature/.../..."
    "coscli : 1/able, 0/disable（default）"
  )
  funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variModule=$1
  local variModuleUpper=$(echo "${variModule}" | tr 'a-z' 'A-Z')
  local variBranch=$2
  local variAutoScalingStatus=${3:-0}
  local variBastionAccount=$(funcProtectedPullEncryptEnvi "BASTION_ACCOUNT")
  local variBastionIp=$(funcProtectedPullEncryptEnvi "BASTION_IP")
  local variBastionPort=$(funcProtectedPullEncryptEnvi "BASTION_PORT")
  local variScpStatus=1
  local variScpOnce=0
  local variScpPath="/var/tmp"
  local variHostMachineProjectPath="${VARI_GLOBAL["HOST_MACHINE_WORKSPACE_PATH"]}/repository/haohaiyou/unicorn"
  local variBinName="unicorn_${variModule}"
  local variBinMd5=$(md5sum ${variHostMachineProjectPath}/bin/${variBinName} | awk '{print $1}')
  # 統計「執行狀態」/1[START]
  local varSelectedCounter=0
  local variSucceededCounter=0
  local variFailedAbstract=""
  # 統計「執行狀態」/1[END]
  # 彈性伸縮/1[START]
  if [ ${variAutoScalingStatus} -eq 1 ]; then
    rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos
    mkdir -p ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos
    /usr/bin/cp -rf ${variHostMachineProjectPath}/bin/${variBinName} ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos/${variBinName}
  fi
  # 彈性伸縮/1[END]
  funcProtectedCloudSelector
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachOs=$(echo ${variEachValue} | awk '{print $9}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $10}')
    # 檢測目標節點環節是否支持當前模塊[START]
    variEachValueLower=$(echo "$variEachValue" | tr 'A-Z' 'a-z')
    if [[ $variEachValueLower != *${variModule}* && $variEachValueLower != *master* ]]; then
      echo "invalid selection : [ ${variEachValue} ]"
      continue
    fi
    # 檢測目標節點環節是否支持當前模塊[END]
    # 彈性伸縮/2[START]
    if [ ${variAutoScalingStatus} -eq 1 ]; then
      echo "${variBinMd5}#${variBranch}" > "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos/${variEachDomain}_${variModuleUpper}_${variEachService}_${variEachRegion}.envi"
    fi
    # 彈性伸縮/2[END]
    # 統計「執行狀態」/2[START]
    varSelectedCounter=$((varSelectedCounter + 1))
    # 統計「執行狀態」/2[END]
    # 自動兼容係統類型[START]
    local variEachSlaveAccount="root"
    local variEachSudoCommand=""
    local variEachGitInstallCommand="yum install -y git"
    if [[ "${variEachOs}" == "UBUNTU" ]]; then
      variEachSlaveAccount="ubuntu"
      variEachSudoCommand="sudo bash -s"
      variEachGitInstallCommand="apt-get update && apt-get install -y git"
    fi
    # 自動兼容係統類型[END]
    rm -rf ~/.ssh/known_hosts
    if [[ ${variScpStatus} -eq 1 && ${variScpOnce} -eq 0 ]]; then
      md5sum ${variHostMachineProjectPath}/bin/${variBinName}
      scp -P ${variBastionPort} -o StrictHostKeyChecking=no ${variHostMachineProjectPath}/bin/${variBinName} ${variBastionAccount}@${variBastionIp}:${variScpPath}/
      variScpOnce=1
    fi
    ssh -o StrictHostKeyChecking=no -A -p ${variBastionPort} -T ${variBastionAccount}@${variBastionIp} <<BASTIONEOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
      rm -rf ~/.ssh/known_hosts
      if [[ ${variScpStatus} -eq 1 ]]; then
        scp -P ${variEachPort} -o StrictHostKeyChecking=no ${variScpPath}/${variBinName} ${variEachSlaveAccount}@${variEachIp}:${variScpPath}/
        scp -P ${variEachPort} -o StrictHostKeyChecking=no ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz ${variEachSlaveAccount}@${variEachIp}:${variScpPath}/
        scp -P ${variEachPort} -o StrictHostKeyChecking=no ${variScpPath}/encrypt.envi ${variEachSlaveAccount}@${variEachIp}:${variScpPath}/
      fi
      ssh -o StrictHostKeyChecking=no -A -p ${variEachPort} -T ${variEachSlaveAccount}@${variEachIp} ${variEachSudoCommand} <<SLAVEEOF
        # --------------------------------------------------
        # （一）envi[START]
        # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
        export DEBIAN_FRONTEND=noninteractive
        # （一）envi[END]
        # --------------------------------------------------
        # （二）資源校驗[START]
        if [[ "\\\$(md5sum ${variScpPath}/${variBinName} | awk '{print \\\$1}')" != "${variBinMd5}" ]]; then
          echo "[ FATAL ] ${variBinMd5} md5 mismatch"
          exit 1
        fi
        # （二）資源校驗[END]
        # --------------------------------------------------
        # （三）ssh init[START]
        tar -xzvf ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
        mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
        touch ~/.ssh/config
        sed -i '/^StrictHostKeyChecking/d' ~/.ssh/config
        echo "StrictHostKeyChecking no" >> ~/.ssh/config
        # 需三重轉義，原因：雙層未加引號的「heredoc」會導致變量被解釋兩次
        chmod 600 ~/.ssh/* && chown \\\$(whoami):\\\$(whoami) ~/.ssh/*
        # （三）ssh init[END]
        # --------------------------------------------------
        # （四）omni.system init[START]
        if ! command -v git &> /dev/null; then
          ${variEachGitInstallCommand}
        fi
        mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime
        if [ -d "${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/.git" ]; then
          cd {VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
        else
          rm -rf {VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
          mkdir -p {VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
          cd {VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio
          git clone https://github.com/chunio/omni.git
          cd ./omni
        fi
        # ----------
        echo "[ omni ] git fetch origin ..."
        git fetch origin
        echo "[ omni ] git fetch origin finished"
        # ----------
        echo "[ omni ] git reset --hard origin/main ..."
        git reset --hard origin/main
        echo "[ omni ] git reset --hard origin/main finished"
        # ----------
        chmod 777 -R .
        ./init/system/system.sh init
        [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
        [ -f /etc/bashrc ] && source /etc/bashrc
        /usr/bin/cp -rf ${variScpPath}/encrypt.envi {VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/
        # （四）omni.system init[END]
        # --------------------------------------------------
        # （五）common[START]
        echo " ${variEachModule} ${variEachService} ${variEachLabel} ${variEachDomain} ${variEachRegion} ${variBranch}"
        {VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Common ${variModuleUpper} ${variEachService} ${variEachLabel} ${variEachDomain} ${variEachRegion} ${variBranch}
        # （五）common[END]
        # --------------------------------------------------
        exit \\\$?
SLAVEEOF
BASTIONEOF
    # 統計「執行狀態」/3[START]
    if [[ $? -eq 0 ]]; then
      variSucceededCounter=$((variSucceededCounter + 1))
      # 統計「執行狀態」/4[END]
    else
      variFailedAbstract="${variFailedAbstract} ${variEachIndex}(${variEachIp})"
    fi
    # 統計「執行狀態」/3[END]
  done
  # 彈性伸縮/3[START]
  if [ ${variAutoScalingStatus} -eq 1 ]; then
    # TODO:關閉所有動態機器
    omni.haohaiyou.sh cloudUnicornReinit_Ascli
  fi
  # 彈性伸縮/3[START]
  # 統計「執行狀態」/4[START]
  echo -e "\nsucceeded : ${variSucceededCounter}/${varSelectedCounter}\n"
  [[ -n "${variFailedAbstract}" ]] && echo -e "\nfailed : ${variFailedAbstract}\n"
  # 統計「執行狀態」/4[END]
  return 0
}

function funcPublicCloudUnicornReinit_Common() {
  local variParameterDescMulti=(
    "module : DSP，ADX"
    "service : BID，TRACK，MASTER"
    "label : 01，02，..."
    "domain : PADDLEWAVER，YONE"
    "region : SINGAPORE，USEAST"
    "branch : main，feature/.../..."
  )
  funcProtectedCheckRequiredParameter 6 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  # ----------
  local variModule=$1
  local variService=$2
  local variLabel=$3
  local variDomain=$4
  local variRegion=$5
  local variBranch=$6
  # ----------
  local variEnvi="PRODUCTION"
  local variScpPath="/var/tmp"
  local variCloudMachineProjectPath="${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/haohaiyou/uncorn"
  local variLaunchTimeout=30
  local variLaunchDuration=0
  # ----------
  local variBinName=$(echo "unicorn_${variModule}" | tr 'A-Z' 'a-z') # 確保小寫
  local variHttpPort=0
  local variGrpcPort=0
  case ${variModule} in
    "ADX")
        variHttpPort=8001
        variGrpcPort=9001
        ;;
    "DSP")
        variHttpPort=8000
        variGrpcPort=9000
        ;;
    *)
        return 1
        ;;
  esac
  # 自動兼容係統類型[START]
  local variOperatingSystem="centos"
  local variCrontabEnviUri="/var/spool/cron/root"
  local variCrontabReloadCommand="systemctl reload crond"
  [ -f /etc/os-release ] && variOperatingSystem=$(. /etc/os-release && echo "${ID}")
  case "${variOperatingSystem}" in
    "ubuntu")
      variCrontabEnviUri="/var/spool/cron/crontabs/root"
      variCrontabReloadCommand="systemctl restart cron"
      ;;
  esac
  # 自動兼容係統類型[END]
  # --------------------------------------------------
  # （一）envi[START]
  # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
  export DEBIAN_FRONTEND=noninteractive
  # （一）envi[END]
  # --------------------------------------------------
  # （二）unicorn[START]
  ulimit -n 655360
  docker rm -f unicorn 2> /dev/null
  if [ -d "${variCloudMachineProjectPath}/src/unicorn/.git" ]; then
    cd ${variCloudMachineProjectPath}/src/unicorn
    # ----------
    echo "[ unicorn ] git fetch origin ..."
    git fetch origin
    echo "[ unicorn ] git fetch origin finished"
    # ----------
    echo "[ unicorn ] git reset --hard origin/${variBranch} ..."
    git reset --hard origin/${variBranch}
    echo "[ unicorn ] git reset --hard origin/${variBranch} finished"
    # ----------
  else
    rm -rf ${variCloudMachineProjectPath}/src/unicorn
    mkdir -p ${variCloudMachineProjectPath}/src
    cd ${variCloudMachineProjectPath}/src
    git clone git@github.com:chunio/unicorn.git
    cd unicorn
    git checkout ${variBranch}
  fi
  ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/init/system/system.sh port ${variHttpPort} kill
  ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/init/system/system.sh port ${variGrpcPort} kill
  mkdir -p ./bin
  chmod 777 -R .
  /usr/bin/cp -rf ${variScpPath}/${variBinName} ./bin/${variBinName}
  echo "" > ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.command
  nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variService} -LABEL ${variLabel} -DOMAIN ${variDomain} -REGION ${variRegion} > ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.log 2>&1 &
  # ----------
  while true; do
    if grep -q ":${variHttpPort}" ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.log; then
      cat ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.log
      echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variService} -LABEL ${variLabel} -DOMAIN ${variDomain} -REGION ${variRegion} > ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.log 2>&1 & [success]"
      echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variService} -LABEL ${variLabel} -DOMAIN ${variDomain} -REGION ${variRegion} > ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.log 2>&1 &" > ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.command
      break
    elif grep -qE "failed|error|panic" ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.log; then
      cat ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.log
      exit 1
    elif [[ ${variLaunchDuration} -ge ${variLaunchTimeout} ]]; then
      echo "[ failed ] ${variBinName} launch exceeded ${variLaunchTimeout} second"
      cat ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/${variBinName}.log
      exit 1
    fi
    variLaunchDuration=$((variLaunchDuration + 1))
    sleep 1
  done
  # ----------
  # （二）unicorn[END]
  # --------------------------------------------------
  # （三）crontab[START]
  touch ${variCrontabEnviUri}
  # （1）supervisor/異常重啟[START]
  local variParameter=$(echo "${variDomain}/${variModule}/${variService}/${variRegion}/${variLabel}" | tr 'a-z' 'A-Z')
  if grep -Fq "cloudUnicornSupervisor ${variParameter}" "${variCrontabEnviUri}"; then
    # 注意：針對刪除命令（即：d），使用非標準界定符號時，需加「\」作爲指定，示例：\#（標準界定符號：/）
    sed -i "\#cloudUnicornSupervisor ${variParameter}#d" "${variCrontabEnviUri}"
  fi
  echo "* * * * * ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor ${variParameter} > /dev/null 2>&1" >> "${variCrontabEnviUri}"
  # （1）supervisor/異常重啟[END]
  # （2）僅限「variService=MASTER」[START]
  if [[ ${variService} == "MASTER" ]]; then
    if grep -Fq "cloudUnicornMinutelyCrontab" "${variCrontabEnviUri}"; then
      sed -i "/cloudUnicornMinutelyCrontab/d" "${variCrontabEnviUri}"
    fi
    echo "* * * * * ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornMinutelyCrontab > /dev/null 2>&1" >> "${variCrontabEnviUri}"
  fi
  # （2）僅限「variService=MASTER」[END]
  cat "${variCrontabEnviUri}"
  ${variCrontabReloadCommand}
  # （三）crontab[END]
  # --------------------------------------------------
  # （四）host[START]
  ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni/module/haohaiyou/haohaiyou.sh cloudHostReinit
  # （四）host[END]
  # --------------------------------------------------
  return 0
}

# auto scaling command-line interface
function funcPublicCloudUnicornReinit_Ascli(){
  omni.haohaiyou.sh cloudCoscliReinit
  omni.haohaiyou.sh cloudTccliReinit
  local variCosBucketName=$(funcProtectedPullEncryptEnvi "TENCENT_COS_BUCKET_NAME")
  local variCosBucket="cos://${variCosBucketName}"
  local variLocalPath="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos"
  # --------------------------------------------------
  # 上傳{配置文件 && 編譯程序}[START]
  for variEachEnviUri in $(find ${variLocalPath} -name "*.envi" -type f); do
    local variEachEnviName=$(basename "${variEachEnviUri}" .envi)
    local variEachCosRemotePath="unicorn/release/${variEachEnviName}"
    # ----------
    local variEachDomain=$(echo "${variEachEnviName}" | awk -F'_' '{print $1}')
    local variEachModule=$(echo "${variEachEnviName}" | awk -F'_' '{print $2}')
    local variEachService=$(echo "${variEachEnviName}" | awk -F'_' '{print $3}')
    local variEachRegion=$(echo "${variEachEnviName}" | awk -F'_' '{print $4}')
    # ----------
    local variEachBinName=$(echo "unicorn_${variEachModule}" | tr 'A-Z' 'a-z')
    local variEachBinMd5=$(cat "${variEachEnviUri}" | tr -d '[:space:]' | awk -F'#' '{print $1}')
    # ----------
    echo "coscli cp ${variLocalPath}/${variEachBinName} ${variCosBucket}/${variEachCosRemotePath}/${variEachBinName}.${variEachBinMd5}"
    coscli cp "${variLocalPath}/${variEachBinName}" "${variCosBucket}/${variEachCosRemotePath}/${variEachBinName}.${variEachBinMd5}" # || { echo "[ FATAL ] failed to upload ${variEachBinName}.${variEachBinMd5}"; continue; }
    echo "coscli cp ${variEachEnviUri} ${variCosBucket}/${variEachCosRemotePath}/${variEachEnviName}.envi"
    coscli cp "${variEachEnviUri}" "${variCosBucket}/${variEachCosRemotePath}/${variEachEnviName}.envi" #  || { echo "[ FATAL ] failed to upload ${variEachEnviName}.envi"; continue; }
    # ----------
    echo "[ coscli ] upload successful : ${variEachEnviName}.envi"
    echo "[ coscli ] upload successful : ${variEachBinName}.${variEachBinMd5}"
    # 保留5個「備份/執行文件」[START]
    # grep -v "\.envi" //排除配置
    # sort -r -k 5 //時間倒序（基於「coscli ls/返回表格」）
    # awk '{print $1}' //相對路徑
    local variBinSlice=$(coscli ls "${variCosBucket}/${variEachCosRemotePath}/" | grep "${variEachBinName}\." | grep -v "\.envi" | sort -r -k 5 | awk '{print $1}')
    local variBackupNum=5
    local variCounterIndex=0
    for variEachSuffixUri in ${variBinSlice}; do
      variCounterIndex=$((variCounterIndex + 1))
      if [[ ${variCounterIndex} -gt ${variBackupNum} ]]; then
        local variEachRemoteBinUri="cos://${variCosBucketName}/${variEachSuffixUri}"
        echo "[ coscli ] coscli rm -f ${variEachRemoteBinUri}"
        coscli rm -f "${variEachRemoteBinUri}" > /dev/null 2>&1
      fi
    done
    # 保留5個「備份/執行文件」[END]
    # --------------------------------------------------
    # 重建「彈性伸縮>>關聯實例」[START]
    local variEachRegionOption=""
    case ${variEachRegion} in
      "SINGAPORE")
          # [--region]「singapore」對應「ap-singapore」
          variEachRegionOption="ap-singapore"
          ;;
      "USEAST")
          # [--region]「virginia」對應「na-ashburn」
          variEachRegionOption="na-ashburn"
          ;;
      *)
          return 1
          ;;
    esac
    variEachAutoScalingGroupName=$(echo "deployment-${variEachDomain}-${variEachModule}-${variEachService}-${variEachRegion}" | tr 'A-Z' 'a-z')
    # 獲取「關聯實例」列表
    local variDescribeAutoScalingInstancesJson=$(tccli as DescribeAutoScalingInstances --region "${variEachRegionOption}" --Limit 100 2>/dev/null)
    local variInstanceIdSlice=$(echo "${variDescribeAutoScalingInstancesJson}" | python3 -c "import sys, json; data=json.load(sys.stdin); print(' '.join([i.get('InstanceId') for i in data.get('AutoScalingInstanceSet', []) if i.get('AutoScalingGroupName') == '${variEachAutoScalingGroupName}']))" 2>/dev/null)
    local variAutoScalingGroupId=$(echo "${variDescribeAutoScalingInstancesJson}" | python3 -c "import sys, json; data=json.load(sys.stdin); ids=[i.get('AutoScalingGroupId') for i in data.get('AutoScalingInstanceSet', []) if i.get('AutoScalingGroupName') == '${variEachAutoScalingGroupName}']; print(ids[0] if ids else '')" 2>/dev/null)
    local variInstanceNum=$(echo "${variInstanceIdSlice}" | wc -w)
    if [[ ${variInstanceNum} -gt 0 && -n "${variAutoScalingGroupId}" ]]; then
      # 構建「JSON/實例ID」[START]
      # 示例：'["ins-qk8c1vo7","ins-o9mbwxef"]'
      local variInstanceIdJson="["
      local variIndex=0
      for variEachInstanceId in ${variInstanceIdSlice}; do
        if [[ ${variIndex} -gt 0 ]]; then
          variInstanceIdJson="${variInstanceIdJson},"
        fi
        variInstanceIdJson="${variInstanceIdJson}\"${variEachInstanceId}\""
        variIndex=$((variIndex + 1))
      done
      variInstanceIdJson="${variInstanceIdJson}]"
      # 構建「JSON/實例ID」[END]
      # 批量刪除多個實例
      local variRemoveInstancesCommand="tccli cvm TerminateInstances --region \"${variEachRegionOption}\" --InstanceIds '${variInstanceIdJson}'"
      echo "[ tccli ] ${variRemoveInstancesCommand}"
      # 執行銷毀（「伸縮組」會自行拉起等量的「關聯實例」）
      # 禁止：local variRemoveInstancesResult=$(eval "${variRemoveInstancesCommand}" 2>&1)，否則後續「$?」會獲取「local/賦值語句」的執行結果
      local variRemoveInstancesResult
      variRemoveInstancesResult=$(eval "${variRemoveInstancesCommand}" 2>&1)
      if [[ $? -eq 0 ]]; then
        echo "[ tccli ] ${variEachAutoScalingGroupName} rebuild succeeded"
      else
        echo "[ tccli ] ${variEachAutoScalingGroupName} rebuild failed : ${variRemoveInstancesResult}"
      fi
    fi
    # 重建「彈性伸縮>>關聯實例」[END]
    # --------------------------------------------------
  done
  # 上傳{配置文件 && 編譯程序}[END]
  return 0
}

:<<'MARK'
[依賴]係統預裝：
ssh（[backend]include：haohaiyou_cicd）
omni.haohaiyou cloudPodReinit
# ----------
omni.haohaiyou cloudUnicornReinit_Dynamic PADDLEWAVER DSP BID SINGAPORE（√）
omni.haohaiyou cloudUnicornReinit_Dynamic PADDLEWAVER DSP BID USEAST（√）
omni.haohaiyou cloudUnicornReinit_Dynamic PADDLEWAVER ADX BID SINGAPORE（√）
omni.haohaiyou cloudUnicornReinit_Dynamic PADDLEWAVER ADX BID USEAST（√）
# ----------
omni.haohaiyou cloudUnicornReinit_Dynamic YONE DSP BID SINGAPORE
omni.haohaiyou cloudUnicornReinit_Dynamic YONE DSP BID USEAST
omni.haohaiyou cloudUnicornReinit_Dynamic YONE ADX BID SINGAPORE（√）
omni.haohaiyou cloudUnicornReinit_Dynamic YONE ADX BID USEAST
MARK
function funcPublicCloudUnicornReinit_Dynamic() {
  # --------------------------------------------------
  # omni.system init[START]
  mkdir -p ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}runtime
  cd ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/chunio/omni
  # ----------
  echo "[ omni ] git fetch origin ..."
  git fetch origin
  echo "[ omni ] git fetch origin finished"
  # ----------
  echo "[ omni ] git reset --hard origin/main ..."
  git reset --hard origin/main
  echo "[ omni ] git reset --hard origin/main finished"
  # ----------
  chmod 777 -R .
  ./init/system/system.sh init
  [ -f /etc/bashrc ] && source /etc/bashrc
  [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
  # omni.system init[END]
  # --------------------------------------------------
  local variParameterDescMulti=(
    "domain : PADDLEWAVER，YONE"
    "module : DSP，ADX"
    "service : BID，TRACK，MASTER"
    "region : SINGAPORE，USEAST"
  )
  funcProtectedCheckRequiredParameter 4 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variDomain=$1
  local variModule=$2
  local variService=$3
  local variRegion=$4
  local variEnvi="PRODUCTION"
  local variScpPath="/var/tmp"
  local variCosBucketName=$(funcProtectedPullEncryptEnvi "TENCENT_COS_BUCKET_NAME")
  local variCosBucket="cos://${variCosBucketName}"
  local variCosRemotePath="unicorn/release/${variDomain}_${variModule}_${variService}_${variRegion}"
  local variEnviFilename="${variDomain}_${variModule}_${variService}_${variRegion}.envi"
  local variBinName=$(echo "unicorn_${variModule}" | tr 'A-Z' 'a-z') # 確保小寫
  # --------------------------------------------------
  # envi[START]
  # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
  export DEBIAN_FRONTEND=noninteractive
  # ----------
  local variLabel=$(hostname -I 2>/dev/null | awk '{print $1}' | tr '.' 'P')
  [[ -z "${variLabel}" ]] && variLabel=$(echo "$(date +%s%N)${RANDOM}$$" | md5sum | awk '{print $1}' | tr 'a-z' 'A-Z')
  # ----------
  coscli cp ${variCosBucket}/${variCosRemotePath}/${variEnviFilename} ${variScpPath}/${variEnviFilename}
  # 「tr -d '[:space:]」表示移除空白符號（含：空格/換行/回車/製表）
  # 示例：9e141db7f404dae193a6d52fbc0e3210#main（md5#branch）
  local variEnviContent=$(cat ${variScpPath}/${variEnviFilename} | tr -d '[:space:]')
  local variRemoteBinMd5=$(echo "${variEnviContent}" | awk -F'#' '{print $1}')
  local variBranch=$(echo "${variEnviContent}" | awk -F'#' '{print $2}')
  # ----------
  coscli cp ${variCosBucket}/${variCosRemotePath}/${variBinName}.${variRemoteBinMd5} ${variScpPath}/${variBinName}
  local variLocalBinMd5=$(md5sum ${variScpPath}/${variBinName} | awk '{print $1}')
  chmod +x ${variScpPath}/${variBinName}
  # ----------
  local variFeishuTitle="${variDomain}/${variModule}/${variService}/${variRegion}/${variLabel}"
  if [[ "${variLocalBinMd5}" != "${variRemoteBinMd5}" ]]; then
    omni.haohaiyou feishu ${variFeishuTitle} "AUTO_SCALING_FAILED/BIN_MD5_UNMATCHED"
    return 1
  fi
 # ----------
  # envi[END]
  # common[START]
  omni.haohaiyou cloudUnicornReinit_Common ${variModule} ${variService} ${variLabel} ${variDomain} ${variRegion} ${variBranch}
  local variReturn=$?
  # common[END]
  if [[ ${variReturn} -eq 0 ]]; then
    omni.haohaiyou feishu ${variFeishuTitle} "AUTO_SCALING_SUCCEEDED"
  else
    omni.haohaiyou feishu ${variFeishuTitle} "AUTO_SCALING_FAILED/COMMON_RETURN_NOT0"
  fi
  return ${variReturn}
}

function funcPublicCloudUnicornCheck() {
  funcProtectedCloudSelector
  local variBastionAccount=$(funcProtectedPullEncryptEnvi "BASTION_ACCOUNT")
  local variBastionIp=$(funcProtectedPullEncryptEnvi "BASTION_IP")
  local variBastionPort=$(funcProtectedPullEncryptEnvi "BASTION_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    rm -rf /root/.ssh/known_hosts
    ssh -o StrictHostKeyChecking=no -A -p ${variBastionPort} -t ${variBastionAccount}@${variBastionIp} <<BASTIONEOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
      rm -rf /root/.ssh/known_hosts
      ssh -o StrictHostKeyChecking=no -p ${variEachPort} -t root@${variEachIp} <<SLAVEEOF
        tail -n 50 ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/runtime/unicorn_${variEachModule,,}.log
        # 按「文件大小」倒敘排序，取前10個
        ls -lhS ${VARI_GLOBAL["CLOUD_MACHINE_WORKSPACE_PATH"]}/repository/haohaiyou/unicorn/runtime | grep -v '^d' | head -n 11
        df -h
SLAVEEOF
BASTIONEOF
  done
  return 0
}

# (crontab -l 2>/dev/null; echo "* * * * * /workspace/repository/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor") | crontab -
# 更新腳本時無需重啟「crontab」
function funcPublicCloudUnicornSupervisor(){
  local variParameterDescMulti=("label ：PADDLEWAVER/ADX/BID/SINGAPORE/01")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variLabel=$1
  # 使用「/」分割 >> 提取第二的元素 >> 轉至小寫
  variModuleName=$(echo "${variLabel}" | cut -d'/' -f2 | tr 'A-Z' 'a-z')
  variHost="localhost"
  case ${variModuleName} in
    "adx")
        variHttpPort=8001
        variGrpcPort=9001
        ;;
    "dsp")
        variHttpPort=8000
        variGrpcPort=9000
        ;;
    *)
        return 1
        ;;
  esac
  variTimeout=${variTimeout:-1}
  variCurrentUtc0Datetime=$(date -u +"%Y-%m-%d %H:%M:%S")
  # check heartbeat[START]
  if timeout ${variTimeout} bash -c "</dev/tcp/${variHost}/${variHttpPort}" >/dev/null 2>&1; then
    echo "[ UTC0 : ${variCurrentUtc0Datetime} ] health check succeeded，${variHost}:${variHttpPort} is active" >> /workspace/runtime/supervisor.log
  else
    echo "[ UTC0 : ${variCurrentUtc0Datetime} ] health check failed，${variHost}:${variHttpPort} is inactive" >> /workspace/runtime/supervisor.log
    /workspace/repository/chunio/omni/module/haohaiyou/haohaiyou.sh feishu "${variLabel}" "HEALTH_CHECK_FAILED"
    # supervisor[START]
    /workspace/repository/chunio/omni/init/system/system.sh port ${variHttpPort} kill
    /workspace/repository/chunio/omni/init/system/system.sh port ${variGrpcPort} kill
    /usr/bin/cp -rf /workspace/runtime/unicorn_${variModuleName}.log /workspace/runtime/unicorn_${variModuleName}_$(date +%Y%m%d%H%M%S).log
    # /workspace/repository/chunio/omni/init/system/system.sh process unicorn kill
    cd /workspace/repository/haohaiyou/unicorn
    eval "$(cat /workspace/runtime/unicorn_${variModuleName}.command)"
    echo "[ UTC0 : ${variCurrentUtc0Datetime} ] health check action，${variHost}:${variHttpPort} is restart" >> /workspace/runtime/supervisor.log
    # supervisor[END]
  fi
  # check heartbeat[END]
  return 0
}

function funcPublicCloudHostReinit(){
  local variEtcHostsUri="/etc/hosts"
  local variIp2DomainSlice=(
    "172.22.0.51 sg.adx.paddlewaver.localhost.com"
    "10.0.0.24 us.adx.paddlewaver.localhost.com"
    "172.22.0.91 sg.dsp.paddlewaver.localhost.com"
    "10.0.0.29 us.dsp.paddlewaver.localhost.com"
    "172.22.0.67 sg.dsp.yone.localhost.com"
    "10.0.0.18 us.dsp.yone.localhost.com"
  )
  # /usr/bin/cp -rf "$variEtcHostsUri" "${variEtcHostsUri}.backup.$(date '+%Y%m%d%H%M%S')"
  local variEachRecord variDomain variIp
  for variEachRecord in "${variIp2DomainSlice[@]}"; do
    variIp=$(awk '{print $1}' <<< "$variEachRecord")
    variDomain=$(awk '{print $2}' <<< "$variEachRecord")
    if grep -qE "[[:space:]]${variDomain}([[:space:]]|$)" "$variEtcHostsUri"; then
      sed -i "/[[:space:]]${variDomain}\([[:space:]]\|$\)/d" "$variEtcHostsUri"
    fi
    echo "$variIp $variDomain" >> "$variEtcHostsUri"
    echo "$variEtcHostsUri << $variIp $variDomain"
  done
  return 0
}

# 含：sclick archived
function funcPublicCloudUnicornMinutelyCrontab(){
  local variExecuteId="EXECUTE_ID_$(date -u "+%Y%m%d_%H%M%S_%N")"
  local variKeywordUtc0DatehourStart=$(date -u -d "24 hours ago" "+%Y%m%d%H")
  local variKeywordUtc0DatehourEnd=$(date -u "+%Y%m%d%H")
  # local variKeywordUtc0DatehourEnd=$(date -u -d "1 hour ago" "+%Y%m%d%H")
  local variPath="/mnt/volume1/unicorn/runtime/"
  local variMethod="gzip"
  case ${variMethod} in
  "gzip")
      variOption="czf"
      variSuffix="tgz"
      ;;
  "bzip2")
      if ! command -v bzip2 >/dev/null 2>&1; then
        yum install -y bzip2
      fi
      variOption="cjf"
      variSuffix="bz2"
      ;;
  "xz")
      variOption="cJf"
      variSuffix="xz"
      ;;
  *)
      return 1
      ;;
  esac
  local variArchivedLockUri="/workspace/runtime/archived.lock"
  local variArchivedExitUri="/workspace/runtime/archived.exit"
  local variArchivedLogUri="/workspace/runtime/archived.log"
  if [ -f "${variArchivedLockUri}" ]; then
    # 鎖定文件大於2個小時則重置[START]
    local variCurrentTimestamp=$(date -u +%s)
    local variLockTimestamp=$(stat -c %Y "${variArchivedLockUri}" 2>/dev/null || echo "")
    if [ -n "$variLockTimestamp" ] && [ $((variCurrentTimestamp - variLockTimestamp)) -gt 7200 ];then
      rm -f "${variArchivedLockUri}"
    else
      echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] the last task did not completed" >> "${variArchivedLogUri}"
      return 0
    fi
    # 鎖定文件大於2個小時則重置[END]
  fi
  touch "${variArchivedLockUri}"
  echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} ACTION" >> "${variArchivedLogUri}"
  #「*bid-request*」相關日誌僅保留6個小時，超時刪除[START]
  local variBidRequestCustomHour=$(date -u -d "6 hours ago" "+%Y%m%d%H")
  find "${variPath}" -type f -name "*bid-request*" | while read -r variEachFileUri; do
    variEachFilename=$(basename "${variEachFileUri}")
    if [[ ${variEachFilename} =~ ([0-9]{10}) ]]; then
      variEachUtc0Datehour=${BASH_REMATCH[1]}
      if [[ ${variEachUtc0Datehour} =~ ^[0-9]{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])(0[0-9]|1[0-9]|2[0-3])$ ]]; then
        if [[ "${variEachUtc0Datehour}" -lt "${variBidRequestCustomHour}" ]]; then
          rm -rf "${variEachFileUri}"
          echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} ${variEachFileUri} DELETED" >> "${variArchivedLogUri}"
        fi
      fi 
    fi
  done
  #「*bid-request*」相關日誌僅保留6個小時，超時刪除[END]
  local variOrderByUtc0DatehourDescUri=$(mktemp)
  # ORDER BY「storage」DESC
  # find "${variPath}" -type f -name "*.log" -printf '%s %p\n' | sort -n | cut -d' ' -f2- | while read -r variEachFileUri; do
  find "${variPath}" -type f -name "*.log" | while read -r variEachFileUri; do
    variEachFilename=$(basename "${variEachFileUri}")
    if [[ $variEachFilename =~ ([0-9]{10}) ]]; then
      variEachUtc0Datehour=${BASH_REMATCH[1]}
      if [[ ${variEachUtc0Datehour} =~ ^[0-9]{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])(0[0-9]|1[0-9]|2[0-3])$ ]]; then
        if [[ "${variEachUtc0Datehour}" -ge "${variKeywordUtc0DatehourStart}" && "${variEachUtc0Datehour}" -lt "${variKeywordUtc0DatehourEnd}" ]]; then
          variEachArchivedUri="${variEachFileUri%.log}.${variSuffix}"
          if [[ ! -f "${variEachArchivedUri}" ]]; then
              # ll -lh "${variEachFileUri}"
              echo "${variEachUtc0Datehour} ${variEachFileUri} ${variEachArchivedUri}" >> "${variOrderByUtc0DatehourDescUri}"
          fi
        fi
      fi
    fi
  done
  # ORDER BY「variEachUtc0Datehour」DESC[START]
  sort -r -k1,1 "${variOrderByUtc0DatehourDescUri}" | while read -r variEachUtc0Datehour variEachFileUri variEachArchivedUri; do
    # exit signal monitor[START]
    if [ -f "${variArchivedExitUri}" ]; then
      echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} EXIT" >> "${variArchivedLogUri}"
      rm -rf "${variOrderByUtc0DatehourDescUri}" "${variArchivedLockUri}" "${variArchivedExitUri}"
      return 0
    fi
    # exit signal monitor[END]
    variEachStartTime=$(date +%s.%N)
    # include path
    echo "time tar -${variOption} ${variEachArchivedUri} -C ${variPath} $(basename ${variEachFileUri})"
    time tar -${variOption} ${variEachArchivedUri} -C ${variPath} "$(basename "${variEachFileUri}")"
    # case ${variCommand} in
    # "tar")
    #     echo "time tar -${variOption} ${variEachArchivedUri} ${variEachFileUri}"
    #     time tar -${variOption} ${variEachArchivedUri} ${variEachFileUri}
    #     ;;
    # "xz")
    #     #「-T0」：啟用多核（優點：關閉耗時:啟用耗時≈22:09，缺點：關閉負載:啟用耗時≈2.5:11.5）
    #     echo "time xz -${variOption} ${variEachFileUri} > ${variEachArchivedUri}"
    #     time xz -${variOption} ${variEachFileUri} > ${variEachArchivedUri}
    #     # xz -d ${variEachArchivedUri}
    #     ;;
    # *)
    #     return 1
    #     ;;
    # esac
    variEachEndTime=$(date +%s.%N)
    variEachDuration=$(echo "${variEachEndTime} - ${variEachStartTime}" | bc)
    variEachFileSize=$(echo "scale=2; $(stat -c%s "${variEachFileUri}")/1048576" | bc)
    variEachArchivedSize=$(echo "scale=2; $(stat -c%s "${variEachArchivedUri}")/1048576" | bc)
    echo "-> ${variEachDuration} / ${variEachFileSize}MB >> ${variEachArchivedSize}MB ${variEachArchivedUri}" succeeded >> "${variArchivedLogUri}"
  done
  # ORDER BY「variEachUtc0Datehour」DESC[END]
  echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} COMPLETED" >> "${variArchivedLogUri}"
  rm -rf "${variOrderByUtc0DatehourDescUri}" "${variArchivedLockUri}" "${variArchivedExitUri}"
  return 0
}

function funcPublicFeishu(){
  local variParameterDescMulti=("label" "message")
  funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variLabel=$1
  local variMessage=$2
  local variFeishuWebhook="https://open.feishu.cn/open-apis/bot/v2/hook/c10997f8-7322-452a-b7b7-bc36ded483c2"
  local variBody="{
    \"msg_type\": \"text\",
    \"content\": {
      \"text\": \"{\\\"label\\\":\\\"${variLabel}\\\",\\\"message\\\":\\\"${variMessage}\\\"}\"
    }
  }"
  echo $(curl -s -X POST -H "Content-Type: application/json" -d "${variBody}" "${variFeishuWebhook}")
  return 0
}

function funcPublicCdUnicornRuntime(){
  cd /workspace/repository/haohaiyou/unicorn/runtime
  pwd
  df -h
  ls -lh
  return 0
}

function funcPublicTailUnicornTrack(){
  cd /workspace/repository/haohaiyou/unicorn/runtime
  pwd
  df -h
  echo "tail -f *-track-$(date -u +%Y%m%d).log"
  tail -f *-track-$(date -u +%Y%m%d).log
  return 0
}

# 僅使用於「[騰訊雲]對象存儲」
function funcPublicCloudCoscliReinit(){
  local variTencentAccountSecretId=$(funcProtectedPullEncryptEnvi "TENCENT_ACCOUNT_SECRET_ID")
  local variTencentAccountSecretKey=$(funcProtectedPullEncryptEnvi "TENCENT_ACCOUNT_SECRET_KEY")
  local variTencentCosBucketName=$(funcProtectedPullEncryptEnvi "TENCENT_COS_BUCKET_NAME")
  local variTencentCosBucketEndpoint=$(funcProtectedPullEncryptEnvi "TENCENT_COS_BUCKET_ENDPOINT")
  if ! command -v coscli &> /dev/null; then
    wget https://cosbrowser.cloud.tencent.com/software/coscli/coscli-linux-amd64 -O /usr/local/bin/coscli
    chmod +x /usr/local/bin/coscli
  fi
  cat > ${HOME}/.cos.yaml <<EOF
cos:
  base:
    secretid: ${variTencentAccountSecretId}
    secretkey: ${variTencentAccountSecretKey}
    sessiontoken: ""
    protocol: https
    disableencryption: false
    disableautofetchbuckettype: false
    closeautoswitchhost: false
  buckets:
    - name: ${variTencentCosBucketName}
      endpoint: ${variTencentCosBucketEndpoint}
EOF
  # chmod +x /usr/local/bin/coscli
  if coscli ls cos://${variTencentCosBucketName}; then
    echo "the coscli connection succeeded"
    return 0
  else
    echo "the coscli connection failed"
    return 1
  fi
}

# 僅使用於「[騰訊雲]命令行工具」
function funcPublicCloudTccliReinit(){
  local variTencentAccountSecretId=$(funcProtectedPullEncryptEnvi "TENCENT_ACCOUNT_SECRET_ID")
  local variTencentAccountSecretKey=$(funcProtectedPullEncryptEnvi "TENCENT_ACCOUNT_SECRET_KEY")
  if ! command -v tccli &> /dev/null; then
    if ! command -v pip3 &> /dev/null; then
      if command -v yum &> /dev/null; then
        yum install -y python3 python3-pip
      elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y python3-pip
      else
        echo "no package manager found, please install python3-pip manually"
        return 1
      fi
    fi
    # --break-system-packages：centos7.9無需， ubuntu24.04需要
    pip3 install tccli -q 2>/dev/null || pip3 install tccli --break-system-packages -q
  fi
  mkdir -p ${HOME}/.tccli
  cat > ${HOME}/.tccli/default.credential <<EOF
{
    "secretId": "${variTencentAccountSecretId}",
    "secretKey": "${variTencentAccountSecretKey}"
}
EOF
  cat > ${HOME}/.tccli/default.configure <<EOF
{
    "region": "ap-singapore",
    "output": "json"
}
EOF
  if tccli as DescribeAutoScalingGroups --Limit 1 &> /dev/null; then
    echo "the tccli connection succeeded"
    return 0
  else
    echo "the tccli connection failed"
    return 1
  fi
}

# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"