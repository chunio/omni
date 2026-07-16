#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
[offset explorer >> JAAS Config]
KafkaClient {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="root"
   password="0000";
};
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
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicDocker()
{
  variCurrentIP=$(hostname -I | awk '{print $1}')
  cat <<DOCKERCOMPOSEYML >  ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  zookeeper:
    image: bitnamilegacy/zookeeper:3.7.0
    container_name: zookeeper
    ports:
      - "2181:2181"
    environment:
      - ALLOW_ANONYMOUS_LOGIN=yes
    networks:
      - common
  kafka:
    image: bitnamilegacy/kafka:3.7.0
    container_name: kafka
    ports:
      - "9092:9092"
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_CFG_LISTENERS=PLAINTEXT://:9092
      - KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://${variCurrentIP}:9092
      - KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT
      - KAFKA_CFG_INTER_BROKER_LISTENER_NAME=PLAINTEXT
      - ALLOW_PLAINTEXT_LISTENER=yes
      - KAFKA_CFG_AUTHORIZER_CLASS_NAME=kafka.security.authorizer.AclAuthorizer
      - KAFKA_CFG_SUPER_USERS=User:root
      - KAFKA_CFG_ALLOW_EVERYONE_IF_NO_ACL_FOUND=true
      - KAFKA_CLIENT_USERS=root
      - KAFKA_CLIENT_PASSWORDS=0000
    depends_on:
      - zookeeper
    networks:
      - common
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  # docker compose down -v
  docker compose -p kafka down -v 2> /dev/null
  docker compose -p kafka up --build -d
  docker update --restart=always zookeeper
  docker update --restart=always kafka
  docker ps -a | grep -E 'zookeeper|kafka'
  return 0
}

function funcPublicImportBusinessData_Haohaiyou() {
  local variContainerName="kafka"
  local variTopicSlice=(
    # ----------
    paddlewaver_adx_imp_stream_topic
    paddlewaver_adx_imp_stat02_topic
    paddlewaver_adx_bid_stat_topic
    paddlewaver_adx_track_stat_topic
    paddlewaver_adx_dsp_stat02_topic
    paddlewaver_adx_landing_page_topic
    # ----------
    paddlewaver_dsp_budo_stat_topic
    paddlewaver_dsp_imp_stat10_topic
    paddlewaver_dsp_imp_stat10_bid_union_topic
    paddlewaver_dsp_imp_stat10_track_union_topic
    paddlewaver_dsp_imp_stat10_conversion_union_topic
    paddlewaver_dsp_imp_stream10_topic
    paddlewaver_dsp_imp_stream10_hour_stat_track_union_topic
    paddlewaver_dsp_imp_stream10_value_stat_track_union_topic
    # ----------
    paddlewaver_adx_sclick_bid_request_sg_topic
    paddlewaver_adx_sclick_track_impression_sg_topic
    paddlewaver_adx_sclick_bid_request_us_topic
    paddlewaver_adx_sclick_track_impression_us_topic
    # ----------
    paddlewaver_dsp_sclick_bid_request_sg_topic
    paddlewaver_dsp_sclick_track_impression_sg_topic
    paddlewaver_dsp_sclick_bid_request_us_topic
    paddlewaver_dsp_sclick_track_impression_us_topic
    # ----------
  )
  if [ ${#variTopicSlice[@]} -eq 0 ]; then
    echo "[ warn ] topic list is empty(1)"
    return 0
  fi
  local variContainerStatus=$(docker inspect -f '{{.State.Status}}' "${variContainerName}" 2>/dev/null)
  if [ "$variContainerStatus" != "running" ]; then
    echo "[ error ] '${variContainerName}' is ${variContainerStatus}"
    return 1
  fi
  local variRetryNum=30 # 重試次數
  local variRetryInterval=2 # 重試間隔(unit:second)
  local variEachTopic variImportStatus variEachCommand
  for variEachTopic in "${variTopicSlice[@]}"; do
    echo "[ import ] create topic : ${variEachTopic}"
    variImportStatus="failed" # default
    for ((variRetryIndex=1; variRetryIndex<=variRetryNum; variRetryIndex++)); do
      # [忽略]WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.
      variEachCommand="docker exec -i ${variContainerName} kafka-topics.sh --create --bootstrap-server localhost:9092 --topic ${variEachTopic} --partitions 1 --replication-factor 1 --if-not-exists"
      if eval "${variEachCommand}"; then
        variImportStatus="succeeded"
        funcProtectedTrace "${variEachTopic} create ${variImportStatus}"
        break
      else
        echo "[ retry ] ${variRetryIndex}/${variRetryNum}  ..."
        sleep ${variRetryInterval}
      fi
    done
    if [ "$variImportStatus" = "failed" ]; then
      funcProtectedTodo "${variEachTopic} create ${variImportStatus}"
    fi
  done
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"