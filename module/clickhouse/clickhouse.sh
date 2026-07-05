#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
include : clickhouse-client --host=192.168.255.131 --port=9000 --user=default --password=0000
最小內存：2G
 * Linux transparent hugepages are set to "always". Check /sys/kernel/mm/transparent_hugepage/enabled
 * Linux threads max count is too low. Check /proc/sys/kernel/threads-max
 * Available memory at server startup is too low (2GiB).
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
VARI_GLOBAL["CLICKHOUSE_USERNAME"]=""
VARI_GLOBAL["CLICKHOUSE_PASSWORD"]=""
VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]="$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')/clickhouse"
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicDocker(){
  # local variParameterDescList=("SQL version（default : 0 / example : 20240828）")
  # funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  # ----------
  rm -rf ${VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]}
  mkdir -p ${VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]}
  chmod -R 777 ${VARI_GLOBAL["CLICKHOUSE_DATA_PATH"]}
  # ----------
  rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/users.d
  mkdir -p ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/users.d
  # ----------
  local variSchemaPath="${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/schema"
  local variClickhouseUsername=$(funcProtectedPullEncryptEnvi "CLICKHOUSE_USERNAME")
  local variClickhousePassword=$(funcProtectedPullEncryptEnvi "CLICKHOUSE_PASSWORD")
  local variClickhousePasswordSha256=$(echo -n "${variClickhousePassword}" | sha256sum | cut -d' ' -f1)
  cat <<DEFAULTUSERXML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/users.d/default-user.xml
<clickhouse>
    <users>
        <${variClickhouseUsername}>
            <password_sha256_hex>${variClickhousePasswordSha256}</password_sha256_hex>
            <networks>
                <ip>::/0</ip>
            </networks>
            <profile>${variClickhouseUsername}</profile>
            <quota>${variClickhouseUsername}</quota>
            <access_management>1</access_management>
        </${variClickhouseUsername}>
    </users>
</clickhouse>
DEFAULTUSERXML
  cat <<CONFIGXML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/config.xml
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
    <user_directories>
        <users_xml>
            <path>/etc/clickhouse-server/users.xml</path>
        </users_xml>
        <local_directory>
            <path>/var/lib/clickhouse/access/</path>
        </local_directory>
    </user_directories>
</yandex>
CONFIGXML
  # [固定]文件名稱「users.xml」
  cat <<USERSXML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/users.xml
<yandex>
    <users>
        <${variClickhouseUsername}>
            <password_sha256_hex>${variClickhousePasswordSha256}</password_sha256_hex>
            <networks>
                <ip>::/0</ip>
            </networks>
            <profile>${variClickhouseUsername}</profile>
            <quota>${variClickhouseUsername}</quota>
            <access_management>1</access_management>
        </${variClickhouseUsername}>
    </users>
    <profiles>
        <${variClickhouseUsername}>
            <max_memory_usage>10000000000</max_memory_usage>
            <use_uncompressed_cache>0</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
        </${variClickhouseUsername}>
    </profiles>
    <quotas>
        <${variClickhouseUsername}>
            <interval>
                <duration>3600</duration>
                <queries>0</queries>
                <errors>0</errors>
                <result_rows>0</result_rows>
                <read_rows>0</read_rows>
                <execution_time>0</execution_time>
            </interval>
        </${variClickhouseUsername}>
    </quotas>
