#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/23

:<<'MARK'
/etc/profile : 「登錄」時執行一次（含：1/ssh，2終端）>> [自動執行]/etc/profile.d/*.sh（影響：所有用戶，弊端：執行「source /etc/profile」亦無法加載最新變更至當前終端））
/etc/bashrc : 開啟「新的終端窗口」時執行一次（影響：所有用戶（~/.bashrc（影響：單個用戶）））
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
# 要求：基於純淨係統（centos7.9）
function funcProtectedManualInit(){
  #（1）設置網絡
  # GRUB_CMDLINE_LINUX="rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet" >> GRUB_CMDLINE_LINUX="rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet net.ifnames=0 biosdevname=0"
  vim /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
  reboot
  nmcli connection add type ethernet ifname eth0 con-name eth0
  # 保留「{$NICName}==eth0」的，其餘全部分別刪除
  nmcli connection delete {$NICName1}
  nmcli connection modify eth0 ipv4.method manual ipv4.addresses 192.168.255.130/24 ipv4.gateway 192.168.255.254 ipv4.dns 114.114.114.114 connection.autoconnect yes
  nmcli connection up eth0
  cat <<IFCFGETH0 > /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=eth0
UUID=276a668b-6904-4c68-9479-263547f40fa6
DEVICE=eth0
ONBOOT=yes
IPADDR=192.168.255.130
PREFIX=24
GATEWAY=192.168.255.254
DNS1=114.114.114.114
IFCFGETH0
  systemctl restart network.service
  systemctl disable firewalld
  systemctl stop firewalld
  systemctl status firewalld
  # SELINUX=enforcing >> SELINUX=disabled
  vi /etc/sysconfig/selinux
  source /etc/sysconfig/selinux
  # SELINUX=enforcing >> SELINUX=disabled
  vi /etc/selinux/config
  source /etc/selinux/config
  reboot
  # [selinux]查看狀態
  sestatus
  local variMountUsername=$(funcProtectedPullEncryptEnvi "MOUNT_USERNAME")
  loacl variMountPassword=$(funcProtectedPullEncryptEnvi "MOUNT_PASSWORD")
  #（2）掛載目錄
cat <<FSTAB >> /etc/fstab
//192.168.255.1/mount /windows cifs dir_mode=0777,file_mode=0777,username=${variMountUsername},password=${variMountPassword},uid=1005,gid=1005,vers=3.0 0 0
FSTAB
cat <<PROFILE >> /etc/bashrc
alias omni.centos="source /windows/code/backend/chunio/omni/init/centos/centos.sh"
PROFILE
  source /etc/bashrc
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
# 驗證方法：curl https://www.google.com（由於ICMP協議不走HTTP代理，因此PING不通亦正常）
function funcPublicProxy() {
  local variParameterDescMulti=("port")
  funcProtectedCheckRequiredParameter 1 variParameterDescMulti[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variPort=${1:-0}
  variProxy="192.168.255.1:${variPort}"
  if [ ${variPort} -gt 0 ]; then
    # common proxy[START]
    if grep -q 'export http_proxy="http' /etc/bashrc; then
        sed -i '/http_proxy="http/c\export http_proxy="http:\/\/'${variProxy}'"' /etc/bashrc
        sed -i '/https_proxy="http/c\export https_proxy="http:\/\/'${variProxy}'"' /etc/bashrc
    else
        echo 'export http_proxy="http://'${variProxy}'"' >> /etc/bashrc
        echo 'export https_proxy="http://'${variProxy}'"' >> /etc/bashrc
    fi
    # common proxy[END]
    # docker proxy[START]
    mkdir -p /etc/systemd/system/docker.service.d
    cat <<HTTPPROXYCONF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://${variProxy}"
Environment="HTTPS_PROXY=http://${variProxy}"
HTTPPROXYCONF
    # docker proxy[END]
  else
    # common proxy[START]
    if grep -q 'export http_proxy="http' /etc/bashrc; then
        sed -i '/http_proxy="http/c\# export http_proxy="http:\/\/'${variProxy}'"' /etc/bashrc
        sed -i '/https_proxy="http/c\# export https_proxy="http:\/\/'${variProxy}'"' /etc/bashrc
    else
        echo "# export http_proxy=\"http://${variProxy}\"" >> /etc/bashrc
        echo "# export https_proxy=\"http://${variProxy}\"" >> /etc/bashrc
    fi
    unset http_proxy
    unset https_proxy
    # common proxy[END]
    # docker proxy[START]
    rm -rf /etc/systemd/system/docker.service.d/http-proxy.conf 2> /dev/null
    # docker proxy[END]
  fi
  # systemctl restart network.service
  source /etc/bashrc
  systemctl daemon-reload
  systemctl restart docker
  # [臨時]禁用代理
  # env -i curl https://www.google.com
  # [臨時]啟用代理
  # curl -x http://192.168.255.1:10809 https://www.google.com
  # ICMP（如：ping）流量不經過HTTP/SOCKS代理
  echo '/etc/bashrc' >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo 'http_proxy = '${http_proxy} >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo 'https_proxy = '${https_proxy} >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo '/etc/systemd/system/docker.service.d/http-proxy.conf' >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  cat /etc/systemd/system/docker.service.d/http-proxy.conf 2> /dev/null >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"