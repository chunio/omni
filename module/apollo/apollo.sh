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
VARI_GLOBAL["SERVICE_DOMAIN"]="http://192.168.255.104"
# 端口詳情：
# [宿主]{13306/[開發]數據庫 13307/[沙箱]數據庫 13308/[生產]數據庫} >> [容器]{3306}
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
function funcPublicRebuild() {
  local variParameterDescList=("SQL version（defualt : 0 / example : 20240527010100）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  # -----
  variSQLVersion=${1:-0}
  variSQLPath=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/sql/${variSQLVersion}
  if [ $variSQLVersion == 0 ] || [ ! -d "${variSQLPath}" ];then
    variSQLPath=${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql
  fi
  # -----
  rm -rf ${VARI_GLOBAL["MYSQL_DATA_PATH"]} && mkdir -p /windows ${VARI_GLOBAL["MYSQL_DATA_PATH"]}/{development,sandbox,production,portal}
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
version: '3.8'
services:
  # ##################################################
  # mysql[START]
  apollo-mysql-development:
    image: mysql:5.7
    container_name: apollo-mysql-development
    environment:
      MYSQL_ROOT_PASSWORD: ${variPassword}
      MYSQL_DATABASE: ApolloConfigDB
    ports:
      # 宿主端口:容器端口
      - "13306:3306"
    volumes:
      # [數據目錄等於空時]自動按名稱順序執行./*.sh && *.sql
      - ${variSQLPath}/apollo-mysql-development:/docker-entrypoint-initdb.d
      - mysql-data-development:/var/lib/mysql
      - /windows:/windows
    networks:
      - apollo-network
  apollo-mysql-sandbox:
    image: mysql:5.7
    container_name: apollo-mysql-sandbox
    environment:
      MYSQL_ROOT_PASSWORD: ${variPassword}
      MYSQL_DATABASE: ApolloConfigDB
    ports:
      - "13307:3306"
    volumes:
      - ${variSQLPath}/apollo-mysql-sandbox:/docker-entrypoint-initdb.d
      - mysql-data-sandbox:/var/lib/mysql
      - /windows:/windows
    networks:
      - apollo-network
  apollo-mysql-production:
    image: mysql:5.7
    container_name: apollo-mysql-production
    environment:
      MYSQL_ROOT_PASSWORD: ${variPassword}
      MYSQL_DATABASE: ApolloConfigDB
    ports:
      - "13308:3306"
    volumes:
      - ${variSQLPath}/apollo-mysql-production:/docker-entrypoint-initdb.d
      - mysql-data-production:/var/lib/mysql
      - /windows:/windows
    networks:
      - apollo-network
  apollo-mysql-portal:
    image: mysql:5.7
    container_name: apollo-mysql-portal
    environment:
      MYSQL_ROOT_PASSWORD: ${variPassword}
      MYSQL_DATABASE: ApolloPortalDB
    ports:
      - "13309:3306"
    volumes:
      - ${variSQLPath}/apollo-mysql-portal:/docker-entrypoint-initdb.d
      - mysql-data-portal:/var/lib/mysql
      - /windows:/windows
    networks:
      - apollo-network
  # mysql[END]
  # ##################################################
  # config[START]
  apollo-config-development:
    image: apolloconfig/apollo-configservice:2.2.0
    container_name: apollo-config-development
    depends_on:
      - apollo-mysql-development
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql-development:3306/ApolloConfigDB?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
    ports:
      - 18080:8080
    networks:
      - apollo-network
  apollo-config-sandbox:
    image: apolloconfig/apollo-configservice:2.2.0
    container_name: apollo-config-sandbox
    depends_on:
      - apollo-mysql-sandbox
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql-sandbox:3306/ApolloConfigDB?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
    ports:
      - 18081:8080
    networks:
      - apollo-network
  apollo-config-production:
    image: apolloconfig/apollo-configservice:2.2.0
    container_name: apollo-config-production
    depends_on:
      - apollo-mysql-production
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql-production:3306/ApolloConfigDB?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
    ports:
      - 18082:8080
    networks:
      - apollo-network
  # config[END]
  # ##################################################
  # admin[START]
  apollo-admin-development:
    image: apolloconfig/apollo-adminservice:2.2.0
    container_name: apollo-admin-development
    depends_on:
      - apollo-mysql-development
      - apollo-config-development
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql-development:3306/ApolloConfigDB?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
      - EUREKA_SERVICE_URL=http://apollo-config-development:8080/eureka/
    ports:
      - 18090:8090
    networks:
      - apollo-network
  apollo-admin-sandbox:
    image: apolloconfig/apollo-adminservice:2.2.0
    container_name: apollo-admin-sandbox
    depends_on:
      - apollo-mysql-sandbox
      - apollo-config-sandbox
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql-sandbox:3306/ApolloConfigDB?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
      - EUREKA_SERVICE_URL=http://apollo-config-sandbox:8080/eureka/
    ports:
      - 18091:8090
    networks:
      - apollo-network
  apollo-admin-production:
    image: apolloconfig/apollo-adminservice:2.2.0
    container_name: apollo-admin-production
    depends_on:
      - apollo-mysql-production
      - apollo-config-production
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql-production:3306/ApolloConfigDB?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
      - EUREKA_SERVICE_URL=http://apollo-config-production:8080/eureka/
    ports:
      - 18092:8090
    networks:
      - apollo-network
  # admin[END]
  # ##################################################
  # portal[START]
  apollo-portal-common:
    image: apolloconfig/apollo-portal:2.2.0
    container_name: apollo-portal-common
    depends_on:
      - apollo-mysql-development
      - apollo-config-development
      - apollo-admin-development
      - apollo-mysql-sandbox
      - apollo-config-sandbox
      - apollo-admin-sandbox
      - apollo-mysql-production
      - apollo-config-production
      - apollo-admin-production
    environment:
      - DS_URL=jdbc:mysql://apollo-mysql-portal:3306/ApolloPortalDB?characterEncoding=utf8
      - DS_USERNAME=${variUsername}
      - DS_PASSWORD=${variPassword}
      - EUREKA_SERVICE_URL=http://apollo-config-development:8080/eureka/,http://apollo-config-sandbox:8080/eureka/,http://apollo-config-production:8080/eureka/
    ports:
      - 8070:8070
    volumes:
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/apollo-env.properties:/apollo-portal/config/apollo-env.properties
    networks:
      - apollo-network
    # portal[END]
    # ##################################################
networks:
  apollo-network:
    driver: bridge
volumes:
  mysql-data-development:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${VARI_GLOBAL["MYSQL_DATA_PATH"]}/development
  mysql-data-sandbox:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${VARI_GLOBAL["MYSQL_DATA_PATH"]}/sandbox
  mysql-data-production:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${VARI_GLOBAL["MYSQL_DATA_PATH"]}/production
  mysql-data-portal:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${VARI_GLOBAL["MYSQL_DATA_PATH"]}/portal
DOCKERCOMPOSEYML
  # 「docker-compose.yml」[END]
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker-compose down -v
  docker-compose up --build -d
  docker ps -a | grep apollo
  return 0
}

function funcPublicBackup(){
  declare -A map=(
    ["apollo-mysql-production"]="ApolloConfigDB"
    ["apollo-mysql-development"]="ApolloConfigDB"
    ["apollo-mysql-sandbox"]="ApolloConfigDB"
    ["apollo-mysql-portal"]="ApolloPortalDB"
  )
  variSQLVersion=$(date "+%Y%m%d%H%M%S")
  variSQLVersionPath=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/sql/${variSQLVersion}
  echo "version ：${variSQLVersion}"
  for variEachContainer in "${!map[@]}"; do
    variEachDatabase=${map[${variEachContainer}]}
    mkdir -p ${variSQLVersionPath}/${variEachContainer}
    cat <<INITSQL > ${variSQLVersionPath}/${variEachContainer}/00init.sql
CREATE DATABASE IF NOT EXISTS ${variEachDatabase};
USE ${variEachDatabase};
INITSQL
    variEachSQLUri="${variSQLVersionPath}/${variEachContainer}/01${variEachContainer}.sql"
    docker exec ${variEachContainer} mysqldump -u${variUsername} -p${variPassword} ${variEachDatabase} 2>&1 | grep -v "${VARI_GLOBAL["MYSQL_EXEC_IGNORE"]}" > $variEachSQLUri
    if [ $? -eq 0 ]; then
      echo "${variEachContainer} -> ${variEachDatabase} >> ${variEachSQLUri} backup succeeded"
    else
      echo "${variEachContainer} -> ${variEachDatabase} >> ${variEachSQLUri} backup failed"
    fi
  done
  return 0
}

# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"