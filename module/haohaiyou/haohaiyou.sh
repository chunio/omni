#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<'MARK'
cd /windows/code/backend/chunio/omni && find . -type f -exec dos2unix {} \;
/windows/code/backend/chunio/omni/init/system/system.sh init
# ----------
# [示例]將當前腳本的目標函數[聲明/定義]拷貝至遠端 && 執行函數
# about : funcProtectedTemplate
function funcPublicTemplate() {
    ssh -t root@xxxx 'bash -s' <<EOF
$(typeset -f funcProtectedTemplate)
funcProtectedTemplate
exec \$SHELL
EOF
}
# ----------
# [批量]模糊删除（替換：customKeywork）
EVAL "local cursor='0'; local deleted=0; repeat local result=redis.call('SCAN',cursor,'MATCH','*customKeywork*'); cursor=result[1]; for _,key in ipairs(result[2]) do redis.call('DEL',key); deleted=deleted+1; end; until cursor=='0'; return deleted" 0
# ----------
# 擴展存儲[START]
[ext4]
lsblk
yum install -y cloud-utils-growpart
growpart /dev/vda 1
resize2fs /dev/vda1
df -h /dev/vda1
# 擴展存儲[END]
# ----------
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="MASTER"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# global variable[START]

# global variable[END]
# local variable[START]
# VARI_CLOUD_OLD=(
#   # ==================================================
#   # jump[START]
#   "000 INDEX HONGKONG -00 119.28.55.124 22"
#   # jump[END]
#   # ==================================================
#   # common[START]
#   "001 MIX/COMMON SINGAPORE -01 43.133.61.186 22"
#   "002 MIX/COMMON USEAST -01 43.130.116.28 22"
#   "003 ADX/COMMON SINGAPORE IPTABLE 43.156.140.171 22"
#   "004 ADX/COMMON USEAST IPTABLE 170.106.132.12 22"
#   # common[END]
#   # notice[START]
#   "101 DSP/NOTICE01 SINGAPORE -01 101.32.165.195 22"
#   "102 DSP/NOTICE02 SINGAPORE -02 43.153.194.242 22"
#   "103 DSP/NOTICE01 USEAST -01 43.130.106.95 22"
#   "104 DSP/NOTICE02 USEAST -02 170.106.14.178 22"
#   # notice[END]
#   # bid[START]
#   "105 DSP/BID01 SINGAPORE IPTABLE 43.134.241.241 22"
#   "106 DSP/BID02 SINGAPORE -02 119.28.114.114 22"
#   "107 DSP/BID03 SINGAPORE -03 43.156.43.47 22"
#   "108 DSP/BID04 SINGAPORE -04 43.133.43.225 22"
#   "109 DSP/BID01 USEAST IPTABLE 43.130.90.22 22"
#   "200 DSP/BID02 USEAST -02 43.130.108.36 22" 
#   # bid[END]
#   # ==================================================
#   # notice[START]
#   "201 ADX/NOTICE01 SINGAPORE -01 119.28.122.140 22"
#   "202 ADX/NOTICE02 SINGAPORE -02 101.32.126.189 22"
#   "203 ADX/NOTICE01 USEAST -01 170.106.160.191 22"
#   "204 ADX/NOTICE02 USEAST -02 43.130.108.190 22"
#   # notice[END]
#   # bid[START]
#   "205 ADX/BID01 SINGAPORE -01 43.134.74.106 22"
#   "206 ADX/BID02 SINGAPORE -02 101.32.254.10 22"
#   "207 ADX/BID03 SINGAPORE -03 43.159.52.147 22"
#   "208 ADX/BID01 USEAST -01 43.130.66.178 22"
#   "209 ADX/BID02 USEAST -02 170.106.165.51 22"
#   "210 ADX/BID03 USEAST -03 170.106.9.32 22"
#   # bid[END]
#   # ==================================================
# )
VARI_PADDLEWAVER_CLOUD=(
  # ==================================================
  # jumper
  "000 JUMPER -- -- -- HONGKONG 119.28.55.124 22 --"
  "001 MIX IPTABLE 01 MIX SINGAPORE 43.156.140.171 22 --"
  "002 MIX IPTABLE 01 MIX USEAST 170.106.132.12 22 --"
  # ==================================================
  # common
  "101 MIX COMMON 01 PADDLEWAVER SINGAPORE 43.133.61.186 22 hyperf/kratos"
  "102 MIX COMMON 01 PADDLEWAVER USEAST 43.130.116.28 22 hyperf/kratos"
  # ==================================================
  # adx
  "201 ADX NOTICE 01 PADDLEWAVER SINGAPORE 119.28.122.140 22 --"
  "202 ADX NOTICE 02 PADDLEWAVER SINGAPORE 101.32.126.189 22 --"
  "203 ADX NOTICE 01 PADDLEWAVER USEAST 170.106.160.191 22 --"
  "204 ADX NOTICE 02 PADDLEWAVER USEAST 43.130.108.190 22 --"
  "205 ADX BID 01 PADDLEWAVER SINGAPORE 43.134.74.106 22 --"
  "206 ADX BID 02 PADDLEWAVER SINGAPORE 101.32.254.10 22 --"
  "207 ADX BID 03 PADDLEWAVER SINGAPORE 43.159.52.147 22 --"
  "208 ADX BID 01 PADDLEWAVER USEAST 43.130.66.178 22 --"
  "209 ADX BID 02 PADDLEWAVER USEAST 170.106.165.51 22 --"
  "210 ADX BID 03 PADDLEWAVER USEAST 170.106.9.32 22 --"
  # ==================================================
  # dsp
  "301 DSP NOTICE 01 PADDLEWAVER SINGAPORE 101.32.165.195 22 --"
  "302 DSP NOTICE 02 PADDLEWAVER SINGAPORE 43.153.194.242 22 --"
  "303 DSP NOTICE 01 PADDLEWAVER USEAST 43.130.106.95 22 --"
  "304 DSP NOTICE 02 PADDLEWAVER USEAST 170.106.14.178 22 --"
  "305 DSP BID 01 PADDLEWAVER SINGAPORE 43.134.241.241 22 iptable"
  "306 DSP BID 02 PADDLEWAVER SINGAPORE 119.28.114.114 22 --"
  "307 DSP BID 03 PADDLEWAVER SINGAPORE 43.156.43.47 22 --"
  "308 DSP BID 04 PADDLEWAVER SINGAPORE 43.133.43.225 22 --"
  "309 DSP BID 01 PADDLEWAVER USEAST 43.130.90.22 22 iptable"
  "310 DSP BID 02 PADDLEWAVER USEAST 43.130.108.36 22 --" 
  # ==================================================
)
VARI_YONE_CLOUD=(
  # ==================================================
  # jumper
  "000 JUMPER -- -- -- HONGKONG 119.28.55.124 22 --"
  "001 MIX IPTABLE 01 MIX SINGAPORE 43.156.140.171 22 --"
  "002 MIX IPTABLE 01 MIX USEAST 170.106.132.12 22 --"
  # ==================================================
  # common
  "101 MIX COMMON 01 YONE SINGAPORE 43.134.87.222 22 hyperf/kratos"
  "102 MIX COMMON 01 YONE USEAST 43.130.147.251 22 hyperf/kratos"
  # ==================================================
  # adx
  "201 ADX NOTICE 01 YONE SINGAPORE 43.159.51.144 22 --"
  "202 ADX NOTICE 02 YONE SINGAPORE 43.133.63.172 22 --"
  "203 ADX NOTICE 01 YONE USEAST 43.130.148.210 22 --"
  "204 ADX NOTICE 02 YONE USEAST 43.130.132.19 22 --"
  "205 ADX BID 01 YONE SINGAPORE 43.156.0.206 22 --"
  "206 ADX BID 02 YONE SINGAPORE 43.134.87.59 22 --"
  "207 ADX BID 01 YONE USEAST 43.130.134.51 22 --"
  "208 ADX BID 02 YONE USEAST 43.166.247.44 22 --"
  # ==================================================
  # dsp
  "301 DSP NOTICE 01 YONE SINGAPORE 43.133.37.4 22 --"
  "302 DSP NOTICE 02 YONE SINGAPORE 129.226.95.66 22 --"
  "303 DSP NOTICE 01 YONE USEAST 43.166.247.136 22 --"
  "304 DSP NOTICE 02 YONE USEAST 43.166.226.222 22 --"
  "305 DSP BID 01 YONE SINGAPORE 43.134.49.186 22 --"
  "306 DSP BID 02 YONE SINGAPORE 43.134.32.190 22 --"
  "307 DSP BID 01 YONE USEAST 43.166.254.65 22 --"
  "308 DSP BID 02 YONE USEAST 43.166.254.61 22 --" 
  # ==================================================
)
# local variable[END]
# ##################################################

