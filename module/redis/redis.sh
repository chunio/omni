#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
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
function funcPublicRebuildSingle()
{
  cat <<REDISCONF > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/redis.conf
bind 0.0.0.0
protected-mode yes
port 6379
requirepass 0000
REDISCONF
  cat <<DOCKERCOMPOSEYML >  ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
version: '3.8'
services:
  redis:
    image: redis:7.0
    container_name: redis70
    ports:
      - "6389:6379"
    volumes:
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/redis.conf:/usr/local/etc/redis/redis.conf
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker-compose down -v
  docker-compose up --build -d
  docker ps -a | grep redis70
  return 0
}
function funcPublicRebuildCluster()
{
  #!/bin/bash

# 定义变量
REDIS_VERSION="7.0"
REDIS_MASTER_PORT=6389
REDIS_SLAVE_PORT=6399
REDIS_PASSWORD="0000"
COMPOSE_FILE="docker-compose.yml"

# 创建 docker-compose.yml 文件
cat > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml <<EOF
version: '3.8'
services:
  redis-master:
    image: redis:${REDIS_VERSION}
    container_name: redis-master
    command: ["redis-server", "--requirepass", "${REDIS_PASSWORD}", "--port", "${REDIS_MASTER_PORT}", "--appendonly", "yes"]
    ports:
      - "${REDIS_MASTER_PORT}:${REDIS_MASTER_PORT}"
    networks:
      - redis-cluster-net

  redis-slave:
    image: redis:${REDIS_VERSION}
    container_name: redis-slave
    command: ["redis-server", "--requirepass", "${REDIS_PASSWORD}", "--port", "${REDIS_SLAVE_PORT}", "--appendonly", "yes", "--slaveof", "redis-master", "${REDIS_MASTER_PORT}"]
    depends_on:
      - redis-master
    ports:
      - "${REDIS_SLAVE_PORT}:${REDIS_SLAVE_PORT}"
    networks:
      - redis-cluster-net

networks:
  redis-cluster-net:
    driver: bridge
EOF
# 启动 Redis 集群
cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
docker-compose up -d

# 输出连接信息
echo "Redis 集群已启动"
echo "主节点：$(hostname -I | awk '{print $1}'):${REDIS_MASTER_PORT}"
echo "从节点：$(hostname -I | awk '{print $1}'):${REDIS_SLAVE_PORT}"
echo "密码：${REDIS_PASSWORD}"

}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"