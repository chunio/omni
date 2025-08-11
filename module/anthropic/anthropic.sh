#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<'MARK'
# https://docs.github.com/en/code-security/secret-scanning/working-with-secret-scanning-and-push-protection/working-with-push-protection-from-the-command-line#removing-a-secret-introduced-by-an-earlier-commit-on-your-branch
working with push protection from the command line ：
0，git log
1，git rebase -i {$commitId}~1
2，[delete commit] dd && :wq
3，[check conflict] git status
4，[resolve conflict] git add module/confict.file && git rebase --continue
5，git push origin main
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="SLAVE"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

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

# 依賴：
# 1，glibc2.25+（centos7.9/[原生]glibc2.17）
function funcPublicClaudeCodeReinit(){
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/bin/bash
# 會被「docker run」中指定命令覆蓋
# sed -i 's|^gpgcheck=1|gpgcheck=0|g' /etc/yum.repos.d/CentOS-*.repo 2> /dev/null
# sed -i 's|^mirrorlist=|# mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo 2> /dev/null
# sed -i 's|#\s*baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo 2> /dev/null

# 解決報錯[START]
#（1）Failed to set locale, defaulting to C.UTF-8
# yum install -y glibc-langpack-en
# localedef -i en_US -f UTF-8 en_US.UTF-8
# export LANG=en_US.UTF-8
# 解決報錯[END]

# /windows/code/backend/chunio/omni/init/system/system.sh init 1

# yum install -y git curl
# curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
# yum install -y nodejs
# npm install -g @anthropic-ai/claude-code
# 禁止「return」
# return 0
ENTRYPOINTSH
  cat <<DOCKERCOMPOSEYML > "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"/docker-compose.yml
services:
  centos:
    image: quay.io/centos/centos:stream9
    container_name: claude-code
    environment:
      HTTP_PROXY:  http://192.168.255.1:10809
      HTTPS_PROXY: http://192.168.255.1:10809
      NO_PROXY: localhost,127.0.0.1,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    extra_hosts:
      - "host.docker.internal:host-gateway"
    #「sleep infinity」保持運行，防止退出
    command: bash -lc "/usr/local/bin/entrypoint.sh || true; sleep infinity"
    volumes:
      - /windows:/windows:rw
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    networks:
      - common
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f claude-code
  docker-compose down -v
  docker-compose -p claude-code up --build -d
  docker update --restart=always claude-code
  docker ps -a | grep claude-code
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"