#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
# [示例]將當前腳本的目標函數[聲明/定義]拷貝至遠端 && 執行函數
# about : funcProtectedTemplate
function funcPublicTemplate() {
    ssh -t root@xxxx 'bash -s' <<EOF
$(typeset -f funcProtectedTemplate)
funcProtectedTemplate
exec \$SHELL
EOF
}

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p tcp --dport 6379 -j DNAT --to-destination 10.0.0.10:6379
iptables -t nat -A POSTROUTING -d 10.0.0.10 -p tcp --dport 6379 -j MASQUERADE
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
# VARI_CLOUD=(
#   "00 INDEX bwh81 -01 98.142.138.87 29396"
#   # "00 ADMIN TORONTO -01 159.89.116.79 22"
#   "01 CODE/BI SINGAPORE -01 152.42.200.117 22"
#   "02 CODE/BI NEWYORK -01 45.55.134.33 22"
#   # -----
#   "03 CODE/BID01 SINGAPORE -01 139.59.255.135 22"
#   "04 CODE/BID02 SINGAPORE -02 152.42.196.117 22"
#   "05 CODE/BID03 SINGAPORE -03 146.190.93.91 22"
#   # -----
#   "06 CODE/BID04 NEWYORK -01 138.197.74.229 22"
#   "07 CODE/BID05 NEWYORK -02 174.138.78.11 22"
#   # -----
#   "08 CODE/NOTICE06 SINGAPORE -01 174.138.20.208 22"
#   "09 CODE/NOTICE07 SINGAPORE -02 174.138.28.254 22"
#   "10 CODE/NOTICE08 NEWYORK -01 159.203.76.109 22"
#   "11 CODE/NOTICE09 NEWYORK -02 159.203.88.75 22"
#   # -----
#   "12 CODE/MOCK SINGAPORE -01 157.245.147.213 22"
#   "13 CODE/MOCK SINGAPORE -02 206.189.81.28 22"
#   "14 CODE/CHECK SINGAPORE -02 152.42.204.116 22"
# )
VARI_CLOUD=(
  "00 INDEX HONGKONG -01 119.28.55.124 22"
  # -----
  "01 CODE/COMMON SINGAPORE -00 43.133.61.186 22"
  "02 CODE/COMMON NEWYORK -01 43.130.116.28 22"
  "08 CODE/COMMON NEWYORK -01 43.130.91.178 22"
  # -----
  "03 CODE/BID01 SINGAPORE -01 124.156.196.133 22"
  "04 CODE/BID02 SINGAPORE -02 119.28.115.210 22"
  # -----
  "05 CODE/BID01 NEWYORK -02 43.130.79.155 22"
  # -----
  "06 CODE/NOTICE01 SINGAPORE -02 43.134.226.231 22"
  "07 CODE/NOTICE01 NEWYORK -02 43.130.69.78 22"
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
  variImagePattern=${1:-"chunio/php:8370"}
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
  docker-compose down -v
  docker-compose -p ${veriModuleName} up --build -d
  docker update --restart=always ${veriModuleName}
  docker ps -a | grep ${veriModuleName}
  cd ${variMasterPath}/gopath/src/${veriModuleName}
  docker exec -it ${veriModuleName} /bin/bash
  return 0
}

# function funcPublicUnicorn()
# {
#   # [MASTER]persistence
#   variMasterPath="/windows/code/backend/haohaiyou"
#   # [DOCKER]temporary
#   variDockerWorkSpace="/windows/code/backend/haohaiyou"
#   # local variParameterDescMulti=("module name（from:${variMasterPath}/gopath/src/*）")
#   # funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
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

