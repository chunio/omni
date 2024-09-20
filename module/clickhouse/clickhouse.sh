#!/bin/bash

# author : [Your Name]
# datetime : 2024/05/20

:<<MARK
include : clickhouse-client --host=192.168.255.131 --port=9000 --user=default --password=0000
最小內存：2G
 * Linux transparent hugepages are set to "always". Check /sys/kernel/mm/transparent_hugepage/enabled
 * Linux threads max count is too low. Check /proc/sys/kernel/threads-max
 * Available memory at server startup is too low (2GiB).
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="SLAVE"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# global variable[START]
VARI_GLOBAL["CLICKHOUSE_USERNAME"]=""
VARI_GLOBAL["CLICKHOUSE_PASSWORD"]=""
VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]=$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')
VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]=$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')/clickhouse
# global variable[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicRunNode(){
  # local variParameterDescList=("SQL version（default : 0 / example : 20240828）")
  # funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  # -----
  variSQLPath=${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/sql
  # -----
  rm -rf ${VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]} && mkdir -p /windows ${VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]}
  chmod 777 -R /linux ${VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]}
  # -----
  variUsername=$(funcProtectedPullEncryptEnvi "CLICKHOUSE_USERNAME")
  variPassword=$(funcProtectedPullEncryptEnvi "CLICKHOUSE_PASSWORD")
  variPasswordSha256=$(echo -n "${variPassword}" | sha256sum | cut -d' ' -f1)
  cat <<CONFIGXML > ${VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]}/config.xml
<yandex>
    <logger>
        <level>trace</level>
        <log>/var/log/clickhouse-server/clickhouse-server.log</log>
        <errorlog>/var/log/clickhouse-server/clickhouse-server.err.log</errorlog>
        <size>1000M</size>
        <count>10</count>
    </logger>
    <http_port>8123</http_port>
    <tcp_port>9000</tcp_port>
    <listen_host>::</listen_host>
    <max_connections>4096</max_connections>
    <keep_alive_timeout>3</keep_alive_timeout>
    <max_concurrent_queries>100</max_concurrent_queries>
    <uncompressed_cache_size>8589934592</uncompressed_cache_size>
    <mark_cache_size>5368709120</mark_cache_size>
    <path>/var/lib/clickhouse/</path>
    <tmp_path>/var/lib/clickhouse/tmp/</tmp_path>
    <user_files_path>/var/lib/clickhouse/user_files/</user_files_path>
    <format_schema_path>/var/lib/clickhouse/format_schemas/</format_schema_path>
    <users_config>users.xml</users_config>
    <default_profile>default</default_profile>
    <default_database>default</default_database>
    <timezone>UTC</timezone>
    <mlock_executable>false</mlock_executable>
    <builtin_dictionaries_reload_interval>3600</builtin_dictionaries_reload_interval>
    <max_session_timeout>3600</max_session_timeout>
    <default_session_timeout>60</default_session_timeout>
</yandex>
CONFIGXML
  # [固定]文件名稱「users.xml」
  cat <<USERSXML > ${VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]}/users.xml
<yandex>
    <users>
        <${variUsername}>
            <password_sha256_hex>${variPasswordSha256}</password_sha256_hex>
            <networks>
                <ip>::/0</ip>
            </networks>
            <profile>${variUsername}</profile>
            <quota>${variUsername}</quota>
            <access_management>1</access_management>
        </${variUsername}>
    </users>
    <profiles>
        <${variUsername}>
            <max_memory_usage>10000000000</max_memory_usage>
            <use_uncompressed_cache>0</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
        </${variUsername}>
    </profiles>
    <quotas>
        <${variUsername}>
            <interval>
                <duration>3600</duration>
                <queries>0</queries>
                <errors>0</errors>
                <result_rows>0</result_rows>
                <read_rows>0</read_rows>
                <execution_time>0</execution_time>
            </interval>
        </${variUsername}>
    </quotas>
</yandex>
USERSXML
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  clickhouse:
    image: clickhouse/clickhouse-server:24.8.2.3
    container_name: clickhouse
    user: "101:101"
    environment:
      CLICKHOUSE_DB: default
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      - ${VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]}/config.xml:/etc/clickhouse-server/config.xml
      - ${VARI_GLOBAL["LINUX_UNIT_RUNTIME_PATH"]}/users.xml:/etc/clickhouse-server/users.xml
      - clickhouse-data:/var/lib/clickhouse
      - /windows:/windows
      # - ${variSQLPath}:/docker-entrypoint-initdb.d
    ulimits:
      nofile:
        soft: 262144
        hard: 262144
    networks:
      - common
networks:
  common:
    driver: bridge
volumes:
  clickhouse-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]}
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker-compose down -v
  docker-compose -p clickhouse up --build -d
  docker update --restart=always clickhouse
  docker ps -a | grep clickhouse
  echo "username : ${variUsername}"
  echo "password : ${variPassword}"
  for variRetryIndex in {1..120}; do
    if docker exec clickhouse clickhouse-client --user=${variUsername} --password=${variPassword} -q "SELECT 1" &>/dev/null; then
        echo "clickhouse is active"
        break
    fi
    echo "[ check ] attempt : ${variRetryIndex}/120 ..."
    sleep 1
  done
  variRetryNum=120
  for variEachSQL in ${variSQLPath}/*.sql; do
    if [ -f "$variEachSQL" ]; then
      for ((variRetryIndex=1; variRetryIndex<=variRetryNum; variRetryIndex++)); do
        echo "[ import ] attempt : ${variRetryIndex}/${variRetryNum} ..."
        # docker exec -i clickhouse clickhouse-client --user=${variUsername} --password=${variPassword} < "$variEachSQL"
        if docker exec -i clickhouse clickhouse-client --user=${variUsername} --password=${variPassword} < "$variEachSQL"; then
          echo "import : $variEachSQL"
          echo "docker exec -i clickhouse clickhouse-client --user=${variUsername} --password=${variPassword} < ${variEachSQL}"
          echo "successfully imported ${variEachSQL}"
          break
        else
          if [ $variRetryIndex -eq $variRetryNum ]; then
            echo "failed to import ${variEachSQL}"
          fi
          sleep 1
        fi
      done
    fi
  done
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"