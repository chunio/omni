#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
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
# ##################################################

# ##################################################
# protected function[START]

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
#function funcPublicUnicorn(){
#  cd /windows/code/backend/haohaiyou/gopath/src/unicorn
#  pwd && du -sh && ls -alh
#  return 0
#}

function funcPublicSkeleton(){
  # [MASTER]persistence
  variMasterPath="/windows/code/backend/haohaiyou"
  # [DOCKER]temporary
  variDockerWorkSpace="/windows/code/backend/haohaiyou"
  veriModuleName="skeleton"
  variImagePattern=${1:-"hyperf/hyperf:8.3-alpine-v3.19-swoole-5.1.3"}
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
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/bin/bash
# 會被「docker run」中指定命令覆蓋
touch /etc/bashrc
chmod 644 /etc/bashrc
# /windows/code/backend/chunio/omni/init/system/system.sh init && source /etc/bashrc
# 禁止「return」
# return 0
ENTRYPOINTSH
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

function funcPublicUnicornTemp()
{
  # [MASTER]persistence
  variMasterPath="/windows/code/backend/haohaiyou"
  # [DOCKER]temporary
  variDockerWorkSpace="/windows/code/backend/haohaiyou"
  # local variParameterDescMulti=("module name（from:${variMasterPath}/gopath/src/*）")
  # funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variModuleName="unicorn"
  mkdir -p ${variMasterPath}/{gopath,gocache.linux,gocache.windows}
  mkdir -p ${variMasterPath}/gopath{/bin,/pkg,/src}
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variModuleName}:
    image: chunio/go:1220
    container_name: ${variModuleName}
    environment:
      - GOENV=/windows/code/backend/golang/go.env.linux
      - PATH=$PATH:/usr/local/go/bin:${variDockerWorkSpace}/gopath/bin
    volumes:
      - /windows/code/backend/haohaiyou/go.env.linux:/windows/code/backend/golang/go.env.linux
      - /windows/code/backend/haohaiyou:/windows/code/backend/golang
    working_dir: /windows/code/backend/golang/gopath/src/${variModuleName}
    networks:
      - common
    command: ["tail", "-f", "/dev/null"]
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker-compose down -v
  docker-compose -p ${variModuleName} up --build -d
  docker update --restart=always ${variModuleName}
  docker ps -a | grep ${variModuleName}
  cd ${variMasterPath}/gopath/src/${variModuleName}
  docker exec -it ${variModuleName} /bin/bash
  return 0
}

function funcPublicDevel(){
  go build -gcflags="all=-N -l" -o ./bin/unicorn ./cmd/unicorn/main.go ./cmd/unicorn/wire_gen.go
  dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec ./bin/unicorn -- -conf ./
  # -----
  go build -gcflags="all=-N -l" -o ./bin/dspservice ./module/dsp/main/main.go ./module/dsp/main/wire_gen.go
}

# 容器內部執行
function funcPublic1220EnvironmentInit(){
  yum install -y git
  # wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -O ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go1.22.0.linux-amd64.tar.gz
  tar -xvf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/go1.22.0.linux-amd64.tar.gz -C /usr/local
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
  variParameterDescList=("image pattern（example ：chunio/go:1220）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=${1-"chunio/go:1220"}
  variContainerName="go1220Environment"
  docker rm -f ${variContainerName} 2> /dev/null
  docker rmi -f $variImagePattern 2> /dev/null
  # 鏡像不存在時自動執行：docker pull $variImageName
  docker run -d --privileged --name ${variContainerName} -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /windows:/windows --tmpfs /run --tmpfs /run/lock -p 80:80 centos:7.9.2009 /sbin/init
  docker exec -it ${variContainerName} /bin/bash -c "cd ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]} && ./$(basename "${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]}") 1220EnvironmentInit;"
  variContainerId=$(docker ps --filter "name=${variContainerName}" --format "{{.ID}}")
  echo "docker commit $variContainerId $variImagePattern"
  docker commit $variContainerId $variImagePattern
  docker ps --filter "name=${variContainerName}"
  docker images --filter "reference=${variImagePattern}"
  echo "${FUNCNAME} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "docker exec -it ${variContainerName} /bin/bash" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"