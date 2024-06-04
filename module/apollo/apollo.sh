#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
[ curl :8070 ]
username : apollo
password : admin
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="SLAVE"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" || true
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"

# ##################################################
# reset builtin variable[START]
VARI_GLOBAL["BUILTIN_RUNTIME_LIMIT"]=0
# reset builtin variable[END]
# global variable[START]
VARI_GLOBAL["SERVICE_DOMAIN"]="http://192.168.255.131"
# 端口詳情：
# [宿主]{13306/{[開發]數據庫/[沙箱]數據庫/[生產]數據庫}} >> [容器]{3306}
# [宿主]{18080/[開發]配置服務 18081/[沙箱]配置服務 18082/[生產]配置服務} >> [容器]{8080}
# [宿主]{18090/[開發]管理服務 18091/[沙箱]管理服務 18092/[生產]管理服務} >> [容器]{8090}
# [宿主]{8070/管理服務} >> [容器]{8070}
VARI_GLOBAL["PORT_LIST"]="3306 13306 13307 13308 8080 18080 18081 18082 8090 18090 18091 18092 8070"
VARI_GLOBAL["MYSQL_USERNAME"]=""
VARI_GLOBAL["MYSQL_PASSWORD"]=""
# 「volumes.driver_opt.device」要求符合「linux文件係統」
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
function funcPublicRunNode() {
  local variParameterDescList=("SQL version（defualt : 0 / example : 20240527010100）")
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
  # 「apollo-env.properties」設置宿主端口（使用於客戶端拉取配置）[START]
  variUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  variPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  cat <<APOLLOENVPROPERTIES > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/apollo-env.properties
development.meta=${VARI_GLOBAL["SERVICE_DOMAIN"]}:18080
sandbox.meta=${VARI_GLOBAL["SERVICE_DOMAIN"]}:18081
production.meta=${VARI_GLOBAL["SERVICE_DOMAIN"]}:18082
portal.api.enabled=true
APOLLOENVPROPERTIES
  # 「apollo-env.properties」設置宿主端口（使用於客戶端拉取配置）[END]
  # 「docker-compose.yml」[START]
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  # ##################################################
  # mysql[START]
  # [兩個服務（即：1apollo-config，2apollo-admin）/同一環境/共享一個]ApolloConfigDB
  # [一個服務（即：apollo-portal）/所有環境/獨享一個]ApolloPortalDB
  apollo-mysql:
    image: mysql:8.0
    container_name: apollo-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${variPassword}
      # MYSQL_INITDB_SKIP_TZINFO: 1
    ports:
      # 宿主端口:容器端口
      - "13306:3306"
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
  # config[START]
  apollo-config-development:
    image: apolloconfig/apollo-configservice:2.2.0
    container_name: apollo-config-development
    depends_on:
      - apollo-mysql
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql:3306/apolloconfigdb_development?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
    ports:
      - 18080:8080
    networks:
      - common
  apollo-config-sandbox:
    image: apolloconfig/apollo-configservice:2.2.0
    container_name: apollo-config-sandbox
    depends_on:
      - apollo-mysql
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql:3306/apolloconfigdb_sandbox?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
    ports:
      - 18081:8080
    networks:
      - common
  apollo-config-production:
    image: apolloconfig/apollo-configservice:2.2.0
    container_name: apollo-config-production
    depends_on:
      - apollo-mysql
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql:3306/apolloconfigdb_production?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
    ports:
      - 18082:8080
    networks:
      - common
  # config[END]
  # ##################################################
  # admin[START]
  apollo-admin-development:
    image: apolloconfig/apollo-adminservice:2.2.0
    container_name: apollo-admin-development
    depends_on:
      - apollo-mysql
      - apollo-config-development
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql:3306/apolloconfigdb_development?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
      - EUREKA_SERVICE_URL=http://apollo-config-development:8080/eureka/
    ports:
      - 18090:8090
    networks:
      - common
  apollo-admin-sandbox:
    image: apolloconfig/apollo-adminservice:2.2.0
    container_name: apollo-admin-sandbox
    depends_on:
      - apollo-mysql
      - apollo-config-sandbox
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql:3306/apolloconfigdb_sandbox?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
      - EUREKA_SERVICE_URL=http://apollo-config-sandbox:8080/eureka/
    ports:
      - 18091:8090
    networks:
      - common
  apollo-admin-production:
    image: apolloconfig/apollo-adminservice:2.2.0
    container_name: apollo-admin-production
    depends_on:
      - apollo-mysql
      - apollo-config-production
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql:3306/apolloconfigdb_production?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
      - EUREKA_SERVICE_URL=http://apollo-config-production:8080/eureka/
    ports:
      - 18092:8090
    networks:
      - common
  # admin[END]
  # ##################################################
  # portal[START]
  apollo-portal-common:
    image: apolloconfig/apollo-portal:2.2.0
    container_name: apollo-portal-common
    depends_on:
      - apollo-mysql
      - apollo-config-development
      - apollo-admin-development
      - apollo-config-sandbox
      - apollo-admin-sandbox
      - apollo-config-production
      - apollo-admin-production
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql:3306/apolloportaldb_common?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
      - EUREKA_SERVICE_URL=http://apollo-config-development:8080/eureka/,http://apollo-config-sandbox:8080/eureka/,http://apollo-config-production:8080/eureka/
    ports:
      - 8070:8070
    volumes:
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/apollo-env.properties:/apollo-portal/config/apollo-env.properties
    networks:
      - common
    # portal[END]
    # ##################################################
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
  # 「docker-compose.yml」[END]
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker-compose down -v
  docker-compose -p apollo up --build -d
  docker update --restart=always apollo-mysql # -development apollo-mysql-sandbox apollo-mysql-production apollo-mysql-portal
  docker update --restart=always apollo-config-development apollo-config-sandbox apollo-config-production
  docker update --restart=always apollo-admin-development apollo-admin-sandbox apollo-admin-production
  docker update --restart=always apollo-portal-common
  docker ps -a | grep apollo
  return 0
}

function funcPublicBackup(){
  local variParameterDescMulti=("custom version（default：YYYYMMDDHHMMSS）")
  funcProtectedCheckOptionParameter 1 variParameterDescMulti[@]
  variContainer="apollo-mysql"
  variUsername=$(funcProtectedPullEncryptEnvi "MYSQL_USERNAME")
  variPassword=$(funcProtectedPullEncryptEnvi "MYSQL_PASSWORD")
  variDatabaseList=(
    "apolloconfigdb_development"
    "apolloconfigdb_sandbox"
    "apolloconfigdb_production"
    "apolloportaldb_common"
  )
  variDefault=$(date "+%Y%m%d%H%M%S")
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
    docker exec apollo-mysql mysqldump -u${variUsername} -p${variPassword} ${variEachDatabase} 2>&1 | grep -v "${VARI_GLOBAL["MYSQL_EXEC_IGNORE"]}" > $variEachSQLUri
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