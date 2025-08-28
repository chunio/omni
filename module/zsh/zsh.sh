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
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="MASTER"
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
function funcPublicReinit(){
  # 解決交互：Do you want to change your default shell to zsh? [Y/n]
  export CHSH=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"