# ##################################################
# protected function[START]

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicSkeleton(){
  # [MASTER]persistence
  variMasterPath="/windows/code/backend/haohaiyou"
  # [DOCKER]temporary
  variDockerWorkSpace="/windows/code/backend/haohaiyou"
  veriModuleName="skeleton"
  # variImagePattern=${1:-"hyperf/hyperf:8.3-alpine-v3.19-swoole-5.1.3"}
  variImagePattern=${1:-"chunio/php:8.3.12"}
    cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/bin/bash
# 會被「docker run」中指定命令覆蓋
return 0
ENTRYPOINTSH
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${veriModuleName}:
    image: ${variImagePattern}
    container_name: ${veriModuleName}
    volumes:
      - /windows:/windows
      - /mnt:/mnt
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    working_dir: ${variDockerWorkSpace}/gopath/src/${veriModuleName}
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
  docker-compose down -v
  docker-compose -p ${veriModuleName} up --build -d
  docker update --restart=always ${veriModuleName}
  docker ps -a | grep ${veriModuleName}
  cd ${variMasterPath}/gopath/src/${veriModuleName}
  docker exec -it ${veriModuleName} /bin/bash
  return 0
}

# [已驗證/官方容器]成功啟動
# function funcPublicUnicorn()
# {
#   variMasterPath="/windows/code/backend/haohaiyou"
#   variDockerWorkSpace="/windows/code/backend/haohaiyou"
#   variModuleName="unicorn"
#   mkdir -p ${variMasterPath}/{gopath,gocache.linux,gocache.windows}
#   mkdir -p ${variMasterPath}/gopath{/bin,/pkg,/src}
#   cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
# services:
#   ${variModuleName}:
#     image: golang:1.22.4
#     container_name: ${variModuleName}
#     environment:
#       - GOENV=/windows/code/backend/golang/go.env.linux
#       - PATH=$PATH:/usr/local/go/bin:${variDockerWorkSpace}/gopath/bin
#     volumes:
#       - /windows/code/backend/haohaiyou/go.env.linux:/windows/code/backend/golang/go.env.linux
#       - /windows/code/backend/haohaiyou:/windows/code/backend/golang
#     working_dir: /windows/code/backend/golang/gopath/src/${variModuleName}
#     networks:
#       - common
#     command: ["tail", "-f", "/dev/null"]
# networks:
#   common:
#     driver: bridge
# DOCKERCOMPOSEYML
#   cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
#   docker-compose down -v
#   docker-compose -p ${variModuleName} up --build -d
#   docker update --restart=always ${variModuleName}
#   docker ps -a | grep ${variModuleName}
#   cd ${variMasterPath}/gopath/src/${variModuleName}
#   docker exec -it ${variModuleName} /bin/bash
#   return 0
# }

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
  variMasterPath="/windows/code/backend/haohaiyou"
  variDockerWorkSpace="/windows/code/backend/haohaiyou"
  veriModuleName="unicorn"
  docker rm -f ${veriModuleName} 2> /dev/null
  mkdir -p ${variMasterPath}/{gopath,gocache.linux,gocache.windows}
  mkdir -p ${variMasterPath}/gopath{/bin,/pkg,/src}
  rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/bin/bash
# 會被「docker run」中指定命令覆蓋
touch /etc/bashrc
chmod 644 /etc/bashrc
# /windows/code/backend/chunio/omni/init/system/system.sh init && source /etc/bashrc
# 禁止「return」
# return 0
ENTRYPOINTSH
  rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux
  cat <<GOENVLINUX > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux
CGO_ENABLED=0
GO111MODULE=on
GOBIN=${variDockerWorkSpace}/gopath/bin
GOCACHE=${variDockerWorkSpace}/gocache.linux
GOMODCACHE=${variDockerWorkSpace}/gopath/pkg/mod
GOPATH=${variDockerWorkSpace}/gopath
GOPROXY=https://goproxy.cn,direct
GOROOT=/usr/local/go
GOSUMDB=sum.golang.google.cn
GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
GOENVLINUX
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${veriModuleName}:
    image: chunio/go:1.22.4
    container_name: ${veriModuleName}
    environment:
      - GOENV=/go.env.linux
      - PATH=$PATH:/usr/local/go/bin:${variDockerWorkSpace}/gopath/bin
    volumes:
      - /windows:/windows
      - /mnt:/mnt
      # - ${BUILTIN_UNIT_CLOUD_PATH}/bin:${variDockerWorkSpace}/gopath/bin
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux:/go.env.linux
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    working_dir: ${variDockerWorkSpace}/gopath/src/${veriModuleName}
    networks:
      - common
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
  docker-compose down -v
  docker-compose -p ${veriModuleName} up --build -d
  docker update --restart=always ${veriModuleName}
  docker ps -a | grep ${veriModuleName}
  cd ${variMasterPath}/gopath/src/${veriModuleName}
  docker exec -it ${veriModuleName} /bin/bash
  return 0
}

