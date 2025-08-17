#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/23

:<<'MARK'
/etc/profile : 「登錄」時執行一次（含：1/ssh，2終端）>> [自動執行]/etc/profile.d/*.sh（影響：所有用戶，弊端：執行「source /etc/profile」亦無法加載最新變更至當前終端））
/etc/bashrc : 開啟「新的終端窗口」時執行一次（影響：所有用戶（~/.bashrc（影響：單個用戶）））
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="MASTER"
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

# 更新倉庫(x9)
#「centos7.9」已停止維護（截止2024/06/30），[官方倉庫]mirrorlist.centos.org >> [歸檔倉庫]vault.centos.org
funcProtectedCento7YumRepositoryReinit(){
  # 僅適用於「centos7」[START]
  if ! grep -qE 'CentOS.* 7(\.|$)' /etc/centos-release 2>/dev/null; then
    return 0
  fi
  # 僅適用於「centos7」[END]
  # 是否備份[START]
  local variRepositoryPath="/etc/yum.repos.d"
  if [ "${variBackupStatus:-0}" == "1" ]; then
    local variBackupPath="${variRepositoryPath}/backup-$(date +%F-%H%M%S)"
    sudo mkdir -p "$variBackupPath"
    sudo mv "$variRepositoryPath"/CentOS-*.repo "$variBackupPath"/ 2>/dev/null || true
  else
    rm -rf "$variRepositoryPath"/CentOS-*.repo
  fi
  # 是否備份[END]
  # local variCentosVersion="${1:-7.9.2009}"
  sed -i 's|^mirrorlist=|# mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo 2> /dev/null
  sed -i 's|#\s*baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo 2> /dev/null

  # DEBUG_LABEL[START]
  sed -i 's|#mirrorlist=|# mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo 2> /dev/null
  # return 0
  # DEBUG_LABEL[END]

  # ----------
  rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository
  mkdir -p ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Base.repo
# 作用說明：核心倉庫，提供係統安裝時的「base/基礎軟件」，「updates/更新軟件」，「extras/額外工具」，「centosplus/功能增強」
# 啟用狀態：--

[base]
name=CentOS-7.9 - Base
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/os/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1
metadata_expire=never
skip_if_unavailable=1

[updates]
name=CentOS-7.9 - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/updates/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1
metadata_expire=never
skip_if_unavailable=1

[extras]
name=CentOS-7.9 - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/extras/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1
metadata_expire=never
skip_if_unavailable=1

[centosplus]
name=CentOS-7.9 - CentOSPlus
baseurl=http://vault.centos.org/7.9.2009/centosplus/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/centosplus/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0
metadata_expire=never
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Cr.repo
# 作用說明：continuous release/持續釋出，使用於正式版本發布之前，提前獲得補丁等
# 啟用狀態：--

[cr]
name=CentOS-7.9 - Cr
baseurl=http://vault.centos.org/7.9.2009/cr/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/cr/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0
metadata_expire=never
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Sclo.repo
# 作用說明：（1）「Software Collections/SCL」是「redhat/centos」提供的一種機制（不影響係統當前版本的基礎上，兼容較新的開發工具），(2)「SCLo」是「centos社區」的特別興趣小組
# 啟用狀態：--

[centos-sclo-rh]
name=CentOS-7.9 - Sclo rh
baseurl=http://vault.centos.org/7.9.2009/sclo/$basearch/rh/
enabled=1
gpgcheck=0
metadata_expire=never
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1

[centos-sclo-sclo]
name=CentOS-7.9 - Sclo sclo
baseurl=http://vault.centos.org/7.9.2009/sclo/$basearch/sclo/
enabled=1
gpgcheck=0
metadata_expire=never
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Media.repo
# 作用說明：離線安裝
# 啟用狀態：--

[c7-media]
name=CentOS-7 - Media
baseurl=file:///media/CentOS/
        file:///media/cdrom/
        file:///media/cdrecorder/
gpgcheck=0
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Vault.repo
# 作用說明：歸檔倉庫，使用於已終止支援的係統版本
# 啟用狀態：預設禁用（原因：避免與「CentOS-Base.repo/Updates」衝突）

[C7.9.2009-base]
name=CentOS-7.9.2009 - Base (vault - disabled)
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0
metadata_expire=never
skip_if_unavailable=1

[C7.9.2009-updates]
name=CentOS-7.9.2009 - Updates (vault - disabled)
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0
metadata_expire=never
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Sources.repo
# 作用說明：提供原碼套件（SRPM），方便開發者檢視源碼/重新編譯
# 啟用狀態：--

[sources]
name=CentOS-7.9 - Sources
baseurl=http://vault.centos.org/7.9.2009/os/Source/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/os/Source/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0
metadata_expire=never
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Fasttrack.repo
# 作用說明：提供{緊急修補/特定套件}的快速更新（注意：並非完整的更新流程），使用於需要第一時間獲取特定修補的環境
# 啟用狀態：預設關閉

[fasttrack]
name=CentOS-7.9 - Fasttrack
baseurl=http://vault.centos.org/7.9.2009/fasttrack/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/fasttrack/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0
metadata_expire=never
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Debuginfo.repo
# 作用說明：提供包含除錯符號的套件（如：gdb/...，如需「debug key」，則保持禁用）
# 啟用狀態：--

[debuginfo]
name=CentOS-7 - Debuginfo
baseurl=http://debuginfo.centos.org/7/$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Debug-7
enabled=0
metadata_expire=never
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-x86_64-kernel.repo
# 作用說明：內核倉庫，但於「centos 7 EOL」之後已無法通過「[官方]mirrorlist」獲取（注意：歸檔倉庫亦無獨立的內核倉庫）
# 啟用狀態：預設關閉

[centos-kernel]
name=CentOS 7 - LTS Kernel (disabled; EOL)
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1
MARK
  # ----------
  # /usr/bin/cp -rf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/repository/* ${variRepositoryPath}/
   /usr/bin/cp -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/* ${variRepositoryPath}/
  chmod -R 644 ${variRepositoryPath}
  #「docker-ce-stable」對於「centos7」不再維護，需自行安裝
  sudo yum-config-manager --disable docker-ce-stable > /dev/null || true
  sudo yum clean all
  # sudo yum makecache fast
  # sudo yum repolist
  return 0
}

function funcProtectedCloudInit() {
  funcProtectedCento7YumRepositoryReinit
  rm -f /var/run/yum.pid
  variPackageList=(
    epel-release
    git
    lsof
    tree
    wget
    expect
    telnet
    dos2unix
    net-tools
    # 含：nslookup（用以測試域名解析等）
    bind-utils
    docker
    docker-compose
    bash-completion
  )
  variCloudInitSucceeded=1
  variCloudInitVersion="${variPackageList[*]} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
  grep -qF "${variCloudInitVersion}" "${VARI_GLOBAL["VERSION_URI"]}" 2> /dev/null
  [ $? -eq 0 ] && return 0
  local variRetry=2
  declare -A variCloudInstallResult
  for variEachPackage in "${variPackageList[@]}"; do
    variEachPackageInstalledLabel="yum install -y ${variEachPackage} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
    grep -qF "${variEachPackageInstalledLabel}" "${VARI_GLOBAL["VERSION_URI"]}" 2> /dev/null
    # 安裝狀態，值：0/已安裝，1/未安裝
    variInstalled=$?
    case ${variEachPackage} in
      "docker")
        if command -v docker > /dev/null && [ "$(docker --version | awk '{print $3}' | sed 's/,//')" == "26.1.3" ]; then
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        else
          # https://docs.docker.com/engine/install/centos/
          # docker-ce-cli-20.10.7-3.el7.x86_64.rpm
          yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
          yum install -y yum-utils device-mapper-persistent-data lvm2
          yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
          yum install -y docker-ce docker-ce-cli containerd.io
          systemctl enable docker
          systemctl restart docker
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        fi
        ;;
      "docker-compose")
        if command -v docker-compose > /dev/null && [ "$(docker-compose --version | awk '{print $4}' | sed 's/,//')" == "v2.27.1" ]; then
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        else
          # https://github.com/docker/compose/releases
          # docker-compose-linux-x86_64
          variDockerComposeUri=$(which docker-compose)
          [ -n "${variDockerComposeUri}" ] && rm -f ${variDockerComposeUri}
          curl -L "https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        fi
        ;;
      *)
        local variCount=0
        while [ $variCount -lt $variRetry ]; do
          if [ "${variInstalled}" == 0 ] || yum install -y "${variEachPackage}"; then
            if [ ${variInstalled} != 0 ]; then
              echo "${variEachPackageInstalledLabel}" >> ${VARI_GLOBAL["VERSION_URI"]}
            fi
            variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
            break
          else
            variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}
            ((variCount++))
          fi
        done
        ;;
    esac
  done
  # --------------------------------------------------
  for variEachPackage in "${!variCloudInstallResult[@]}"; do
    echo "${variEachPackage} : ${variCloudInstallResult[${variEachPackage}]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    [ ${variCloudInstallResult[${variEachPackage}]} == ${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]} ] && variCloudInitSucceeded=0
  done
  [ ${variCloudInitSucceeded} == 1 ] && echo ${variCloudInitVersion} >> ${VARI_GLOBAL["VERSION_URI"]}
  # --------------------------------------------------
  return 0
}

function funcProtectedCommandInit(){
  local variAbleUnitFileURIList=${1}
  local variEtcBashrcReloadStatus=0
  rm -rf /usr/local/bin/"${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}."*
  for variAbleUnitFileUri in ${variAbleUnitFileURIList}; do
    variEachUnitFilename=$(basename ${variAbleUnitFileUri})
    variEachUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    if grep -q 'VARI_GLOBAL\["BUILTIN_BASH_EVNI"\]="MASTER"' ${variAbleUnitFileUri}; then
        # 基於當前環境的命令（即：vim /etc/bashrc）[START]
        pattern='alias '${variEachUnitCommand}'="source '${variAbleUnitFileUri}'"'
        if ! $(grep -qF "$pattern" /etc/bashrc); then
          echo $pattern >> /etc/bashrc
          [ $variEtcBashrcReloadStatus -eq 0 ] && echo 'source /etc/bashrc' >> ${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}
          variEtcBashrcReloadStatus=1
        fi
        # 基於當前環境的命令（即：vim /etc/bashrc）[END]
    else
        # 基於派生環境的命令（即：ln -sf ./omni/.../example.sh /usr/local/bin/omni.example）[START]
        # echo "ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachUnitCommand" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
        ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachUnitCommand
        # 基於派生環境的命令（即：ln -sf ./omni/.../example.sh /usr/local/bin/omni.example）[END]
    fi
  done
  return 0
}

function funcProtectedOptionInit(){
  local variAbleUnitFileURIList=${1}
  # 隔斷符號（echo $COMP_WORDBREAKS）"'><=;|&(:
  rm -rf /etc/bash_completion.d/${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}.*
  # inherit the public functions from builtin.sh[START]
  local variIncludeOptionList=""
  for variEachIncludeFuncName in $(grep -oP 'function \KfuncPublic\w+' "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/include/builtin/builtin.sh"); do
    # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[START]
    variOptionName=$(echo "$variEachIncludeFuncName" | sed 's/^funcPublic//')
    variOptionName=$(echo "$variOptionName" | awk '{print tolower(substr($0, 1, 1)) substr($0, 2)}')
    # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[END]
    variIncludeOptionList="$variIncludeOptionList $variOptionName"
  done
  # remove leading and trailing whitespace/移除首末空格
  variIncludeOptionList=$(echo ${variIncludeOptionList} | sed 's/^[ \t]*//;s/[ \t]*$//')
  printf "%-5s %-15s -> %-70s\n" "[ - ]" "--" "$variIncludeOptionList" >> ${VARI_GLOBAL["VERSION_URI"]}
  printf "%-5s %-15s -> %-70s\n" "[ - ]" "--" "$variIncludeOptionList" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  # inherit the public functions from builtin.sh[END]
  # report1/3[START]
  declare -A variOptionReport
  # report1/3[END]
  for variAbleUnitFileUri in ${variAbleUnitFileURIList}; do
    variEachUnitFilename=$(basename $variAbleUnitFileUri)
    variEachUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    variFuncNameCollection=$(grep -oP 'function \KfuncPublic\w+' "$variAbleUnitFileUri") || true
    [ -z "$variFuncNameCollection" ] && continue
    local variEachOptionList=""
    for variEachFuncName in $variFuncNameCollection; do
      # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[START]
      variOptionName=$(echo "$variEachFuncName" | sed 's/^funcPublic//')
      variOptionName=$(echo "$variOptionName" | awk '{print tolower(substr($0, 1, 1)) substr($0, 2)}')
      # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[END]
      variEachOptionList="$variEachOptionList $variOptionName"
    done
    # remove leading and trailing whitespace/移除首末空格
    variEachOptionList=$(echo $variEachOptionList | sed 's/^[ \t]*//;s/[ \t]*$//')
    grep -q 'VARI_GLOBAL\["BUILTIN_BASH_EVNI"\]="MASTER"' ${variAbleUnitFileUri} && variEachBashEvni="M" || variEachBashEvni="S"
    funcProtectedComplete "$variEachUnitCommand" "${variIncludeOptionList} ${variEachOptionList}"
    # report2/3[START]
    if [ ${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}} == 'centos' ]; then
      # 置頂
      variEachIndex=${variEachBashEvni}_0_${variEachUnitCommand}
    else
      variEachIndex=${variEachBashEvni}_1_${variEachUnitCommand}
    fi
    variOptionReport[${variEachIndex}]="${variEachOptionList}"
    # report2/3[END]
  done
  # 「source /usr/share/bash-completion/bash_completion」成功返回：exit 1（待理解？）
  source /usr/share/bash-completion/bash_completion || true
  # pull public function list/自動補全選項列表[END]
  # report3/3[START]
  # command sort：0-9a-zA-Z
  for variEachIndex in $(echo "${!variOptionReport[@]}" | tr ' ' '\n' | sort); do
    IFS='_' read -r variEachBashEvni variDevNull variEachUnitCommand <<< "${variEachIndex}"
    # option sort：0-9a-zA-Z
    variEachOptionList=$(echo "${variOptionReport[$variEachIndex]}" | tr ' ' '\n' | sort | xargs)
    printf "%-5s %-15s -> %-70s\n" "[ ${variEachBashEvni} ]" "$variEachUnitCommand" "$variEachOptionList" >> ${VARI_GLOBAL["VERSION_URI"]}
    printf "%-5s %-15s -> %-70s\n" "[ ${variEachBashEvni} ]" "$variEachUnitCommand" "$variEachOptionList" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  done
  # report3/3[END]
  return 0
}

