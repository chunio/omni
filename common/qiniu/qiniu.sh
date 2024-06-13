#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true
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
  variParameterDescList=("the uri of the file to be uploaded")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variTodoUploadFileUri=${1};
  # --------------------------------------------------
  variQiniuAccount=$(funcProtectedPullEncryptEnvi "QINIU_ACCOUNT")
  variQiniuAccessKey=$(funcProtectedPullEncryptEnvi "QINIU_ACCESS_KEY")
  variQiniuSecretKey=$(funcProtectedPullEncryptEnvi "QINIU_SECRET_KEY")
  variQiniuBucketName=$(funcProtectedPullEncryptEnvi "QINIU_BUCKET_NAME")
  variQiniuBucketDirectory=$(funcProtectedPullEncryptEnvi "QINIU_BUCKET_DIRECTORY")
  echo 'variQiniuBucketDirectory: ' $variQiniuBucketDirectory
  # --------------------------------------------------
  qshell account ${variQiniuAccessKey} ${variQiniuSecretKey} ${variQiniuAccount} &> /dev/null
  if [ -n "${variTodoUploadFileUri}" ];then
    echo "qshell rput --overwrite ${variQiniuBucketName} ${variQiniuBucketDirectory}/$(basename ${variTodoUploadFileUri}) $variTodoUploadFileUri"
    qshell rput --overwrite ${variQiniuBucketName} ${variQiniuBucketDirectory}/$(basename ${variTodoUploadFileUri}) $variTodoUploadFileUri
  fi
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"