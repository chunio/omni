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
function funcPublicRunNode()
{
  variWorkSpace="/windows/code/backend/golang"
  mkdir -p ${variWorkSpace}/{gopath,gocache.linux,gocache.windows}
  mkdir -p ${variWorkSpace}/gopath{/bin,/pkg,/src}
  cat <<ENV > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux
CGO_ENABLED=1
GO111MODULE=on
GOBIN=${variWorkSpace}/gopath/bin
GOCACHE=${variWorkSpace}/gocache.linux
GOMODCACHE=${variWorkSpace}/gopath/pkg/mod
GOPATH=${variWorkSpace}/gopath
GOPROXY=https://goproxy.cn,direct
GOROOT=/usr/local/go
GOSUMDB=sum.golang.google.cn
GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
ENV
  cat <<DOCKERCOMPOSEYML >  ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  go:
    image: golang:1.22.0
    container_name: go
    environment:
      - GOENV=/go.env.linux
    volumes:
      - /windows:/windows
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux:/go.env.linux
    working_dir: ${variWorkSpace}/gopath/src
    networks:
      - common
    # 啟動進程關閉時，則容器退出
    command: /bin/bash -c "export PATH=$PATH:${variWorkSpace}/gopath/bin && tail -f /dev/null"
networks:
  common:
    driver: bridge
volumes:
  gopath:
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker-compose down -v
  docker-compose -p go up --build -d
  docker update --restart=always go
  docker ps -a | grep go
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"