</yandex>
USERSXML
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  clickhouse:
    # image: clickhouse/clickhouse-server:24.8.2.3
    image: clickhouse/clickhouse-server:25.3.3.42
    container_name: clickhouse
    # user: "101:101"
    environment:
      CLICKHOUSE_DB: default
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/config.xml:/etc/clickhouse-server/config.xml
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/users.xml:/etc/clickhouse-server/users.xml
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/users.d:/etc/clickhouse-server/users.d
      - clickhouse-data:/var/lib/clickhouse
      # - /windows:/windows
      # - ${variSchemaPath}:/docker-entrypoint-initdb.d
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
  # docker compose down -v
  docker compose -p clickhouse down -v 2> /dev/null
  docker compose -p clickhouse up --build -d
  docker update --restart=always clickhouse
  docker ps -a | grep clickhouse
  echo "username : ${variClickhouseUsername}"
  echo "password : ${variClickhousePassword}"
  for variRetryIndex in {1..120}; do
    if docker exec clickhouse clickhouse-client --user=${variClickhouseUsername} --password=${variClickhousePassword} -q "SELECT 1" &>/dev/null; then
        echo "clickhouse is active"
        break
    fi
    echo "[ check ] attempt : ${variRetryIndex}/120 ..."
    sleep 1
  done
  if false; then
    local variRetryNum=120
    for variEachSql in ${variSchemaPath}/*.sql; do
      if [ -f "$variEachSql" ]; then
        for ((variRetryIndex=1; variRetryIndex<=variRetryNum; variRetryIndex++)); do
          echo "[ import ] attempt : ${variRetryIndex}/${variRetryNum} ..."
          # docker exec -i clickhouse clickhouse-client --user=${variClickhouseUsername} --password=${variClickhousePassword} < "$variEachSql"
          if docker exec -i clickhouse clickhouse-client --user=${variClickhouseUsername} --password=${variClickhousePassword} < "$variEachSql"; then
            echo "import : $variEachSql"
            echo "docker exec -i clickhouse clickhouse-client --user=${variClickhouseUsername} --password=${variClickhousePassword} < ${variEachSql}"
            echo "successfully imported ${variEachSql}"
            break
          else
            if [ $variRetryIndex -eq $variRetryNum ]; then
              echo "failed to import ${variEachSql}"
            fi
            sleep 1
          fi
        done
      fi
    done
  fi
  return 0
}

function funcPublicImportBusinessData_Haohaiyou() {
  local variContainerName="clickhouse"
  local varSchemaMasterPath="${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/schema/haohaiyou"
  local variClickhouseUsername=$(funcProtectedPullEncryptEnvi "CLICKHOUSE_USERNAME")
  local variClickhousePassword=$(funcProtectedPullEncryptEnvi "CLICKHOUSE_PASSWORD")
  if [ ! -d "${varSchemaMasterPath}" ]; then
    echo "[ warn ] ${varSchemaMasterPath} is empty(0)"
    return 1
  fi
  # 目錄排序/名稱升序[START]
  local variSchemeSlavePathSlice
  mapfile -t variSchemeSlavePathSlice < <(find "${varSchemaMasterPath}" -mindepth 1 -maxdepth 1 -type d | sort -V)
  # 目錄排序/名稱升序[END]
  if [ ${#variSchemeSlavePathSlice[@]} -eq 0 ]; then
    echo "[ warn ] ${varSchemaMasterPath} is empty(1)"
    return 0
  fi
  local variConteinerStatus=$(docker inspect -f '{{.State.Status}}' "${variContainerName}" 2>/dev/null)
  if [ "$variConteinerStatus" != "running" ]; then
    echo "[ error ] '${variContainerName}' is ${variConteinerStatus}"
    return 1
  fi
  local variRetryNum=30 # 重試次數
  local variRetryInterval=2 # 重試間隔(unit:second)
  local variEachSchemaSlavePath variEachSqlUri variImportStatus variEachCommand
  local variSqlUriSlice
  for variEachSchemaSlavePath in "${variSchemeSlavePathSlice[@]}"; do
    # 文件排序/名稱升序[START]
    mapfile -t variSqlUriSlice < <(find "${variEachSchemaSlavePath}" -maxdepth 1 -name "*.sql" -type f | sort -V)
    # 文件排序/名稱升序[END]
    if [ ${#variSqlUriSlice[@]} -eq 0 ]; then
      echo "[ warn ] ${variEachSchemaSlavePath} is empty(2)"
      continue
    fi
    for variEachSqlUri in "${variSqlUriSlice[@]}"; do
      echo "[ import ] ${variEachSqlUri}"
      variImportStatus="failed" # default
      for ((variRetryIndex=1; variRetryIndex<=variRetryNum; variRetryIndex++)); do
        variEachCommand="docker exec -i ${variContainerName} clickhouse-client -n --user=${variClickhouseUsername}"
        if [ -n "${variClickhousePassword}" ]; then
          variEachCommand="${variEachCommand} --password=${variClickhousePassword}"
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
  done
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"