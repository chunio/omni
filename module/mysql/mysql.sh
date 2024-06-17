#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
mysql:8.0默認安裝「validate_password」插件（用以檢查用戶密碼，如設置太簡單將導致登錄失敗）
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
VARI_GLOBAL["MYSQL_USERNAME"]=""
VARI_GLOBAL["MYSQL_PASSWORD"]=""
# 「volumes.driver_opt.device」要求符合「linux文件係統」
VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]=$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')
VARI_GLOBAL["MYSQL_DATA_PATH"]=$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')/mysql
VARI_GLOBAL["MYSQL_EXEC_IGNORE"]="Using a password on the command line interface can be insecure."
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicRunNode(){
  local variParameterDescList=("SQL version（defualt : 0 / example : 20240527）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  # -----
  variSQLVersion=${1:-0}
  variSQLPath=${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql
  variSQLVersionPath=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/sql/${variSQLVersion}
  if [ $variSQLVersion != 0 ] && [ -d "${variSQLVersionPath}" ];then
    variSQLPath=${variSQLVersionPath}
  fi
  # -----
  rm -rf ${VARI_GLOBAL["MYSQL_DATA_PATH"]} && mkdir -p /windows ${VARI_GLOBAL["MYSQL_DATA_PATH"]}
  # variUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  variPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  echo ${variPassword}
#  cat <<MYCNF > ${VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]}/my.cnf
#[mysqld]
#bind-address = 0.0.0.0
#MYCNF
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  # ##################################################
  mysql:
    image: mysql:8.0
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${variPassword}
      # MYSQL_INITDB_SKIP_TZINFO: 1
    ports:
      # 宿主端口:容器端口
      - "3306:3306"
    volumes:
      # [數據目錄等於空時]自動按名稱順序執行./*.sh && *.sql
      # - ${VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]}/my.cnf:/etc/mysql/conf.d/my.cnf
      - ${variSQLPath}:/docker-entrypoint-initdb.d
      - mysql-data:/var/lib/mysql
      - /windows:/windows
      # - /usr/share/zoneinfo:/usr/share/zoneinfo:ro
      # - /etc/localtime:/etc/localtime:ro
    command: mysqld --host_cache_size=0
    networks:
      - common
networks:
  common:
    driver: bridge
volumes:
  mysql-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${VARI_GLOBAL["MYSQL_DATA_PATH"]}
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker-compose down -v
  docker-compose -p mysql up --build -d
  docker update --restart=always mysql
  docker ps -a | grep mysql
  return 0
}

function funcPublicBackup(){
  local variParameterDescMulti=("custom version（default：YYYYMMDD）")
  funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
  variContainer="mysql"
  variUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  variPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  variDatabaseList=(
    "account"
  )
  variDefault=$(date "+%Y%m%d")
  variSQLVersion=${1:-$variDefault}
  variSQLVersionPath=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/sql/${variSQLVersion}
  mkdir -p ${variSQLVersionPath}
  echo "version ：${variSQLVersion}"
  for variEachDatabase in "${variDatabaseList[@]}"; do
    cat <<INITSQL >> ${variSQLVersionPath}/00init.sql
CREATE DATABASE IF NOT EXISTS ${variEachDatabase};
USE ${variEachDatabase};
SOURCE /docker-entrypoint-initdb.d/01${variEachDatabase}.sql;
INITSQL
    variEachSQLUri="${variSQLVersionPath}/01${variEachDatabase}.sql"
    docker exec ${variContainer} mysqldump -u${variUsername} -p${variPassword} ${variEachDatabase} 2>&1 | grep -v "${VARI_GLOBAL["MYSQL_EXEC_IGNORE"]}" > $variEachSQLUri
    if [ $? -eq 0 ]; then
      echo "${variContainer} -> ${variEachDatabase} >> ${variEachSQLUri} backup succeeded"
    else
      echo "${variContainer} -> ${variEachDatabase} >> ${variEachSQLUri} backup failed"
    fi
  done
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"