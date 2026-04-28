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
# TODO:[SingletonGoroutine.go]添加每日定時任務：find /var/spool/postfix/maildrop -type f -delete
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
function funcProtectedOmniReinit(){
  # git[START]
  if ! command -v git &> /dev/null; then
    local variOperatingSystem=""
    [ -f /etc/os-release ] && variOperatingSystem=$(. /etc/os-release && echo "${ID}")
    case "${variOperatingSystem}" in
      "centos"|"rhel"|"rocky"|"almalinux")
        yum install -y git
        ;;
      "ubuntu"|"debian")
        apt-get update && apt-get install -y git
        ;;
      *)
        yum install -y git 2>/dev/null || apt-get update && apt-get install -y git 2>/dev/null
        ;;
    esac
  fi
  # git[END]
  # omni.system init[START]
  mkdir -p /windows/runtime
  if [ -d "/windows/code/backend/chunio/omni/.git" ]; then
    cd /windows/code/backend/chunio/omni
  else
    rm -rf /windows/code/backend/chunio/omni
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
  chmod 777 -R .
  ./init/system/system.sh init
  [ -f /etc/bashrc ] && source /etc/bashrc
  [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
  # omni.system init[END]
  return 0
}

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
  #   variEachOs=$(echo ${variEachValue} | awk '{print $9}')
  #   variEachDesc=$(echo ${variEachValue} | awk '{print $10}')
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
    "01 -- -- 01 ALL SINGAPORE 43.156.140.171 22 CENTOS iptable"
    "02 -- -- 01 ALL USEAST 170.106.132.12 22 CENTOS iptable"
  )
  local variPaddlewaverCloudSlice=(
    # ==================================================
    "01 SKELETON MASTER 01 PADDLEWAVER SINGAPORE 43.133.61.186 22 CENTOS --"
    "02 SKELETON MASTER 01 PADDLEWAVER USEAST 43.130.116.28 22 CENTOS --"
    "03 SKELETON SLAVE 01 PADDLEWAVER SINGAPORE 43.156.226.228 22 CENTOS --"
    "04 SKELETON SLAVE 01 PADDLEWAVER USEAST 43.130.150.62 22 CENTOS --"
    # ==================================================
    "01 ADX TRACK 01 PADDLEWAVER SINGAPORE 119.28.122.140 22 CENTOS --"
    "02 ADX TRACK 02 PADDLEWAVER SINGAPORE 101.32.126.189 22 CENTOS --"
    "03 ADX TRACK 01 PADDLEWAVER USEAST 170.106.160.191 22 CENTOS --"
    "04 ADX TRACK 02 PADDLEWAVER USEAST 43.130.108.190 22 CENTOS --"
    "05 ADX BID 01 PADDLEWAVER SINGAPORE 43.134.74.106 22 CENTOS --"
    "06 ADX BID 02 PADDLEWAVER SINGAPORE 101.32.254.10 22 CENTOS --"
    "07 ADX BID 01 PADDLEWAVER USEAST 43.166.250.183 22 CENTOS --"
    "08 ADX BID 02 PADDLEWAVER USEAST 170.106.165.51 22 CENTOS --"
    # ==================================================
    "01 DSP TRACK 01 PADDLEWAVER SINGAPORE 43.163.102.16 22 CENTOS --"
    "02 DSP TRACK 02 PADDLEWAVER SINGAPORE 43.156.30.57 22 CENTOS --"
    "03 DSP TRACK 01 PADDLEWAVER USEAST 43.130.106.95 22 CENTOS --"
    "04 DSP TRACK 02 PADDLEWAVER USEAST 170.106.14.178 22 CENTOS --"
    "05 DSP BID 01 PADDLEWAVER SINGAPORE 119.28.107.30 22 CENTOS --"
    "06 DSP BID 02 PADDLEWAVER SINGAPORE 43.156.9.31 22 CENTOS --"
    "07 DSP BID 03 PADDLEWAVER SINGAPORE 43.156.103.66 22 CENTOS --"
    "08 DSP BID 04 PADDLEWAVER SINGAPORE 150.109.13.128 22 CENTOS --"
    "09 DSP BID 05 PADDLEWAVER SINGAPORE 43.133.37.245 22 CENTOS --"
    "10 DSP BID 06 PADDLEWAVER SINGAPORE 43.163.90.220 22 CENTOS --"
    "11 DSP BID 07 PADDLEWAVER SINGAPORE 43.156.103.34 22 CENTOS --"
    "12 DSP BID 08 PADDLEWAVER SINGAPORE 43.163.100.13 22 CENTOS --"
    "13 DSP BID 09 PADDLEWAVER SINGAPORE 43.134.27.101 22 CENTOS --"
    "14 DSP BID 10 PADDLEWAVER SINGAPORE 43.156.110.205 22 CENTOS --"
    "15 DSP BID 11 PADDLEWAVER SINGAPORE 43.156.6.213 22 CENTOS --"
    "16 DSP BID 12 PADDLEWAVER SINGAPORE 43.156.26.249 22 CENTOS --"
    "17 DSP BID 13 PADDLEWAVER SINGAPORE 43.156.99.95 22 CENTOS --"
    "18 DSP BID 14 PADDLEWAVER SINGAPORE 43.156.108.53 22 CENTOS --"
    "19 DSP BID 15 PADDLEWAVER SINGAPORE 129.226.82.236 22 CENTOS --"
    "20 DSP BID 01 PADDLEWAVER USEAST 43.130.90.22 22 CENTOS --"
    "21 DSP BID 02 PADDLEWAVER USEAST 43.130.108.36 22 CENTOS --"
    # ==================================================
  )
  local variYoneCloudSlice=(
    # ==================================================
    "01 SKELETON MASTER 01 YONE SINGAPORE 43.134.87.222 22 CENTOS --"
    "02 SKELETON MASTER 01 YONE USEAST 43.130.147.251 22 CENTOS --"
    # ==================================================
    "01 ADX TRACK 01 YONE SINGAPORE 43.159.51.144 22 CENTOS --"
    "02 ADX TRACK 02 YONE SINGAPORE 43.133.63.172 22 CENTOS --"
    "03 ADX TRACK 01 YONE USEAST 43.130.148.210 22 CENTOS --"
    "04 ADX TRACK 02 YONE USEAST 43.130.132.19 22 CENTOS --"
    "05 ADX BID 01 YONE SINGAPORE 43.156.0.206 22 CENTOS --"
    "06 ADX BID 02 YONE SINGAPORE 43.134.87.59 22 CENTOS --"
    "07 ADX BID 03 YONE SINGAPORE 43.134.10.168 22 CENTOS --"
    "08 ADX BID 04 YONE SINGAPORE 43.163.113.138 22 CENTOS --"
    "09 ADX BID 05 YONE SINGAPORE 43.134.57.230 22 CENTOS --"
    "10 ADX BID 06 YONE SINGAPORE 43.156.68.83 22 CENTOS --"
    "11 ADX BID 07 YONE SINGAPORE 43.163.1.233 22 CENTOS --"
    "12 ADX BID 08 YONE SINGAPORE 129.226.152.214 22 CENTOS --"
    "13 ADX BID 01 YONE USEAST 43.130.134.51 22 CENTOS --"
    "14 ADX BID 02 YONE USEAST 43.166.247.44 22 CENTOS --"
    # ==================================================
    "01 DSP TRACK 01 YONE SINGAPORE 43.133.37.4 22 CENTOS --"
    "02 DSP TRACK 02 YONE SINGAPORE 129.226.95.66 22 CENTOS --"
    "03 DSP TRACK 01 YONE USEAST 43.166.247.136 22 CENTOS --"
    "04 DSP TRACK 02 YONE USEAST 43.166.226.222 22 CENTOS --"
    "05 DSP BID 01 YONE SINGAPORE 43.134.49.186 22 CENTOS --"
    "06 DSP BID 02 YONE SINGAPORE 43.134.32.190 22 CENTOS --"
    "07 DSP BID 01 YONE USEAST 43.166.254.65 22 CENTOS --"
    "08 DSP BID 02 YONE USEAST 43.166.254.61 22 CENTOS --"
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
  printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" \
    "INDEX" "MODULE" "SERVICE" "LABEL" "DOMAIN" "REGION" "IP" "PORT" "OS" "DESC"
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
    variEachOs=$(echo "$variEachValue" | awk '{print $9}')
    variEachDesc=$(echo "$variEachValue" | awk '{print $10}')
    [[ $variEachModule != $variSelectedModuleName* ]] && continue
    variCheckAllSlice="${variCheckAllSlice} $(echo $variEachValue | awk '{print $1}')"
    variSelectedCloudMap[$variEachIndex]="$variEachValue"
    printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" "$variEachIndex" "$variEachModule" "$variEachService" "$variEachLabel" "$variEachDomain" "$variEachRegion" "$variEachIp" "$variEachPort" "$variEachOs" "$variEachDesc"
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
  apt-get update
  #「dialog」支持文本界面對話框體 (TUI/text-based user interface)
  #「apt-utils」提供「apt」使用的輔助工具
  apt-get install -y --no-install-recommends dialog apt-utils ca-certificates
  apt-get install -y git wget curl make graphviz
  # claude code install[START]
  # 允許安裝「man」幫助手冊[START]
  # 解决警告x22：update-alternatives: warning: skip creation of /usr/share/man/man1/js.1.gz because associated file /usr/share/man/man1/nodejs.1.gz (of link group js) doesn't exist
  sed -i 's/^path-exclude=\/usr\/share\/man/#path-exclude=\/usr\/share\/man/' /etc/dpkg/dpkg.cfg.d/excludes || true
  sed -i 's/^path-exclude=\/usr\/share\/doc/#path-exclude=\/usr\/share\/doc/' /etc/dpkg/dpkg.cfg.d/excludes || true
  # 允許安裝「man」幫助手冊[END]
  apt-get install -y npm && npm install -g @anthropic-ai/claude-code
  # windows[START]
  # powershell >> irm https://claude.ai/install.ps1 | iex
  # powershell >> [System.Environment]::SetEnvironmentVariable("http_proxy", "http://127.0.0.1:10809", "User")
  # powershell >> [System.Environment]::SetEnvironmentVariable("https_proxy", "http://127.0.0.1:10809", "User")
  # manual >> 配置「[搜尋路徑]C:\Users\zengweitao\.local\bin」至「system variables.Path」
  # windows[END]
  # 取消代理[START]
  # powershell >> [System.Environment]::SetEnvironmentVariable("http_proxy", $null, "User")
  # powershell >> [System.Environment]::SetEnvironmentVariable("https_proxy", $null, "User")
  # 取消代理[END]
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

:<<'MARK'
「chunio/php:haohaiyou」封裝日誌：
docker rm -f skeleton
docker rm -f chunio-php-haohaiyou
docker rmi -f chunio/php:haohaiyou
docker run -d \
  --privileged \
  --name chunio-php-haohaiyou \
  --tmpfs /tmp \
  --tmpfs /run \
  --tmpfs /run/lock \
  --cgroupns=host \
  -v /windows:/windows \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  chunio/php:8.3.24 /sbin/init
docker exec -it chunio-php-haohaiyou /bin/bash
# ----------
root@${variContainerId}:/# apt-get update
root@${variContainerId}:/# apt-get install -y python3 python3-pip python3-venv
root@${variContainerId}:/# pip3 install Pillow --break-system-packages
root@${variContainerId}:/# pip3 install playwright --break-system-packages
root@${variContainerId}:/# playwright install
root@${variContainerId}:/# playwright install-deps
root@${variContainerId}:/# apt clean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
root@${variContainerId}:/# history -c
root@${variContainerId}:/# exit
# ----------
docker commit $(docker ps --filter "name=chunio-php-haohaiyou" --format "{{.ID}}") chunio/php:haohaiyou
MARK
function funcPublicSkeleton(){
  # [MASTER]persistence
  variMasterPath="/windows/code/backend/haohaiyou"
  # [DOCKER]temporary
  variDockerWorkSpace="/windows/code/backend/haohaiyou"
  variModuleName="skeleton"
  # variImagePattern=${1:-"hyperf/hyperf:8.3-alpine-v3.19-swoole-5.1.3"}
  variImagePattern=${1:-"chunio/php:haohaiyou"}
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

# manual[START]
# tar -czvf /windows/code/backend/chunio/omni/module/haohaiyou/runtime/omni.haohaiyou.cloud.ssh.tgz -C /windows/code/backend/chunio/omni/module/haohaiyou/cloud ssh
# scp -P 22 -o StrictHostKeyChecking=no /windows/code/backend/chunio/omni/module/haohaiyou/runtime/omni.haohaiyou.cloud.ssh.tgz root@101.32.14.43:/
# ssh root@101.32.14.43
# manual[END]
function funcPublicCloudJumperReinit() {
  local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  # 重啟保留（區別：/tmp重啟清空）
  local variScpPath="/var/tmp"
  tar -czvf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz -C ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} ssh
  # 兼容：係統重裝[START]
  ssh-keygen -R ${variJumperIp} 2>/dev/null
  ssh-keygen -R "[${variJumperIp}]:${variJumperPort}" 2>/dev/null
  # 兼容：係統重裝[END]
  scp -P ${variJumperPort} -o StrictHostKeyChecking=no ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/omni.haohaiyou.cloud.ssh.tgz ${variJumperAccount}@${variJumperIp}:${variScpPath}/
  scp -P ${variJumperPort} -o StrictHostKeyChecking=no ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/encrypt.envi ${variJumperAccount}@${variJumperIp}:${variScpPath}/
  ssh -o StrictHostKeyChecking=no -p ${variJumperPort} ${variJumperAccount}@${variJumperIp} "sudo bash -s" <<JUMPEREOF
    # --------------------------------------------------
    export DEBIAN_FRONTEND=noninteractive
    # --------------------------------------------------
    # ssh[START]
    tar -xzvf ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
    /usr/bin/mv ~/.ssh/ssh/* ~/.ssh
    rm -rf ~/.ssh/ssh
    touch ~/.ssh/config
    sed -i '/^StrictHostKeyChecking/d' ~/.ssh/config 2>/dev/null
    echo "StrictHostKeyChecking no" >> ~/.ssh/config
    # 追加密鑰（admin_cicd/對應權限：雲服務器/代碼倉庫）[START]
    touch ~/.ssh/authorized_keys
    sed -i "\|\$(cat ~/.ssh/id_rsa.pub)|d" ~/.ssh/authorized_keys 2>/dev/null
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    # 追加密鑰（admin_cicd/對應權限：雲服務器/代碼倉庫）[END]
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/*
    chown \$(whoami):\$(whoami) ~/.ssh/*
    # ssh[END]
    # --------------------------------------------------
    # git[START]
    if ! command -v git &> /dev/null; then
      variOperatingSystem=""
      [ -f /etc/os-release ] && variOperatingSystem=\$(. /etc/os-release && echo "\${ID}")
      case "\${variOperatingSystem}" in
        "centos"|"rhel"|"rocky"|"almalinux")
          yum install -y git
          ;;
        "ubuntu"|"debian")
          apt-get update && apt-get install -y git
          ;;
        *)
          yum install -y git 2>/dev/null || apt-get update && apt-get install -y git 2>/dev/null
          ;;
      esac
    fi
    # git[END]
    # --------------------------------------------------
    # omni.system init[START]
    mkdir -p /windows/runtime
    if [ -d "/windows/code/backend/chunio/omni/.git" ]; then
      cd /windows/code/backend/chunio/omni
    else
      rm -rf /windows/code/backend/chunio/omni
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
    chmod 777 -R .
    ./init/system/system.sh init
    [ -f /etc/bashrc ] && source /etc/bashrc
    [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
    # omni.system init[END]
    # --------------------------------------------------
    /usr/bin/cp -rf ${variScpPath}/encrypt.envi /windows/code/backend/chunio/omni/module/haohaiyou/
    /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudCoscliReinit
    /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudTccliReinit
JUMPEREOF
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

function funcPublicCloudSkeletonReinit() {
  local variParameterDescMulti=("branch : main（default），feature/zengweitao/...")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variBranchName=${1}
  # slave variable[START]
  # systemctl reload crond
  variCrontabEnviUri="/var/spool/cron/root"
  # slave variable[END]
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
          sed -i "s/^APP_SERVICE=.*/APP_SERVICE=${variEachService}/" .env
          rm -rf runtime/container
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
          # crontab[START]
          if grep -Fq "cloudSkeletonHourlyCrontab" "${variCrontabEnviUri}"; then
            sed -i '/cloudSkeletonHourlyCrontab/d' "${variCrontabEnviUri}"
          fi
          echo "0 * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudSkeletonHourlyCrontab" >> "${variCrontabEnviUri}"
          cat "${variCrontabEnviUri}"
          systemctl reload crond
          # crontab[END]
          #（3）slave main[END]
          # --------------------------------------------------
SLAVEEOF
JUMPEREOF
  done
  return 0
}


function funcPublicCloudSkeletonHourlyCrontab(){
  rm -rf /windows/code/backend/haohaiyou/gopath/src/skeleton/core.*
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
        # 超時限制（否則默認：60s）[START]
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
        # 超時限制（否則默認：60s）[END]
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
    # 採集日誌[START]
    access_log /windows/runtime/${variDomain}_access.log main;
    error_log  /windows/runtime/${variDomain}_error.log warn;
    # 採集日誌[END]
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
        # 超時限制（否則默認：60s）[START]
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
        # 超時限制（否則默認：60s）[END]
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

# 兼容：centos && ubuntu
function funcPublicCloudUnicornReinit_Official() {
  local variParameterDescMulti=("module : dsp，adx" "branch : main，feature/zengweitao/...")
  funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variModuleName=$1
  local variBranchName=$2
  local variEnvi="PRODUCTION"
  local variBinName="unicorn_${variModuleName}"
  # ----------
  local variScpStatus=1
  local variScpOnce=0
  local variScpPath="/tmp/"
  local variLaunchTimeout=30
  # ----------
  local variHttpPort=0
  local variGrpcPort=0
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
  # 統計「執行狀態」/1[START]
  local varSelectedCounter=0
  local variSucceededCounter=0
  local variFailedAbstract=""
  # 統計「執行狀態」/1[END]
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachOs=$(echo ${variEachValue} | awk '{print $9}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $10}')
    # 檢測目標節點環節是否支持當前模塊[START]
    variEachValueLower=$(echo "$variEachValue" | tr 'A-Z' 'a-z')
    if [[ $variEachValueLower != *$variModuleName* && $variEachValueLower != *singleton* ]]; then
      echo "invalid selection : [ ${variEachValue} ]"
      continue
    fi
    # 檢測目標節點環節是否支持當前模塊[END]
    # 統計「執行狀態」/2[START]
    varSelectedCounter=$((varSelectedCounter + 1))
    # 統計「執行狀態」/2[END]
    # 係統兼容[START]
    local variEachSlaveAccount="root"
    local variEachSudoCommand=""
    local variEachCrontabEnviUri="/var/spool/cron/root"
    local variEachCrontabReloadCommand="systemctl reload crond"
    local variEachGitInstallCommand="yum install -y git"
    if [[ "${variEachOs}" == "UBUNTU" ]]; then
      variEachSlaveAccount="ubuntu"
      variEachSudoCommand="sudo bash -s"
      variEachCrontabEnviUri="/var/spool/cron/crontabs/root"
      variEachCrontabReloadCommand="systemctl restart cron"
      variEachGitInstallCommand="apt-get update && apt-get install -y git"
    fi
    # 係統兼容[END]
    rm -rf ~/.ssh/known_hosts
    if [[ ${variScpStatus} -eq 1 && ${variScpOnce} -eq 0 ]]; then
      md5sum /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName}
      scp -P ${variJumperPort} -o StrictHostKeyChecking=no /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName} ${variJumperAccount}@${variJumperIp}:${variScpPath}
      variScpOnce=1
    fi
    variEachLabelUpper=$(echo "${variEachDomain}/${variModuleName}/${variEachService}/${variEachRegion}/${variEachLabel}" | tr 'a-z' 'A-Z')
    # variEachCrontabTask="* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor ${variEachLabelUpper} > /dev/null 2>&1"
    ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -T ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
      rm -rf ~/.ssh/known_hosts
      if [[ ${variScpStatus} -eq 1 ]]; then
        scp -P ${variEachPort} -o StrictHostKeyChecking=no ${variScpPath}${variBinName} ${variEachSlaveAccount}@${variEachIp}:${variScpPath}
        scp -P ${variEachPort} -o StrictHostKeyChecking=no ${variScpPath}omni.haohaiyou.cloud.ssh.tgz ${variEachSlaveAccount}@${variEachIp}:${variScpPath}
      fi
      ssh -o StrictHostKeyChecking=no -A -p ${variEachPort} -T ${variEachSlaveAccount}@${variEachIp} ${variEachSudoCommand} <<SLAVEEOF
        # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
        export DEBIAN_FRONTEND=noninteractive
        # --------------------------------------------------
        # （1）ssh init[START]
        tar -xzvf ${variScpPath}omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
        mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
        touch ~/.ssh/config
        sed -i '/^StrictHostKeyChecking/d' ~/.ssh/config
        echo "StrictHostKeyChecking no" >> ~/.ssh/config
        # 需三重轉義，原因：雙層未加引號的「heredoc」會導致變量被解釋兩次
        chmod 600 ~/.ssh/* && chown \\\$(whoami):\\\$(whoami) ~/.ssh/*
        # （1）ssh init[END]
        # --------------------------------------------------
        # （2）omni.system init[START]
        if ! command -v git &> /dev/null; then
          ${variEachGitInstallCommand}
        fi
        mkdir -p /windows/runtime
        if [ -d "/windows/code/backend/chunio/omni/.git" ]; then
          cd /windows/code/backend/chunio/omni
        else
          rm -rf /windows/code/backend/chunio/omni
          mkdir -p /windows/code/backend/chunio
          cd /windows/code/backend/chunio
          git clone https://github.com/chunio/omni.git && cd ./omni
        fi
        echo "[ omni ] git fetch origin ..."
        git fetch origin
        echo "[ omni ] git fetch origin finished"
        echo "[ omni ] git reset --hard origin/main ..."
        git reset --hard origin/main
        echo "[ omni ] git reset --hard origin/main finished"
        chmod 777 -R . && ./init/system/system.sh init
        [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
        [ -f /etc/bashrc ] && source /etc/bashrc
        #（2）omni.system init[END]
        # --------------------------------------------------
        #（3）slave main[START]
        ulimit -n 655360
        docker rm -f unicorn 2> /dev/null
        if [ -d "/windows/code/backend/haohaiyou/gopath/src/unicorn/.git" ]; then
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
          rm -rf /windows/code/backend/haohaiyou/gopath/src/unicorn
          mkdir -p /windows/code/backend/haohaiyou/gopath/src && cd /windows/code/backend/haohaiyou/gopath/src
          git clone git@github.com:chunio/unicorn.git && cd unicorn
          git checkout ${variBranchName}
        fi
        /windows/code/backend/chunio/omni/init/system/system.sh port ${variHttpPort} kill
        /windows/code/backend/chunio/omni/init/system/system.sh port ${variGrpcPort} kill
        # /windows/code/backend/chunio/omni/init/system/system.sh process unicorn kill
        mkdir -p ./bin && chmod 777 -R .
        /usr/bin/cp -rf ${variScpPath}${variBinName} ./bin/${variBinName}
        echo "" > /windows/runtime/${variBinName}.command
        nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachService} -LABEL ${variEachLabel} -DOMAIN ${variEachDomain} -REGION ${variEachRegion} > /windows/runtime/${variBinName}.log 2>&1 &
        # ----------
        variEachLaunchDuration=0
        while true; do
          if grep -q ":${variHttpPort}" /windows/runtime/${variBinName}.log; then
            cat /windows/runtime/${variBinName}.log
            echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachService} -LABEL ${variEachLabel} -DOMAIN ${variEachDomain} -REGION ${variEachRegion} > /windows/runtime/${variBinName}.log 2>&1 & [success]"
            echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variEachService} -LABEL ${variEachLabel} -DOMAIN ${variEachDomain} -REGION ${variEachRegion} > /windows/runtime/${variBinName}.log 2>&1 &" > /windows/runtime/${variBinName}.command
            # TODO:進去此分支才統計「執行狀態」
            break
          elif grep -qE "failed|error|panic" /windows/runtime/${variBinName}.log; then
            cat /windows/runtime/${variBinName}.log
            exit 1
          elif [[ \\\${variEachLaunchDuration} -ge ${variLaunchTimeout} ]]; then
            # 需三重轉義，原因：雙層未加引號的「heredoc」會導致變量被解釋兩次
            echo "[ failed ] ${variBinName} launch exceeded ${variLaunchTimeout} second"
            cat /windows/runtime/${variBinName}.log
            exit 1
          fi
          variEachLaunchDuration=\\\$((variEachLaunchDuration + 1))
          sleep 1
        done
        # ----------
        # unicorn[END]
        # crontab[START]
        touch ${variEachCrontabEnviUri}
        # （1）supervisor
        if grep -Fq "cloudUnicornSupervisor ${variEachLabelUpper}" "${variEachCrontabEnviUri}"; then
          # 注意：針對刪除命令（即：d），使用非標準界定符號時，需加「\」作爲指定，示例：\#（標準界定符號：/）
          sed -i '\#cloudUnicornSupervisor ${variEachLabelUpper}#d' "${variEachCrontabEnviUri}"
        fi
        echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor ${variEachLabelUpper} > /dev/null 2>&1" >> "${variEachCrontabEnviUri}"
        # （2）僅使用於「variEachService=MASTER」
        if [[ ${variEachService} == "MASTER" ]]; then
          # TODO:[臨時]廢棄清理[START]
          if grep -Fq "cloudSclickArchived" "${variEachCrontabEnviUri}"; then
            sed -i '/cloudSclickArchived/d' "${variEachCrontabEnviUri}"
          fi
          # TODO:[臨時]廢棄清理[END]
          if grep -Fq "cloudUnicornMinutelyCrontab" "${variEachCrontabEnviUri}"; then
            sed -i '/cloudUnicornMinutelyCrontab/d' "${variEachCrontabEnviUri}"
          fi
          echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornMinutelyCrontab > /dev/null 2>&1" >> "${variEachCrontabEnviUri}"
        fi
        # ----------
        cat "${variEachCrontabEnviUri}"
        ${variEachCrontabReloadCommand}
        # crontab[END]
        /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudHostReinit
        md5sum /windows/code/backend/haohaiyou/gopath/src/unicorn/bin/${variBinName}
        #（3）slave main[END]
        # --------------------------------------------------
SLAVEEOF
JUMPEREOF
    # 統計「執行狀態」/3[START]
    if [[ $? -eq 0 ]]; then
      variSucceededCounter=$((variSucceededCounter + 1))
    else
      variFailedAbstract="${variFailedAbstract} ${variEachIndex}(${variEachIp})"
    fi
    # 統計「執行狀態」/3[END]
  done
  # 統計「執行狀態」/4[START]
  echo -e "\nsucceeded : ${variSucceededCounter}/${varSelectedCounter}\n"
  [[ -n "${variFailedAbstract}" ]] && echo -e "\nfailed : ${variFailedAbstract}\n"
  # 統計「執行狀態」/4[END]
  return 0
}

:<<'MARK'
[依賴]係統預裝：
ssh（[backend]include：admin_cicd / zengweitao_yx044r26）
omni.haohaiyou cloudPodReinit
MARK
function funcPublicCloudPodReinit(){
  local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  local variSlaveAccount="ubuntu"
  local variSlaveIp="101.32.126.179"
  local variSlavePort="22"
  local variScpPath="/var/tmp"
  ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -T ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variSlaveIp} ..."
      echo "===================================================================================================="
      rm -rf ~/.ssh/known_hosts
      scp -P ${variSlavePort} -o StrictHostKeyChecking=no ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz ${variSlaveAccount}@${variSlaveIp}:${variScpPath}/
      scp -P ${variSlavePort} -o StrictHostKeyChecking=no ${variScpPath}/encrypt.envi ${variSlaveAccount}@${variSlaveIp}:${variScpPath}/
      ssh -o StrictHostKeyChecking=no -A -p ${variSlavePort} -T ${variSlaveAccount}@${variSlaveIp} "sudo bash -s" <<SLAVEEOF
        # --------------------------------------------------
        # envi[START]
        # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
        export DEBIAN_FRONTEND=noninteractive
        # envi[END]
        # --------------------------------------------------
        # ssh init[START]
        tar -xzvf ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
        mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
        touch ~/.ssh/config
        sed -i '/^StrictHostKeyChecking/d' ~/.ssh/config
        echo "StrictHostKeyChecking no" >> ~/.ssh/config
        # 需三重轉義，原因：雙層未加引號的「heredoc」會導致變量被解釋兩次
        chmod 600 ~/.ssh/* && chown \\\$(whoami):\\\$(whoami) ~/.ssh/*
        # ssh init[END]
        # --------------------------------------------------
        # omni.system init[START]
        if ! command -v git &> /dev/null; then
          apt-get update && apt-get install -y git
        fi
        mkdir -p /windows/runtime
        if [ -d "/windows/code/backend/chunio/omni/.git" ]; then
          cd /windows/code/backend/chunio/omni
        else
          rm -rf /windows/code/backend/chunio/omni
          mkdir -p /windows/code/backend/chunio
          cd /windows/code/backend/chunio
          git clone https://github.com/chunio/omni.git
          cd ./omni
        fi
        # ----------
        echo "[ omni ] git fetch origin ..."
        git fetch origin
        echo "[ omni ] git fetch origin finished"
        # ----------
        echo "[ omni ] git reset --hard origin/main ..."
        git reset --hard origin/main
        echo "[ omni ] git reset --hard origin/main finished"
        # ----------
        chmod 777 -R .
        ./init/system/system.sh init
        [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
        [ -f /etc/bashrc ] && source /etc/bashrc
        # omni.system init[END]
        # --------------------------------------------------
        /usr/bin/cp -rf ${variScpPath}/encrypt.envi /windows/code/backend/chunio/omni/module/haohaiyou/
        /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudCoscliReinit
        /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudTccliReinit
        # --------------------------------------------------
        history -c
SLAVEEOF
JUMPEREOF
  return 0
}


:<<'MARK'
兼容：centos && ubuntu
MARK
function funcPublicCloudUnicornReinit() {
  local variParameterDescMulti=(
    "module : dsp，adx"
    "branch : main，feature/.../..."
    "coscli : 1/able, 0/disable（default）"
  )
  funcProtectedCheckRequiredParameter 2 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variModule=$1
  local variModuleUpper=$(echo "${variModule}" | tr 'a-z' 'A-Z')
  local variBranch=$2
  local variAutoScalingStatus=${3:-0}
  local variJumperAccount=$(funcProtectedPullEncryptEnvi "JUMPER_ACCOUNT")
  local variJumperIp=$(funcProtectedPullEncryptEnvi "JUMPER_IP")
  local variJumperPort=$(funcProtectedPullEncryptEnvi "JUMPER_PORT")
  local variScpStatus=1
  local variScpOnce=0
  local variScpPath="/var/tmp"
  local variGoPath="/windows/code/backend/haohaiyou/gopath"
  local variBinName="unicorn_${variModule}"
  local variBinMd5=$(md5sum ${variGoPath}/src/unicorn/bin/${variBinName} | awk '{print $1}')
  # 統計「執行狀態」/1[START]
  local varSelectedCounter=0
  local variSucceededCounter=0
  local variFailedAbstract=""
  # 統計「執行狀態」/1[END]
  # 彈性伸縮/1[START]
  if [ ${variAutoScalingStatus} -eq 1 ]; then
    rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos
    mkdir -p ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos
    /usr/bin/cp -rf ${variGoPath}/src/unicorn/bin/${variBinName} ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos/${variBinName}
  fi
  # 彈性伸縮/1[END]
  funcProtectedCloudSelector
  for variEachValue in "${VARI_B40BC66C185E49E93B95239A8365AC4A[@]}"; do
    variEachIndex=$(echo ${variEachValue} | awk '{print $1}')
    variEachModule=$(echo ${variEachValue} | awk '{print $2}')
    variEachService=$(echo ${variEachValue} | awk '{print $3}')
    variEachLabel=$(echo ${variEachValue} | awk '{print $4}')
    variEachDomain=$(echo ${variEachValue} | awk '{print $5}')
    variEachRegion=$(echo ${variEachValue} | awk '{print $6}')
    variEachIp=$(echo ${variEachValue} | awk '{print $7}')
    variEachPort=$(echo ${variEachValue} | awk '{print $8}')
    variEachOs=$(echo ${variEachValue} | awk '{print $9}')
    variEachDesc=$(echo ${variEachValue} | awk '{print $10}')
    # 檢測目標節點環節是否支持當前模塊[START]
    variEachValueLower=$(echo "$variEachValue" | tr 'A-Z' 'a-z')
    if [[ $variEachValueLower != *${variModule}* && $variEachValueLower != *singleton* ]]; then
      echo "invalid selection : [ ${variEachValue} ]"
      continue
    fi
    # 檢測目標節點環節是否支持當前模塊[END]
    # 彈性伸縮/2[START]
    if [ ${variAutoScalingStatus} -eq 1 ]; then
      echo "${variBinMd5}#${variBranch}" > "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos/${variEachDomain}_${variModuleUpper}_${variEachService}_${variEachRegion}.envi"
    fi
    # 彈性伸縮/2[END]
    # 統計「執行狀態」/2[START]
    varSelectedCounter=$((varSelectedCounter + 1))
    # 統計「執行狀態」/2[END]
    # 自動兼容係統類型[START]
    local variEachSlaveAccount="root"
    local variEachSudoCommand=""
    local variEachGitInstallCommand="yum install -y git"
    if [[ "${variEachOs}" == "UBUNTU" ]]; then
      variEachSlaveAccount="ubuntu"
      variEachSudoCommand="sudo bash -s"
      variEachGitInstallCommand="apt-get update && apt-get install -y git"
    fi
    # 自動兼容係統類型[END]
    rm -rf ~/.ssh/known_hosts
    if [[ ${variScpStatus} -eq 1 && ${variScpOnce} -eq 0 ]]; then
      md5sum ${variGoPath}/src/unicorn/bin/${variBinName}
      scp -P ${variJumperPort} -o StrictHostKeyChecking=no ${variGoPath}/src/unicorn/bin/${variBinName} ${variJumperAccount}@${variJumperIp}:${variScpPath}/
      variScpOnce=1
    fi
    ssh -o StrictHostKeyChecking=no -A -p ${variJumperPort} -T ${variJumperAccount}@${variJumperIp} <<JUMPEREOF
      echo "===================================================================================================="
      echo ">> [ SLAVE ] ${variEachValue} ..."
      echo "===================================================================================================="
      rm -rf ~/.ssh/known_hosts
      if [[ ${variScpStatus} -eq 1 ]]; then
        scp -P ${variEachPort} -o StrictHostKeyChecking=no ${variScpPath}/${variBinName} ${variEachSlaveAccount}@${variEachIp}:${variScpPath}/
        scp -P ${variEachPort} -o StrictHostKeyChecking=no ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz ${variEachSlaveAccount}@${variEachIp}:${variScpPath}/
        scp -P ${variEachPort} -o StrictHostKeyChecking=no ${variScpPath}/encrypt.envi ${variEachSlaveAccount}@${variEachIp}:${variScpPath}/
      fi
      ssh -o StrictHostKeyChecking=no -A -p ${variEachPort} -T ${variEachSlaveAccount}@${variEachIp} ${variEachSudoCommand} <<SLAVEEOF
        # --------------------------------------------------
        # （一）envi[START]
        # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
        export DEBIAN_FRONTEND=noninteractive
        # （一）envi[END]
        # --------------------------------------------------
        # （二）資源校驗[START]
        if [[ "\\\$(md5sum ${variScpPath}/${variBinName} | awk '{print \\\$1}')" != "${variBinMd5}" ]]; then
          echo "[ FATAL ] ${variBinMd5} md5 mismatch"
          exit 1
        fi
        # （二）資源校驗[END]
        # --------------------------------------------------
        # （三）ssh init[START]
        tar -xzvf ${variScpPath}/omni.haohaiyou.cloud.ssh.tgz -C ~/.ssh/
        mv ~/.ssh/ssh/* ~/.ssh && rm -rf ~/.ssh/ssh
        touch ~/.ssh/config
        sed -i '/^StrictHostKeyChecking/d' ~/.ssh/config
        echo "StrictHostKeyChecking no" >> ~/.ssh/config
        # 需三重轉義，原因：雙層未加引號的「heredoc」會導致變量被解釋兩次
        chmod 600 ~/.ssh/* && chown \\\$(whoami):\\\$(whoami) ~/.ssh/*
        # （三）ssh init[END]
        # --------------------------------------------------
        # （四）omni.system init[START]
        if ! command -v git &> /dev/null; then
          ${variEachGitInstallCommand}
        fi
        mkdir -p /windows/runtime
        if [ -d "/windows/code/backend/chunio/omni/.git" ]; then
          cd /windows/code/backend/chunio/omni
        else
          rm -rf /windows/code/backend/chunio/omni
          mkdir -p /windows/code/backend/chunio
          cd /windows/code/backend/chunio
          git clone https://github.com/chunio/omni.git
          cd ./omni
        fi
        # ----------
        echo "[ omni ] git fetch origin ..."
        git fetch origin
        echo "[ omni ] git fetch origin finished"
        # ----------
        echo "[ omni ] git reset --hard origin/main ..."
        git reset --hard origin/main
        echo "[ omni ] git reset --hard origin/main finished"
        # ----------
        chmod 777 -R .
        ./init/system/system.sh init
        [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
        [ -f /etc/bashrc ] && source /etc/bashrc
        /usr/bin/cp -rf ${variScpPath}/encrypt.envi /windows/code/backend/chunio/omni/module/haohaiyou/
        # /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudCoscliReinit
        # /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudTccliReinit
        # （四）omni.system init[END]
        # --------------------------------------------------
        # （五）common[START]
        echo " ${variEachModule} ${variEachService} ${variEachLabel} ${variEachDomain} ${variEachRegion} ${variBranch}"
        /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Common ${variModuleUpper} ${variEachService} ${variEachLabel} ${variEachDomain} ${variEachRegion} ${variBranch}
        # （五）common[END]
        # --------------------------------------------------
        exit \\\$?
SLAVEEOF
JUMPEREOF
    # 統計「執行狀態」/3[START]
    if [[ $? -eq 0 ]]; then
      variSucceededCounter=$((variSucceededCounter + 1))
      # 統計「執行狀態」/4[END]
    else
      variFailedAbstract="${variFailedAbstract} ${variEachIndex}(${variEachIp})"
    fi
    # 統計「執行狀態」/3[END]
  done
  # 彈性伸縮/3[START]
  if [ ${variAutoScalingStatus} -eq 1 ]; then
    # TODO:關閉所有動態機器
    /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Ascli
  fi
  # 彈性伸縮/3[START]
  # 統計「執行狀態」/4[START]
  echo -e "\nsucceeded : ${variSucceededCounter}/${varSelectedCounter}\n"
  [[ -n "${variFailedAbstract}" ]] && echo -e "\nfailed : ${variFailedAbstract}\n"
  # 統計「執行狀態」/4[END]
  return 0
}

function funcPublicCloudUnicornReinit_Common() {
  local variParameterDescMulti=(
    "module : DSP，ADX"
    "service : BID，TRACK，MASTER"
    "label : 01，02，..."
    "domain : PADDLEWAVER，YONE"
    "region : SINGAPORE，USEAST"
    "branch : main，feature/.../..."
  )
  funcProtectedCheckRequiredParameter 6 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  # ----------
  local variModule=$1
  local variService=$2
  local variLabel=$3
  local variDomain=$4
  local variRegion=$5
  local variBranch=$6
  # ----------
  local variEnvi="PRODUCTION"
  local variScpPath="/var/tmp"
  local variGoPath="/windows/code/backend/haohaiyou/gopath"
  local variLaunchTimeout=30
  local variLaunchDuration=0
  # ----------
  local variBinName=$(echo "unicorn_${variModule}" | tr 'A-Z' 'a-z') # 確保小寫
  local variHttpPort=0
  local variGrpcPort=0
  case ${variModule} in
    "ADX")
        variHttpPort=8001
        variGrpcPort=9001
        ;;
    "DSP")
        variHttpPort=8000
        variGrpcPort=9000
        ;;
    *)
        return 1
        ;;
  esac
  # 自動兼容係統類型[START]
  local variOperatingSystem="centos"
  local variCrontabEnviUri="/var/spool/cron/root"
  local variCrontabReloadCommand="systemctl reload crond"
  [ -f /etc/os-release ] && variOperatingSystem=$(. /etc/os-release && echo "${ID}")
  case "${variOperatingSystem}" in
    "ubuntu")
      variCrontabEnviUri="/var/spool/cron/crontabs/root"
      variCrontabReloadCommand="systemctl restart cron"
      ;;
  esac
  # 自動兼容係統類型[END]
  # --------------------------------------------------
  # （一）envi[START]
  # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
  export DEBIAN_FRONTEND=noninteractive
  # （一）envi[END]
  # --------------------------------------------------
  # （二）unicorn[START]
  ulimit -n 655360
  docker rm -f unicorn 2> /dev/null
  if [ -d "${variGoPath}/src/unicorn/.git" ]; then
    cd ${variGoPath}/src/unicorn
    # ----------
    echo "[ unicorn ] git fetch origin ..."
    git fetch origin
    echo "[ unicorn ] git fetch origin finished"
    # ----------
    echo "[ unicorn ] git reset --hard origin/${variBranch} ..."
    git reset --hard origin/${variBranch}
    echo "[ unicorn ] git reset --hard origin/${variBranch} finished"
    # ----------
  else
    rm -rf ${variGoPath}/src/unicorn
    mkdir -p ${variGoPath}/src
    cd ${variGoPath}/src
    git clone git@github.com:chunio/unicorn.git
    cd unicorn
    git checkout ${variBranch}
  fi
  /windows/code/backend/chunio/omni/init/system/system.sh port ${variHttpPort} kill
  /windows/code/backend/chunio/omni/init/system/system.sh port ${variGrpcPort} kill
  mkdir -p ./bin
  chmod 777 -R .
  /usr/bin/cp -rf ${variScpPath}/${variBinName} ./bin/${variBinName}
  echo "" > /windows/runtime/${variBinName}.command
  nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variService} -LABEL ${variLabel} -DOMAIN ${variDomain} -REGION ${variRegion} > /windows/runtime/${variBinName}.log 2>&1 &
  # ----------
  while true; do
    if grep -q ":${variHttpPort}" /windows/runtime/${variBinName}.log; then
      cat /windows/runtime/${variBinName}.log
      echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variService} -LABEL ${variLabel} -DOMAIN ${variDomain} -REGION ${variRegion} > /windows/runtime/${variBinName}.log 2>&1 & [success]"
      echo "nohup ./bin/${variBinName} -ENVI ${variEnvi} -SERVICE ${variService} -LABEL ${variLabel} -DOMAIN ${variDomain} -REGION ${variRegion} > /windows/runtime/${variBinName}.log 2>&1 &" > /windows/runtime/${variBinName}.command
      break
    elif grep -qE "failed|error|panic" /windows/runtime/${variBinName}.log; then
      cat /windows/runtime/${variBinName}.log
      exit 1
    elif [[ ${variLaunchDuration} -ge ${variLaunchTimeout} ]]; then
      echo "[ failed ] ${variBinName} launch exceeded ${variLaunchTimeout} second"
      cat /windows/runtime/${variBinName}.log
      exit 1
    fi
    variLaunchDuration=$((variLaunchDuration + 1))
    sleep 1
  done
  # ----------
  # （二）unicorn[END]
  # --------------------------------------------------
  # （三）crontab[START]
  touch ${variCrontabEnviUri}
  # （1）supervisor/異常重啟[START]
  local variParameter=$(echo "${variDomain}/${variModule}/${variService}/${variRegion}/${variLabel}" | tr 'a-z' 'A-Z')
  if grep -Fq "cloudUnicornSupervisor ${variParameter}" "${variCrontabEnviUri}"; then
    # 注意：針對刪除命令（即：d），使用非標準界定符號時，需加「\」作爲指定，示例：\#（標準界定符號：/）
    sed -i "\#cloudUnicornSupervisor ${variParameter}#d" "${variCrontabEnviUri}"
  fi
  echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornSupervisor ${variParameter} > /dev/null 2>&1" >> "${variCrontabEnviUri}"
  # （1）supervisor/異常重啟[END]
  # （2）僅限「variService=MASTER」[START]
  if [[ ${variService} == "MASTER" ]]; then
    if grep -Fq "cloudUnicornMinutelyCrontab" "${variCrontabEnviUri}"; then
      sed -i "/cloudUnicornMinutelyCrontab/d" "${variCrontabEnviUri}"
    fi
    echo "* * * * * /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornMinutelyCrontab > /dev/null 2>&1" >> "${variCrontabEnviUri}"
  fi
  # （2）僅限「variService=MASTER」[END]
  cat "${variCrontabEnviUri}"
  ${variCrontabReloadCommand}
  # （三）crontab[END]
  # --------------------------------------------------
  # （四）host[START]
  /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudHostReinit
  # （四）host[END]
  # --------------------------------------------------
  return 0
}

# auto scaling command-line interface
function funcPublicCloudUnicornReinit_Ascli(){
  /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudCoscliReinit
  /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudTccliReinit
  local variCosBucketName=$(funcProtectedPullEncryptEnvi "TENCENT_COS_BUCKET_NAME")
  local variCosBucket="cos://${variCosBucketName}"
  local variLocalPath="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cos"
  # --------------------------------------------------
  # 上傳{配置文件 && 編譯程序}[START]
  for variEachEnviUri in $(find ${variLocalPath} -name "*.envi" -type f); do
    local variEachEnviName=$(basename "${variEachEnviUri}" .envi)
    local variEachCosRemotePath="unicorn/release/${variEachEnviName}"
    # ----------
    local variEachDomain=$(echo "${variEachEnviName}" | awk -F'_' '{print $1}')
    local variEachModule=$(echo "${variEachEnviName}" | awk -F'_' '{print $2}')
    local variEachService=$(echo "${variEachEnviName}" | awk -F'_' '{print $3}')
    local variEachRegion=$(echo "${variEachEnviName}" | awk -F'_' '{print $4}')
    # ----------
    local variEachBinName=$(echo "unicorn_${variEachModule}" | tr 'A-Z' 'a-z')
    local variEachBinMd5=$(cat "${variEachEnviUri}" | tr -d '[:space:]' | awk -F'#' '{print $1}')
    # ----------
    coscli cp "${variLocalPath}/${variEachBinName}" "${variCosBucket}/${variEachCosRemotePath}/${variEachBinName}.${variEachBinMd5}" || { echo "[ FATAL ] failed to upload ${variEachBinName}.${variEachBinMd5}"; continue; }
    coscli cp "${variEachEnviUri}" "${variCosBucket}/${variEachCosRemotePath}/${variEachEnviName}.envi" || { echo "[ FATAL ] failed to upload ${variEachEnviName}.envi"; continue; }
    # ----------
    echo "[ coscli ] upload successful : ${variEachEnviName}.envi"
    echo "[ coscli ] upload successful : ${variEachBinName}.${variEachBinMd5}"
    # 保留5個「備份/執行文件」[START]
    # grep -v "\.envi" //排除配置
    # sort -r -k 5 //時間倒序（基於「coscli ls/返回表格」）
    # awk '{print $1}' //相對路徑
    local variBinSlice=$(coscli ls "${variCosBucket}/${variEachCosRemotePath}/" | grep "${variEachBinName}\." | grep -v "\.envi" | sort -r -k 5 | awk '{print $1}')
    local variBackupNum=5
    local variCounterIndex=0
    for variEachSuffixUri in ${variBinSlice}; do
      variCounterIndex=$((variCounterIndex + 1))
      if [[ ${variCounterIndex} -gt ${variBackupNum} ]]; then
        local variEachRemoteBinUri="cos://${variCosBucketName}/${variEachSuffixUri}"
        # TODO:無法刪除/待測試？
        echo "[ coscli ] coscli rm ${variEachRemoteBinUri}"
        coscli rm "${variEachRemoteBinUri}" > /dev/null 2>&1
      fi
    done
    # 保留5個「備份/執行文件」[END]
    # --------------------------------------------------
    # 重建「彈性伸縮>>關聯實例」[START]
    local variEachRegionOption=""
    case ${variEachRegion} in
      "SINGAPORE")
          # [--region]「singapore」對應「ap-singapore」
          variEachRegionOption="ap-singapore"
          ;;
      "USEAST")
          # [--region]「virginia」對應「na-ashburn」
          variEachRegionOption="na-ashburn"
          ;;
      *)
          return 1
          ;;
    esac
    variEachAutoScalingGroupName=$(echo "deployment-${variEachDomain}-${variEachModule}-${variEachService}-${variEachRegion}" | tr 'A-Z' 'a-z')
    # 獲取「關聯實例」列表
    local variDescribeAutoScalingInstancesJson=$(tccli as DescribeAutoScalingInstances --region "${variEachRegionOption}" --Limit 100 2>/dev/null)
    local variInstanceIdSlice=$(echo "${variDescribeAutoScalingInstancesJson}" | python3 -c "import sys, json; data=json.load(sys.stdin); print(' '.join([i.get('InstanceId') for i in data.get('AutoScalingInstanceSet', []) if i.get('AutoScalingGroupName') == '${variEachAutoScalingGroupName}']))" 2>/dev/null)
    local variAutoScalingGroupId=$(echo "${variDescribeAutoScalingInstancesJson}" | python3 -c "import sys, json; data=json.load(sys.stdin); ids=[i.get('AutoScalingGroupId') for i in data.get('AutoScalingInstanceSet', []) if i.get('AutoScalingGroupName') == '${variEachAutoScalingGroupName}']; print(ids[0] if ids else '')" 2>/dev/null)
    local variInstanceNum=$(echo "${variInstanceIdSlice}" | wc -w)
    if [[ ${variInstanceNum} -gt 0 && -n "${variAutoScalingGroupId}" ]]; then
      # 構建「JSON/實例ID」[START]
      # 示例：'["ins-qk8c1vo7","ins-o9mbwxef"]'
      local variInstanceIdJson="["
      local variIndex=0
      for variEachInstanceId in ${variInstanceIdSlice}; do
        if [[ ${variIndex} -gt 0 ]]; then
          variInstanceIdJson="${variInstanceIdJson},"
        fi
        variInstanceIdJson="${variInstanceIdJson}\"${variEachInstanceId}\""
        variIndex=$((variIndex + 1))
      done
      variInstanceIdJson="${variInstanceIdJson}]"
      # 構建「JSON/實例ID」[END]
      # 批量刪除多個實例
      local variRemoveInstancesCommand="tccli cvm TerminateInstances --region \"${variEachRegionOption}\" --InstanceIds '${variInstanceIdJson}'"
      echo "[ tccli ] ${variRemoveInstancesCommand}"
      # 執行銷毀（「伸縮組」會自行拉起等量的「關聯實例」）
      # 禁止：local variRemoveInstancesResult=$(eval "${variRemoveInstancesCommand}" 2>&1)，否則後續「$?」會獲取「local/賦值語句」的執行結果
      local variRemoveInstancesResult
      variRemoveInstancesResult=$(eval "${variRemoveInstancesCommand}" 2>&1)
      if [[ $? -eq 0 ]]; then
        echo "[ tccli ] ${variEachAutoScalingGroupName} rebuild succeeded"
      else
        echo "[ tccli ] ${variEachAutoScalingGroupName} rebuild failed : ${variRemoveInstancesResult}"
      fi
    fi
    # 重建「彈性伸縮>>關聯實例」[END]
    # --------------------------------------------------
  done
  # 上傳{配置文件 && 編譯程序}[END]
  return 0
}

:<<'MARK'
[依賴]係統預裝：
ssh（[backend]include：admin_cicd）
omni.haohaiyou cloudPodReinit
# ----------
/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Dynamic PADDLEWAVER DSP BID SINGAPORE（√）
/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Dynamic PADDLEWAVER DSP BID USEAST（√）
/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Dynamic PADDLEWAVER ADX BID SINGAPORE（√）
/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Dynamic PADDLEWAVER ADX BID USEAST（√）
# ----------
/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Dynamic YONE DSP BID SINGAPORE
/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Dynamic YONE DSP BID USEAST
/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Dynamic YONE ADX BID SINGAPORE（√）
/windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Dynamic YONE ADX BID USEAST
MARK
function funcPublicCloudUnicornReinit_Dynamic() {
  # --------------------------------------------------
  # omni.system init[START]
  mkdir -p /windows/runtime
  cd /windows/code/backend/chunio/omni
  # ----------
  echo "[ omni ] git fetch origin ..."
  git fetch origin
  echo "[ omni ] git fetch origin finished"
  # ----------
  echo "[ omni ] git reset --hard origin/main ..."
  git reset --hard origin/main
  echo "[ omni ] git reset --hard origin/main finished"
  # ----------
  chmod 777 -R .
  ./init/system/system.sh init
  [ -f /etc/bashrc ] && source /etc/bashrc
  [ -f /etc/bash.bashrc ] && source /etc/bash.bashrc
  # omni.system init[END]
  # --------------------------------------------------
  local variParameterDescMulti=(
    "domain : PADDLEWAVER，YONE"
    "module : DSP，ADX"
    "service : BID，TRACK，MASTER"
    "region : SINGAPORE，USEAST"
  )
  funcProtectedCheckRequiredParameter 4 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variDomain=$1
  local variModule=$2
  local variService=$3
  local variRegion=$4
  local variEnvi="PRODUCTION"
  local variScpPath="/var/tmp"
  local variCosBucketName=$(funcProtectedPullEncryptEnvi "TENCENT_COS_BUCKET_NAME")
  local variCosBucket="cos://${variCosBucketName}"
  local variCosRemotePath="unicorn/release/${variDomain}_${variModule}_${variService}_${variRegion}"
  local variEnviFilename="${variDomain}_${variModule}_${variService}_${variRegion}.envi"
  local variBinName=$(echo "unicorn_${variModule}" | tr 'A-Z' 'a-z') # 確保小寫
  # --------------------------------------------------
  # envi[START]
  # 跳過交互（報錯：debconf: unable to initialize frontend: Dialog，原因：「sudo bash -s」無執行終端）
  export DEBIAN_FRONTEND=noninteractive
  # ----------
  local variLabel=$(hostname -I 2>/dev/null | awk '{print $1}' | tr '.' 'P')
  [[ -z "${variLabel}" ]] && variLabel=$(echo "$(date +%s%N)${RANDOM}$$" | md5sum | awk '{print $1}' | tr 'a-z' 'A-Z')
  # ----------
  coscli cp ${variCosBucket}/${variCosRemotePath}/${variEnviFilename} ${variScpPath}/${variEnviFilename}
  # 「tr -d '[:space:]」表示移除空白符號（含：空格/換行/回車/製表）
  # 示例：9e141db7f404dae193a6d52fbc0e3210#main（md5#branch）
  local variEnviContent=$(cat ${variScpPath}/${variEnviFilename} | tr -d '[:space:]')
  local variRemoteBinMd5=$(echo "${variEnviContent}" | awk -F'#' '{print $1}')
  local variBranch=$(echo "${variEnviContent}" | awk -F'#' '{print $2}')
  # ----------
  coscli cp ${variCosBucket}/${variCosRemotePath}/${variBinName}.${variRemoteBinMd5} ${variScpPath}/${variBinName}
  local variLocalBinMd5=$(md5sum ${variScpPath}/${variBinName} | awk '{print $1}')
  chmod +x ${variScpPath}/${variBinName}
  # ----------
  local variFeishuTitle="${variDomain}/${variModule}/${variService}/${variRegion}/${variLabel}"
  if [[ "${variLocalBinMd5}" != "${variRemoteBinMd5}" ]]; then
    /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh feishu ${variFeishuTitle} "AUTO_SCALING_FAILED/BIN_MD5_UNMATCHED"
    return 1
  fi
 # ----------
  # envi[END]
  # common[START]
  /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh cloudUnicornReinit_Common ${variModule} ${variService} ${variLabel} ${variDomain} ${variRegion} ${variBranch}
  local variReturn=$?
  # common[END]
  if [[ ${variReturn} -eq 0 ]]; then
    /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh feishu ${variFeishuTitle} "AUTO_SCALING_SUCCEEDED"
  else
    /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh feishu ${variFeishuTitle} "AUTO_SCALING_FAILED/COMMON_RETURN_NOT0"
  fi
  return ${variReturn}
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
    /windows/code/backend/chunio/omni/module/haohaiyou/haohaiyou.sh feishu "${variLabel}" "HEALTH_CHECK_FAILED"
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

# 含：sclick archived
function funcPublicCloudUnicornMinutelyCrontab(){
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
  if [ -f "${variArchivedLockUri}" ]; then
    # 鎖定文件大於2個小時則重置[START]
    local variCurrentTimestamp=$(date -u +%s)
    local variLockTimestamp=$(stat -c %Y "${variArchivedLockUri}" 2>/dev/null || echo "")
    if [ -n "$variLockTimestamp" ] && [ $((variCurrentTimestamp - variLockTimestamp)) -gt 7200 ];then
      rm -f "${variArchivedLockUri}"
    else
      echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] the last task did not completed" >> "${variArchivedLogUri}"
      return 0
    fi
    # 鎖定文件大於2個小時則重置[END]
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
    # exit signal monitor[START]
    if [ -f "${variArchivedExitUri}" ]; then
      echo "[ UTC0 : $(date -u "+%Y-%m-%d %H:%M:%S") ] ${variExecuteId} EXIT" >> "${variArchivedLogUri}"
      rm -rf "${variOrderByUtc0DatehourDescUri}" "${variArchivedLockUri}" "${variArchivedExitUri}"
      return 0
    fi
    # exit signal monitor[END]
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
  done
  # ORDER BY「variEachUtc0Datehour」DESC[END]
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
  ls -lh
  return 0
}

function funcPublicTailUnicornTrack(){
  cd /windows/code/backend/haohaiyou/gopath/src/unicorn/runtime
  pwd
  df -h
  echo "tail -f *-track-$(date -u +%Y%m%d).log"
  tail -f *-track-$(date -u +%Y%m%d).log
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

# 僅使用於「[騰訊雲]對象存儲」
function funcPublicCloudCoscliReinit(){
  local variTencentAccountSecretId=$(funcProtectedPullEncryptEnvi "TENCENT_ACCOUNT_SECRET_ID")
  local variTencentAccountSecretKey=$(funcProtectedPullEncryptEnvi "TENCENT_ACCOUNT_SECRET_KEY")
  local variTencentCosBucketName=$(funcProtectedPullEncryptEnvi "TENCENT_COS_BUCKET_NAME")
  local variTencentCosBucketEndpoint=$(funcProtectedPullEncryptEnvi "TENCENT_COS_BUCKET_ENDPOINT")
  if ! command -v coscli &> /dev/null; then
    wget https://cosbrowser.cloud.tencent.com/software/coscli/coscli-linux-amd64 -O /usr/local/bin/coscli
    chmod +x /usr/local/bin/coscli
  fi
  cat > ${HOME}/.cos.yaml <<EOF
cos:
  base:
    secretid: ${variTencentAccountSecretId}
    secretkey: ${variTencentAccountSecretKey}
    sessiontoken: ""
    protocol: https
    disableencryption: false
    disableautofetchbuckettype: false
    closeautoswitchhost: false
  buckets:
    - name: ${variTencentCosBucketName}
      endpoint: ${variTencentCosBucketEndpoint}
EOF
  if coscli ls cos://${variTencentCosBucketName} &> /dev/null; then
    echo "the coscli connection succeeded"
    return 0
  else
    echo "the coscli connection failed"
    return 1
  fi
}

# 僅使用於「[騰訊雲]命令行工具」
function funcPublicCloudTccliReinit(){
  local variTencentAccountSecretId=$(funcProtectedPullEncryptEnvi "TENCENT_ACCOUNT_SECRET_ID")
  local variTencentAccountSecretKey=$(funcProtectedPullEncryptEnvi "TENCENT_ACCOUNT_SECRET_KEY")
  if ! command -v tccli &> /dev/null; then
    if ! command -v pip3 &> /dev/null; then
      if command -v yum &> /dev/null; then
        yum install -y python3 python3-pip
      elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y python3-pip
      else
        echo "no package manager found, please install python3-pip manually"
        return 1
      fi
    fi
    # --break-system-packages：centos7.9無需， ubuntu24.04需要
    pip3 install tccli -q 2>/dev/null || pip3 install tccli --break-system-packages -q
  fi
  mkdir -p ${HOME}/.tccli
  cat > ${HOME}/.tccli/default.credential <<EOF
{
    "secretId": "${variTencentAccountSecretId}",
    "secretKey": "${variTencentAccountSecretKey}"
}
EOF
  cat > ${HOME}/.tccli/default.configure <<EOF
{
    "region": "ap-singapore",
    "output": "json"
}
EOF
  if tccli as DescribeAutoScalingGroups --Limit 1 &> /dev/null; then
    echo "the tccli connection succeeded"
    return 0
  else
    echo "the tccli connection failed"
    return 1
  fi
}

# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"