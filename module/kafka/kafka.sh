#!/bin/bash

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

# global variable[END]
# ##################################################

# ##################################################
# protected function[START]

# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicRunNode()
{
  variCurrentIP=$(hostname -I | awk '{print $1}')
  cat <<DOCKERCOMPOSEYML >  ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  zookeeper:
    image: bitnami/zookeeper:3.7
    container_name: zookeeper
    ports:
      - "2181:2181"
    environment:
      - ALLOW_ANONYMOUS_LOGIN=yes
    networks:
      - common
  kafka:
    image: bitnami/kafka:3.7
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
  docker-compose down -v
  docker-compose -p kafka up --build -d
  docker update --restart=always zookeeper
  docker update --restart=always kafka
  docker ps -a | grep -E 'zookeeper|kafka'
  return 0
}

# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"