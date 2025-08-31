#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/23

:<<'MARK'
/etc/profile : 「登錄」時執行一次（含：1/ssh，2終端）>> [自動執行]/etc/profile.d/*.sh（影響：所有用戶，弊端：執行「source /etc/profile」亦無法加載最新變更至當前終端））
/etc/bash.bashrc : 開啟「新的終端窗口」時執行一次（影響：所有用戶（~/.bashrc（影響：單個用戶）））
find /windows/code/backend/chunio/omni -type f -name "*.sh" -exec dos2unix {} \;
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
VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"]="include vendor"
VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]="template"
VARI_GLOBAL["VERSION_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/init.version"
VARI_GLOBAL["MOUNT_USERNAME"]=""
VARI_GLOBAL["MOUNT_PASSWORD"]=""
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
# 要求：基於純淨係統（ubuntu24.04）
# 人工執行
function funcProtectedManualInit(){
  #（1）設置網絡
  sudo -i
  ip a
  #「99」表示加載順序，以確保能夠覆蓋係統默認/其他配置
  # 114.114.114.114/國內DNS（[南京]信風網絡）
  # 8.8.8.8/國際DNS（谷歌）
  tee /etc/netplan/99-ens33.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.255.140/24
      routes:
        - to: default
          via: 192.168.255.254
      nameservers:
        addresses: [114.114.114.114, 8.8.8.8]
EOF
  chmod 600 /etc/netplan/99-ens33.yaml
  netplan apply
  systemctl disable --now apparmor
  systemctl disable --now ufw
  # 至此支持：ssh && network
  #（2）掛載目錄
  local variMountUsername=$(funcProtectedPullEncryptEnvi "MOUNT_USERNAME")
  loacl variMountPassword=$(funcProtectedPullEncryptEnvi "MOUNT_PASSWORD")
  grep -qF '//192.168.255.1/mount /windows' /etc/fstab || cat <<FSTAB >> /etc/fstab
//192.168.255.1/mount /windows cifs dir_mode=0777,file_mode=0777,username=${variMountUsername},password=${variMountPassword},uid=1005,gid=1005,vers=3.0 0 0
FSTAB
  mkdir -p /windows
  mount -a
  systemctl daemon-reload
#  cat <<'PROFILE' >> /etc/bash.bashrc
#alias omni.system="source /windows/code/backend/chunio/omni/init/system/system.sh"
#PROFILE
  source /etc/bash.bashrc
  # TODO:echo 'set nu' >> ~/.vimrc
  return 0
}

function funcProtectedCloudInit() {
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
# clash:7890
# v2rayn:10809（設置 >> 參數設置 >> 開啟「允許來自局域網的連接」）
# 驗證方法：curl https://www.google.com（由於ICMP協議不走HTTP/SOCKS代理，因此PING不通亦正常）
# [臨時]禁用代理：env -i curl https://www.google.com
# [臨時]啟用代理：curl -x http://192.168.255.1:10809 https://www.google.com
function funcPublicProxy() {
  local variParameterDescMulti=("port")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variProxyPort=${1:-0}
  local variProxyUrl="< NIL >"
  if [ ${variProxyPort} -gt 0 ]; then
    variProxyUrl="http://192.168.255.1:${variProxyPort}"
    #（1）common[START]
    sed -i '/^export http_proxy=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export https_proxy=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export no_proxy=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export HTTP_PROXY=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export HTTPS_PROXY=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export NO_PROXY=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    echo 'export http_proxy="'${variProxyUrl}'"' >> ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    echo 'export https_proxy="'${variProxyUrl}'"' >> ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    echo 'export no_proxy="localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"' >> ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    echo 'export HTTP_PROXY="'${variProxyUrl}'"' >> ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    echo 'export HTTPS_PROXY="'${variProxyUrl}'"' >> ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    echo 'export NO_PROXY="localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"' >> ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    #（1）common[END]
    #（2）yum[START]
    cat > /etc/apt/apt.conf.d/80proxy <<APT_CONF_D
Acquire::http::Proxy "http://${variProxy}";
Acquire::https::Proxy "http://${variProxy}";
APT_CONF_D
    #（2）yum[END]
    #（3）docker[START]
    mkdir -p /etc/systemd/system/docker.service.d
    cat <<HTTPPROXYCONF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${variProxyUrl}"
Environment="HTTPS_PROXY=${variProxyUrl}"
Environment="NO_PROXY=localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
HTTPPROXYCONF
    #（3）docker[END]
  else
    #（1）common[START]
    sed -i '/^export http_proxy=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export https_proxy=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export no_proxy=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export HTTP_PROXY=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export HTTPS_PROXY=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    sed -i '/^export NO_PROXY=/d' ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    unset http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
    #（1）common[END]
    #（2）yum[START]
    rm -f /etc/apt/apt.conf.d/80proxy 2>/dev/null
    #（2）yum[END]
    #（3）docker[START]
    rm -rf /etc/systemd/system/docker.service.d/http-proxy.conf 2> /dev/null
    #（3）docker[END]
  fi
  # systemctl restart network.service
  systemctl daemon-reload
  systemctl restart docker 2> /dev/null
  echo "update ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "update /etc/yum.conf" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "update /etc/systemd/system/docker.service.d/http-proxy.conf" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "update http/https/yum/docker proxy : ${variProxyUrl}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"