function funcProtectedComplete(){
  variCommand=$1
  variOptionList=$2
# 添加當前腳本的命令補全邏輯
echo '# 1按下「table」時執行提示，2_complete()執行完畢後觸發補全邏輯
_'${variCommand}'_complete() {
    local currentWord optionList
    currentWord="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=()
    case ${COMP_CWORD} in
        1)
            optionList="'${variOptionList}'"
            COMPREPLY=( $(compgen -W "${optionList}" -- "${currentWord}") )
            ;;
        *)
            return 0
            ;;
    esac
    return 0
}
# 啟動「交互終端」時執行一次
complete -F _'${variCommand}'_complete '${variCommand} > /etc/bash_completion.d/${variCommand}
  chmod +x /etc/bash_completion.d/${variCommand}
  return 0
}

function funcProtectedEchoGreen(){
  echo -e "\033[32m$1\033[0m"
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicInit(){
  local variParameterDescList=("init mode，value：0/（default），1/refresh cache")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  variRefreshCache=${1:-0}
  if [ -z "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}" ] || [ ${variRefreshCache} -eq 1 ]; then
    echo '' > ${VARI_GLOBAL["VERSION_URI"]}
    variOmniRootPath="${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]%'/init/centos'}"
    funcProtectedUpdateVariGlobalBuiltinValue "BUILTIN_OMNI_ROOT_PATH" ${variOmniRootPath}
  fi
  # pull *.sh list[START]
  # filter : ${VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"] && ${VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]}
  # find "/windows/code/backend/chunio/omni" \
  # -type d -path "/windows/code/backend/chunio/omni/vendor" -prune -o \
  # -type d -path "/windows/code/backend/chunio/omni/include" -prune -o \
  # -type d -regex ".*/template" -prune -o \
  # -type f -name "*.sh" -print
  local variFindCommand="find \"${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}\""
  for variEachIgnoreDirectory in ${VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"]}; do
      variFindCommand="$variFindCommand -type d -path \"${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/$variEachIgnoreDirectory\" -prune -o"
  done
  for variEachIgnoreDirectory in ${VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]}; do
      variFindCommand="$variFindCommand -type d -regex \".*/$variEachIgnoreDirectory\" -prune -o"
  done
  variFindCommand="$variFindCommand -type f -name \"*${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}\" -print"
  variAbleUnitFileURIList=$(eval "$variFindCommand" | sort -u)
  # pull *.sh list[END]
  funcProtectedCommandInit "${variAbleUnitFileURIList}"
  funcProtectedOptionInit "${variAbleUnitFileURIList}"
  return 0
}

function funcPublicSaveUnit(){
  local variParameterDescList=("unit name（limited to the ./omni/module/*）" "save to [ the path ]")
  funcProtectedCheckRequiredParameter 2 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variUnitName=${1}
  variSaveToThePath=${2}
  variArchiveCommand=omni.${variUnitName}
  # [ ${variSaveToThePath} == "/" ] && variSaveToThePath=""
  variArchivePath=${variSaveToThePath}/${variArchiveCommand}
  rm -rf ${variArchivePath} ${variSaveToThePath}/${variArchiveCommand}.tgz
  mkdir -p ${variArchivePath}/module
  /usr/bin/cp -rf "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}"/{common,include,init} ${variArchivePath}
  /usr/bin/cp -rf "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}"/module/${variUnitName} ${variArchivePath}/module
  # flush the useless data[START]
  find ${variArchivePath} -type f -name "encrypt.envi" -exec truncate -s 0 {} \;
  variRuntimePathList=$(find ${variArchivePath} -type d -name "runtime")
  for variEachRuntimePath in ${variRuntimePathList}; do
    rm -rf "${variEachRuntimePath:?}"/*
  done
  # flush the useless data[END]
  echo "[root@localhost /]# tar -xvf ${variArchiveCommand}.tgz" >> ${variArchivePath}/README.md
  echo "[root@localhost /]# ./${variArchiveCommand}/init/centos/centos.sh init && source /etc/bashrc" >> ${variArchivePath}/README.md
  echo "[root@localhost /]# omni.centos version" >> ${variArchivePath}/README.md
  echo '[root@localhost /]# # example : [ input ] '${variArchiveCommand}' >> \table' >> ${variArchivePath}/README.md
  tar -czvf ${variSaveToThePath}/${variArchiveCommand}.tgz ${variArchivePath}
  rm -rf ${variSaveToThePath}/${variArchiveCommand}
  return 0
}

function funcPublicNewUnit(){
  local variParameterDescList=("unit name")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variUnitName=${1}
  if [[ -d "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/module/${variUnitName}" ]]; then
    echo "error : ${variUnitName} already exists" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    return 1
  fi
  cp -rf ${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/init/template ${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/module/${variUnitName}
  mv ${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/module/${variUnitName}/template.sh ${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/module/${variUnitName}/${variUnitName}.sh
  return 0
}

function funcPublicShowPort(){
  local variParameterDescList=("port")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variPort=${1}
  variExpectAction=${2:-"cancel"}
  variProcessIdList=$(lsof -i :${variPort} -t)
  if [ -z "$variProcessIdList" ]; then
    funcProtectedEchoGreen "${variPort} is not being listened to"
  else
    funcProtectedEchoGreen 'command >> netstat -lutnp | grep ":'${variPort}'"'
    netstat -lutnp | grep ":${variPort}"
    funcProtectedEchoGreen "command >> lsof -i :${variPort}"
    lsof -i :${variPort}
    funcProtectedEchoGreen "command >> lsof -i :${variPort} -t | xargs -r ps -fp"
    lsof -i :${variPort} -t | xargs -r ps -fp
    if [ ${variExpectAction} == "confirm" ];then
      variInput="confirm"
    else
      read -p "Do you want to release the port（$variPort） ? (type 'confirm' to release): " variInput
    fi
    if [[ "$variInput" == "confirm" ]]; then
      for eachProcessId in ${variProcessIdList}
      do
          variEachCommand=$(ps -p ${eachProcessId} -f -o cmd --no-headers)
          /usr/bin/kill -9 $eachProcessId
          funcProtectedEchoGreen "kill -9 $eachProcessId success （${variEachCommand}）"
      done
    fi
  fi
  return 0
}

function funcPublicMatchKill() {
    local variParameterDescList=("keyword")
    funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
    local variKeyword=$1
    ps aux | grep "${variKeyword}"
    local variPidList=$(ps aux | grep "${variKeyword}" | grep -v grep | awk '{print $2}')
    if [ -z "${variPidList}" ]; then
        echo "no process found with keyword : ${variKeyword}"
        return 1
    fi
    for variEachPid in ${variPidList}; do
        echo "killing process with pid : ${variEachPid}"
        kill ${variEachPid}
        sleep 1
        if ps -p ${variEachPid} > /dev/null; then
            echo "process ${variEachPid} did not terminate, force killing ..."
            kill -9 ${variEachPid}
        else
            echo "process ${variEachPid} terminated"
        fi
    done
    echo "all processes with keyword '${variKeyword}' have been killed"
    return 0
}


function funcPublicVersion() {
    local variLineNum=$(tac "${VARI_GLOBAL["VERSION_URI"]}" | awk '/releaseCloud/ {print NR; exit}')
    if [ -z "$variLineNum" ]; then
        return 1
    else
        local variTotalLineNum=$(wc -l < "${VARI_GLOBAL["VERSION_URI"]}")
        local variForwardLineNum=$((variTotalLineNum - variLineNum + 1))
        tail -n +$variForwardLineNum "${VARI_GLOBAL["VERSION_URI"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    fi
    return 0
}

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

# 免費證書 && 自動續簽
# 如已完成域名解釋，則由服務器端操作證書安裝即可（即：無需二次驗證/解釋）
# 權限驗證（即：證書頒發機構確認申請者是否對域名擁有控制權的一種方法）：DNS‑01/HTTP‑01/...
#「certbot」是由「Let’s Encrypt」官方提供的命令行客戶端，基於「ACME/自動證書(SSL/TLS)管理環境」協議，支持:[免費]申請/續簽（有效期：90天）
#「webroot」將使用「nginx/other web serivce/...」響應「/​.well-known/acme‑challenge/」下的挑戰文件（不必:讓出80端口，推薦）
#「standalone」將啟動一個臨時的HTTP服務來影響權限驗證（必需：讓出80端口）
# --post-hook「certbot命令」執行結束觸發的勾子
# --deploy-hook 證書內容成功更新觸發的勾子
# [證書目錄] /usr/local/nginx/certbot/config/live/skeleton.y-one.co.jp
# [證書測試] curl -vI https://skeleton.y-one.co.jp/cookie?status=1
# [續簽測試] certbot renew --dry-run（#續簽時機：[默認]在證書過期前30天開始嘗試續簽）
# omni.centos certbot "baichuan.wiki" "webroot" "/usr/local/nginx1170/certbot" "nginx1170"
function funcPublicCertbot() {
  local variParameterDescList=("domain, example : baichuan.wiki" "model，value : webroot, standalone" "certbot path，example : /usr/local/nginx1170/certbot" "service name，example : nginx1170")
  funcProtectedCheckRequiredParameter 4 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  if ! command -v certbot &> /dev/null; then
    yum install -y certbot
  fi
  local variDomain=${1}
  local variModel=${2}
  local variCertbotPath=${3-"/usr/local/nginx/certbot"}
  local variServiceName=${4-"nginx"}
  local variEmail="zengweitao@msn.com"
  local variRenewShellUri=""
  # 備份證書[START]
  if [[ -d "${variCertbotPath}/config/live/${variDomain}" ]]; then
    local variBackupPath="${variCertbotPath}/backup/$(date +%Y%m%d%H%M%S)"
    mkdir -p "${variBackupPath}"
    /usr/bin/cp -rf "${variCertbotPath}/config/live/${variDomain}" "${variBackupPath}/"
    echo "successful backup : ${variBackupPath}"
  fi
  # 備份證書[END]
  mkdir -p ${variCertbotPath}/webroot/.well-known/acme-challenge
  chown root:root ${variCertbotPath}
  chmod 755 ${variCertbotPath}
  case ${variModel} in
    "webroot")
      certbot certonly \
        --webroot \
        -w ${variCertbotPath}/webroot \
        -d ${variDomain} \
        --agree-tos \
        --email ${variEmail} \
        --non-interactive \
        --config-dir ${variCertbotPath}/config \
        --work-dir ${variCertbotPath}/work \
        --logs-dir ${variCertbotPath}/logs
      variRenewShellUri=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cerbot.${variDomain}.renew.sh
      cat <<WEBROOTRENEWSHELL > ${variRenewShellUri}
#!/bin/bash
certbot renew --quiet \
  --config-dir ${variCertbotPath}/config \
  --work-dir ${variCertbotPath}/work \
  --logs-dir ${variCertbotPath}/logs \
  --deploy-hook "systemctl reload ${variServiceName}.service"
WEBROOTRENEWSHELL
    ;;
    "standalone")
      /windows/code/backend/chunio/omni/init/centos/centos.sh showPort 80 confirm
      certbot certonly \
        --standalone \
        --preferred-challenges http \
        -d ${variDomain} \
        --agree-tos \
        --email ${variEmail} \
        --non-interactive \
        --config-dir ${variCertbotPath}/config \
        --work-dir ${variCertbotPath}/work \
        --logs-dir ${variCertbotPath}/logs
      variRenewShellUri=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cerbot.${variDomain}.renew.sh
      cat <<STANDALONERENEWSHELL > ${variRenewShellUri}
#!/bin/bash
certbot renew --quiet \
  --standalone \
  --config-dir ${variCertbotPath}/config \
  --work-dir ${variCertbotPath}/work \
  --logs-dir ${variCertbotPath}/logs \
  --pre-hook "systemctl stop ${variServiceName}.service" \
  --deploy-hook "systemctl restart ${variServiceName}.service"
STANDALONERENEWSHELL
    ;;
  *)
   echo "Unknown Mode : ${variModel}"; 
   return 1
  ;;
  esac
  chmod +x ${variRenewShellUri}
  if ! grep -q "${variRenewShellUri}" /var/spool/cron/root; then
    echo "0 0 * * 1 ${variRenewShellUri}" >> /var/spool/cron/root
  fi
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"