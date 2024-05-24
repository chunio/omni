#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" || true
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"

# ##################################################
# global variable[START]
VARI_GLOBAL["QINIU_ACCOUNT"]=""
VARI_GLOBAL["QINIU_ACCESS_KEY"]=""
VARI_GLOBAL["QINIU_SECRET_KEY"]=""
VARI_GLOBAL["QINIU_DOMAIN_ALIAS"]=""
# South China / Guangdong
# VARI_ENCRYPT["QINIU_BUCKET_NAME"]="chunio"
# North America / Los Angeles
VARI_GLOBAL["QINIU_BUCKET_NAME"]=""
VARI_GLOBAL["QINIU_BUCKET_DIRECTORY"]=""
# example : VARI_GLOBAL["TODO_UPLOAD_LIST"]="example1.tgz example2.tgz"
VARI_GLOBAL["TODO_UPLOAD_LIST"]=""


VARIABLE_QINIU_ACCOUNT="zengweitao@msn.com"
VARIABLE_QINIU_ACCESS_KEY="BqJfB_Wfr80at2T2KI7WdeCBUmPQk-EN8K2Y4htd"
VARIABLE_QINIU_SECRET_KEY="U6c-G2wffEHy3n47bkguH92g1-Kj14GQ4HNQATrl"
VARIABLE_QINIU_DOWNLOAD_DOMAIN="http://cloud.baichuan.wiki"
# North America / Los Angeles
VARIABLE_QINIU_BUCKET_NAME="zengweitao"
# South China / Guangdong
# QINIU_BUCKET_NAME="chunio"
VARIABLE_QINIU_BUCKET_DIRECTORY="common"
VARIABLE_TODO_UPLOAD_LIST=(
  # "example1.tgz"
  # "example2.tgz"
)
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedCloudInit() {
    which qshell &> /dev/null
    if [ $? -ne 0 ];then
        cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
        # https://github.com/qiniu/qshell/releases
        wget https://github.com/qiniu/qshell/releases/download/v2.14.0/qshell-v2.14.0-linux-386.tar.gz
        tar -zxf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/qshell-v2.14.0-linux-386.tar.gz -C /usr/local/bin/
        rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/qshell-v2.14.0-linux-386.tar.gz
    fi
    return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicUpload(){
  variParameterDescList=("--")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variableTodoUploadFile=$1;
  # --------------------------------------------------
  variQiniuAccount=$(funcProtectedPullEncryptEnvi "QINIU_ACCOUNT")
  variQiniuAccessKey=$(funcProtectedPullEncryptEnvi "QINIU_ACCESS_KEY")
  variQiniuSecretKey=$(funcProtectedPullEncryptEnvi "QINIU_SECRET_KEY")
  variQiniuBucketName=$(funcProtectedPullEncryptEnvi "QINIU_BUCKET_NAME")
  variQiniuBucketDirectory=$(funcProtectedPullEncryptEnvi "QINIU_BUCKET_DIRECTORY")
  # --------------------------------------------------
  qshell account ${variQiniuAccessKey} ${variQiniuSecretKey} ${variQiniuAccount} &> /dev/null
  if [ -n "$variableTodoUploadFile" ];then
    # [優先等級1]存在參數時，則上傳目標文件
    qshell rput --overwrite ${variQiniuBucketName} ${variQiniuBucketDirectory}/$variableTodoUploadFile ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/$variableTodoUploadFile
  elif [ -z ${VARI_GLOBAL["TODO_UPLOAD_LIST"]} ];then
    # [優先等級2]TODO_UPLOAD_LIST=(file1,file2,...)時，則上傳file1,file2,...
    for variEachTodoUploadFile in ${VARI_GLOBAL["TODO_UPLOAD_LIST"]}; do
        qshell rput --overwrite ${variQiniuBucketName} ${variQiniuBucketDirectory}/$variEachTodoUploadFile ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/$variEachTodoUploadFile
        rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/${variEachTodoUploadFile}
    done
  else
    # [優先等級3]TODO_UPLOAD_LIST=()時，則上傳static/{$all}
    for variEachTodoUploadFile in "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}"/*
    do
        qshell rput --overwrite ${variQiniuBucketName} ${variQiniuBucketDirectory}/${variEachTodoUploadFile} ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/${variEachTodoUploadFile}
        rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/${variEachTodoUploadFile}
    done
  fi
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"