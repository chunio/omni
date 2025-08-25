#!/bin/bash
# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<MARK
1，mongodb://root:0000@192.168.255.131:27017/test?authSource=admin&replicaSet=rs0
2，已設置副本集（即：支持事務）
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="SLAVE"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

VARI_GLOBAL["MONGO_DATA_PATH"]=$(echo "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}" | sed 's/windows/linux/')/mongo

function funcPublicRunNode(){
    variCurrentIP=$(hostname -I | awk '{print $1}')
    rm -rf ${VARI_GLOBAL["MONGO_DATA_PATH"]}
    mkdir -p ${VARI_GLOBAL["MONGO_DATA_PATH"]}
    chmod -R 777 ${VARI_GLOBAL["MONGO_DATA_PATH"]}
    cat <<EOF > ${VARI_GLOBAL["MONGO_DATA_PATH"]}/mongod.conf
storage:
  dbPath: /data/db
net:
  bindIp: 0.0.0.0
  port: 27017
security:
  authorization: disabled
setParameter:
  enableLocalhostAuthBypass: true
replication:
  replSetName: rs0
EOF
    cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  mongodb7:
    image: mongo:7.0
    container_name: mongo
    ports:
      - "27017:27017"
    volumes:
      - ${VARI_GLOBAL["MONGO_DATA_PATH"]}:/data/db
      - ${VARI_GLOBAL["MONGO_DATA_PATH"]}/mongod.conf:/etc/mongod.conf
    command: ["mongod", "--config", "/etc/mongod.conf"]
    networks:
      - common

networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
    cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
    docker-compose down -v
    docker-compose -p mongo up --build -d
    # check status[START]
    for i in {1..120}; do
        if docker ps | grep -q mongo; then
            echo "[ check ] attempt : ${i}/120 / mongo is active && db.adminCommand('ping') ..."
            if docker exec mongo mongosh --eval "db.adminCommand('ping')" --quiet; then
                echo "mongo is active"
                break
            fi
        else
            echo "[ check ] attempt : ${i}/120 / mongo is inactive && docker logs mongo ..."
            docker logs mongo
            sleep 1
            continue
        fi
        if [ $i -eq 120 ]; then
            echo "mongo start failed && docker logs mongo ..."
            docker logs mongo
            return 1
        fi
    done
    # check status[END]
    docker exec mongo mongosh --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: '${variCurrentIP}:27017'}]})"
    for i in {1..10}; do
        if docker exec mongo mongosh --eval "rs.status().ok" --quiet | grep -q "1"; then
            echo "replica set initialized successfully"
            break
        fi
        if [ $i -eq 10 ]; then
            echo "replica set initialization failed && docker logs mongo ..."
            docker logs mongo
            return 1
        fi
        sleep 1
    done
    docker exec mongo mongosh --eval "admin = db.getSiblingDB('admin'); admin.createUser({user: 'root', pwd: '0000', roles: ['root']})"
    docker update --restart=always mongo
    docker ps -a | grep mongo
    return 0
}

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"