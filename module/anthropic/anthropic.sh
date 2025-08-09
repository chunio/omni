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
  cat <<DOCKERCOMPOSEYML > "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"/docker-compose.yml
services:
  centos:
    image: centos:8.4.2105
    container_name: claude-code
    command: >
        bash -lc "
            sleep infinity
        "
    volumes:
      - /windows:/windows:rw
    networks:
      - common
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker-compose down -v
  docker-compose -p claude-code up --build -d
  docker update --restart=always claude-code
  docker ps -a | grep claude-code
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"