function funcPublicUnicorn()
{
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
  # [MASTER]persistence
  variMasterPath="/windows/code/backend/haohaiyou"
  # [DOCKER]temporary
  variDockerWorkSpace="/windows/code/backend/haohaiyou"
  veriModuleName="unicorn"
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
  yum install -y git
  # wget https://go.dev/dl/go1.22.4.linux-amd64.tar.gz -O ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go1.22.4.linux-amd64.tar.gz
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
  variParameterDescList=("image pattern（example ：chunio/go:1224）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=${1-"chunio/go:1224"}
  variContainerName="go1224Environment"
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
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "NODE_LABEL" "NODE_REGION" "MEMO" "IP" "PORT" 
  for variEachValue in "${VARI_CLOUD[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachLabel=$(echo $variEachValue | awk '{print $2}')
    variEachRegion=$(echo $variEachValue | awk '{print $3}')
    variEachMemo=$(echo $variEachValue | awk '{print $4}')
    variEachIp=$(echo $variEachValue | awk '{print $5}')
    variEachPort=$(echo $variEachValue | awk '{print $6}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachLabel" "$variEachRegion" "${variEachMemo}" "$variEachIp" "$variEachPort" 
  done
  read -p "enter the [number]index to connect: " variInput
  if [[ ! $variInput =~ ^[0-9]+$ ]]; then
    echo "error : expect a [number]index"
    return 1
  fi
  variMasterKeyword="INDEX"
  for variMasterValue in "${VARI_CLOUD[@]}"; do
    if [[ $variMasterValue == *" ${variMasterKeyword} "* ]]; then
      variEachMasterLabel=$(echo $variMasterValue | awk '{print $2}')
      variEachMasterIP=$(echo $variMasterValue | awk '{print $5}')
      variEachMasterPort=$(echo $variMasterValue | awk '{print $6}')
      break
    fi
  done
  for variEachValue in "${VARI_CLOUD[@]}"; do
    variSlaveIndex=$(echo $variEachValue | awk '{print $1}')
    variSlaveLabel=$(echo $variEachValue | awk '{print $2}')
    variSlaveRegion=$(echo $variEachValue | awk '{print $3}')
    variSlaveMemo=$(echo $variEachValue | awk '{print $4}')
    variSlaveIp=$(echo $variEachValue | awk '{print $5}')
    variSlavePort=$(echo $variEachValue | awk '{print $6}')
    if [[ 10#$variSlaveIndex -eq 10#$variInput ]]; then
      echo "initiate connection: [${variSlaveLabel} / ${variSlaveRegion} / ${variSlaveMemo}]${variSlaveIp}:${variSlavePort} ..."
      rm -rf /root/.ssh/known_hosts
      echo "ssh -o StrictHostKeyChecking=no -J root@${variEachMasterIP}:${variEachMasterPort} root@${variSlaveIp} -p ${variSlavePort}"
      # 配置一層[SSH]秘鑰
      # ssh -o StrictHostKeyChecking=no -J root@${variEachMasterIP}:${variEachMasterPort} root@${variSlaveIp} -p ${variSlavePort}
      # 配置二層[SSH]秘鑰
      ssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -p ${variEachMasterPort} root@${variEachMasterIP}" root@${variSlaveIp} -p ${variSlavePort}
      return 0
    fi
  done
  echo "error : invalid index ($variInput)"
  return 1
}

function funcPublicCloudSkeletonInit() {
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "NODE_LABEL" "NODE_REGION" "MEMO" "IP" "PORT" 
  for variEachValue in "${VARI_CLOUD[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachLabel=$(echo $variEachValue | awk '{print $2}')
    variEachRegion=$(echo $variEachValue | awk '{print $3}')
    variEachMemo=$(echo $variEachValue | awk '{print $4}')
    variEachIp=$(echo $variEachValue | awk '{print $5}')
    variEachPort=$(echo $variEachValue | awk '{print $6}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachLabel" "$variEachRegion" "${variEachMemo}" "$variEachIp" "$variEachPort"
  done
  echo -n "Enter the 「NODE_LABEL」 keyword to match: "
  read variSlaveKeyword
  echo "Matched (${variSlaveKeyword}):"
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "NODE_LABEL" "NODE_REGION" "MEMO" "IP" "PORT"
  for variEachValue in "${VARI_CLOUD[@]}"; do
    if [[ $variEachValue == *" ${variSlaveKeyword}"* ]]; then
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
            ssh -o StrictHostKeyChecking=no -p ${variEachMastrPort} -t root@${variEachMasterIP} <<MASTEREOF
              # //TODO：send SHUTDOWN/signal to redis pub/sub
              echo "initiate connection: [${variEachSlaveLabel} / ${variEachSlaveRegion} / ${variEachSlaveMemo}] ${variEachSlaveIP}:${variEachSlavePort} ..."
              rm -rf /root/.ssh/known_hosts
              scp -P ${variEachSlavePort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachSlaveIP}:/
              ssh -o StrictHostKeyChecking=no -p ${variEachSlavePort} -t root@${variEachSlaveIP} <<SLAVEEOF
                # ssh init[START]
                tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
                mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
                echo "StrictHostKeyChecking no" > ~/.ssh/config
                chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
                # ssh init[END]
                # omni.system init[START]
                yum install -y git
                mkdir -p /windows/runtime
                if [ -d "/windows/code/backend/chunio/omni" ]; then
                  cd /windows/code/backend/chunio/omni
                  echo "git fetch origin ..."
                  git fetch origin
                  echo "git reset --hard origin/main ..."
                  git reset --hard origin/main
                  chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                else
                  mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
                  git clone https://github.com/chunio/omni.git
                  cd ./omni && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                fi
                # omni.system init[END]
                # skeleton[START]
                docker rm -f skeleton 2> /dev/null
                if [ -d "/windows/code/backend/haohaiyou/gopath/src/skeleton" ]; then
                  cd /windows/code/backend/haohaiyou/gopath/src/skeleton
                  echo "git fetch origin ..."
                  git fetch origin
                  echo "git reset --hard origin/main ..."
                  git reset --hard origin/main
                else
                  mkdir -p /windows/code/backend/haohaiyou/gopath/src && cd /windows/code/backend/haohaiyou/gopath/src
                  git clone git@github.com:chunio/skeleton.git && cd skeleton
                fi
                chmod 777 -R .
                /usr/bin/cp -rf .env.production.${variEachSlaveRegion} .env
                expect -c '
                set timeout -1
                spawn /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh skeleton chunio/php:8370
                expect "skeleton"
                send "composer install\r"
                expect "skeleton"
                send "nohup php bin/hyperf.php start > /windows/runtime/skeleton.log 2>&1 &\r"
                expect "skeleton"
                send "exit\r"
                expect eof
                '
                # skeleton[END]
SLAVEEOF
MASTEREOF
          fi
        done
      done
    fi
  done
  return 0
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
  scp -P ${variEachMastrPort} -o StrictHostKeyChecking=no /windows/code/backend/chunio/omni/module/haohaiyou/runtime/omni.haohaiyou.cloud.ssh.tgz ${variMasterAccount}@${variEachMasterIP}:/
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

function funcPublicCloudUnicornInit() {
  # local variParameterDescMulti=("envi local/development/production（default）")
  # funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
  local variParameterDescMulti=("scp value : 0/no，1/yes（default）" "envi local/development/production（default）")
  funcProtectedCheckOptionParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variScp=${1:-"1"}
  variEnvi=${2:-"production"}
  variMasterAccount="root"
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "NODE_LABEL" "NODE_REGION" "MEMO" "IP" "PORT" 
  for variEachValue in "${VARI_CLOUD[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachLabel=$(echo $variEachValue | awk '{print $2}')
    variEachRegion=$(echo $variEachValue | awk '{print $3}')
    variEachMemo=$(echo $variEachValue | awk '{print $4}')
    variEachIp=$(echo $variEachValue | awk '{print $5}')
    variEachPort=$(echo $variEachValue | awk '{print $6}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachLabel" "$variEachRegion" "${variEachMemo}" "$variEachIp" "$variEachPort"
  done
  echo -n "Enter the 「NODE_LABEL」 keyword to match: "
  read variSlaveKeyword
  echo "Matched (${variSlaveKeyword}):"
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "NODE_LABEL" "NODE_REGION" "MEMO" "IP" "PORT"
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
            if [[ ${variScp} -eq 1 ]]; then
              scp -P ${variEachMastrPort} -o StrictHostKeyChecking=no /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/unicorn_exec ${variMasterAccount}@${variEachMasterIP}:/
            fi
            ssh -o StrictHostKeyChecking=no -A -p ${variEachMastrPort} -t ${variMasterAccount}@${variEachMasterIP} <<MASTEREOF
              echo "initiate connection: [${variEachSlaveLabel} / ${variEachSlaveRegion} / ${variEachSlaveMemo}] ${variEachSlaveIP}:${variEachSlavePort} ..."
              rm -rf /root/.ssh/known_hosts
              if [[ ${variScp} -eq 1 ]]; then
                scp -P ${variEachSlavePort} -o StrictHostKeyChecking=no /unicorn_exec root@${variEachSlaveIP}:/
                scp -P ${variEachSlavePort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachSlaveIP}:/
              fi
              ssh -o StrictHostKeyChecking=no -A -p ${variEachSlavePort} -t root@${variEachSlaveIP} <<SLAVEEOF
                # --------------------------------------------------
                # ssh init[START]
                tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
                mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
                echo "StrictHostKeyChecking no" > ~/.ssh/config
                chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
                # ssh init[END]
                # --------------------------------------------------
                # --------------------------------------------------
                # omni.system init[START]
                if ! command -v git &> /dev/null; then
                    yum install -y git
                fi
                mkdir -p /windows/runtime
                if [ -d "/windows/code/backend/chunio/omni" ]; then
                  cd /windows/code/backend/chunio/omni
                  echo "git fetch origin ..."
                  git fetch origin
                  echo "git reset --hard origin/main ..."
                  git reset --hard origin/main
                  chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                else
                  mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
                  git clone https://github.com/chunio/omni.git
                  cd ./omni && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
                fi
                # omni.system init[END]
                # --------------------------------------------------
                # --------------------------------------------------
                # unicorn[START]
                ulimit -n 65536
                docker rm -f unicorn 2> /dev/null
                /windows/code/backend/chunio/omni/init/system/system.sh showPort 8000 confirm
                /windows/code/backend/chunio/omni/init/system/system.sh showPort 9000 confirm
                if [ -d "/windows/code/backend/haohaiyou/gopath/src/unicorn" ]; then
                  cd /windows/code/backend/haohaiyou/gopath/src/unicorn
                  echo "git fetch origin ..."
                  git fetch origin
                  echo "git reset --hard origin/main ..."
                  # git reset --hard origin/main
                  git reset --hard origin/feature/zengweitao/data
                else
                  mkdir -p /windows/code/backend/haohaiyou/gopath/src && cd /windows/code/backend/haohaiyou/gopath/src
                  git clone git@github.com:chunio/unicorn.git && cd unicorn
                fi
                chmod 777 -R .
                /usr/bin/cp -rf /unicorn_exec ./bin/unicorn_exec 
                nohup ./bin/unicorn_exec -ENVI_LABEL ${variEnvi} -NODE_LABEL ${variEachSlaveLabel} -NODE_REGION ${variEachSlaveRegion} > /windows/runtime/unicorn.log 2>&1 &
                (
                  while true; do
                    if grep -q "9000" /windows/runtime/unicorn.log; then
                      cat /windows/runtime/unicorn.log
                      echo "nohup ./bin/unicorn_exec -ENVI_LABEL ${variEnvi} -NODE_LABEL ${variEachSlaveLabel} -NODE_REGION ${variEachSlaveRegion} > /windows/runtime/unicorn.log 2>&1 & [success]"
                      break
                    elif grep -qE "failed|error|panic" /windows/runtime/unicorn.log; then
                      cat /windows/runtime/unicorn.log
                      break
                    fi
                    sleep 1
                  done
                ) &
                # unicorn[END]
                # --------------------------------------------------
                # expect -c '
                # set timeout -1
                # spawn /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh unicorn
                # expect "unicorn"
                # send "nohup ./bin/unicorn_exec -ENVI_LABEL production -NODE_LABEL ${variEachSlaveLabel} -NODE_REGION ${variEachSlaveRegion} > /windows/runtime/unicorn.log 2>&1 &\r"
                # expect "unicorn"
                # send "exit\r"
                # expect eof
                # '
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
  # local variParameterDescMulti=("envi local/development/production（default）")
  # funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
  local variParameterDescMulti=("scp value : 0/no，1/yes（default）" "envi local/development/production（default）")
  funcProtectedCheckOptionParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variScp=${1:-"1"}
  variEnvi=${2:-"production"}
  # variMasterAccount="ec2-user"
  variMasterAccount="root"
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "NODE_LABEL" "NODE_REGION" "MEMO" "IP" "PORT" 
  for variEachValue in "${VARI_CLOUD[@]}"; do
    variEachIndex=$(echo $variEachValue | awk '{print $1}')
    variEachLabel=$(echo $variEachValue | awk '{print $2}')
    variEachRegion=$(echo $variEachValue | awk '{print $3}')
    variEachMemo=$(echo $variEachValue | awk '{print $4}')
    variEachIp=$(echo $variEachValue | awk '{print $5}')
    variEachPort=$(echo $variEachValue | awk '{print $6}')
    printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachLabel" "$variEachRegion" "${variEachMemo}" "$variEachIp" "$variEachPort"
  done
  echo -n "Enter the 「NODE_LABEL」 keyword to match: "
  read variSlaveKeyword
  echo "Matched (${variSlaveKeyword}):"
  printf "%-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "NODE_LABEL" "NODE_REGION" "MEMO" "IP" "PORT"
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
            ssh -o StrictHostKeyChecking=no -p ${variEachMastrPort} -t ${variMasterAccount}@${variEachMasterIP} <<MASTEREOF
              echo "initiate connection: [${variEachSlaveLabel} / ${variEachSlaveRegion} / ${variEachSlaveMemo}] ${variEachSlaveIP}:${variEachSlavePort} ..."
              rm -rf /root/.ssh/known_hosts
              ssh -o StrictHostKeyChecking=no -p ${variEachSlavePort} -t root@${variEachSlaveIP} <<SLAVEEOF
                tail -n 50 /windows/runtime/unicorn.log
SLAVEEOF
MASTEREOF
          fi
        done
      done
    fi
  done
  return 0
}

function funcPublicMongo(){
#     db.bid_stream_20240626.count({ bid_response_status: 1 })
#     db.bid_stream_20240626.find({ bid_response_status:1 })
#     db.bid_stream_20240626.find({ auction_price: { $ne: null } })
#     db.getCollection("bid_stream_20240626").find({
#       creative_snapshot_json: {
#         $regex: "\\[\\s*{\\s*\"creative_id\"\\s*:\\s*\"1528\""
#       }
#     })
    return 0
}
# public function[END]

# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"