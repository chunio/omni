#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/20

:<<'MARK'
# --------------------------------------------------
cd /windows/code/backend/chunio/omni && find . -type f -exec dos2unix {} \;
/windows/code/backend/chunio/omni/init/system/system.sh init
# --------------------------------------------------
# [示例]將當前腳本的目標函數[聲明/定義]拷貝至遠端 && 執行函數
# about : funcProtectedTemplate
function funcPublicTemplate() {
    ssh -t root@xxxx 'bash -s' <<EOF
$(typeset -f funcProtectedTemplate)
funcProtectedTemplate
exec \$SHELL
EOF
}
# --------------------------------------------------
# [批量]模糊删除（替換：customKeywork）
EVAL "local cursor='0'; local deleted=0; repeat local result=redis.call('SCAN',cursor,'MATCH','*customKeywork*'); cursor=result[1]; for _,key in ipairs(result[2]) do redis.call('DEL',key); deleted=deleted+1; end; until cursor=='0'; return deleted" 0
# [導出]HAsh/field/value
redis-cli -h ${IP} -p ${PORT} -a ${PASSWORD} HGETALL unicorn:HASH:Temp:2025-01-12:SKADNETWORK:ALGORIX > /windows/runtime/temp.txt
# [統計]文件大小
du -ch /mnt/volume1/unicorn/runtime/bid-request-20250220* | grep total$
# --------------------------------------------------
# [騰訊雲]磁盤管理[START]
# 僅適用於「ext4」文件係統類型（查看：df -T /）
# （1）係統磁盤/擴容
# 查看磁盤信息（含：1分區結構，2掛載信息）
lsblk
yum install -y cloud-utils-growpart
growpart /dev/vda 1
resize2fs /dev/vda1
df -h /dev/vda1
# ----------
#（2A）數據磁盤/掛載
mkdir -p /mnt/datadisk0/unicorn/runtime && mkdir -p /mnt/volume1/unicorn/runtime
mount --bind /mnt/datadisk0/unicorn/runtime /mnt/volume1/unicorn/runtime
df -h /mnt/volume1/unicorn/runtime
mount | grep runtime
# ----------
#（2B）數據磁盤/擴容
# 查看磁盤信息（含：1分區結構，2掛載信息）
lsblk
resize2fs /dev/vdb
df -h /mnt/datadisk0
# [騰訊雲]磁盤管理[END]
# --------------------------------------------------
scp root@170.106.165.51:/windows/runtime/profile001.svg .
# --------------------------------------------------
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="SLAVE"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# global variable[START]
VARI_GLOBAL["JUMPER_ACCOUNT"]=""
VARI_GLOBAL["JUMPER_IP"]=""
VARI_GLOBAL["JUMPER_PORT"]=""
# 0 declare 顯式聲明，支持指定數據類型（否則：字符串（default））
# 1 declare -a 索引數組
# 2 declare -A 關聯數組
# 2 declare -p 打印變量
# 2 declare -P 用於打印關聯數組
# 使用隨機名稱以避免「VARI_GLOBAL[BUILTIN_BASH_ENVI]=MASTER」時，變量衝突
declare -a VARI_B40BC66C185E49E93B95239A8365AC4A
# global variable[END]
# local variable[START]
# local variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedCloudSelector() {
  # --------------------------------------------------
  # call example :
  # funcProtectedCloudSelector
  # local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  # local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  # local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  # for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
  #   variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
  #   variEachModule=$(echo ${variEachValue} | awk '{print $2}')
  #   variEachService=$(echo ${variEachValue} | awk '{print $3}')
  #   variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
  #   variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
  #   variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
  #   variEachIp=$(echo ${variEachValue} | awk '{print $7}')
  #   variEachPort=$(echo ${variEachValue} | awk '{print $8}')
  #   variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
  # done
  # return 0
  # --------------------------------------------------
  VARI_B40BC66C185E49E93B95239A8365AC4A=() # 防御性的
  tar -czf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh 
  # 未使用「local」關鍵字的變量皆全局變量
  local variFirstIndexSlice=(
    "01 COMMON --"
    "02 PADDLEWAVER --"
    "03 YONE --"
  )
  local variSecondIndexSlice=(
    "01 SKELETON include:php/go({adx&&dsp}SingletonGoroutine)"
    "02 ADX --"
    "03 DSP --"
  )
  local variIptableCloudSlice=(
    "01 -- -- 01 ALL SINGAPORE 43.156.140.171 22 iptable"
    "02 -- -- 01 ALL USEAST 170.106.132.12 22 iptable"
  )
  local variPaddlewaverCloudSlice=(
    # ==================================================
    "01 SKELETON SINGLETON 01 PADDLEWAVER SINGAPORE 43.133.61.186 22 --"
    "02 SKELETON SINGLETON 01 PADDLEWAVER USEAST 43.130.116.28 22 --"
    # ==================================================
    "01 ADX NOTICE 01 PADDLEWAVER SINGAPORE 119.28.122.140 22 --"
    "02 ADX NOTICE 02 PADDLEWAVER SINGAPORE 101.32.126.189 22 --"
    "03 ADX NOTICE 01 PADDLEWAVER USEAST 170.106.160.191 22 --"
    "04 ADX NOTICE 02 PADDLEWAVER USEAST 43.130.108.190 22 --"
    "05 ADX BID 01 PADDLEWAVER SINGAPORE 43.134.74.106 22 --"
    "06 ADX BID 02 PADDLEWAVER SINGAPORE 101.32.254.10 22 --"
    "07 ADX BID 03 PADDLEWAVER SINGAPORE 43.159.52.147 22 --"
    "08 ADX BID 04 PADDLEWAVER SINGAPORE 43.156.84.25 22 --"
    "09 ADX BID 05 PADDLEWAVER SINGAPORE 43.133.34.72 22 --"
    "10 ADX BID 06 PADDLEWAVER SINGAPORE 43.134.5.111 22 --"
    "11 ADX BID 07 PADDLEWAVER SINGAPORE 43.163.122.163 22 --"
    "12 ADX BID 08 PADDLEWAVER SINGAPORE 43.156.45.125 22 --"
    "13 ADX BID 09 PADDLEWAVER SINGAPORE 43.163.87.23 22 --"
    "14 ADX BID 10 PADDLEWAVER SINGAPORE 43.163.88.142 22 --"
    "15 ADX BID 01 PADDLEWAVER USEAST 43.166.250.183 22 --"
    "16 ADX BID 02 PADDLEWAVER USEAST 170.106.165.51 22 --"
    "17 ADX BID 03 PADDLEWAVER USEAST 170.106.9.32 22 --"
    "18 ADX BID 04 PADDLEWAVER USEAST 43.166.253.225 22 --"
    "19 ADX BID 05 PADDLEWAVER USEAST 43.130.111.18 22 --"
    # ==================================================
    "01 DSP NOTICE 01 PADDLEWAVER SINGAPORE 43.163.102.16 22 --"
    "02 DSP NOTICE 02 PADDLEWAVER SINGAPORE 43.156.30.57 22 --"
    "03 DSP NOTICE 03 PADDLEWAVER SINGAPORE 43.134.90.124 22 --"
    "04 DSP NOTICE 04 PADDLEWAVER SINGAPORE 43.163.87.38 22 --"
    "05 DSP NOTICE 01 PADDLEWAVER USEAST 43.130.106.95 22 --"
    "06 DSP NOTICE 02 PADDLEWAVER USEAST 170.106.14.178 22 --"
    "07 DSP BID 01 PADDLEWAVER SINGAPORE 119.28.107.30 22 --"
    "08 DSP BID 02 PADDLEWAVER SINGAPORE 43.156.9.31 22 --"
    "09 DSP BID 03 PADDLEWAVER SINGAPORE 43.156.103.66 22 --"
    "10 DSP BID 04 PADDLEWAVER SINGAPORE 150.109.13.128 22 --"
    "11 DSP BID 05 PADDLEWAVER SINGAPORE 43.133.37.245 22 --"
    "12 DSP BID 06 PADDLEWAVER SINGAPORE 43.163.90.220 22 --"
    "13 DSP BID 07 PADDLEWAVER SINGAPORE 43.156.103.34 22 --"
    "14 DSP BID 08 PADDLEWAVER SINGAPORE 43.163.100.13 22 --"
    "15 DSP BID 09 PADDLEWAVER SINGAPORE 43.134.27.101 22 --"
    "16 DSP BID 10 PADDLEWAVER SINGAPORE 43.156.110.205 22 --"
    "17 DSP BID 11 PADDLEWAVER SINGAPORE 43.156.6.213 22 --"
    "18 DSP BID 12 PADDLEWAVER SINGAPORE 43.156.26.249 22 --"
    "19 DSP BID 13 PADDLEWAVER SINGAPORE 43.156.99.95 22 --"
    "20 DSP BID 14 PADDLEWAVER SINGAPORE 43.156.108.53 22 --"
    "21 DSP BID 15 PADDLEWAVER SINGAPORE 129.226.82.236 22 --"
    "22 DSP BID 16 PADDLEWAVER SINGAPORE 43.134.129.99 22 --"
    "23 DSP BID 17 PADDLEWAVER SINGAPORE 124.156.206.54 22 --"
    "24 DSP BID 18 PADDLEWAVER SINGAPORE 43.163.93.187 22 --"
    "25 DSP BID 19 PADDLEWAVER SINGAPORE 43.156.8.253 22 ubuntu"
    "26 DSP BID 01 PADDLEWAVER USEAST 43.130.90.22 22 --"
    "27 DSP BID 02 PADDLEWAVER USEAST 43.130.108.36 22 --"
    "28 DSP BID 03 PADDLEWAVER USEAST 43.166.134.30 22 --"
    "29 DSP BID 04 PADDLEWAVER USEAST 43.166.233.154 22 --"
    # ==================================================
  )
  local variYoneCloudSlice=(
    # ==================================================
    "01 SKELETON SINGLETON 01 YONE SINGAPORE 43.134.87.222 22 --"
    "02 SKELETON SINGLETON 01 YONE USEAST 43.130.147.251 22 --"
    # ==================================================
    "01 ADX NOTICE 01 YONE SINGAPORE 43.159.51.144 22 --"
    "02 ADX NOTICE 02 YONE SINGAPORE 43.133.63.172 22 --"
    "03 ADX NOTICE 01 YONE USEAST 43.130.148.210 22 --"
    "04 ADX NOTICE 02 YONE USEAST 43.130.132.19 22 --"
    "05 ADX BID 01 YONE SINGAPORE 43.156.0.206 22 --"
    "06 ADX BID 02 YONE SINGAPORE 43.134.87.59 22 --"
    "07 ADX BID 03 YONE SINGAPORE 43.134.10.168 22 --"
    "08 ADX BID 04 YONE SINGAPORE 43.163.113.138 22 --"
    "09 ADX BID 05 YONE SINGAPORE 43.134.57.230 22 --"
    "10 ADX BID 06 YONE SINGAPORE 43.156.68.83 22 --"
    "11 ADX BID 07 YONE SINGAPORE 43.163.1.233 22 --"
    "12 ADX BID 08 YONE SINGAPORE 129.226.152.214 22 --"
    "13 ADX BID 01 YONE USEAST 43.130.134.51 22 --"
    "14 ADX BID 02 YONE USEAST 43.166.247.44 22 --"
    # ==================================================
    "01 DSP NOTICE 01 YONE SINGAPORE 43.133.37.4 22 --"
    "02 DSP NOTICE 02 YONE SINGAPORE 129.226.95.66 22 --"
    "03 DSP NOTICE 01 YONE USEAST 43.166.247.136 22 --"
    "04 DSP NOTICE 02 YONE USEAST 43.166.226.222 22 --"
    "05 DSP BID 01 YONE SINGAPORE 43.134.49.186 22 --"
    "06 DSP BID 02 YONE SINGAPORE 43.134.32.190 22 --"
    "07 DSP BID 01 YONE USEAST 43.166.254.65 22 --"
    "08 DSP BID 02 YONE USEAST 43.166.254.61 22 --" 
    # ==================================================
  )
  printf "%-15s %-15s %-15s\n" "INDEX" "CLOUD" "DESC"
  for variEachValue in "${variFirstIndexSlice[@]}"; do
    variEachIndex=$(echo "$variEachValue" | awk '{print $1}')
    variEachCloud=$(echo "$variEachValue" | awk '{print $2}')
    variEachDesc=$(echo "$variEachValue" | awk '{print $3}')
    printf "%-15s %-15s %-15s\n" "$variEachIndex" "$variEachCloud" "$variEachDesc"
  done
  echo -n "enter the index : "
  read variSelectedCloudIndex
  local -a variSelectedCloudSlice
  case $variSelectedCloudIndex in
    01) variSelectedCloudSlice=("${variIptableCloudSlice[@]}") ;;
    02) variSelectedCloudSlice=("${variPaddlewaverCloudSlice[@]}") ;;
    03) variSelectedCloudSlice=("${variYoneCloudSlice[@]}") ;;
    *) echo "invalid selection : ${variSelectedCloudIndex}"; return 1 ;;
  esac
  # ----------
  if [[ ${variSelectedCloudIndex} == "01" ]]; then
    variSelectedModuleName="--" 
  else
    printf "%-15s %-15s %-15s\n" "INDEX" "MODULE" "DESC"
    for variEachValue in "${variSecondIndexSlice[@]}"; do
      variEachIndex=$(echo "$variEachValue" | awk '{print $1}')
      variEachModule=$(echo "$variEachValue" | awk '{print $2}')
      variEachDesc=$(echo "$variEachValue" | awk '{print $3}')
      printf "%-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachDesc"
    done
    echo -n "enter the index : "
    read variSelectedModuleIndex
    case $variSelectedModuleIndex in
      01) variSelectedModuleName="SKELETON" ;;
      02) variSelectedModuleName="ADX" ;;
      03) variSelectedModuleName="DSP" ;;
      *) echo "invalid selection : ${variSelectedModuleIndex}"; return 1 ;;
    esac
  fi
  # ----------
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "DESC"
  local variCheckAllSlice
  declare -A variSelectedCloudMap
  for variEachValue in "${variSelectedCloudSlice[@]}"; do
    [[ $variEachValue == \#* ]] && continue
    variEachIndex=$(echo "$variEachValue" | awk '{print $1}')
    variEachModule=$(echo "$variEachValue" | awk '{print $2}')
    variEachService=$(echo "$variEachValue" | awk '{print $3}')
    variEachLabel=$(echo "$variEachValue" | awk '{print $4}')
    variEachDomain=$(echo "$variEachValue" | awk '{print $5}')
    variEachRegion=$(echo "$variEachValue" | awk '{print $6}')
    variEachIp=$(echo "$variEachValue" | awk '{print $7}')
    variEachPort=$(echo "$variEachValue" | awk '{print $8}')
    variEachDesc=$(echo "$variEachValue" | awk '{print $9}')
    [[ $variEachModule != $variSelectedModuleName* ]] && continue
    variCheckAllSlice="${variCheckAllSlice} $(echo $variEachValue | awk '{print $1}')"
    variSelectedCloudMap[$variEachIndex]="$variEachValue"
    printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachDesc"
  done
  echo -n "enter the index ( 0:當前頁面的全部 / 支持多個,空格間隔 ) : "
  read -a variInputIndexSlice
  local -a variSelectIndexSlice
  #「10#${variInputIndexSlice}」将八進制（如：09）轉換至十進制
  if [[ 10#${variInputIndexSlice} -eq 0 ]]; then
    variSelectIndexSlice=(${variCheckAllSlice})
  else
    variSelectIndexSlice=(${variInputIndexSlice[@]})
  fi
  echo "index : ${variSelectIndexSlice[*]}"
  read -p "input「confirm」to continue : " variInput
  if [[ "$variInput" != "confirm" ]]; then
    return 1
  fi
  for variEachIndex in "${variSelectIndexSlice[@]}"; do
    if [[ -n "${variSelectedCloudMap[$variEachIndex]}" ]]; then
      VARI_B40BC66C185E49E93B95239A8365AC4A+=("${variSelectedCloudMap[$variEachIndex]}")
    fi
  done
  length=${#VARI_B40BC66C185E49E93B95239A8365AC4A[@]}
  if [[ ${length} -eq 0 ]]; then
    echo "invalid selection"
    return 1
  fi 
  # printf '%s\n' "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicRebuildImage(){
  # 構建鏡像[START]
  variParameterDescList=("image pattern（default ：chunio/go:1.25.0（ <namespace>/<repository>:<tag>））" "image main（default : Go1250Main）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=${1-"chunio/go:1.25.0"}
  variImageMain=${2-"Go1250Main"}
  # 習慣:中間橫線，原因：兼容DNS/主機名稱
  variContainerName="chunio-go-1.25.0"
  docker builder prune --all -f
  docker rm -f ${variContainerName} 2> /dev/null
  docker rmi -f $variImagePattern 2> /dev/null
  docker stop $(docker ps -aq)
  # 鏡像不存在時自動執行：docker pull $variImageName
  # DEBUG_LABEL[START]
  # [unsystemd] docker run -d --name ${variContainerName} -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /windows:/windows -p 80:80 ubuntu:24.04 sleep infinity
  # [centos] docker run -d --privileged --name ${variContainerName} -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /windows:/windows --tmpfs /run --tmpfs /run/lock -p 80:80 centos:7.9 /sbin/init
  omni.docker buildSystemdUbuntuImage
  docker run -d \
    --privileged \
    --name ${variContainerName} \
    --tmpfs /tmp \
    --tmpfs /run \
    --tmpfs /run/lock \
    --cgroupns=host \
    -v /windows:/windows \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    systemd.ubuntu /sbin/init
  # DEBUG_LABEL[END]
  docker exec -it ${variContainerName} /bin/bash -c "cd ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]} && ./$(basename "${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]}") rebuildImage_${variImageMain};"
  variContainerId=$(docker ps --filter "name=${variContainerName}" --format "{{.ID}}")
  echo "docker commit $variContainerId $variImagePattern"
  docker commit $variContainerId $variImagePattern
  docker ps --filter "name=${variContainerName}"
  docker images --filter "reference=${variImagePattern}"
  echo "${FUNCNAME} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "docker exec -it ${variContainerName} /bin/bash" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}

# from : funcPublicRebuildImage()
# 運行於容器內部
function funcPublicRebuildImage_Go1250Main(){
  # 減少容器特有/安全性的警告信息[START]
  # 禁止彈出交互窗口，默認配置完成安裝
  export DEBIAN_FRONTEND=noninteractive
  #「invoke-rc.d」依賴運行級別，一個使用於啟動/停止/管理係統服務的腳本
  # invoke-rc.d: could not determine current runlevel
  # invoke-rc.d: policy-rc.d denied execution of start.
  cat <<EOF > /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
  chmod +x /usr/sbin/policy-rc.d
  # No schema files found: doing nothing.
  # 減少容器特有/安全性的警告信息[END]
  apt update
  #「dialog」支持文本界面對話框體 (TUI/text-based user interface)
  #「apt-utils」提供「apt」使用的輔助工具
  apt install -y --no-install-recommends dialog apt-utils ca-certificates
  apt install -y git wget curl make graphviz
  # claude code install[START]
  # 允許安裝「man」幫助手冊[START]
  # 解决警告x22：update-alternatives: warning: skip creation of /usr/share/man/man1/js.1.gz because associated file /usr/share/man/man1/nodejs.1.gz (of link group js) doesn't exist
  sed -i 's/^path-exclude=\/usr\/share\/man/#path-exclude=\/usr\/share\/man/' /etc/dpkg/dpkg.cfg.d/excludes || true
  sed -i 's/^path-exclude=\/usr\/share\/doc/#path-exclude=\/usr\/share\/doc/' /etc/dpkg/dpkg.cfg.d/excludes || true
  # 允許安裝「man」幫助手冊[END]
  apt install -y npm && npm install -g @anthropic-ai/claude-code
  # windows[START]
  # powershell >> irm https://claude.ai/install.ps1 | iex
  # powershell >> [System.Environment]::SetEnvironmentVariable("http_proxy", "http://127.0.0.1:10809", "User")
  # powershell >> [System.Environment]::SetEnvironmentVariable("https_proxy", "http://127.0.0.1:10809", "User")
  # manual >> 配置「[搜尋路徑]C:\Users\zengweitao\.local\bin」至「system variables.Path」
  # windows[END]
  # claude code install[END]
  # wget https://go.dev/dl/go1.25.0.linux-amd64.tar.gz -O ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/go1.25.0.linux-amd64.tar.gz
  tar -xvf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/go1.25.0.linux-amd64.tar.gz -C /usr/local
  variWorkPath="/windows/code/backend"
  mkdir -p ${variWorkPath}
  mkdir -p ${variWorkPath}/golang/{gopath,gocache.linux,gocache.windows}
  mkdir -p ${variWorkPath}/golang/gopath{/bin,/pkg,/src}
  cat <<GOENVLINUX > ${variWorkPath}/golang/go.env.linux
CGO_ENABLED=0
GO111MODULE=on
GOBIN=${variWorkPath}/golang/gopath/bin
GOCACHE=${variWorkPath}/golang/gocache.linux
GOMODCACHE=${variWorkPath}/golang/gopath/pkg/mod
GOPATH=${variWorkPath}/golang/gopath
GOPROXY=https://goproxy.cn,direct
GOROOT=/usr/local/go
GOSUMDB=sum.golang.google.cn
GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
GOENVLINUX
  cat <<ETCBASHRC >> /etc/bashrc
export PATH=$PATH:/usr/local/go/bin:${variWorkPath}/golang/gopath/bin
export GOENV=${variWorkPath}/golang/go.env.linux
ETCBASHRC
  #  mkdir -p ${variWorkPath}/chunio
  #  git clone https://github.com/chunio/omni.git
  #  cd ${variWorkPath}/chunio/omni
  #  chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
  cp -rf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/bin/* ${variWorkPath}/golang/gopath/bin/
  ulimit -n 102400
  return 0
}

# [已驗證/官方容器]成功啟動
# function funcPublicUnicorn()
# {
#   variMasterPath="/windows/code/backend/haohaiyou"
#   variDockerWorkSpace="/windows/code/backend/haohaiyou"
#   variModuleName="unicorn"
#   mkdir -p ${variMasterPath}/{gopath,gocache.linux,gocache.windows}
#   mkdir -p ${variMasterPath}/gopath{/bin,/pkg,/src}
#   cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
# services:
#   ${variModuleName}:
#     image: golang:1.22.4
#     container_name: ${variModuleName}
#     environment:
#       - GOENV=/windows/code/backend/golang/go.env.linux
#       - PATH=$PATH:/usr/local/go/bin:${variDockerWorkSpace}/gopath/bin
#     volumes:
#       - /windows/code/backend/haohaiyou/go.env.linux:/windows/code/backend/golang/go.env.linux
#       - /windows/code/backend/haohaiyou:/windows/code/backend/golang
#     working_dir: /windows/code/backend/golang/gopath/src/${variModuleName}
#     networks:
#       - common
#     command: ["tail", "-f", "/dev/null"]
# networks:
#   common:
#     driver: bridge
# DOCKERCOMPOSEYML
#   cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
#   docker compose down -v
#   docker compose -p ${variModuleName} up --build -d
#   docker update --restart=always ${variModuleName}
#   docker ps -a | grep ${variModuleName}
#   cd ${variMasterPath}/gopath/src/${variModuleName}
#   docker exec -it ${variModuleName} /bin/bash
#   return 0
# }

#「chunio/go:1.22.4」基於「golang:1.22.4」進行調整：
# cat /etc/os-release
# ##################################################
# PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
# NAME="Debian GNU/Linux"
# VERSION_ID="12"
# VERSION="12 (bookworm)"
# VERSION_CODENAME=bookworm
# ID=debian
# HOME_URL="https://www.debian.org/"
# SUPPORT_URL="https://www.debian.org/support"
# BUG_REPORT_URL="https://bugs.debian.org/"
# ##################################################
# apt-get update
# apt-get install -y graphviz
# apt-get install -y vim
function funcPublicUnicorn()
{
  variMasterPath="/windows/code/backend/haohaiyou"
  variDockerWorkSpace="/windows/code/backend/haohaiyou"
  variModuleName="unicorn"
  docker rm -f ${variModuleName} 2> /dev/null
  mkdir -p ${variMasterPath}/{gopath,gocache.linux,gocache.windows}
  mkdir -p ${variMasterPath}/gopath{/bin,/pkg,/src}
  rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/bin/bash
# 會被「docker run」中指定命令覆蓋
touch /etc/bashrc
chmod 644 /etc/bashrc
# /windows/code/backend/chunio/omni/init/system/system.sh init && source /etc/bashrc
# 禁止「return」
# return 0
ENTRYPOINTSH
  rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux
  cat <<GOENVLINUX > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux
CGO_ENABLED=0
GO111MODULE=on
GOBIN=${variDockerWorkSpace}/gopath/bin
GOCACHE=${variDockerWorkSpace}/gocache.linux
GOMODCACHE=${variDockerWorkSpace}/gopath/pkg/mod
GOPATH=${variDockerWorkSpace}/gopath
GOPROXY=https://goproxy.cn,direct
GOROOT=/usr/local/go
GOSUMDB=sum.golang.google.cn
GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
GOENVLINUX
# TODO:chunio/go:1.25.0/error[START]
# root@6ecb6df251c4:/windows/code/backend/haohaiyou/gopath/src/unicorn# make generate
# # go mod tidy
# # go get github.com/google/wire/cmd/wire@latest
# go generate ./...
# # golang.org/x/tools/internal/tokeninternal
# ../../../../../pkg/mod/golang.org/x/tools@v0.22.0/internal/tokeninternal/tokeninternal.go:64:9: invalid array length -delta * delta (constant -256 of type int64)
# module/adx/main/wire_gen.go:3: running "go": exit status 1
# # golang.org/x/tools/internal/tokeninternal
# ../../../../../pkg/mod/golang.org/x/tools@v0.22.0/internal/tokeninternal/tokeninternal.go:64:9: invalid array length -delta * delta (constant -256 of type int64)
# module/dsp/main/wire_gen.go:3: running "go": exit status 1
# make: *** [Makefile:82: generate] Error 1
# TODO:chunio/go:1.25.0/error[END]
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variModuleName}:
    image: chunio/go:1.25.0
    container_name: ${variModuleName}
    environment:
      - HTTP_PROXY=http://192.168.255.1:10809
      - HTTPS_PROXY=http://192.168.255.1:10809
      - NO_PROXY=localhost,127.0.0.1,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
      - GOENV=/go.env.linux
      - PATH=$PATH:/usr/local/go/bin:${variDockerWorkSpace}/gopath/bin
    volumes:
      - /windows:/windows
      - /mnt:/mnt
      # - ${BUILTIN_UNIT_CLOUD_PATH}/bin:${variDockerWorkSpace}/gopath/bin
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/go.env.linux:/go.env.linux
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    working_dir: ${variDockerWorkSpace}/gopath/src/${variModuleName}
    networks:
      - common
    extra_hosts:
      - "host.docker.internal:192.168.255.1"
    ports:
      - "2345:2345"
      - "8000:8000"
      - "8001:8001"
    # entrypoint: ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
    # 啟動進程關閉時，則容器退出
    command: ["tail", "-f", "/dev/null"]
    # 解決提示：connections are not authenticated nor encrypted[START]
    cap_add:
      - SYS_PTRACE
    security_opt:
      - seccomp=unconfined
    # 解決提示：connections are not authenticated nor encrypted[END]
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker compose down -v
  docker compose -p ${variModuleName} up --build -d
  docker update --restart=always ${variModuleName}
  docker ps -a | grep ${variModuleName}
  cd ${variMasterPath}/gopath/src/${variModuleName}
  docker exec -it ${variModuleName} /bin/bash
  return 0
}

function funcPublicSkeleton(){
  # [MASTER]persistence
  variMasterPath="/windows/code/backend/haohaiyou"
  # [DOCKER]temporary
  variDockerWorkSpace="/windows/code/backend/haohaiyou"
  variModuleName="skeleton"
  # variImagePattern=${1:-"hyperf/hyperf:8.3-alpine-v3.19-swoole-5.1.3"}
  variImagePattern=${1:-"chunio/php:8.3.24"}
  cat <<ENTRYPOINTSH > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh
#!/bin/bash
# 會被「docker run」中指定命令覆蓋
return 0
ENTRYPOINTSH
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variModuleName}:
    image: ${variImagePattern}
    container_name: ${variModuleName}
    # 開啟VPN/代理[START]
    # environment:
    #   HTTP_PROXY: http://192.168.255.1:10809
    #   HTTPS_PROXY: http://192.168.255.1:10809
    #   NO_PROXY: localhost,127.0.0.1,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    # extra_hosts:
    #   - "host.docker.internal:host-gateway"
    # 開啟VPN/代理[END]
    volumes:
      - /windows:/windows
      - /mnt:/mnt
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/entrypoint.sh:/usr/local/bin/entrypoint.sh
    working_dir: ${variDockerWorkSpace}/gopath/src/${variModuleName}
    networks:
      - common
    ports:
      - "9501:9501"
    # entrypoint: ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
    # 啟動進程關閉時，則容器退出
    command: ["tail", "-f", "/dev/null"]
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f skeleton 2> /dev/null
  docker compose down -v
  docker compose -p ${variModuleName} up --build -d
  docker update --restart=always ${variModuleName}
  docker ps -a | grep ${variModuleName}
  cd ${variMasterPath}/gopath/src/${variModuleName}
  docker exec -it ${variModuleName} /bin/bash
  return 0
}

function funcPublicCloudIndex(){
  funcProtectedCloudSelector
  local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    echo "===================================================================================================="
    echo ">> [ SLAVE ] ${variEachSlaveValue} ..."
    echo "===================================================================================================="
    rm -rf /root/.ssh/known_hosts
    echo "ssh -o StrictHostKeyChecking=no -J ${variJumperAccount}@${variJumperIp}:${variJumperPort} root@${variEachIp} -p ${variEachPort}"
    # 配置一層[SSH]秘鑰
    # ssh -o StrictHostKeyChecking=no -J ${variJumperAccount}@${variJumperIp}:${variJumperPort} root@${variEachIp} -p ${variEachPort}
    # 配置二層[SSH]秘鑰
    ssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -p ${variJumperPort} ${variJumperAccount}@${variJumperIp}" root@${variEachIp} -p ${variEachPort}
    return 0
  done
  return 0
}

# jump server init[START]
# scp /windows/code/backend/chunio/omni/module/haohaiyou/runtime/omni.haohaiyou.cloud.ssh.tgz root@159.89.116.79:/
# ssh root@159.89.116.79
# tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
# mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
# echo "StrictHostKeyChecking no" > ~/.ssh/config
# chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
# jump server init[END]
function funcPublicCloudJumperReinit() {
  variMasterKeyword="INDEX"
  for variMasterValue in "${VARI_CLOUD[@]}"; do
    if [[ $variMasterValue == *" ${variMasterKeyword} "* ]]; then
      variEachMasterLabel=$(echo $variMasterValue | awk '{print $2}')
      variEachMasterIP=$(echo $variMasterValue | awk '{print $5}')
      variEachMasterPort=$(echo $variMasterValue | awk '{print $6}')
      break
    fi
  done
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  scp -P ${variEachMastrPort} -o StrictHostKeyChecking=no /windows/code/backend/chunio/omni/module/haohaiyou/runtime/omni.haohaiyou.cloud.ssh.tgz ${variJumperAccount}@${variEachMasterIP}:/
:<<MARK
# [manual]ssh init[START]
tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
echo "StrictHostKeyChecking no" > ~/.ssh/config
chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
# [manual]ssh init[END]
MARK
  return 0
}

function funcPublicCloudIptableReinit(){
  funcProtectedCloudSelector
  local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    rm -rf /root/.ssh/known_hosts
    ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -t ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
      rm -rf /root/.ssh/known_hosts
      scp -P ${variEachPort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachIp}:/
      ssh -o StrictHostKeyChecking=no -A -p ${variEachPort} -t root@${variEachIp} <<'SLAVEEOF'
        # --------------------------------------------------
        # （1）ssh init[START]
        tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
        mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
        echo "StrictHostKeyChecking no" > ~/.ssh/config
        chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
        # （1）ssh init[END]
        # --------------------------------------------------
        # （2）omni.system init[START]
        if ! command -v git &> /dev/null; then
            yum install -y git
        fi
        mkdir -p /windows/runtime
        if [ -d "/windows/code/backend/chunio/omni" ]; then
          cd /windows/code/backend/chunio/omni
          echo "[ omni ] git fetch origin ..."
          git fetch origin
          echo "[ omni ] git fetch origin finished"
          echo "[ omni ] git reset --hard origin/main ..."
          git reset --hard origin/main
          echo "[ omni ] git reset --hard origin/main finished"
          chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
        else
          mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
          git clone https://github.com/chunio/omni.git
          cd ./omni && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
        fi
        #（2）omni.system init[END]
        # --------------------------------------------------
        # （3）slave main[START]
        case ${variEachRegion} in
          "SINGAPORE")
            variLanSlice=(
              "redis/skeleton/paddlewaver/envi 172.22.0.42 11110"
              "redis/adx/paddlewaver/common 172.22.0.2 11210"
              "redis/adx/paddlewaver/table 172.22.0.96 11220"
              "redis/dsp/paddlewaver/common 172.22.0.38 11310"
              "redis/dsp/paddlewaver/table 172.22.0.17 11320"
              "redis/dsp/paddlewaver/cluster 172.22.0.33 6379"
              # ----------
              "redis/skeleton/yone/envi 172.22.0.34 21110"
              "redis/adx/yone/common 172.22.0.14 21210"
              "redis/adx/yone/table 172.22.0.59 21220"
              "redis/dsp/yone/common 172.22.0.27 21310"
              "redis/dsp/yone/table 172.22.0.82 21320"
              # ----------
              "clickhouse/mix/mix/http 172.22.0.20 8123"
              "clickhouse/mix/mix/tcp 172.22.0.20 9000"
              "clickhouse/mix/mix/mysql 172.22.0.20 9004"
            )
            ;;
          "USEAST")
            variLanSlice=(
              "redis/skeleton/paddlewaver/envi 10.0.0.27 12110"
              "redis/adx/paddlewaver/common 10.0.0.12 12210"
              "redis/adx/paddlewaver/table 10.0.0.5 12220"
              "redis/dsp/paddlewaver/common 10.0.0.47 12310"
              "redis/dsp/paddlewaver/table 10.0.0.42 12320"
              # ----------
              "redis/skeleton/yone/common 10.0.0.16 22110"
              "redis/adx/yone/common 10.0.0.6 22210"
              "redis/adx/yone/common 10.0.0.11 22220"
              "redis/dsp/yone/common 10.0.0.3 22310"
              "redis/dsp/yone/table 10.0.0.2 22320"
            )
            ;;
          *)
            echo "error : lan not found"
            exit 1
            ;;
        esac
        # declare -p variLanSlice
        # 3A/清空規則
        iptables -t nat -F
        iptables -F FORWARD
        iptables -P FORWARD ACCEPT
        # 3B/追加規則
        for variEachLan in "\${variLanSlice[@]}"; do
          read -r variEachLabel variEachIP variEachPort <<< "\${variEachLan}"
          echo 1 > /proc/sys/net/ipv4/ip_forward
          iptables -t nat -A PREROUTING -p tcp --dport \${variEachPort} -j DNAT --to-destination \${variEachIP}:\${variEachPort}
          iptables -t nat -A POSTROUTING -d \${variEachIP} -p tcp --dport \${variEachPort} -j MASQUERADE
          # iptables -t nat -A POSTROUTING -d \${variEachIP} -p tcp --dport \${variEachPort} -j SNAT --to-source 172.22.0.45
        done
        # 3C/查看規則
        iptables -t nat -L -n -v
        # （3）slave main[END]
        # --------------------------------------------------
SLAVEEOF
JUMPEREOF
  done
  return 0
}

function funcPublicCloudSkeletonRinit() {
  local variParameterDescMulti=("branch : main（default），feature/zengweitao/...")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variBranchName=${1}
  funcProtectedCloudSelector
  local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    rm -rf /root/.ssh/known_hosts
    ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -t ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
        rm -rf /root/.ssh/known_hosts
        scp -P ${variEachPort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachIp}:/
        ssh -o StrictHostKeyChecking=no -p ${variEachPort} -t root@${variEachIp} <<SLAVEEOF
          # --------------------------------------------------
          # （1）ssh init[START]
          tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
          mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
          echo "StrictHostKeyChecking no" > ~/.ssh/config
          chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
          # （1）ssh init[END]
          # --------------------------------------------------
          # （2）omni.system init[START]
          if ! command -v git &> /dev/null; then
              yum install -y git
          fi
          mkdir -p /windows/runtime
          if [ -d "/windows/code/backend/chunio/omni" ]; then
            cd /windows/code/backend/chunio/omni
          else
            mkdir -p /windows/code/backend/chunio
            cd /windows/code/backend/chunio
            git clone https://github.com/chunio/omni.git
            cd ./omni
          fi
          echo "[ omni ] git fetch origin ..."
          git fetch origin
          echo "[ omni ] git fetch origin finished"
          echo "[ omni ] git reset --hard origin/main ..."
          git reset --hard origin/main
          echo "[ omni ] git reset --hard origin/main finished"
          chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
          #（2）omni.system init[END]
          # --------------------------------------------------
          #（3）slave main[START]
          docker rm -f skeleton 2> /dev/null
          if [ -d "/windows/code/backend/haohaiyou/gopath/src/skeleton" ]; then
            cd /windows/code/backend/haohaiyou/gopath/src/skeleton
            echo "[ skeleton ] git fetch origin ..."
            git fetch origin
            echo "[ skeleton ] git fetch origin finished"
            # ----------
            echo "[ skeleton ] git reset --hard origin/${variBranchName} ..."
            git reset --hard origin/${variBranchName}
            echo "[ skeleton ] git reset --hard origin/${variBranchName} finished"
            # ----------
          else
            mkdir -p /windows/code/backend/haohaiyou/gopath/src && cd /windows/code/backend/haohaiyou/gopath/src
            git clone git@github.com:chunio/skeleton.git && cd skeleton
            git checkout ${variBranchName}
          fi
          chmod 777 -R .
          echo "/usr/bin/cp -rf .env.production.${variEachDomain}.${variEachRegion} .env"
          /usr/bin/cp -rf .env.production.${variEachDomain}.${variEachRegion} .env
          expect -c '
          set timeout -1
          spawn /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh skeleton
          expect "skeleton"
          send "composer install\r"
          expect "skeleton"
          send "nohup php bin/hyperf.php start > /windows/runtime/skeleton.log 2>&1 &\r"
          expect "skeleton"
          send "exit\r"
          expect eof
          '
          #（3）slave main[END]
          # --------------------------------------------------
SLAVEEOF
JUMPEREOF
  done
  return 0
}

# 將「80」端口轉發至「9501」端口
# cd /windows/code/backend/chunio/omni && git fetch origin && git reset --hard origin/main && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
function funcPublicCloudSkeletonPaddlewaverProxy(){
  local variParameterDescList=("domain")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  local variDomain=${1:-"paddlewaver"}
  local variModuleName="skeleton"
  local variCurrentIp=$(hostname -I | awk '{print $1}')
  cat <<LOCALSKELETONCONF > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://${variCurrentIp}:9501;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
LOCALSKELETONCONF
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variModuleName}-nginx:
    image: nginx:1.27.0
    container_name: ${variModuleName}-nginx
    volumes:
      - /windows:/windows
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "80:80"
    networks:
      - common
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f skeleton-nginx
  docker compose down -v
  docker compose -p ${variModuleName} up --build -d
  docker ps -a | grep ${variModuleName}
  return 0
}

# 將「80/443」端口轉發至「9501」端口
# cd /windows/code/backend/chunio/omni && git fetch origin && git reset --hard origin/main && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
function funcPublicCloudSkeletonYoneProxy(){
  # local variParameterDescList=("domain")
  # funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  local variDomain=${1:-"skeleton.y-one.co.jp"}
  local variModuleName="skeleton"
  local variCurrentIp=$(hostname -I | awk '{print $1}')
  cat <<LOCALSKELETONCONF > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf
# 80[START]
server {
    listen 80;
    server_name ${variDomain};
    #「Let’s Encrypt」挑戰認證[START]
    location ^~ /.well-known/acme-challenge/ {
        root /etc/nginx/webroot;
        default_type "text/plain";
        allow all;
    }
    #「Let’s Encrypt」挑戰認證[END]
    # return 301 https://\$server_name\$request_uri;
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
# 80[END]
# 443[START]
server {
    listen 443 ssl http2;
    server_name ${variDomain};
    # 證書配置[START]
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_prefer_server_ciphers off;
    # 證書配置[END]
    location / {
        # [CORS/同源策略]預檢響應[START]
        if (\$request_method = 'OPTIONS') {
            # add_header 'Access-Control-Allow-Origin' '*' always;
            # add_header 'Access-Control-Allow-Credentials' 'false' always;
            add_header 'Access-Control-Allow-Origin' 'https://www.y-one.co.jp' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,Xauth' always;
            add_header 'Access-Control-Max-Age' 86400 always;
            # add_header 'Content-Length' 0;
            return 204;
        }
        # [CORS/同源策略]預檢響應[END]
        # [CORS/同源策略]標準響應[START]
        # add_header 'Access-Control-Allow-Origin' '*' always;
        # add_header 'Access-Control-Allow-Credentials' 'false' always;
        add_header 'Access-Control-Allow-Origin' 'https://www.y-one.co.jp' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization,Xauth' always;
        # add_header 'Access-Control-Expose-Headers' 'custom' always;
        # [CORS/同源策略]標準響應[END]
        proxy_pass http://${variCurrentIp}:9501;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
# 443[END]
LOCALSKELETONCONF
  cat <<DOCKERCOMPOSEYML > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml
services:
  ${variModuleName}-nginx:
    image: nginx:1.27.0
    container_name: ${variModuleName}-nginx
    volumes:
      - /windows:/windows
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/local.skeleton.conf:/etc/nginx/conf.d/default.conf
      - /usr/local/nginx/certbot/webroot:/etc/nginx/webroot:rw
      - /usr/local/nginx/certbot/config/live/skeleton.y-one.co.jp/fullchain.pem:/etc/nginx/ssl/fullchain.pem:ro
      - /usr/local/nginx/certbot/config/live/skeleton.y-one.co.jp/privkey.pem:/etc/nginx/ssl/privkey.pem:ro
    ports:
      - "80:80"
      - "443:443"
    networks:
      - common
networks:
  common:
    driver: bridge
DOCKERCOMPOSEYML
  cd ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}
  docker rm -f skeleton-nginx
  docker compose down -v
  docker compose -p ${variModuleName} up --build -d
  docker ps -a | grep ${variModuleName}
  return 0
}

# TODO:ubuntu/error[START]
# enter the index ( 0:當前頁面的全部 / 支持多個,空格間隔 ) : 25
# index : 25
# input「confirm」to continue : confirm
# 13e286f4449f9cfe3bc592306e97c975  /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/unicorn_dsp
# Warning: Permanently added '119.28.55.124' (ECDSA) to the list of known hosts.
# unicorn_dsp -> 100% 41MB 5.1MB/s 00:08
# Pseudo-terminal will not be allocated because stdin is not a terminal.
# ====================================================================================================
# >> [ SLAVE ] 25 DSP BID 19 PADDLEWAVER SINGAPORE 43.156.8.253 22 ubuntu ...
# ====================================================================================================
# Warning: Permanently added '43.156.8.253' (ECDSA) to the list of known hosts.
# Permission denied, please try again.
# Permission denied, please try again.
# Permission denied (publickey,password).
# lost connection
# Permission denied, please try again.
# Permission denied, please try again.
# Permission denied (publickey,password).
# lost connection
# Pseudo-terminal will not be allocated because stdin is not a terminal.
# Permission denied, please try again.
# Permission denied, please try again.
# Permission denied (publickey,password).
# // omni.haohaiyou cloudUnicornReinit ...
# TODO:ubuntu/error[END]
function funcPublicCloudUnicornReinit() {
  local variParameterDescMulti=("module : dsp，adx" "branch : main，feature/zengweitao/...")
  funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variModuleName=$1
  variBranchName=$2
  variEnvi="PRODUCTION"
  variBinName="unicorn_${variModuleName}"
  variScpAble=1
  variScpSyncOnce=0
  # slave variable[START]
  # systemctl reload crond
  variCrontabUri="/var/spool/cron/root"
  # slave variable[END]
  case ${variModuleName} in
    "adx")
        variHttpPort=8001
        variGrpcPort=9001
        ;;
    "dsp")
        variHttpPort=8000
        variGrpcPort=9000
        ;;
    *)
        return 1
        ;;
  esac
  funcProtectedCloudSelector
  local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    # 檢測目標節點環節是否支持當前模塊[START]
    variEachValueLower=$(echo "$variEachValue" | tr 'A-Z' 'a-z')
    if [[ $variEachValueLower != *$variModuleName* && $variEachValueLower != *singleton* ]]; then
      echo "invalid selection : [ ${variEachValue} ]"
      continue
    fi
    # 檢測目標節點環節是否支持當前模塊[END]
    rm -rf /root/.ssh/known_hosts
    if [[ ${variScpAble} -eq 1 ]]; then
      if [[ ${variScpSyncOnce} -eq 0 ]]; then
        md5sum /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName}
        scp -P ${variJumperPort} -o StrictHostKeyChecking=no /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName} ${variJumperAccount}@${variJumperIp}:/
        variScpSyncOnce=1
      fi 
    fi
    variEachLabelUpper=$(echo "${variEachDomain}/${variModuleName}/${variEachService}/${variEachRegion}/${variEachLabel}" | tr 'a-z' 'A-Z')
    variEachCrontabTask="* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor ${variEachLabelUpper}"
    ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -t ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
      rm -rf /root/.ssh/known_hosts
      if [[ ${variScpAble} -eq 1 ]]; then
        scp -P ${variEachPort} -o StrictHostKeyChecking=no /${variBinName} root@${variEachIp}:/
        scp -P ${variEachPort} -o StrictHostKeyChecking=no /omni.haohaiyou.cloud.ssh.tgz root@${variEachIp}:/
      fi
      ssh -o StrictHostKeyChecking=no -A -p ${variEachPort} -t root@${variEachIp} <<SLAVEEOF
        # --------------------------------------------------
        # （1）ssh init[START]
        tar -xzvf /omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
        mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
        echo "StrictHostKeyChecking no" > ~/.ssh/config
        chmod 600 ~/.ssh/* && chown root:root ~/.ssh/*
        # （1）ssh init[END]
        # --------------------------------------------------
        # （2）omni.system init[START]
        if ! command -v git &> /dev/null; then
            yum install -y git
        fi
        mkdir -p /windows/runtime
        if [ -d "/windows/code/backend/chunio/omni" ]; then
          cd /windows/code/backend/chunio/omni
        else
          mkdir -p /windows/code/backend/chunio
          cd /windows/code/backend/chunio
          git clone https://github.com/chunio/omni.git
          cd ./omni
        fi
        echo "[ omni ] git fetch origin ..."
        git fetch origin
        echo "[ omni ] git fetch origin finished"
        echo "[ omni ] git reset --hard origin/main ..."
        git reset --hard origin/main
        echo "[ omni ] git reset --hard origin/main finished"
        chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
        #（2）omni.system init[END]
        # --------------------------------------------------
        #（3）slave main[START]
        ulimit -n 655360
        docker rm -f unicorn 2> /dev/null
        if [ -d "/windows/code/backend/haohaiyou/gopath/src/unicorn" ]; then
          cd /windows/code/backend/haohaiyou/gopath/src/unicorn
          # ----------
          echo "[ unicorn ] git fetch origin ..."
          git fetch origin
          echo "[ unicorn ] git fetch origin finished"
          # ----------
          echo "[ unicorn ] git reset --hard origin/${variBranchName} ..."
          git reset --hard origin/${variBranchName}
          echo "[ unicorn ] git reset --hard origin/${variBranchName} finished"
          # ----------
        else
          mkdir -p /windows/code/backend/haohaiyou/gopath/src && cd /windows/code/backend/haohaiyou/gopath/src
          git clone git@github.com:chunio/unicorn.git && cd unicorn
          git checkout ${variBranchName}
        fi
        /windows/code/backend/chunio/omni/init/system/system.sh port ${variHttpPort} kill
        /windows/code/backend/chunio/omni/init/system/system.sh port ${variGrpcPort} kill
        # /windows/code/backend/chunio/omni/init/system/system.sh process unicorn kill
        mkdir -p ./bin && chmod 777 -R .
        /usr/bin/cp -rf /${variBinName} ./bin/${variBinName} 
        echo "" > /windows/runtime/${variBinName}.command
        nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachService} -LABEL ${variEachLabel} -DOMAIN ${variEachDomain} -REGION ${variEachRegion} > /windows/runtime/${variBinName}.log 2>&1 &
        (
          while true; do
            if grep -q ":${variHttpPort}" /windows/runtime/${variBinName}.log; then
              cat /windows/runtime/${variBinName}.log
              echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachService} -LABEL ${variEachLabel} -DOMAIN ${variEachDomain} -REGION ${variEachRegion} > /windows/runtime/${variBinName}.log 2>&1 & [success]"
              echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachService} -LABEL ${variEachLabel} -DOMAIN ${variEachDomain} -REGION ${variEachRegion} > /windows/runtime/${variBinName}.log 2>&1 &" > /windows/runtime/${variBinName}.command
              break
            elif grep -qE "failed|error|panic" /windows/runtime/${variBinName}.log; then
              cat /windows/runtime/${variBinName}.log
              break
            fi
            sleep 1
          done
        ) # &
        # unicorn[END]
        # supervisor[START]
        if grep -Fq "cloudUnicornSupervisor" "${variCrontabUri}"; then
          sed -i '/cloudUnicornSupervisor/d' "${variCrontabUri}"
        fi
        # 重置日誌
        # echo "" >> /windows/runtime/supervisor.log
        echo "${variEachCrontabTask}" >> "${variCrontabUri}"
        # 僅使用於「variEachService=SINGLETON」[START]
        if [[ ${variEachService} == "SINGLETON" ]]; then
          if grep -Fq "cloudSclickArchived" "${variCrontabUri}"; then
            sed -i '/cloudSclickArchived/d' "${variCrontabUri}"
          fi
          echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudSclickArchived" >> "${variCrontabUri}"
        fi
        # 僅使用於「variEachService=SINGLETON」[END]
        cat "${variCrontabUri}"
        systemctl reload crond
        echo "[ cloudUnicornSupervisor ] crontab init succeeded"
        # supervisor[END]
        /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudHostReinit
        md5sum /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName}
        #（3）slave main[END]
        # --------------------------------------------------
SLAVEEOF
JUMPEREOF
  done
  return 0
}

function funcPublicCloudUnicornCheck() {
  funcProtectedCloudSelector
  local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $9}')
    rm -rf /root/.ssh/known_hosts
    ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -t ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
      rm -rf /root/.ssh/known_hosts
      ssh -o StrictHostKeyChecking=no -p ${variEachPort} -t root@${variEachIp} <<SLAVEEOF
        tail -n 50 /windows/runtime/unicorn_${variEachModule,,}.log
        # 按「文件大小」倒敘排序，取前10個
        ls -lhS /windows/code/backend/haohaiyou/gopath/src/unicorn/runtime | grep -v '^d' | head -n 11
        df -h
SLAVEEOF
JUMPEREOF
  done
  return 0
}

# (crontab -l 2>/dev/null; echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudSkeletonSupervisor") | crontab -
# 更新腳本時無需重啟「crontab」
# function funcPublicCloudSkeletonSupervisor(){
#   variHost="localhost"
#   variPort=9501
#   timeout=${timeout:-1}
#   variCurrentUtc0Datetime=$(date -u +"%Y-%m-%d %H:%M:%S")
#   # check heartbeat[START]
#   if timeout ${timeout} bash -c "</dev/tcp/${variHost}/${variPort}" >/dev/null 2>&1; then
#     echo "[ ${variCurrentUtc0Datetime} / ${variPort} ] health check succeeded，${variHost}:${variPort} is active" >> /windows/runtime/supervisor.log
#   else
#     echo "[ ${variCurrentUtc0Datetime} / ${variPort} ] health check failed，${variHost}:${variPort} is inactive" >> /windows/runtime/supervisor.log
#     # supervisor[START]
#     /windows/code/backend/chunio/omni/common/docker/docker.sh process unicorn kill
#     cd /windows/code/backend/haohaiyou/gopath/src/unicorn
#     eval "$(cat /windows/runtime/command.variable)"
#     echo "[ ${variCurrentUtc0Datetime} ] health check action，${variHost}:${variPort} is restart" >> /windows/runtime/supervisor.log
#     # supervisor[END]
#   fi
#   # check heartbeat[END]
#   return 0
# }

# (crontab -l 2>/dev/null; echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor") | crontab -
# 更新腳本時無需重啟「crontab」
function funcPublicCloudUnicornSupervisor(){
  local variParameterDescMulti=("label ：PADDLEWAVER/ADX/BID/SINGAPORE/01")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variLabel=$1
  # 使用「/」分割 >> 提取第二的元素 >> 轉至小寫
  variModuleName=$(echo "${variLabel}" | cut -d'/' -f2 | tr 'A-Z' 'a-z')
  variHost="localhost"
  case ${variModuleName} in
    "adx")
        variHttpPort=8001
        variGrpcPort=9001
        ;;
    "dsp")
        variHttpPort=8000
        variGrpcPort=9000
        ;;
    *)
        return 1
        ;;
  esac
  variTimeout=${variTimeout:-1}
  variCurrentUtc0Datetime=$(date -u +"%Y-%m-%d %H:%M:%S")
  # check heartbeat[START]
  if timeout ${variTimeout} bash -c "</dev/tcp/${variHost}/${variHttpPort}" >/dev/null 2>&1; then
    echo "[ UTC0 : ${variCurrentUtc0Datetime} ] health check succeeded，${variHost}:${variHttpPort} is active" >> /windows/runtime/supervisor.log
  else
    echo "[ UTC0 : ${variCurrentUtc0Datetime} ] health check failed，${variHost}:${variHttpPort} is inactive" >> /windows/runtime/supervisor.log
    /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh feishu "${variLabel}" "HealthCheckFailed"
    # supervisor[START]
    /windows/code/backend/chunio/omni/init/system/system.sh port ${variHttpPort} kill
    /windows/code/backend/chunio/omni/init/system/system.sh port ${variGrpcPort} kill
    /usr/bin/cp -rf /windows/runtime/unicorn_${variModuleName}.log /windows/runtime/unicorn_${variModuleName}_$(date +%Y%m%d%H%M%S).log
    # /windows/code/backend/chunio/omni/init/system/system.sh process unicorn kill
    cd /windows/code/backend/haohaiyou/gopath/src/unicorn
    eval "$(cat /windows/runtime/unicorn_${variModuleName}.command)"
    echo "[ UTC0 : ${variCurrentUtc0Datetime} ] health check action，${variHost}:${variHttpPort} is restart" >> /windows/runtime/supervisor.log
    # supervisor[END]
  fi
  # check heartbeat[END]
  return 0
}

function funcPublicCloudHostReinit(){
  local variEtcHostsUri="/etc/hosts"
  local variIp2DomainSlice=(
    "172.22.0.51 sg.adx.paddlewaver.localhost.com"
    "10.0.0.24 us.adx.paddlewaver.localhost.com"
    "172.22.0.91 sg.dsp.paddlewaver.localhost.com"
    "10.0.0.29 us.dsp.paddlewaver.localhost.com"
    "172.22.0.67 sg.dsp.yone.localhost.com"
    "10.0.0.18 us.dsp.yone.localhost.com"
  )
  # /usr/bin/cp -rf "$variEtcHostsUri" "${variEtcHostsUri}.backup.$(date '+%Y%m%d%H%M%S')"
  local variEachRecord variDomain variIp
  for variEachRecord in "${variIp2DomainSlice[@]}"; do
    variIp=$(awk '{print $1}' <<< "$variEachRecord")
    variDomain=$(awk '{print $2}' <<< "$variEachRecord")
    if grep -qE "[[:space:]]${variDomain}([[:space:]]|$)" "$variEtcHostsUri"; then
      sed -i "/[[:space:]]${variDomain}\([[:space:]]\|$\)/d" "$variEtcHostsUri"
    fi
    echo "$variIp $variDomain" >> "$variEtcHostsUri"
    echo "$variEtcHostsUri << $variIp $variDomain"
  done
  return 0
}

function funcPublicCloudSclickArchived(){
  local variExecuteId="EXECUTE_ID_$(date -u "+%Y%m%d_%H%M%S_%N")"
  local variKeywordUtc0DatehourStart=$(date -u -d "24 hours ago" "+%Y%m%d%H")
  local variKeywordUtc0DatehourEnd=$(date -u "+%Y%m%d%H")
  # local variKeywordUtc0DatehourEnd=$(date -u -d "1 hour ago" "+%Y%m%d%H")
  local variPath="/mnt/volume1/unicorn/runtime/"
  local variMethod="gzip"
  case ${variMethod} in
  "gzip")
      variOption="czf"
      variSuffix="tgz"
      ;;
  "bzip2")
      if ! command -v bzip2 >/dev/null 2>&1; then
        yum install -y bzip2
      fi
      variOption="cjf"
      variSuffix="bz2"
      ;;
  "xz")
      variOption="cJf"
      variSuffix="xz"
      ;;
  *)
      return 1
      ;;
  esac
  local variArchivedLockUri="/windows/runtime/archived.lock"
  local variArchivedExitUri="/windows/runtime/archived.exit"
  local variArchivedLogUri="/windows/runtime/archived.log"
  local variGoroutineActiveLimit=4
  # local variGoroutineActiveNum=0
  if [ -f "${variArchivedLockUri}" ]; then
    echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] the last task did not completed" >> "${variArchivedLogUri}"
    return 0
  fi
  touch "${variArchivedLockUri}"
  echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} ACTION" >> "${variArchivedLogUri}"
  #「*bid-request*」相關日誌僅保留6個小時，超時刪除[START]
  local variBidRequestCustomHour=$(date -u -d "6 hours ago" "+%Y%m%d%H")
  find "${variPath}" -type f -name "*bid-request*" | while read -r variEachFileUri; do
    variEachFilename=$(basename "${variEachFileUri}")
    if [[ ${variEachFilename} =~ ([0-9]{10}) ]]; then
      variEachUtc0Datehour=${BASH_REMATCH[1]}
      if [[ ${variEachUtc0Datehour} =~ ^[0-9]{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])(0[0-9]|1[0-9]|2[0-3])$ ]]; then
        if [[ "${variEachUtc0Datehour}" -lt "${variBidRequestCustomHour}" ]]; then
          rm -rf "${variEachFileUri}"
          echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} ${variEachFileUri} DELETED" >> "${variArchivedLogUri}"
        fi
      fi 
    fi
  done
  #「*bid-request*」相關日誌僅保留6個小時，超時刪除[END]
  local variOrderByUtc0DatehourDescUri=$(mktemp)
  # ORDER BY「storage」DESC
  # find "${variPath}" -type f -name "*.log" -printf '%s %p\n' | sort -n | cut -d' ' -f2- | while read -r variEachFileUri; do
  find "${variPath}" -type f -name "*.log" | while read -r variEachFileUri; do
    variEachFilename=$(basename "${variEachFileUri}")
    if [[ $variEachFilename =~ ([0-9]{10}) ]]; then
      variEachUtc0Datehour=${BASH_REMATCH[1]}
      if [[ ${variEachUtc0Datehour} =~ ^[0-9]{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])(0[0-9]|1[0-9]|2[0-3])$ ]]; then
        if [[ "${variEachUtc0Datehour}" -ge "${variKeywordUtc0DatehourStart}" && "${variEachUtc0Datehour}" -lt "${variKeywordUtc0DatehourEnd}" ]]; then
          variEachArchivedUri="${variEachFileUri%.log}.${variSuffix}"
          if [[ ! -f "${variEachArchivedUri}" ]]; then
              # ll -lh "${variEachFileUri}"
              echo "${variEachUtc0Datehour} ${variEachFileUri} ${variEachArchivedUri}" >> "${variOrderByUtc0DatehourDescUri}"
          fi
        fi
      fi
    fi
  done
  # ORDER BY「variEachUtc0Datehour」DESC[START]
  sort -r -k1,1 "${variOrderByUtc0DatehourDescUri}" | while read -r variEachUtc0Datehour variEachFileUri variEachArchivedUri; do
    {
      variEachStartTime=$(date +%s.%N)
      # include path
      echo "time tar -${variOption} ${variEachArchivedUri} -C ${variPath} $(basename ${variEachFileUri})"
      time tar -${variOption} ${variEachArchivedUri} -C ${variPath} "$(basename "${variEachFileUri}")"
      # case ${variCommand} in
      # "tar")
      #     echo "time tar -${variOption} ${variEachArchivedUri} ${variEachFileUri}"
      #     time tar -${variOption} ${variEachArchivedUri} ${variEachFileUri}
      #     ;;
      # "xz")
      #     #「-T0」：啟用多核（優點：關閉耗時:啟用耗時≈22:09，缺點：關閉負載:啟用耗時≈2.5:11.5）
      #     echo "time xz -${variOption} ${variEachFileUri} > ${variEachArchivedUri}"
      #     time xz -${variOption} ${variEachFileUri} > ${variEachArchivedUri}
      #     # xz -d ${variEachArchivedUri}
      #     ;;
      # *)
      #     return 1
      #     ;;
      # esac
      variEachEndTime=$(date +%s.%N)
      variEachDuration=$(echo "${variEachEndTime} - ${variEachStartTime}" | bc)
      variEachFileSize=$(echo "scale=2; $(stat -c%s "${variEachFileUri}")/1048576" | bc)
      variEachArchivedSize=$(echo "scale=2; $(stat -c%s "${variEachArchivedUri}")/1048576" | bc)
      echo "-> ${variEachDuration} / ${variEachFileSize}MB >> ${variEachArchivedSize}MB ${variEachArchivedUri}" succeeded >> "${variArchivedLogUri}"
    } &
    while [ "$(jobs -r | wc -l)" -ge ${variGoroutineActiveLimit} ]; do
        # exit signal monitor[START]
        if [ -f "${variArchivedExitUri}" ]; then
          echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} EXIT" >> "${variArchivedLogUri}"
          jobs -p | xargs kill -9
          wait
          rm -rf "${variOrderByUtc0DatehourDescUri}" "${variArchivedLockUri}" "${variArchivedExitUri}"
          return 0
        fi
        # exit signal monitor[END]
        sleep 1
    done
  done
  # 阻塞至「當前進行/所有任務」執行完畢//
  wait
  # ORDER BY「variEachUtc0Datehour」DESC[END]
  # 處理「imp_streamstate02-*」文件[START]
  # local variTodayUtc0Date=$(date -u "+%Y%m%d")
  # local variYesterdayUtc0Date=$(date -u -d "yesterday" +"%Y%m%d")
  # if [[ ! -f "${variPath}imp_streamstate02-${variYesterdayUtc0Date}.${variSuffix}" ]]; then
    # 移除{空行 && 雙引號}
    # rm -rf ${variPath}imp_streamstate02-${variYesterdayUtc0Date}.log
    # sed '/^$/d; s/"//g' ${variPath}imp_streamstate02-${variTodayUtc0Date}.log > ${variPath}imp_streamstate02-${variYesterdayUtc0Date}.log
    # time tar -${variOption} ${variEachArchivedUri} -C ${variPath} "$(basename "${variEachFileUri}")"
  # fi
  # 處理「imp_streamstate02-*」文件[END]
  echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} COMPLETED" >> "${variArchivedLogUri}"
  rm -rf "${variOrderByUtc0DatehourDescUri}" "${variArchivedLockUri}" "${variArchivedExitUri}"
  return 0
}

function funcPublicFeishu(){
  local variParameterDescMulti=("label" "message")
  funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variLabel=$1
  local variMessage=$2
  local variFeishuWebhook="https://open.feishu.cn/open-apis/bot/v2/hook/c10997f8-7322-452a-b7b7-bc36ded483c2"
  local variBody="{
    \"msg_type\": \"text\",
    \"content\": {
      \"text\": \"{\\\"label\\\":\\\"${variLabel}\\\",\\\"message\\\":\\\"${variMessage}\\\"}\"
    }
  }"
  echo $(curl -s -X POST -H "Content-Type: application/json" -d "${variBody}" "${variFeishuWebhook}")
  return 0
}

function funcPublicCdUnicornRuntime(){
  cd /windows/code/backend/haohaiyou/gopath/src/unicorn/runtime
  pwd
  df -h
  ll -lh
  return 0
}

function funcPublicTailUnicornNotice(){
  cd /windows/code/backend/haohaiyou/gopath/src/unicorn/runtime
  pwd
  df -h
  echo "tail -f notice-$(date -u +%Y%m%d).log"
  tail -f notice-$(date -u +%Y%m%d).log
  return 0
}


# gcloud auth activate-service-account --key-file=/windows/runtime/protectedmedia-468207-afb588ea4c73.json
# gsutil ls -lh gs://1001069.reports.protected.media/2025/08/17
# gsutil cp gs://1001069.reports.protected.media/2025/08/17/hourly-report-by-levels-1001069-20250817-00.csv /windows/runtime
function funcPublicPullProtectedMediaHourlyReport(){
# 注意：每行頂格
#   cat <<EOF > /etc/yum.repos.d/google-cloud-sdk.repo
# [google-cloud-sdk]
# name=Google Cloud SDK
# baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
# enabled=1
# gpgcheck=1
# repo_gpgcheck=1
# gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
#        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
# EOF
  # chmod -R 644 /etc/yum.repos.d
  # yum install -y google-cloud-sdk
  variParameterDescList=("utc0 date（example ：2025-01-01）")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variUtc0Date="${1:-$(date -u +%Y-%m-%d)}"
  local variBucketId="1001069"
  local variBucketName="${variBucketId}.reports.protected.media"
  local variPrivateKeyUri=${VARI_GLOBAL['BUILTIN_UNIT_CLOUD_PATH']}/protectedmedia-468207-afb588ea4c73.json
  local variDownloadPath="/windows/runtime"
  gcloud auth activate-service-account --key-file="${variPrivateKeyUri}" 
  local variYear="${variUtc0Date:0:4}"
  local variMonth="${variUtc0Date:5:2}"
  local variDay="${variUtc0Date:8:2}"
  local variUtc0DateShortName="${variYear}${variMonth}${variDay}"
  mkdir -p "$variDownloadPath"
  for variEachIndex in $(seq 0 23); do
    variEachHour=$(printf "%02d" "$variEachIndex")
    variEachFilename="hourly-report-by-levels-${variBucketId}-${variUtc0DateShortName}-${variEachHour}.csv"
    variEachFileUri="gs://${variBucketName}/${variYear}/${variMonth}/${variDay}/${variEachFilename}"
    if ! gsutil -q stat "$variEachFileUri"; then
      echo "[ MISS ] ${variYear}/${variMonth}/${variDay}/${variEachFilename}"
      continue
    fi
    echo "gsutil cp ${variEachFileUri} ${variDownloadPath}/"
    gsutil cp "$variEachFileUri" "$variDownloadPath"/
  done
  ls -lh $variDownloadPath/hourly-report-by-levels-*
  return 0
}

# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"