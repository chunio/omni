#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
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
# 「volumes.driver_opt.device」要求符合「linux文件係統」
VARI_GLOBAL["REDIS_DATA_PATH"]=$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')/redis
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
function funcPublicRestart(){
  echo "[MYSQL]LATEST VERSION : $(cat ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/shema/version)"
  rm -rf ${VARI_GLOBAL["MYSQL_DATA_PATH"]} && mkdir -p ${VARI_GLOBAL["MYSQL_DATA_PATH"]}
  rm -rf ${VARI_GLOBAL["REDIS_DATA_PATH"]} && mkdir -p ${VARI_GLOBAL["REDIS_DATA_PATH"]}
  # chmod 777 -R /linux
  local variShemaPath=${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/shema
  # [MASTER]persistence
  # variMasterPath="/Users/zengweitao/archived/workspace/repository/chunio/account/"
  # [DOCKER]temporary
  local variContainerWorkPath="/Users/zengweitao/archived/workspace/repository/chunio/account/"
  local variContainerName="account"
  local variPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/usr/bin/env bash
# 會被「docker run」中指定命令覆蓋
return 0
ENTRYPOINTSH
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variContainerName}-nginx:
    image: nginx:1.27.0
    container_name: ${variContainerName}-nginx
    volumes:
      # - /windows:/windows
      - ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/nginx/localhost.chunio.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "80:80"
    networks:
      - common
  # ##################################################
  # mysql[START]
  ${variContainerName}-mysql:
    image: mysql:8.0
    container_name: ${variContainerName}-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${variPassword}
      # MYSQL_INITDB_SKIP_TZINFO: 1
    ports:
      # 宿主端口:容器端口
      - "3306:3306"
    volumes:
      # [數據目錄等於空時]自動按名稱順序執行./*.sh && *.sql
      - ${variShemaPath}:/docker-entrypoint-initdb.d
      - mysql-data:/var/lib/mysql
      # - /windows:/windows
      # - /usr/share/zoneinfo:/usr/share/zoneinfo:ro
      # - /etc/localtime:/etc/localtime:ro
    command: mysqld --host_cache_size=0
    networks:
      - common
  # mysql[END]
  # ##################################################
  ${variContainerName}-redis:
    image: redis:7.2.5
    container_name: ${variContainerName}-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - common
    # 「--appendonly yes」表示是否開啟「AOF (Append Only File)」 /持久化機制
    command: redis-server --appendonly yes --requirepass 0000
  ${variContainerName}-php:
    image: hyperf/hyperf:7.4-alpine-v3.13-swoole-v4.8
    container_name: ${variContainerName}-php
    volumes:
      #　- /windows:/windows
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    working_dir: ${variContainerWorkPath}/backend
    networks:
      - common
    ports:
      - "18306:18306"
    command: ["tail", "-f", "/dev/null"]
    depends_on:
      - ${variContainerName}-nginx
      - ${variContainerName}-mysql
      - ${variContainerName}-redis
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
  docker rm -f "${variContainerName}-php" 2> /dev/null
  docker rm -f "${variContainerName}-redis" 2> /dev/null
  docker rm -f "${variContainerName}-mysql" 2> /dev/null
  docker rm -f "${variContainerName}-nginx" 2> /dev/null
  # 徹底重啟[END]
  docker compose down -v
  # 強制清除未使用的「volume」
  docker volume prune -f
  docker compose -p ${variContainerName} up --build -d
  docker ps -a | grep ${variContainerName}
  cd "${variContainerWorkPath}/backend"
  docker exec -it ${variContainerName}-php /bin/bash -c "php bin/swoft http:restart; exec /bin/bash"
  return 0
}

function funcPublicBackup(){
  local variParameterDescMulti=("custom version（default：YYYYMMDD）")
  funcProtectedCheckOptionParameter 1 'variParameterDescMulti[@]'
  local variContainerName="account-mysql"
  local variUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  local variPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  local variDatabaseList=(
    "account"
  )
  local variDefault=$(date "+%Y%m%d%H%M%S")
  local variShemaVersion=${1:-$variDefault}
  local variShemaVersionPath="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/shema"
  mkdir -p "${variShemaVersionPath}"
  echo "version ：${variShemaVersion}"
  for variEachDatabase in "${variDatabaseList[@]}"; do
    variLatestSqlUrl="${variShemaVersionPath}/${variShemaVersion}.sql"
    # docker exec ${variContainer} mysqldump -u${variUsername} -p${variPassword} ${variEachDatabase} 2>&1 | grep -v "${VARI_GLOBAL["MYSQL_EXEC_IGNORE"]}" > $variLatestSqlUrl
    docker exec ${variContainerName} mysqldump -u${variUsername} -p${variPassword} ${variEachDatabase} > $variLatestSqlUrl
    if [ $? -eq 0 ]; then
      echo "${variContainerName} -> ${variEachDatabase} >> ${variLatestSqlUrl} backup succeeded"
      # update [cloud]latest version[START]
      cat <<INITSQL > ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/shema/00init.sql
CREATE DATABASE IF NOT EXISTS ${variEachDatabase};
USE ${variEachDatabase};
SOURCE /docker-entrypoint-initdb.d/01account.sql;
INITSQL
      # -----
      /usr/bin/cp -rf ${variLatestSqlUrl} ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/shema/01account.sql
      sed -i '1iCREATE DATABASE IF NOT EXISTS account;\nUSE account;\n' ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/shema/01account.sql
      echo ${variShemaVersion} > ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/shema/version
      echo "${variContainerName} -> ${variEachDatabase} >> ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/shema/01account.sql update succeeded"
      # update [cloud]latest version[END]
      # version quantity control[START]
      variAllSqlVersionUriSlice=$(ls -t ${variShemaVersionPath}/*.sql)
      variKeepSqlVersionUriSlice=$(echo "${variAllSqlVersionUriSlice}" | head -n 10)
      for variEachSqlVersionUri in $variAllSqlVersionUriSlice; do
        if ! echo "$variKeepSqlVersionUriSlice" | grep -q "^${variEachSqlVersionUri}$"; then
          rm -rf ${variEachSqlVersionUri}
        fi
      done
      # version quantity control[END]
    else
      echo "${variContainerName} -> ${variEachDatabase} >> ${variLatestSqlUrl} backup failed"
    fi
  done
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"