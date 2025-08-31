#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
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
VARI_GLOBAL["MYSQL_USERNAME"]=""
VARI_GLOBAL["MYSQL_PASSWORD"]=""
# 「volumes.driver_opt.device」要求符合「linux文件係統」
VARI_GLOBAL["MYSQL_DATA_PATH"]=$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')/mysql
VARI_GLOBAL["MYSQL_EXEC_IGNORE"]="Using a password on the command line interface can be insecure."
VARI_GLOBAL["REDIS_DATA_PATH"]=$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')/redis
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicRestart(){
  echo "[MYSQL]LATEST VERSION : $(cat ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql/version)"
  rm -rf ${VARI_GLOBAL["MYSQL_DATA_PATH"]} && mkdir -p /windows ${VARI_GLOBAL["MYSQL_DATA_PATH"]} 
  rm -rf ${VARI_GLOBAL["REDIS_DATA_PATH"]} && mkdir -p /windows ${VARI_GLOBAL["REDIS_DATA_PATH"]} 
  chmod 777 -R /linux
  variSQLPath=${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql
  # [MASTER]persistence
  variMasterPath="/windows/code/backend/chunio"
  # [DOCKER]temporary
  variDockerWorkSpace="/windows/code/backend/chunio"
  veriModuleName="account"
  variPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/bin/bash
# 會被「docker run」中指定命令覆蓋
return 0
ENTRYPOINTSH
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${veriModuleName}-nginx:
    image: nginx:1.27.0
    container_name: ${veriModuleName}-nginx
    volumes:
      - /windows:/windows
      - ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/nginx/localhost.chunio.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "80:80"
    networks:
      - common
  # ##################################################
  # mysql[START]
  ${veriModuleName}-mysql:
    image: mysql:8.0
    container_name: ${veriModuleName}-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${variPassword}
      # MYSQL_INITDB_SKIP_TZINFO: 1
    ports:
      # 宿主端口:容器端口
      - "3306:3306"
    volumes:
      # [數據目錄等於空時]自動按名稱順序執行./*.sh && *.sql
      - ${variSQLPath}:/docker-entrypoint-initdb.d
      - mysql-data:/var/lib/mysql
      - /windows:/windows
      # - /usr/share/zoneinfo:/usr/share/zoneinfo:ro
      # - /etc/localtime:/etc/localtime:ro
    command: mysqld --host_cache_size=0
    networks:
      - common
  # mysql[END]
  # ##################################################
  ${veriModuleName}-redis:
    image: redis:7.2.5
    container_name: ${veriModuleName}-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - common
    # 「--appendonly yes」表示是否開啟「AOF (Append Only File)」 /持久化機制
    command: redis-server --appendonly yes --requirepass 0000
  ${veriModuleName}-php:
    image: hyperf/hyperf:7.4-alpine-v3.13-swoole-v4.8
    container_name: ${veriModuleName}-php
    volumes:
      - /windows:/windows
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    working_dir: ${variDockerWorkSpace}/${veriModuleName}/backend
    networks:
      - common
    ports:
      - "18306:18306"
    command: ["tail", "-f", "/dev/null"]
    depends_on:
      - ${veriModuleName}-nginx
      - ${veriModuleName}-mysql
      - ${veriModuleName}-redis
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
  redis_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${VARI_GLOBAL["REDIS_DATA_PATH"]}
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  # 徹底重啟[START]
  docker rm -f account-php 2> /dev/null
  docker rm -f account-redis 2> /dev/null
  docker rm -f account-mysql 2> /dev/null
  docker rm -f account-nginx 2> /dev/null
  # 徹底重啟[END]
  docker compose down -v
  # 強制清除未使用的「volume」
  docker volume prune -f
  docker compose -p ${veriModuleName} up --build -d
  docker ps -a | grep ${veriModuleName}
  cd ${variDockerWorkSpace}/${veriModuleName}/backend
  docker exec -it ${veriModuleName}-php /bin/bash -c "php bin/swoft http:restart; exec /bin/bash"
  return 0
}

function funcPublicBackup(){
  local variParameterDescMulti=("custom version（default：YYYYMMDD）")
  funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
  variContainer="account-mysql"
  variUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  variPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  variDatabaseList=(
    "account"
  )
  variDefault=$(date "+%Y%m%d%H%M%S")
  variSqlVersion=${1:-$variDefault}
  variSqlVersionPath=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/sql
  mkdir -p ${variSqlVersionPath}
  echo "version ：${variSqlVersion}"
  for variEachDatabase in "${variDatabaseList[@]}"; do
    variLatestSqlVersionUri="${variSqlVersionPath}/${variSqlVersion}.sql"
    # docker exec ${variContainer} mysqldump -u${variUsername} -p${variPassword} ${variEachDatabase} 2>&1 | grep -v "${VARI_GLOBAL["MYSQL_EXEC_IGNORE"]}" > $variLatestSqlVersionUri
    docker exec ${variContainer} mysqldump -u${variUsername} -p${variPassword} ${variEachDatabase} > $variLatestSqlVersionUri
    if [ $? -eq 0 ]; then
      echo "${variContainer} -> ${variEachDatabase} >> ${variLatestSqlVersionUri} backup succeeded"
      # update [cloud]latest version[START]
      cat <<INITSQL > ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql/00init.sql
CREATE DATABASE IF NOT EXISTS ${variEachDatabase};
USE ${variEachDatabase};
SOURCE /docker-entrypoint-initdb.d/01account.sql;
INITSQL
      # -----
      /usr/bin/cp -rf ${variLatestSqlVersionUri} ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql/01account.sql
      sed -i '1iCREATE DATABASE IF NOT EXISTS account;\nUSE account;\n' ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql/01account.sql
      echo ${variSqlVersion} > ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql/version
      echo "${variContainer} -> ${variEachDatabase} >> ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql/01account.sql update succeeded"
      # update [cloud]latest version[END]
      # version quantity control[START]
      variAllSqlVersionUriSlice=$(ls -t ${variSqlVersionPath}/*.sql)
      variKeepSqlVersionUriSlice=$(echo "${variAllSqlVersionUriSlice}" | head -n 10)
      for variEachSqlVersionUri in $variAllSqlVersionUriSlice; do
        if ! echo "$variKeepSqlVersionUriSlice" | grep -q "^${variEachSqlVersionUri}$"; then
          rm -rf ${variEachSqlVersionUri}
        fi
      done
      # version quantity control[END]
    else
      echo "${variContainer} -> ${variEachDatabase} >> ${variLatestSqlVersionUri} backup failed"
    fi
  done
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"