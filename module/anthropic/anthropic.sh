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
4，[resolve conflict] git add module/conflict.file && git rebase --continue
5，git push origin main
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="SLAVE"
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

# docker exec -it claude-code /bin/bash
# 環境依賴：glibc2.25+（centos7.9/[原生]glibc2.17）
#「claude code」僅支持「HTTP/HTTPS」VPN/代理，不支持「SOCKS」VPN/代理（原因：底層使用「node.js」的HTTP客戶端，默认僅識別「HTTP_PROXY/HTTPS_PROXY」環境變量）
function funcPublicClaudeCodeReinit(){
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/bin/bash
apt update
apt install -y npm
npm install -g @anthropic-ai/claude-code
ENTRYPOINTSH
  cat <<DOCKERCOMPOSEYML > "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"/docker-compose.yml
services:
  centos:
    image: ubuntu:24.04
    container_name: claude-code
    # 開啟VPN/代理[START]
    environment:
      HTTP_PROXY: http://192.168.255.1:10809
      HTTPS_PROXY: http://192.168.255.1:10809
      NO_PROXY: localhost,127.0.0.1,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    extra_hosts:
      - "host.docker.internal:192.168.255.1"
    # 開啟VPN/代理[END]
    #「sleep infinity」保持運行，防止退出
    command: bash -lc "sleep infinity"
    volumes:
      - /windows:/windows:rw
    networks:
      - common
    privileged: false
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f claude-code 2> /dev/null
  docker compose down -v
  docker compose -p claude-code up --build -d
  docker update --restart=always claude-code
  docker ps -a | grep claude-code
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"