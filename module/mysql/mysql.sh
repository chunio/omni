#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
mysql:8.0默認安裝「validate_password」插件（用以檢查用戶密碼，如設置太簡單將導致登錄失敗）
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="DETACH"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# global variable[START]
VARI_GLOBAL["MYSQL_USERNAME"]=""
VARI_GLOBAL["MYSQL_PASSWORD"]=""
# 使用限制：「volumes.driver_opt.device」要求符合「linux file system」，解決方案：「... | sed 's/windows/linux/'」(兼容:vmware.[windows]/etc/fstab)
VARI_GLOBAL["MYSQL_DATA_PATH"]="$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')/mysql"
VARI_GLOBAL["MYSQL_EXEC_IGNORE"]="Using a password on the command line interface can be insecure."
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicDocker(){
  local variParameterDescList=("[ sql ] version（ default : 0 / example : 20240527 ）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  # restore version[START]
  variSqlVersion=${1:-0}
  variSchemaPath=${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/schema
  variSqlVersionPath=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/schema/${variSqlVersion}
  if [ $variSqlVersion != 0 ] && [ -d "${variSqlVersionPath}" ];then
    variSchemaPath=${variSqlVersionPath}
  fi
  # restore version[END]
  rm -rf ${VARI_GLOBAL["MYSQL_DATA_PATH"]}
  mkdir -p ${VARI_GLOBAL["MYSQL_DATA_PATH"]}
  chmod -R 777 ${VARI_GLOBAL["MYSQL_DATA_PATH"]}
  # variMysqlUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  variMysqlPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
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
      MYSQL_ROOT_PASSWORD: ${variMysqlPassword}
      # MYSQL_INITDB_SKIP_TZINFO: 1
    ports:
      # 宿主端口:容器端口
      - "3306:3306"
    volumes:
      # [數據目錄等於空時]自動按名稱順序執行./*.sh && *.sql
      # - ${VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]}/my.cnf:/etc/mysql/conf.d/my.cnf
      # - ${variSchemaPath}:/docker-entrypoint-initdb.d
      - mysql-data:/var/lib/mysql
      # - 主機路徑:容器路徑
      # - /windows:/windows
      # - ${VARI_GLOBAL["MYSQL_DATA_PATH"]}:${VARI_GLOBAL["MYSQL_DATA_PATH"]}
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
  # docker compose down -v
  docker compose -p mysql down -v 2> /dev/null
  docker compose -p mysql up --build -d
  docker update --restart=always mysql
  docker ps -a | grep mysql
  return 0
}

# function funcPublicBackup(){
#   local variParameterDescMulti=("custom version（default：YYYYMMDD）")
#   funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
#   variContainer="mysql"
#   variMysqlUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
#   variMysqlPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
#   variDatabaseList=(
#     "account"
#   )
#   variDefault=$(date "+%Y%m%d")
#   variSqlVersion=${1:-$variDefault}
#   variSqlVersionPath=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/sql/${variSqlVersion}
#   mkdir -p ${variSqlVersionPath}
#   echo "version ：${variSqlVersion}"
#   for variEachDatabase in "${variDatabaseList[@]}"; do
#     cat <<INITSQL >> ${variSqlVersionPath}/00init.sql
# CREATE DATABASE IF NOT EXISTS ${variEachDatabase};
# USE ${variEachDatabase};
# SOURCE /docker-entrypoint-initdb.d/01${variEachDatabase}.sql;
# INITSQL
#     variEachSQLUri="${variSqlVersionPath}/01${variEachDatabase}.sql"
#     docker exec ${variContainer} mysqldump -u${variMysqlUsername} -p${variMysqlPassword} ${variEachDatabase} 2>&1 | grep -v "${VARI_GLOBAL["MYSQL_EXEC_IGNORE"]}" > $variEachSQLUri
#     if [ $? -eq 0 ]; then
#       echo "${variContainer} -> ${variEachDatabase} >> ${variEachSQLUri} backup succeeded"
#     else
#       echo "${variContainer} -> ${variEachDatabase} >> ${variEachSQLUri} backup failed"
#     fi
#   done
#   return 0
# }

function funcPublicImportBusinessData_Haohaiyou() {
  local variContainerName="mysql"
  local variShemaPath="${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/schema/haohaiyou"
  local variMysqlUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  local variMysqlPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  if [ ! -d "${variShemaPath}" ]; then
    echo "[ warn ] ${variShemaPath} is empty(0)"
    return 1
  fi
  shopt -s nullglob
  local variSqlUriSlice=("${variShemaPath}"/*.sql)
  shopt -u nullglob
  if [ ${#variSqlUriSlice[@]} -eq 0 ]; then
    echo "[ warn ] ${variShemaPath} is empty(1)"
    return 0
  fi
  local variContainerStatus=$(docker inspect -f '{{.State.Status}}' "${variContainerName}" 2>/dev/null)
  if [ "$variContainerStatus" != "running" ]; then
    echo "[ error ] '${variContainerName}' is ${variContainerStatus}"
    return 1
  fi
  local variRetryNum=30 # 重試次數
  local variRetryInterval=2 # 重試間隔(unit:second)
  local variEachSqlUri variImportStatus variEachCommand
  for variEachSqlUri in "${variSqlUriSlice[@]}"; do
    echo "[ import ] ${variEachSqlUri}"
    variImportStatus="failed" # default
    for ((variRetryIndex=1; variRetryIndex<=variRetryNum; variRetryIndex++)); do
      variEachCommand="docker exec -i ${variContainerName} mysql -u${variMysqlUsername}"
      if [ -n "${variMysqlPassword}" ]; then
        variEachCommand="${variEachCommand} -p${variMysqlPassword}"
      fi
      if cat "${variEachSqlUri}" | eval "${variEachCommand}"; then
        variImportStatus="succeeded"
        funcProtectedTrace "${variEachSqlUri} import ${variImportStatus}"
        break
      else
        echo "[ retry ] ${variRetryIndex}/${variRetryNum}  ..."
        sleep ${variRetryInterval}
      fi
    done
    if [ "$variImportStatus" = "failed" ]; then
      funcProtectedTodo "${variEachSqlUri} import ${variImportStatus}"
    fi
  done
  return 0
}

function funcPublicImportBusinessData_Haohaiyou() {
  local variContainerName="mysql"
  local varSchemaMasterPath="${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/schema/haohaiyou"
  local variMysqlUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  local variMysqlPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  if [ ! -d "${varSchemaMasterPath}" ]; then
    echo "[ warn ] ${varSchemaMasterPath} is empty(0)"
    return 1
  fi
  shopt -s nullglob
  local variSchemeSlavePathSlice=("${varSchemaMasterPath}"/*/)
  shopt -u nullglob
  if [ ${#variSchemeSlavePathSlice[@]} -eq 0 ]; then
    echo "[ warn ] ${varSchemaMasterPath} is empty(1)"
    return 0
  fi
  local variContainerStatus=$(docker inspect -f '{{.State.Status}}' "${variContainerName}" 2>/dev/null)
  if [ "$variContainerStatus" != "running" ]; then
    echo "[ error ] '${variContainerName}' is ${variContainerStatus}"
    return 1
  fi
  local variRetryNum=30 # 重試次數
  local variRetryInterval=2 # 重試間隔(unit:second)
  local variEachSchemaSlavePath variEachSqlUri variImportStatus variEachCommand
  local variSqlUriSlice
  for variEachSchemaSlavePath in "${variSchemeSlavePathSlice[@]}"; do
    shopt -s nullglob
    variSqlUriSlice=("${variEachSchemaSlavePath}"*.sql)
    shopt -u nullglob
    if [ ${#variSqlUriSlice[@]} -eq 0 ]; then
      echo "[ warn ] ${variEachSchemaSlavePath} is empty(2)"
      continue
    fi
    for variEachSqlUri in "${variSqlUriSlice[@]}"; do
      echo "[ import ] ${variEachSqlUri}"
      variImportStatus="failed" # default
      for ((variRetryIndex=1; variRetryIndex<=variRetryNum; variRetryIndex++)); do
        variEachCommand="docker exec -i ${variContainerName} mysql -u${variMysqlUsername}"
        if [ -n "${variMysqlPassword}" ]; then
          variEachCommand="${variEachCommand} -p${variMysqlPassword}"
        fi
        cat "${variEachSqlUri}" | eval "${variEachCommand}" 2>&1
        local variEachCommandExitCode=$?
        if [ ${variEachCommandExitCode} -eq 0 ]; then
          variImportStatus="succeeded"
          funcProtectedTrace "${variEachSqlUri} import ${variImportStatus}"
          break
        else
          echo "[ retry ] ${variRetryIndex}/${variRetryNum}  ..."
          sleep ${variRetryInterval}
        fi
      done
      if [ "$variImportStatus" = "failed" ]; then
        funcProtectedTodo "${variEachSqlUri} import ${variImportStatus}"
      fi
    done
  done
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"