# from : funcPublicRebuildImage()
function funcPublic1224EnvironmentInit(){
  # 更新倉庫[START]
  #「centos7.9」已停止維護（截止2024/06/30），官方倉庫 ：mirrorlist.centos.org >> vault.centos.org
  sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo
  # 更新倉庫[END]
  yum install -y git make graphviz
  # wget https://go.dev/dl/go1.22.4.linux-amd64.tar.gz -O ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/go1.22.4.linux-amd64.tar.gz
  tar -xvf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/go1.22.4.linux-amd64.tar.gz -C /usr/local
  variWorkPath="/windows/code/backend"
  mkdir -p ${variWorkPath}
  mkdir -p ${variWorkPath}/golang/{gopath,gocache.linux,gocache.windows}
  mkdir -p ${variWorkPath}/golang/gopath{/bin,/pkg,/src}
  cat <<GOENVLINUX > ${variWorkPath}/golang/go.env.linux
CGO_ENABLED=0
GO111MODULE=on
GOBIN=${variWorkPath}/golang/gopath/bin
GOCACHE=${variWorkPath}/golang/gocache.linux
GOMODCACHE=${variWorkPath}/golang/gopath/pkg/mod
GOPATH=${variWorkPath}/golang/gopath
GOPROXY=https://goproxy.cn,direct
GOROOT=/usr/local/go
GOSUMDB=sum.golang.google.cn
GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
GOENVLINUX
  cat <<ETCBASHRC >> /etc/bashrc
export PATH=$PATH:/usr/local/go/bin:${variWorkPath}/golang/gopath/bin
export GOENV=${variWorkPath}/golang/go.env.linux
ETCBASHRC
  #  mkdir -p ${variWorkPath}/chunio
  #  git clone https://github.com/chunio/omni.git
  #  cd ${variWorkPath}/chunio/omni
  #  chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
  cp -rf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/bin/* ${variWorkPath}/golang/gopath/bin/
  ulimit -n 102400
  return 0
}

function funcPublicRebuildImage(){
  # 構建鏡像[START]
  variParameterDescList=("image pattern（example ：chunio/go:1.22.4）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=${1-"chunio/go:1.22.4"}
  variContainerName="go1224Environment"
  docker builder prune --all -f
  docker rm -f ${variContainerName} 2> /dev/null
  docker rmi -f $variImagePattern 2> /dev/null
  # 鏡像不存在時自動執行：docker pull $variImageName
  docker run -d --privileged --name ${variContainerName} -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /windows:/windows --tmpfs /run --tmpfs /run/lock -p 80:80 centos:7.9.2009 /sbin/init
  docker exec -it ${variContainerName} /bin/bash -c "cd ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]} && ./$(basename "${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]}") 1224EnvironmentInit;"
  variContainerId=$(docker ps --filter "name=${variContainerName}" --format "{{.ID}}")
  echo "docker commit $variContainerId $variImagePattern"
  docker commit $variContainerId $variImagePattern
  docker ps --filter "name=${variContainerName}"
  docker images --filter "reference=${variImagePattern}"
  echo "${FUNCNAME} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "docker exec -it ${variContainerName} /bin/bash" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}

function funcPublicCloudIndex(){
  local variParameterDescMulti=("domain : pw，yone")
  funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
  variDomainName=${1:-"pw"}
  declare -a variSelectedCloud
  case ${variDomainName} in
    "pw")
        variSelectedCloud=("${VARI_PADDLEWAVER_CLOUD[@]}")
        ;;
    "yone")
        variSelectedCloud=("${VARI_YONE_CLOUD[@]}")
        ;;
    *)
        return 1
        ;;
  esac
  #（1）初始展示
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "DESC" 
  for variEachValue in "${variSelectedCloud[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachModule=$(echo $variEachValue | awk '{print $2}')
    variEachService=$(echo $variEachValue | awk '{print $3}')
    variEachLabel=$(echo $variEachValue | awk '{print $4}')
    variEachDomain=$(echo $variEachValue | awk '{print $5}')
    variEachRegion=$(echo $variEachValue | awk '{print $6}')
    variEachIp=$(echo $variEachValue | awk '{print $7}')
    variEachPort=$(echo $variEachValue | awk '{print $8}')
    variEachDesc=$(echo $variEachValue | awk '{print $9}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachDesc"
  done
  read -p "enter the index to connect : " variInput
  if [[ ! $variInput =~ ^[0-9]+$ ]]; then
    echo "error : expect a index"
    return 1
  fi
  for variEachMasterValue in "${variSelectedCloud[@]}"; do
    if [[ $variMasterValue == *" JUMPER "* ]]; then
      variJumperIp=$(echo $variEachMasterValue | awk '{print $7}')
      variJumperPort=$(echo $variEachMasterValue | awk '{print $8}')
      break
    fi
  done
  for variEachSlaveValue in "${variSelectedCloud[@]}"; do
    variEachSlaveIndex=$(echo $variEachSlaveValue | awk '{print $1}')
    variEachSlaveIp=$(echo $variEachSlaveValue | awk '{print $7}')
    variEachSlavePort=$(echo $variEachSlaveValue | awk '{print $8}')
    if [[ 10#$variEachSlaveIndex -eq 10#$variInput ]]; then
      echo "----------------------------------------------------------------------------------------------------"
      echo ">> [ SLAVE ] ${variEachSlaveValue} ..."
      echo "----------------------------------------------------------------------------------------------------"
      # 配置一層[SSH]秘鑰
      # ssh -o StrictHostKeyChecking=no -J root@${variEachMasterIP}:${variEachMasterPort} root@${variSlaveIp} -p ${variSlavePort}
      # 配置二層[SSH]秘鑰
      echo "ssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -p ${variJumperPort} root@${variJumperIp}" root@${variEachSlaveIp} -p ${variEachSlavePort}"
      ssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -p ${variJumperPort} root@${variJumperIp}" root@${variEachSlaveIp} -p ${variEachSlavePort}
      rm -rf /root/.ssh/known_hosts
      return 0
    fi
  done
  echo "error : invalid index ($variInput)"
  return 1
}

# jump server init[START]
# scp /windows/code/backend/chunio/omni/module/haohaiyou/runtime/omni.haohaiyou.cloud.ssh.tgz root@159.89.116.79:/
# ssh root@159.89.116.79
# tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
# mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
# echo "StrictHostKeyChecking no" > ~/.ssh/config
# chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
# jump server init[END]

function funcPublicCloudIndexInit() {
  variMasterKeyword="INDEX"
  for variMasterValue in "${VARI_CLOUD[@]}"; do
    if [[ $variMasterValue == *" ${variMasterKeyword} "* ]]; then
      variEachMasterLabel=$(echo $variMasterValue | awk '{print $2}')
      variEachMasterIP=$(echo $variMasterValue | awk '{print $5}')
      variEachMasterPort=$(echo $variMasterValue | awk '{print $6}')
      break
    fi
  done
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  scp -P ${variEachMastrPort} -o StrictHostKeyChecking=no /windows/code/backend/chunio/omni/module/haohaiyou/runtime/omni.haohaiyou.cloud.ssh.tgz ${variJumperAccount}@${variEachMasterIP}:/
:<<MARK
# [manual]ssh init[START]
tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
echo "StrictHostKeyChecking no" > ~/.ssh/config
chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
# [manual]ssh init[END]
MARK
  return 0
}

function funcPublicCloudSkeletonRinit() {
  local variParameterDescMulti=("domain : pw，yone" "branch : main（default），feature/zengweitao/example")
  funcProtectedCheckOptionParameter 2 variParameterDescMulti[@]
  variDomainName=${1:-"pw"}
  variBranchName=${2:-"main"}
  declare -a variSelectedCloud
  case ${variDomainName} in
    "pw")
        variSelectedCloud=("${VARI_PADDLEWAVER_CLOUD[@]}")
        ;;
    "yone")
        variSelectedCloud=("${VARI_YONE_CLOUD[@]}")
        ;;
    *)
        return 1
        ;;
  esac
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  #（1）初始展示
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "DESC" 
  for variEachValue in "${variSelectedCloud[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachModule=$(echo $variEachValue | awk '{print $2}')
    variEachService=$(echo $variEachValue | awk '{print $3}')
    variEachLabel=$(echo $variEachValue | awk '{print $4}')
    variEachDomain=$(echo $variEachValue | awk '{print $5}')
    variEachRegion=$(echo $variEachValue | awk '{print $6}')
    variEachIp=$(echo $variEachValue | awk '{print $7}')
    variEachPort=$(echo $variEachValue | awk '{print $8}')
    variEachDesc=$(echo $variEachValue | awk '{print $9}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachDesc"
  done
  #（2）模糊匹配
  echo -n "enter the keyword to match: "
  read variSlaveKeyword
  echo "matched (${variSlaveKeyword}):"
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "DESC" 
  variAllIndexSlice=""
  for variEachValue in "${variSelectedCloud[@]}"; do
    if [[ $variEachValue == *"${variSlaveKeyword}"* ]]; then
      # 採集當前頁面的全部索引[START]
      variAllIndexSlice="${variAllIndexSlice} $(echo $variEachValue | awk '{print $1}')"
      # 採集當前頁面的全部索引[END]
      variEachIndex=$(echo $variEachValue | awk '{print $1}')
      variEachModule=$(echo $variEachValue | awk '{print $2}')
      variEachService=$(echo $variEachValue | awk '{print $3}')
      variEachLabel=$(echo $variEachValue | awk '{print $4}')
      variEachDomain=$(echo $variEachValue | awk '{print $5}')
      variEachRegion=$(echo $variEachValue | awk '{print $6}')
      variEachIp=$(echo $variEachValue | awk '{print $7}')
      variEachPort=$(echo $variEachValue | awk '{print $8}')
      variEachDesc=$(echo $variEachValue | awk '{print $9}')
      printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachDesc"
    fi
  done
  #（3）精準選擇
  echo -n "enter the index/number ( 0:當前頁面的全部 / 支持多個,空格間隔 ) : "
  read -a variInputIndexSlice
  if [[ ${variInputIndexSlice} -eq 0 ]]; then
    variInputIndexSlice=(${variAllIndexSlice})
    echo "index : ${variInputIndexSlice[@]}"
  else
    echo "index : ${variInputIndexSlice[@]}"
  fi
  read -p "type「confirm」to continue : " variInput
  # variInputLower=$(echo "$variInput" | tr '[:upper:]' '[:lower:]')
  # if [[ "$variInputLower" != "confirm" ]]; then
  if [[ "$variInput" != "confirm" ]]; then
    return 1
  fi
  for variEachMasterValue in "${variSelectedCloud[@]}"; do
    if [[ $variEachMasterValue == *" JUMPER "* ]]; then
      variJumperIp=$(echo $variEachMasterValue | awk '{print $7}')
      variJumperPort=$(echo $variEachMasterValue | awk '{print $8}')
      for variEachInputIndex in "${variInputIndexSlice[@]}"; do
        for variEachSlaveValue in "${variSelectedCloud[@]}"; do
          variEachSlaveIndex=$(echo $variEachSlaveValue | awk '{print $1}')
          if [[ $variEachSlaveIndex == ${variEachInputIndex} ]]; then
            variEachSlaveService=$(echo $variEachSlaveValue | awk '{print $3}')
            variEachSlaveLabel=$(echo $variEachSlaveValue | awk '{print $4}')
            variEachSlaveDomain=$(echo $variEachSlaveValue | awk '{print $5}')
            variEachSlaveRegion=$(echo $variEachSlaveValue | awk '{print $6}')
            variEachSlaveIp=$(echo $variEachSlaveValue | awk '{print $7}')
            variEachSlavePort=$(echo $variEachSlaveValue | awk '{print $8}')
            echo "===================================================================================================="
            echo ">> [ JUMPER ] ${variEachMasterValue} ..."
            echo "===================================================================================================="
            rm -rf /root/.ssh/known_hosts
            ssh -o StrictHostKeyChecking=no -p ${variJumperPort} -t root@${variJumperIp} <<JUMPEREOF
              # //TODO：send SHUTDOWN/signal to redis pub/sub
              echo "----------------------------------------------------------------------------------------------------"
              echo ">> [ SLAVE ] ${variEachSlaveValue} ..."
              echo "----------------------------------------------------------------------------------------------------"
              rm -rf /root/.ssh/known_hosts
              scp -P ${variEachSlavePort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachSlaveIp}:/
              ssh -o StrictHostKeyChecking=no -p ${variEachSlavePort} -t root@${variEachSlaveIp} <<SLAVEEOF
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
                mkdir -p /windows/runtime
                if [ -d "/windows/code/backend/chunio/omni" ]; then
                  cd /windows/code/backend/chunio/omni
                  echo "[ omni ] git fetch origin ..."
                  git fetch origin
                  echo "[ omni ] git fetch origin finished"
                  echo "[ omni ] git reset --hard origin/main ..."
                  git reset --hard origin/main
                  echo "[ omni ] git reset --hard origin/main finished"
                  chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                else
                  mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
                  git clone https://github.com/chunio/omni.git
                  cd ./omni && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                fi
                #（2）omni.system init[END]
                # --------------------------------------------------
                #（3）slave main[START]
                docker rm -f skeleton 2> /dev/null
                if [ -d "/windows/code/backend/haohaiyou/gopath/src/skeleton" ]; then
                  cd /windows/code/backend/haohaiyou/gopath/src/skeleton
                  echo "[ skeleton ] git fetch origin ..."
                  git fetch origin
                  echo "[ skeleton ] git fetch origin finished"
                  # -----
                  echo "[ skeleton ] git reset --hard origin/${variBranchName} ..."
                  git reset --hard origin/${variBranchName}
                  echo "[ skeleton ] git reset --hard origin/${variBranchName} finished"
                  # -----
                else
                  mkdir -p /windows/code/backend/haohaiyou/gopath/src && cd /windows/code/backend/haohaiyou/gopath/src
                  git clone git@github.com:chunio/skeleton.git && cd skeleton
                  git checkout ${variBranchName}
                fi
                chmod 777 -R .
                echo "/usr/bin/cp -rf .env.production.${variEachSlaveDomain}.${variEachSlaveRegion} .env"
                /usr/bin/cp -rf .env.production.${variEachSlaveDomain}.${variEachSlaveRegion} .env
                expect -c '
                set timeout -1
                spawn /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh skeleton
                expect "skeleton"
                send "composer install\r"
                expect "skeleton"
                send "nohup php bin/hyperf.php start > /windows/runtime/skeleton.log 2>&1 &\r"
                expect "skeleton"
                send "exit\r"
                expect eof
                '
                #（3）slave main[END]
                # --------------------------------------------------
SLAVEEOF
JUMPEREOF
          fi
        done
      done
    fi
  done
  return 0
}

function funcPublicCloudUnicornReinit() {
  local variParameterDescMulti=("module : dsp，adx" "domain : pw, yone" "branch : main，feature/zengweitao/example")
  funcProtectedCheckRequiredParameter 3 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variModuleName=$1
  variDomainName=$2
  variBranchName=$3
  variEnvi="PRODUCTION"
  variBinName="unicorn_${variModuleName}"
  variScpAble=1
  variScpSyncOnce=0
  variJumperAccount="root"
  # slave variable[START]
  # systemctl reload crond
  variSlaveCrontabUri="/var/spool/cron/root"
  variSlaveCrontabTask="* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor ${variModuleName}"
  # slave variable[END]
  # ----------
  # variHttpPort=8000
  # variGrpcPort=9000
  case ${variModuleName} in
    "adx")
        variHttpPort=8000
        variGrpcPort=9000
        ;;
    "dsp")
        variHttpPort=8001
        variGrpcPort=9001
        ;;
    *)
        return 1
        ;;
  esac
  declare -a variSelectedCloud
  case ${variDomainName} in
    "pw")
        variSelectedCloud=("${VARI_PADDLEWAVER_CLOUD[@]}")
        ;;
    "yone")
        variSelectedCloud=("${VARI_YONE_CLOUD[@]}")
        ;;
    *)
        return 1
        ;;
  esac
  # ----------
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  #（1）初始展示
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "DESC" 
  for variEachValue in "${variSelectedCloud[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachModule=$(echo $variEachValue | awk '{print $2}')
    variEachService=$(echo $variEachValue | awk '{print $3}')
    variEachLabel=$(echo $variEachValue | awk '{print $4}')
    variEachDomain=$(echo $variEachValue | awk '{print $5}')
    variEachRegion=$(echo $variEachValue | awk '{print $6}')
    variEachIp=$(echo $variEachValue | awk '{print $7}')
    variEachPort=$(echo $variEachValue | awk '{print $8}')
    variEachDesc=$(echo $variEachValue | awk '{print $9}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachDesc"
  done
  #（2）模糊匹配
  echo -n "enter the keyword to match: "
  read variSlaveKeyword
  echo "matched (${variSlaveKeyword}):"
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "DESC" 
  variAllIndexSlice=""
  for variEachValue in "${variSelectedCloud[@]}"; do
    if [[ $variEachValue == *"${variSlaveKeyword}"* ]]; then
      # 採集當前頁面的全部索引[START]
      variAllIndexSlice="${variAllIndexSlice} $(echo $variEachValue | awk '{print $1}')"
      # 採集當前頁面的全部索引[END]
      variEachIndex=$(echo $variEachValue | awk '{print $1}')
      variEachModule=$(echo $variEachValue | awk '{print $2}')
      variEachService=$(echo $variEachValue | awk '{print $3}')
      variEachLabel=$(echo $variEachValue | awk '{print $4}')
      variEachDomain=$(echo $variEachValue | awk '{print $5}')
      variEachRegion=$(echo $variEachValue | awk '{print $6}')
      variEachIp=$(echo $variEachValue | awk '{print $7}')
      variEachPort=$(echo $variEachValue | awk '{print $8}')
      variEachDesc=$(echo $variEachValue | awk '{print $9}')
      printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachDesc"
    fi
  done
  #（3）精準選擇
  echo -n "enter the index/number ( 0:當前頁面的全部 / 支持多個,空格間隔 ) : "
  read -a variInputIndexSlice
  if [[ ${variInputIndexSlice} -eq 0 ]]; then
    variInputIndexSlice=(${variAllIndexSlice})
    echo "index : ${variInputIndexSlice[@]}"
  else
    echo "index : ${variInputIndexSlice[@]}"
  fi
  read -p "type「confirm」to continue : " variInput
  # variInputLower=$(echo "$variInput" | tr '[:upper:]' '[:lower:]')
  # if [[ "$variInputLower" != "confirm" ]]; then
  if [[ "$variInput" != "confirm" ]]; then
    return 1
  fi
  for variEachMasterValue in "${variSelectedCloud[@]}"; do
    if [[ $variEachMasterValue == *" JUMPER "* ]]; then
      variJumperIp=$(echo $variEachMasterValue | awk '{print $7}')
      variJumperPort=$(echo $variEachMasterValue | awk '{print $8}')
      for variEachInputIndex in "${variInputIndexSlice[@]}"; do
        for variEachSlaveValue in "${variSelectedCloud[@]}"; do
          variEachSlaveIndex=$(echo $variEachSlaveValue | awk '{print $1}')
          if [[ $variEachSlaveIndex == ${variEachInputIndex} ]]; then
            variEachSlaveService=$(echo $variEachSlaveValue | awk '{print $3}')
            variEachSlaveLabel=$(echo $variEachSlaveValue | awk '{print $4}')
            variEachSlaveDomain=$(echo $variEachSlaveValue | awk '{print $5}')
            variEachSlaveRegion=$(echo $variEachSlaveValue | awk '{print $6}')
            variEachSlaveIp=$(echo $variEachSlaveValue | awk '{print $7}')
            variEachSlavePort=$(echo $variEachSlaveValue | awk '{print $8}')
            echo "===================================================================================================="
            echo ">> [ JUMPER ] ${variEachMasterValue} ..."
            echo "===================================================================================================="
            rm -rf /root/.ssh/known_hosts
            if [[ ${variScpAble} -eq 1 ]]; then
              if [[ ${variScpSyncOnce} -eq 0 ]]; then
                md5sum /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName}
                scp -P ${variJumperPort} -o StrictHostKeyChecking=no /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName} ${variJumperAccount}@${variJumperIp}:/
                variScpSyncOnce=1
              fi 
            fi
            ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -t ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
              echo "----------------------------------------------------------------------------------------------------"
              echo ">> [ SLAVE ] ${variEachSlaveValue} ..."
              echo "----------------------------------------------------------------------------------------------------"
              rm -rf /root/.ssh/known_hosts
              if [[ ${variScpAble} -eq 1 ]]; then
                scp -P ${variEachSlavePort} -o StrictHostKeyChecking=no /${variBinName} root@${variEachSlaveIp}:/
                scp -P ${variEachSlavePort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachSlaveIp}:/
              fi
              ssh -o StrictHostKeyChecking=no -A -p ${variEachSlavePort} -t root@${variEachSlaveIp} <<SLAVEEOF
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
                mkdir -p /windows/runtime
                if [ -d "/windows/code/backend/chunio/omni" ]; then
                  cd /windows/code/backend/chunio/omni
                  echo "[ omni ] git fetch origin ..."
                  git fetch origin
                  echo "[ omni ] git fetch origin finished"
                  echo "[ omni ] git reset --hard origin/main ..."
                  git reset --hard origin/main
                  echo "[ omni ] git reset --hard origin/main finished"
                  chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                else
                  mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
                  git clone https://github.com/chunio/omni.git
                  cd ./omni && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                fi
                #（2）omni.system init[END]
                # --------------------------------------------------
                #（3）slave main[START]
                ulimit -n 655360
                docker rm -f unicorn 2> /dev/null
                if [ -d "/windows/code/backend/haohaiyou/gopath/src/unicorn" ]; then
                  cd /windows/code/backend/haohaiyou/gopath/src/unicorn
                  # ----
                  echo "[ unicorn ] git fetch origin ..."
                  git fetch origin
                  echo "[ unicorn ] git fetch origin finished"
                  # -----
                  echo "[ unicorn ] git reset --hard origin/${variBranchName} ..."
                  git reset --hard origin/${variBranchName}
                  echo "[ unicorn ] git reset --hard origin/${variBranchName} finished"
                  # -----
                else
                  mkdir -p /windows/code/backend/haohaiyou/gopath/src && cd /windows/code/backend/haohaiyou/gopath/src
                  git clone git@github.com:chunio/unicorn.git && cd unicorn
                  git checkout ${variBranchName}
                fi
                /windows/code/backend/chunio/omni/init/system/system.sh showPort ${variHttpPort} confirm
                /windows/code/backend/chunio/omni/init/system/system.sh showPort ${variGrpcPort} confirm
                # /windows/code/backend/chunio/omni/init/system/system.sh matchKill unicorn
                mkdir -p ./bin && chmod 777 -R .
                /usr/bin/cp -rf /${variBinName} ./bin/${variBinName} 
                echo "" > /windows/runtime/${variBinName}.command
                nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachSlaveService} -DOMAIN ${variEachSlaveDomain} -REGION ${variEachSlaveRegion} > /windows/runtime/${variBinName}.log 2>&1 &
                (
                  while true; do
                    if grep -q ":${variHttpPort}" /windows/runtime/${variBinName}.log; then
                      cat /windows/runtime/${variBinName}.log
                      echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachSlaveService} -DOMAIN ${variEachSlaveDomain} -REGION ${variEachSlaveRegion} > /windows/runtime/${variBinName}.log 2>&1 & [success]"
                      echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachSlaveService} -DOMAIN ${variEachSlaveDomain} -REGION ${variEachSlaveRegion} > /windows/runtime/${variBinName}.log 2>&1 &" > /windows/runtime/${variBinName}.command
                      break
                    elif grep -qE "failed|error|panic" /windows/runtime/${variBinName}.log; then
                      cat /windows/runtime/${variBinName}.log
                      break
                    fi
                    sleep 1
                  done
                ) # &
                # unicorn[END]
                # supervisor[START]
                if grep -Fq "${variSlaveCrontabTask}" "${variSlaveCrontabUri}"; then
                  echo "[ virtual/supervisor ] crontab is active"
                else
                  echo "${variSlaveCrontabTask}" >> "${variSlaveCrontabUri}"
                  echo "[ virtual/supervisor ] crontab init succeeded"
                fi
                cat "${variSlaveCrontabUri}"
                systemctl reload crond
                # supervisor[END]
                md5sum /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName}
                #（3）slave main[END]
                # --------------------------------------------------
SLAVEEOF
JUMPEREOF
          fi
        done
      done
    fi
  done
  return 0
}


function funcPublicCloudIptableReinit(){
  # local variParameterDescMulti=("event : singapore，virginia")
  # funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  # variEvent=$1
  variJumperAccount="root"
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "LABEL" "REGION" "MEMO" "IP" "PORT" 
  for variEachValue in "${VARI_CLOUD[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachLabel=$(echo $variEachValue | awk '{print $2}')
    variEachRegion=$(echo $variEachValue | awk '{print $3}')
    variEachMemo=$(echo $variEachValue | awk '{print $4}')
    variEachIp=$(echo $variEachValue | awk '{print $5}')
    variEachPort=$(echo $variEachValue | awk '{print $6}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachLabel" "$variEachRegion" "${variEachMemo}" "$variEachIp" "$variEachPort"
  done
  echo -n "enter the 「LABEL」 keyword to match : "
  read variSlaveKeyword
  echo "matched (${variSlaveKeyword}) : "
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "LABEL" "REGION" "MEMO" "IP" "PORT"
  for variEachValue in "${VARI_CLOUD[@]}"; do
    if [[ $variEachValue == *"${variSlaveKeyword}"* ]]; then
      variEachIndex=$(echo $variEachValue | awk '{print $1}')
      variEachLabel=$(echo $variEachValue | awk '{print $2}')
      variEachRegion=$(echo $variEachValue | awk '{print $3}')
      variEachMemo=$(echo $variEachValue | awk '{print $4}')
      variEachIp=$(echo $variEachValue | awk '{print $5}')
      variEachPort=$(echo $variEachValue | awk '{print $6}')
      printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachLabel" "$variEachRegion" "${variEachMemo}" "$variEachIp" "$variEachPort"
    fi
  done
  echo -n "enter the [number]index ( 空格間隔 ) : "
  read -a variInputIndexList
  variMasterKeyword="INDEX"
  for variMasterValue in "${VARI_CLOUD[@]}"; do
    if [[ $variMasterValue == *" ${variMasterKeyword} "* ]]; then
      variEachMasterLabel=$(echo $variMasterValue | awk '{print $2}')
      variEachMastrRegion=$(echo $variMasterValue | awk '{print $3}')
      variEachMastrMemo=$(echo $variMasterValue | awk '{print $4}')
      variEachMasterIP=$(echo $variMasterValue | awk '{print $5}')
      variEachMastrPort=$(echo $variMasterValue | awk '{print $6}')
      for variEachInputIndex in "${variInputIndexList[@]}"; do
        for variSlaveValue in "${VARI_CLOUD[@]}"; do
          variEachIndex=$(echo $variSlaveValue | awk '{print $1}')
          if [[ $variEachIndex == ${variEachInputIndex} ]]; then
            variEachSlaveLabel=$(echo $variSlaveValue | awk '{print $2}')
            variEachSlaveRegion=$(echo $variSlaveValue | awk '{print $3}')
            variEachSlaveMemo=$(echo $variSlaveValue | awk '{print $4}')
            variEachSlaveIP=$(echo $variSlaveValue | awk '{print $5}')
            variEachSlavePort=$(echo $variSlaveValue | awk '{print $6}')
            echo "initiate connection: [${variEachMasterLabel} / ${variEachMastrRegion} / ${variEachMastrMemo}] ${variEachMasterIP}:${variEachMastrPort} ..."
            rm -rf /root/.ssh/known_hosts
            ssh -o StrictHostKeyChecking=no -A -p ${variEachMastrPort} -t ${variJumperAccount}@${variEachMasterIP} <<MASTEREOF
              echo "initiate connection: [${variEachSlaveLabel} / ${variEachSlaveRegion} / ${variEachSlaveMemo}] ${variEachSlaveIP}:${variEachSlavePort} ..."
              rm -rf /root/.ssh/known_hosts
              scp -P ${variEachSlavePort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachSlaveIP}:/
              ssh -o StrictHostKeyChecking=no -A -p ${variEachSlavePort} -t root@${variEachSlaveIP} <<'SLAVEEOF'
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
                mkdir -p /windows/runtime
                if [ -d "/windows/code/backend/chunio/omni" ]; then
                  cd /windows/code/backend/chunio/omni
                  echo "[ omni ] git fetch origin ..."
                  git fetch origin
                  echo "[ omni ] git fetch origin finished"
                  echo "[ omni ] git reset --hard origin/main ..."
                  git reset --hard origin/main
                  echo "[ omni ] git reset --hard origin/main finished"
                  chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                else
                  mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
                  git clone https://github.com/chunio/omni.git
                  cd ./omni && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                fi
                #（2）omni.system init[END]
                # --------------------------------------------------
                # （3）slave main[START]
                case ${variEachSlaveRegion} in
                  "SINGAPORE")
                    # adx[START]
                    # variLanSlice=(
                    #   "redis/common 172.22.0.18 6379"
                    #   "redis/table 172.22.0.80 7379"
                    #   "clickhouse/http 172.22.0.21 8123"
                    #   "clickhouse/tcp 172.22.0.21 9000"
                    #   "clickhouse/mysql 172.22.0.21 9004"
                    # )
                    # adx[END]
                    # dsp[START]
                    variLanSlice=(
                      "redis/common 172.22.0.13 6379"
                      "redis/table 172.22.0.48 7379"
                      "clickhouse/http 172.22.0.20 8123"
                      "clickhouse/tcp 172.22.0.20 9000"
                      "clickhouse/mysql 172.22.0.20 9004"
                    )
                    # dsp[END]
                    ;;
                  "USEAST")
                    # adx[START]
                    variLanSlice=(
                      "redis/common 10.0.0.14 6379"
                      "redis/table 10.0.0.9 7379"
                    )
                    # adx[END]
                    # dsp[START]
                    variLanSlice=(
                      "redis/common 10.0.0.10 6379"
                      "redis/table 10.0.0.4 7379"
                    )
                    # dsp[END]
                    ;;
                  *)
                    echo "error : lan not found"
                    exit 1
                    ;;
                esac
                # declare -p variLanSlice
                # 清空規則
                iptables -t nat -F
                iptables -F FORWARD
                iptables -P FORWARD ACCEPT
                # 追加規則
                for variEachLan in "\${variLanSlice[@]}"; do
                  read -r variEachLabel variEachIP variEachPort <<< "\${variEachLan}"
                  echo 1 > /proc/sys/net/ipv4/ip_forward
                  iptables -t nat -A PREROUTING -p tcp --dport \${variEachPort} -j DNAT --to-destination \${variEachIP}:\${variEachPort}
                  iptables -t nat -A POSTROUTING -d \${variEachIP} -p tcp --dport \${variEachPort} -j MASQUERADE
                  # iptables -t nat -A POSTROUTING -d \${variEachIP} -p tcp --dport \${variEachPort} -j SNAT --to-source 172.22.0.45
                done
                # 查看規則
                iptables -t nat -L -n -v
                # （3）slave main[END]
                # --------------------------------------------------
SLAVEEOF
MASTEREOF
          fi
        done
      done
    fi
  done
  return 0
}

function funcPublicCloudUnicornCheck() {
  local variParameterDescMulti=("domain : pw，yone")
  funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
  variDomainName=${1:-"pw"}
  variJumperAccount="root"
  declare -a variSelectedCloud
  case ${variDomainName} in
    "pw")
        variSelectedCloud=("${VARI_PADDLEWAVER_CLOUD[@]}")
        ;;
    "yone")
        variSelectedCloud=("${VARI_YONE_CLOUD[@]}")
        ;;
    *)
        return 1
        ;;
  esac
  #（1）初始展示
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "DESC" 
  for variEachValue in "${variSelectedCloud[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachModule=$(echo $variEachValue | awk '{print $2}')
    variEachService=$(echo $variEachValue | awk '{print $3}')
    variEachLabel=$(echo $variEachValue | awk '{print $4}')
    variEachDomain=$(echo $variEachValue | awk '{print $5}')
    variEachRegion=$(echo $variEachValue | awk '{print $6}')
    variEachIp=$(echo $variEachValue | awk '{print $7}')
    variEachPort=$(echo $variEachValue | awk '{print $8}')
    variEachDesc=$(echo $variEachValue | awk '{print $9}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachDesc"
  done
  #（2）模糊匹配
  echo -n "enter the keyword to match: "
  read variSlaveKeyword
  echo "matched (${variSlaveKeyword}):"
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "DESC" 
  variAllIndexSlice=""
  for variEachValue in "${variSelectedCloud[@]}"; do
    if [[ $variEachValue == *"${variSlaveKeyword}"* ]]; then
      # 採集當前頁面的全部索引[START]
      variAllIndexSlice="${variAllIndexSlice} $(echo $variEachValue | awk '{print $1}')"
      # 採集當前頁面的全部索引[END]
      variEachIndex=$(echo $variEachValue | awk '{print $1}')
      variEachModule=$(echo $variEachValue | awk '{print $2}')
      variEachService=$(echo $variEachValue | awk '{print $3}')
      variEachLabel=$(echo $variEachValue | awk '{print $4}')
      variEachDomain=$(echo $variEachValue | awk '{print $5}')
      variEachRegion=$(echo $variEachValue | awk '{print $6}')
      variEachIp=$(echo $variEachValue | awk '{print $7}')
      variEachPort=$(echo $variEachValue | awk '{print $8}')
      variEachDesc=$(echo $variEachValue | awk '{print $9}')
      printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachDesc"
    fi
  done
  #（3）精準選擇
  echo -n "enter the index/number ( 0:當前頁面的全部 / 支持多個,空格間隔 ) : "
  read -a variInputIndexSlice
  if [[ ${variInputIndexSlice} -eq 0 ]]; then
    variInputIndexSlice=(${variAllIndexSlice})
    echo "index : ${variInputIndexSlice[@]}"
  else
    echo "index : ${variInputIndexSlice[@]}"
  fi
  read -p "type「confirm」to continue : " variInput
  # variInputLower=$(echo "$variInput" | tr '[:upper:]' '[:lower:]')
  # if [[ "$variInputLower" != "confirm" ]]; then
  if [[ "$variInput" != "confirm" ]]; then
    return 1
  fi
  for variEachMasterValue in "${variSelectedCloud[@]}"; do
    if [[ $variEachMasterValue == *" JUMPER "* ]]; then
      variJumperIp=$(echo $variEachMasterValue | awk '{print $7}')
      variJumperPort=$(echo $variEachMasterValue | awk '{print $8}')
      for variEachInputIndex in "${variInputIndexSlice[@]}"; do
        for variEachSlaveValue in "${variSelectedCloud[@]}"; do
          variEachSlaveIndex=$(echo $variEachSlaveValue | awk '{print $1}')
          if [[ $variEachSlaveIndex == ${variEachInputIndex} ]]; then
            variEachSlaveIp=$(echo $variEachSlaveValue | awk '{print $7}')
            variEachSlavePort=$(echo $variEachSlaveValue | awk '{print $8}')
            # echo "===================================================================================================="
            # echo ">> [ JUMPER ] ${variEachMasterValue} ..."
            # echo "===================================================================================================="
            rm -rf /root/.ssh/known_hosts
            ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -t ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
              echo "===================================================================================================="
              echo ">> [ SLAVE ] ${variEachSlaveValue} ..."
              echo "===================================================================================================="
              rm -rf /root/.ssh/known_hosts
              ssh -o StrictHostKeyChecking=no -p ${variEachSlavePort} -t root@${variEachSlaveIp} <<SLAVEEOF
                tail -n 50 /windows/runtime/unicorn_*.log
                # 按「文件大小」倒敘排序，取前10個
                ls -lhS /windows/code/backend/haohaiyou/gopath/src/unicorn/runtime | grep -v '^d' | head -n 11
                df -h
SLAVEEOF
JUMPEREOF
          fi
        done
      done
    fi
  done
  return 0
}

function funcPublicCdUnicornRuntime(){
  cd /windows/code/backend/haohaiyou/gopath/src/unicorn/runtime
  pwd
  ll -lh
  return 0
}

function funcPublicTailUnicornNotice(){
  cd /windows/code/backend/haohaiyou/gopath/src/unicorn/runtime
  echo "tail -f notice-$(date -u +%Y%m%d).log"
  tail -f notice-$(date -u +%Y%m%d).log
  return 0
}

# 將「80」端口轉發至「9501」端口
function funcPublic80(){
  veriModuleName="skeleton"
  variCurrentIp=$(hostname -I | awk '{print $1}')
  cat <<LOCALSKELETONCONF > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf
server {
    listen 80;
    server_name _;
    location /report/adx {
        proxy_pass http://${variCurrentIp}:9501/report/adx;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
LOCALSKELETONCONF
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${veriModuleName}-nginx:
    image: nginx:1.27.0
    container_name: ${veriModuleName}-nginx
    volumes:
      - /windows:/windows
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
  docker-compose down -v
  docker-compose -p ${veriModuleName} up --build -d
  docker ps -a | grep ${veriModuleName}
  return 0
}

# example: funcPublicUnicornRestart "production" "CODE/BID01" "SINGAPORE"
function funcPublicUnicornRestart(){
  variEnviLabel=${1}
  variNodeLabel=${2}
  variNodeRegion=${3}
  /windows/code/backend/chunio/omni/init/system/system.sh showPort 8000 confirm &&
  /windows/code/backend/chunio/omni/init/system/system.sh showPort 9000 confirm && 
  cd /windows/code/backend/haohaiyou/gopath/src/unicorn &&
  nohup ./bin/unicorn_exec -ENVI_LABEL ${variEnviLabel} -LABEL ${variNodeLabel} -REGION ${variNodeRegion} > /windows/runtime/unicorn.log 2>&1 &
  # supervisor[START]
  yum install -y epel-release
  yum install -y supervisor
  cat <<UNICORNSUPERVISORCONF > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/unicorn_supervisor.conf
[program:unicorn_supervisor]
command=/bin/bash -c '/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh unicornRestart "${variEnviLabel}" "${variNodeLabel}" "${variNodeRegion}"'
directory=/windows/code/backend/chunio/omni
user=root
autostart=true
autorestart=true
startretries=10
exitcodes=0
stopsignal=TERM
stopwaitsecs=10
redirect_stderr=true
stdout_logfile=/windows/runtime/unicorn_supervisor_stdout.log
stderr_logfile=/windows/runtime/unicorn_supervisor_stderr.log
stdout_logfile_maxbytes=1024MB
stdout_logfile_backups=10
stderr_logfile_maxbytes=1024MB
stderr_logfile_backups=10
UNICORNSUPERVISORCONF
  # supervisor[END]
  return 0
}

# (crontab -l 2>/dev/null; echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudSkeletonSupervisor") | crontab -
# 更新腳本時無需重啟「crontab」
# function funcPublicCloudSkeletonSupervisor(){
#   variHost="localhost"
#   variPort=9501
#   timeout=${timeout:-1}
#   variCurrentDate=$(date -u +"%Y-%m-%d %H:%M:%S")
#   # check heartbeat[START]
#   if timeout ${timeout} bash -c "</dev/tcp/${variHost}/${variPort}" >/dev/null 2>&1; then
#     echo "[ ${variCurrentDate} / ${variPort} ] health check succeeded，${variHost}:${variPort} is active" >> /windows/runtime/supervisor.log
#   else
#     echo "[ ${variCurrentDate} / ${variPort} ] health check failed，${variHost}:${variPort} is inactive" >> /windows/runtime/supervisor.log
#     # supervisor[START]
#     /windows/code/backend/chunio/omni/common/docker/docker.sh matchKill unicorn
#     cd /windows/code/backend/haohaiyou/gopath/src/unicorn
#     eval "$(cat /windows/runtime/command.variable)"
#     echo "[ ${variCurrentDate} ] health check action，${variHost}:${variPort} is restart" >> /windows/runtime/supervisor.log
#     # supervisor[END]
#   fi
#   # check heartbeat[END]
#   return 0
# }

# (crontab -l 2>/dev/null; echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor") | crontab -
# 更新腳本時無需重啟「crontab」
function funcPublicCloudUnicornSupervisor(){
  local variParameterDescMulti=("module name : dsp，adx")
  funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
  variModuleName=${1:-"dsp"}
  variHost="localhost"
  variHttpPort=8000
  variGrpcPort=9000
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
        variHttpPort=8000
        variGrpcPort=9000
        ;;
  esac
  variTimeout=${variTimeout:-1}
  variCurrentDate=$(date -u +"%Y-%m-%d %H:%M:%S")
  # check heartbeat[START]
  if timeout ${variTimeout} bash -c "</dev/tcp/${variHost}/${variHttpPort}" >/dev/null 2>&1; then
    echo "[ ${variCurrentDate} / ${variHttpPort} ] health check succeeded，${variHost}:${variHttpPort} is active" >> /windows/runtime/supervisor.log
  else
    echo "[ ${variCurrentDate} / ${variHttpPort} ] health check failed，${variHost}:${variHttpPort} is inactive" >> /windows/runtime/supervisor.log
    # supervisor[START]
    /windows/code/backend/chunio/omni/init/system/system.sh showPort ${variHttpPort} confirm
    /windows/code/backend/chunio/omni/init/system/system.sh showPort ${variGrpcPort} confirm
    # /windows/code/backend/chunio/omni/init/system/system.sh matchKill unicorn
    cd /windows/code/backend/haohaiyou/gopath/src/unicorn
    eval "$(cat /windows/runtime/unicorn_${variModuleName}.command)"
    echo "[ ${variCurrentDate} ] health check action，${variHost}:${variHttpPort} is restart" >> /windows/runtime/supervisor.log
    # supervisor[END]
  fi
  # check heartbeat[END]
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"