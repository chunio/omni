#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/23

:<<'MARK'
/etc/profile : 「登錄」時執行一次（含：1/ssh，2終端）>> [自動執行]/etc/profile.d/*.sh（影響：所有用戶，弊端：執行「source /etc/profile」亦無法加載最新變更至當前終端））
/etc/bash.bashrc : 開啟「新的終端窗口」時執行一次（影響：所有用戶（~/.bashrc（影響：單個用戶）））
find /windows/code/backend/chunio/omni -type f -name "*.sh" -exec dos2unix {} \;
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="MASTER"
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
  ip a
  sudo tee /etc/netplan/01-netcfg.yaml > /dev/null <<EOF
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
  sudo chmod 600 /etc/netplan/01-netcfg.yaml
  sudo netplan apply
  sudo systemctl disable ufw
  sudo systemctl stop ufw
  sudo systemctl status ufw
  sudo systemctl stop apparmor || true
  sudo systemctl disable apparmor || true
  aa-status || apparmor_status || true
  #（2）掛載目錄
  local variMountUsername=$(funcProtectedPullEncryptEnvi "MOUNT_USERNAME")
  loacl variMountPassword=$(funcProtectedPullEncryptEnvi "MOUNT_PASSWORD")
  grep -qF '//192.168.255.1/mount /windows' /etc/fstab || cat <<FSTAB >> /etc/fstab
//192.168.255.1/mount /windows cifs dir_mode=0777,file_mode=0777,username=${variMountUsername},password=${variMountPassword},uid=1005,gid=1005,vers=3.0 0 0
FSTAB
  sudo mkdir -p /windows
  sudo mount -a
  sudo systemctl daemon-reload
  cat <<'PROFILE' >> /etc/bash.bashrc
alias omni.system="source /windows/code/backend/chunio/omni/init/system/system.sh"
PROFILE
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
# v2rayn:10809（設置 >> 參數設置 >> 開啟「允許來自局域網的連接」）
# 驗證方法：curl https://www.google.com（由於ICMP協議不走HTTP代理，因此PING不通亦正常）
function funcPublicProxy() {
  local variParameterDescMulti=("port")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variPort=${1:-0}
  variProxy="192.168.255.1:${variPort}"
  if [ ${variPort} -gt 0 ]; then
    # common proxy[START]
    if grep -q 'export http_proxy="http' /etc/bash.bashrc; then
        sed -i '/http_proxy="http/c\export http_proxy="http:\/\/'${variProxy}'"' /etc/bash.bashrc
        sed -i '/https_proxy="http/c\export https_proxy="http:\/\/'${variProxy}'"' /etc/bash.bashrc
    else
        echo 'export http_proxy="http://'${variProxy}'"' >> /etc/bash.bashrc
        echo 'export https_proxy="http://'${variProxy}'"' >> /etc/bash.bashrc
    fi
    # common proxy[END]
    # apt proxy[START]
    cat > /etc/apt/apt.conf.d/80proxy <<APT_CONF_D
Acquire::http::Proxy "http://${variProxy}";
Acquire::https::Proxy "http://${variProxy}";
APT_CONF_D
    # apt proxy[END]
    # docker proxy[START]
    mkdir -p /etc/systemd/system/docker.service.d
    cat <<HTTP_PROXY_CONF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://${variProxy}"
Environment="HTTPS_PROXY=http://${variProxy}"
HTTP_PROXY_CONF
    # docker proxy[END]
  else
    # common proxy[START]
    if grep -q 'export http_proxy="http' /etc/bash.bashrc; then
        sed -i '/http_proxy="http/c\# export http_proxy="http:\/\/'${variProxy}'"' /etc/bash.bashrc
        sed -i '/https_proxy="http/c\# export https_proxy="http:\/\/'${variProxy}'"' /etc/bash.bashrc
    else
        echo "# export http_proxy=\"http://${variProxy}\"" >> /etc/bash.bashrc
        echo "# export https_proxy=\"http://${variProxy}\"" >> /etc/bash.bashrc
    fi
    unset http_proxy
    unset https_proxy
    # common proxy[END]
    # apt proxy[START]
    rm -f /etc/apt/apt.conf.d/80proxy 2>/dev/null
    # apt proxy[END]
    # docker proxy[START]
    rm -rf /etc/systemd/system/docker.service.d/http-proxy.conf 2> /dev/null
    # docker proxy[END]
  fi
  # systemctl restart network.service
  source /etc/bash.bashrc
  systemctl daemon-reload
  systemctl restart docker
  # [臨時]禁用代理
  # env -i curl https://www.google.com
  # [臨時]啟用代理
  # curl -x http://192.168.255.1:10809 https://www.google.com
  # ICMP（如：ping）流量不經過HTTP/SOCKS代理
  echo '/etc/bash.bashrc' >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo 'http_proxy = '${http_proxy} >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo 'https_proxy = '${https_proxy} >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo '/etc/systemd/system/docker.service.d/http-proxy.conf' >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  cat /etc/systemd/system/docker.service.d/http-proxy.conf 2> /dev/null >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"