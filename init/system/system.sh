#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/05/23

:<<'MARK'
/etc/profile : 「登錄」時執行一次（含：1/ssh，2終端）>> [自動執行]/etc/profile.d/*.sh（影響：所有用戶，弊端：執行「source /etc/profile」亦無法加載最新變更至當前終端））
/etc/bashrc : 開啟「新的終端窗口」時執行一次（影響：所有用戶（~/.bashrc（影響：單個用戶）））
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
VARI_GLOBAL["CLOUD_INIT_REFRESH_TIMESTAMP"]=0
VARI_GLOBAL["MOUNT_USERNAME"]=""
VARI_GLOBAL["MOUNT_PASSWORD"]=""
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedOsDistroInit() {
  local variOsType=$(uname)
  local variOsDistro="UNKNOWN"
  local variSourceUri=""
  if [ "$variOsType" = "Darwin" ]; then
      variOsDistro="MACOS"
  elif [ "$variOsType" = "Linux" ]; then
      if [ -f /etc/debian_version ]; then
          variOsDistro="UBUNTU"
          variSourceUri="/etc/bash.bashrc"
      # elif [ -f /etc/os-release ]; then
      #   . /etc/os-release
      #   variOsDistro=$(echo $ID | tr '[:lower:]' '[:upper:]')
      elif [ -f /etc/centos-release ]; then
          variOsDistro="CENTOS"
          variSourceUri="/etc/profile.d/omni.sh"
      elif [ -f /etc/redhat-release ]; then
          variOsDistro="CENTOS"
          variSourceUri="/etc/profile.d/omni.sh"
      fi
  fi
  funcProtectedUpdateVariGlobalBuiltinValue "BUILTIN_OS_DISTRO" ${variOsDistro}
  funcProtectedUpdateVariGlobalBuiltinValue "BUILTIN_SOURCE_URI" ${variSourceUri}
  return 0
}

function funcProtectedCloudInit() {
  funcProtectedOsDistroInit
  case ${VARI_GLOBAL["BUILTIN_OS_DISTRO"]} in
      "MACOS")
          # TODO:...
          ;;
      "UBUNTU"|"DEBIAN")
          funcProtectedUbuntuInit
          ;;
      "CENTOS"|"RHEL"|"REDHAT")
          funcProtectedCentosInit
          ;;
      *)
          return 1
          ;;
  esac
  return 0
}

function funcProtectedUbuntuInit(){
  # 針對「ubuntu/debian」，移除「apt/dpkg」鎖定檔案以防止先前的執行衝突[START]
  rm -f /var/lib/dpkg/lock-frontend
  rm -f /var/lib/dpkg/lock
  rm -f /var/cache/apt/archives/lock
  # 針對「ubuntu/debian」，移除「apt/dpkg」鎖定檔案以防止先前的執行衝突[END]
  apt update
  variPackageList=(
    # ubuntu[START]
    apt-utils
    dialog
    # ubuntu[END]
    ca-certificates
    git
    lsof
    tree
    wget
    expect
    telnet
    dos2unix
    net-tools
    # 含：nslookup（用以測試域名解析等）
    dnsutils
    docker
    docker-compose
    bash-completion
  )
  variCloudInitSucceeded=1
  variAllPackageInstalledLabel="${variPackageList[*]} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
  grep -qF "${variAllPackageInstalledLabel}" "${VARI_GLOBAL["VERSION_URI"]}" 2> /dev/null
  [ $? -eq 0 ] && return 0
  local variRetry=10
  local variSleep=2
  declare -A variCloudInstallResult
  for variEachPackage in "${variPackageList[@]}"; do
    # 檢查單個套件安裝狀態，已完成則跳過[START]
    local variEachPackageInstalledLabel="apt install -y ${variEachPackage} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
    if grep -qF "${variEachPackageInstalledLabel}" "${VARI_GLOBAL["VERSION_URI"]}" 2> /dev/null; then
      echo "package '${variEachPackage}' already installed"
      variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
      continue
    fi
    # 檢查單個套件安裝狀態，已完成則跳過[END]
    # default
    variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}
    case ${variEachPackage} in
      "docker")
        # https://docs.docker.com/engine/install/ubuntu/
        apt remove -y docker.io docker-doc docker-compose containerd runc
        # 等價於：mkdir -p /etc/apt/keyrings && chmod 0755 /etc/apt/keyrings
        install -m 0755 -d /etc/apt/keyrings
        # 獲取公鑰（驗證套件哈希/真實性的）
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        # 動態構建資源倉庫
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
        apt update
        for ((i=1; i<variRetry; i++)); do
          if apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
            systemctl enable docker
            systemctl restart docker
            variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
            break
          fi
          sleep $variSleep
        done
        ;;
      "docker-compose")
        # https://github.com/docker/compose/releases
        # docker-compose-linux-x86_64
        variDockerComposeUri=$(which docker-compose 2> /dev/null)
        [ -n "${variDockerComposeUri}" ] && rm -f ${variDockerComposeUri}
        curl -L "https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        if command -v docker-compose > /dev/null; then
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        fi
        ;;
      *)
        for ((i=1; i<variRetry; i++)); do
          if apt install -y "${variEachPackage}"; then
            variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
            break
          fi
          sleep $variSleep
        done
        ;;
    esac
  done
  # --------------------------------------------------
  for variEachPackage in "${!variCloudInstallResult[@]}"; do
    echo "${variEachPackage} : ${variCloudInstallResult[${variEachPackage}]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    if [ ${variCloudInstallResult[${variEachPackage}]} == ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]} ]; then
      local variEachPackageInstalledLabel="apt install -y ${variEachPackage} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
      echo "${variEachPackageInstalledLabel}" >> "${VARI_GLOBAL["VERSION_URI"]}"
    else
      variCloudInitSucceeded=0
    fi
  done
  [ ${variCloudInitSucceeded} == 1 ] && echo ${variAllPackageInstalledLabel} >> ${VARI_GLOBAL["VERSION_URI"]}
  # --------------------------------------------------
  VARI_GLOBAL["CLOUD_INIT_REFRESH_TIMESTAMP"]=$(date +%s)
  return 0
}

function funcProtectedCentosInit(){
  funcProtectedCentos7YumRepositoryUpdater
  rm -f /var/run/yum.pid
  variPackageList=(
    # centos[START]
    yum-utils
    # Extra Packages for Enterprise Linux/企業係統額外套件
    # epel-release
    # centos[END]
    ca-certificates
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
  # default
  local variCloudInitSucceeded=1
  # 檢查整體套件安裝狀態，已完成則退出[START]
  local variAllPackageInstalledLabel="${variPackageList[*]} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
  grep -qF "${variAllPackageInstalledLabel}" "${VARI_GLOBAL["VERSION_URI"]}" 2> /dev/null && return 0
  # 檢查整體套件安裝狀態，已完成則退出[END]
  local variRetry=10
  local variSleep=2
  declare -A variCloudInstallResult
  for variEachPackage in "${variPackageList[@]}"; do
    # 檢查單個套件安裝狀態，已完成則跳過[START]
    local variEachPackageInstalledLabel="yum install -y ${variEachPackage} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
    if grep -qF "${variEachPackageInstalledLabel}" "${VARI_GLOBAL["VERSION_URI"]}" 2> /dev/null; then
      echo "package '${variEachPackage}' already installed"
      variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
      continue
    fi
    # 檢查單個套件安裝狀態，已完成則跳過[END]
    # default
    variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}
    case ${variEachPackage} in
      "epel-release")
        # 當小於/等於「centos.7.x」時，則跳過「for variEachPackage in "${variPackageList[@]}"; do」（已驗證）
        [[ $(grep -oE '[0-9]+' /etc/centos-release 2>/dev/null | head -n 1) -le 7 ]] && continue
        if yum install -y epel-release; then
          variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        fi
        yum clean all > /dev/null
        ;;
      "docker")
        # https://docs.docker.com/engine/install/centos/
        # docker-ce-cli-20.10.7-3.el7.x86_64.rpm
        yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
        yum install -y lvm2 device-mapper-persistent-data
        yum update -y nss curl openssl
        for ((i=1; i<variRetry; i++)); do
          if yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo; then
            sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/docker-ce.repo
            break
          fi
          sleep $variSleep
        done
        # yum install -y docker-ce docker-ce-cli containerd.io
        for ((i=1; i<variRetry; i++)); do
          if yum install -y docker-ce docker-ce-cli containerd.io; then
            systemctl enable docker
            systemctl restart docker
            variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
            break
          fi
          sleep $variSleep
        done
        ;;
      "docker-compose")
        # https://github.com/docker/compose/releases
        # docker-compose-linux-x86_64
        variDockerComposeUri=$(which docker-compose 2> /dev/null)
        [ -n "${variDockerComposeUri}" ] && rm -f ${variDockerComposeUri}
        curl -L "https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        if command -v docker-compose > /dev/null; then
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        fi
        ;;
      *)
        for ((i=1; i<variRetry; i++)); do
          if yum install -y "${variEachPackage}"; then
            variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
            break
          fi
          sleep $variSleep
        done
        ;;
    esac
  done
  # --------------------------------------------------
  for variEachPackage in "${!variCloudInstallResult[@]}"; do
    echo "${variEachPackage} : ${variCloudInstallResult[${variEachPackage}]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    if [ ${variCloudInstallResult[${variEachPackage}]} == ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]} ]; then
      local variEachPackageInstalledLabel="yum install -y ${variEachPackage} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
      echo "${variEachPackageInstalledLabel}" >> "${VARI_GLOBAL["VERSION_URI"]}"
    else
      variCloudInitSucceeded=0
    fi
  done
  [ ${variCloudInitSucceeded} == 1 ] && echo ${variAllPackageInstalledLabel} >> ${VARI_GLOBAL["VERSION_URI"]}
  # --------------------------------------------------
  VARI_GLOBAL["CLOUD_INIT_REFRESH_TIMESTAMP"]=$(date +%s)
  return 0
}

# 更新倉庫(x9)
#「centos7.9」已停止維護（截止2024/06/30），[官方倉庫]mirrorlist.centos.org >> [歸檔倉庫]vault.centos.org
function funcProtectedCentos7YumRepositoryUpdater(){
  # 僅適用於「centos7」[START]
  # 當大於/等於「centos.8.x」時，則返回0
  [[ $(grep -oE '[0-9]+' /etc/centos-release 2>/dev/null | head -n 1) -ge 8 ]] && return 0
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
  # sed -i 's|^mirrorlist=|# mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo 2> /dev/null
  # sed -i 's|#\s*baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo 2> /dev/null
  rm -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository
  mkdir -p ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Base.repo
# 作用說明：核心倉庫，提供係統安裝時的「base/基礎軟件」，「updates/更新軟件」，「extras/額外工具」，「centosplus/功能增強」
# 啟用狀態：--

[base]
name=CentOS-7.9 - Base
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/os/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
metadata_expire=never
skip_if_unavailable=1

[updates]
name=CentOS-7.9 - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/updates/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
metadata_expire=never
skip_if_unavailable=1

[extras]
name=CentOS-7.9 - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/extras/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
metadata_expire=never
skip_if_unavailable=1

[centosplus]
name=CentOS-7.9 - CentOSPlus
baseurl=http://vault.centos.org/7.9.2009/centosplus/$basearch/
# [alternative]baseurl=https://archive.kernel.org/centos-vault/7.9.2009/centosplus/$basearch/
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
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
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
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
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Vault.repo
# 作用說明：歸檔倉庫，使用於已終止支援的係統版本
# 啟用狀態：預設禁用（原因：避免與「CentOS-Base.repo/Updates」衝突）

[C7.9.2009-base]
name=CentOS-7.9.2009 - Base (vault - disabled)
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
metadata_expire=never
skip_if_unavailable=1

[C7.9.2009-updates]
name=CentOS-7.9.2009 - Updates (vault - disabled)
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
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
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
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
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
metadata_expire=never
skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/CentOS-Debuginfo.repo
# 作用說明：提供包含除錯符號的套件（如：gdb/...，如需「debug key」，則保持禁用）
# 啟用狀態：--

[debuginfo]
name=CentOS-7 - Debuginfo
baseurl=http://debuginfo.centos.org/7/$basearch/
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Debug-7
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
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=https://archives.fedoraproject.org/pub/archive/epel/7/$basearch
# metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
# skip_if_unavailable=1

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - $basearch - Debug
baseurl=https://archives.fedoraproject.org/pub/archive/epel/7/$basearch/debug
# metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-7&arch=$basearch
failovermethod=priority
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
# skip_if_unavailable=1

[epel-source]
name=Extra Packages for Enterprise Linux 7 - $basearch - Source
baseurl=https://archives.fedoraproject.org/pub/archive/epel/7/SRPMS
# metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-7&arch=$basearch
failovermethod=priority
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
# skip_if_unavailable=1
MARK
  cat <<'MARK' > ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/epel-testing.repo
[epel-testing]
name=Extra Packages for Enterprise Linux 7 - Testing - $basearch
baseurl=https://archives.fedoraproject.org/pub/archive/epel/testing/7/$basearch
# metalink=https://mirrors.fedoraproject.org/metalink?repo=testing-epel7&arch=$basearch
failovermethod=priority
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
# skip_if_unavailable=1

[epel-testing-debuginfo]
name=Extra Packages for Enterprise Linux 7 - Testing - $basearch - Debug
baseurl=https://archives.fedoraproject.org/pub/archive/epel/testing/7/$basearch/debug
# metalink=https://mirrors.fedoraproject.org/metalink?repo=testing-debug-epel7&arch=$basearch
failovermethod=priority
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
# skip_if_unavailable=1

[epel-testing-source]
name=Extra Packages for Enterprise Linux 7 - Testing - $basearch - Source
baseurl=https://archives.fedoraproject.org/pub/archive/epel/testing/7/SRPMS
# metalink=https://mirrors.fedoraproject.org/metalink?repo=testing-source-epel7&arch=$basearch
failovermethod=priority
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
# skip_if_unavailable=1
MARK
  # ----------
  # /usr/bin/cp -rf ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/repository/* ${variRepositoryPath}/
  /usr/bin/cp -rf ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/repository/* ${variRepositoryPath}/
  chmod -R 644 ${variRepositoryPath}
  #「docker-ce-stable」對於「centos7」不再維護，需自行安裝
  # yum-config-manager --disable docker-ce-stable > /dev/null || true
  yum clean all > /dev/null
  # sudo yum makecache fast
  # sudo yum repolist
  return 0
}

function funcProtectedCommandInit(){
  local variAbleUnitFileURIList=${1}
  # local variEtcBashrcReloadStatus=0
  rm -rf /usr/local/bin/"${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}."*
  for variAbleUnitFileUri in ${variAbleUnitFileURIList}; do
    variEachUnitFilename=$(basename ${variAbleUnitFileUri})
    variEachUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    # TODO:已廢棄/待移除（直至：所有[haohaiyou]雲服務器皆重新執行一次「omni.system init」）[START]
    local variDeletePattern="^alias ${variEachUnitCommand}="
    sed -i "/${variDeletePattern}/d" ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    # TODO:已廢棄/待移除（直至：所有[haohaiyou]雲服務器皆重新執行一次「omni.system init」）[END]
    ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachUnitCommand
    # if grep -q 'VARI_GLOBAL\["BUILTIN_BASH_ENVI"\]="MASTER"' ${variAbleUnitFileUri}; then
        # 基於當前環境的命令（即：vim /etc/bashrc）[START]
        # local variDeletePattern="^alias ${variEachUnitCommand}="
        # local variDeletedCount=$(grep -c "${variDeletePattern}" /etc/bashrc || true)
        # sed -i "/${variDeletePattern}/d" /etc/bashrc
        # local variAddPattern='alias '${variEachUnitCommand}'="source '${variAbleUnitFileUri}'"'
        # echo $variAddPattern >> /etc/bashrc
        # if [ "${variDeletedCount}" -gt 0 ]; then
        #   [ $variEtcBashrcReloadStatus -eq 0 ] && echo 'source /etc/bashrc' >> ${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}
        #   variEtcBashrcReloadStatus=1
        # fi
        # echo $variAddPattern >> ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
        # 基於當前環境的命令（即：vim /etc/bashrc）[END]
    # else
        # 基於派生環境的命令（即：ln -sf ./omni/.../example.sh /usr/local/bin/omni.example）[START]
        # echo "ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachUnitCommand" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
        # ln -sf $variAbleUnitFileUri /usr/local/bin/$variEachUnitCommand
        # 基於派生環境的命令（即：ln -sf ./omni/.../example.sh /usr/local/bin/omni.example）[END]
    # fi
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
    grep -q 'VARI_GLOBAL\["BUILTIN_BASH_ENVI"\]="MASTER"' ${variAbleUnitFileUri} && variEachBashEvni="M" || variEachBashEvni="S" # TODO:已廢棄/待移除
    funcProtectedBashCompletion "$variEachUnitCommand" "${variIncludeOptionList} ${variEachOptionList}"
    # report2/3[START]
    if [ ${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}} == 'system' ]; then
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

function funcProtectedBashCompletion(){
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

# protected function[END]
# ##################################################

# ##################################################
# public function[START]

function funcPublicInit(){
  local variParameterDescList=("init model，value：0/cache（default），1/refresh")
  funcProtectedCheckOptionParameter 1 variParameterDescList[@]
  local variInitModel=${1:-0}
  if [ -z "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}" ] || [ ${variInitModel} -eq 1 ]; then
    install -m 755 <(echo '#!/bin/bash') ${VARI_GLOBAL["BUILTIN_SOURCE_URI"]}
    echo '' > ${VARI_GLOBAL["VERSION_URI"]}
    # 檢查間隔（要求：大於3秒）[START]
    # 避免首次「omni.system init 1」時，觸發兩次「funcProtectedCloudInit」
    if (( $(date +%s) - ${VARI_GLOBAL["CLOUD_INIT_REFRESH_TIMESTAMP"]} > 3 )); then
      funcProtectedCloudInit
    fi
    # 檢查間隔（要求：大於3秒）[END]
    local variOmniRootPath="${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]%'/init/system'}"
    funcProtectedUpdateVariGlobalBuiltinValue "BUILTIN_OMNI_ROOT_PATH" ${variOmniRootPath}
  fi
  # 設置字符編碼[START]
  localectl set-locale LANG=en_US.UTF-8
  # 設置字符編碼[END]
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

function funcPublicVersion() {
    echo "[ https://github.com/chunio/omni.git ] version 1.0.0"
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
  echo "[root@localhost /]# ./${variArchiveCommand}/init/system/system.sh init && source /etc/bashrc" >> ${variArchivePath}/README.md
  echo "[root@localhost /]# omni.system version" >> ${variArchivePath}/README.md
  echo '[root@localhost /]# # example : [ input ] '${variArchiveCommand}' >> \table' >> ${variArchivePath}/README.md
  tar -czvf ${variSaveToThePath}/${variArchiveCommand}.tgz ${variArchivePath}
  rm -rf ${variSaveToThePath}/${variArchiveCommand}
  return 0
}

# clash:7890
# v2rayn:10809（設置 >> 參數設置 >> 開啟「允許來自局域網的連接」）
# 驗證方法：curl https://www.google.com（由於ICMP協議不走HTTP代理，因此PING不通亦正常）
function funcPublicProxy() {
  case ${VARI_GLOBAL["BUILTIN_OS_DISTRO"]} in
      "MACOS")
          # TODO:...
          ;;
      "UBUNTU"|"DEBIAN")
          omni.ubuntu proxy $1
          ;;
      "CENTOS"|"RHEL"|"REDHAT")
          omni.centos proxy $1
          ;;
      *)
          return 1
          ;;
  esac
  return 0
}

# 一個特定的網絡端點（協議（如：IPV4/IPV6/...） + IP地址 + 端口）僅支持被一個進程綁定
function funcPublicPort(){
  local variParameterDescList=("port")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variPort=${1}
  local variExpectAction=${2:-"cancel"}
  local variInput=""
  #（1）統計數量
  local variProcessIdList=$(lsof -i :${variPort} -t)
  if [ -z "$variProcessIdList" ]; then
    funcProtectedEchoGreen "0 process was found listening on port '${variPort}'"
    return 0
  fi
  local variProcessCount=$(echo "${variProcessIdList}" | wc -w)
  funcProtectedEchoGreen "${variProcessCount} process(es) was(were) found listening on port '${variPort}'"
  #（2）進程信息
  funcProtectedEchoGreen 'command >> netstat -lutnp | grep ":'${variPort}'"'
  netstat -lutnp | grep ":${variPort}"
  funcProtectedEchoGreen "command >> lsof -i :${variPort}"
  lsof -i :${variPort}
  funcProtectedEchoGreen "command >> lsof -i :${variPort} -t | xargs -r ps -fp"
  lsof -i :${variPort} -t | xargs -r ps -fp
  #（2）是否終止
  if [ ${variExpectAction} == "kill" ];then
    variInput="kill"
  else
    read -p "do you want to kill the ${variProcessCount} process(es) listening on port '${variPort}' ? ( type 'kill' to confirm ) : " variInput
  fi
  if [[ "$variInput" == "kill" ]]; then
    for variEachProcessId in ${variProcessIdList}; do
        variEachCommand=$(ps -p ${variEachProcessId} -f -o cmd --no-headers)
        /usr/bin/kill -9 $variEachProcessId
        funcProtectedEchoGreen "kill -9 $variEachProcessId success ( command : ${variEachCommand} ) "
    done
    funcProtectedEchoGreen "${variProcessCount} process(es) with port '${variPort}' has(have) been terminated"
  fi
  return 0
}

function funcPublicProcess() {
    local variParameterDescList=("keyword")
    funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
    local variKeyword=$1
    local variExpectAction=${2:-"cancel"}
    local variInput=""
    #（0）檢查是否命令注入
    if [[ ! "${variKeyword}" =~ ^[a-zA-Z0-9_./:-]+$ ]]; then
        funcProtectedEchoRed "invalid keyword format"
        return 1
    fi
    #（1）統計數量
    local variProcessIdList=$(pgrep -f "${variKeyword}" 2>/dev/null)
    if [ -z "${variProcessIdList}" ]; then
        funcProtectedEchoGreen "0 process was found matching the keyword '${variKeyword}'"
        return 0
    fi
    local variProcessCount=$(echo "${variProcessIdList}" | wc -w)
    funcProtectedEchoGreen "${variProcessCount} process(es) was(were) found matching the keyword '${variKeyword}'"
    #（2）進程信息
    ps -fp ${variProcessIdList}
    #（3）是否終止
    if [ "${variExpectAction}" == "kill" ]; then
        variInput="kill"
    else
        read -p "do you want to kill the ${variProcessCount} process(es) matching the keyword '${variKeyword}' ? ( type 'kill' to confirm ) : " variInput
    fi
    if [[ "$variInput" == "kill" ]]; then
        for variEachProcessId in ${variProcessIdList}; do
            # 獲取進程命令詳情
            local variEachCommand=$(ps -p ${variEachProcessId} -o cmd --no-headers 2>/dev/null)
            if [ -n "${variEachCommand}" ]; then
                kill -9 ${variEachProcessId} 2>/dev/null
                funcProtectedEchoGreen "kill -9 ${variEachProcessId} success ( command : ${variEachCommand} )"
            else
                funcProtectedEchoGreen "the ${variEachProcessId} already terminated ( command : ${variEachCommand} )"
            fi
        done
        funcProtectedEchoGreen "${variProcessCount} process(es) with keyword '${variKeyword}' has(have) been terminated"
    fi
    return 0
}

# 免費證書 && 自動續簽
# 如已完成域名解釋，則由服務器端操作證書安裝即可（即：無需二次驗證/解釋）
# 權限驗證（即：證書頒發機構確認申請者是否對域名擁有控制權的一種方法）：DNS‑01/HTTP‑01/...
#「certbot」是由「Let’s Encrypt」官方提供的命令行客戶端，基於「ACME/自動證書(SSL/TLS)管理環境」協議，支持:[免費]申請/續簽（有效期：90天）
#「webroot」將使用「nginx/other web serivce/...」響應「/​.well-known/acme‑challenge/」下的挑戰文件（不必:讓出80端口，推薦）
#「standalone」將啟動一個臨時的HTTP服務來影響權限驗證（必需：讓出80端口）
#「TLSv1.3」依賴[system/nginx]openssl 1.1.1+
# --post-hook「certbot命令」執行結束觸發的勾子
# --deploy-hook 證書內容成功更新觸發的勾子
# [證書目錄] /usr/local/nginx/certbot/config/live/skeleton.y-one.co.jp
# [證書測試] curl -vI https://skeleton.y-one.co.jp/cookie?status=1
# [續簽測試] certbot renew --dry-run（#續簽時機：[默認]在證書過期前30天開始嘗試續簽）
# [證書評分] https://www.ssllabs.com/ssltest/
# git fetch origin
# git reset --hard origin/feature/zengweitao/ubuntu
# omni.centos certbot "example.wiki" "webroot" "/usr/local/nginx1170/certbot" "nginx1170"
# [nginx]示例模板[START]
# server {
#    listen 80;
#    server_name example.wiki;
#    #「Let’s Encrypt」挑戰認證[START]
#    location ^~ /.well-known/acme-challenge/ {
#        root /usr/local/nginx1170/certbot/webroot;
#        default_type "text/plain";
#        allow all;
#        auth_basic off;
#        try_files $uri $uri/ =404;
#    }
#    #「Let’s Encrypt」挑戰認證[END]
#    location / {
#        return 301 https://$host$request_uri;
#    }
# }
# server {
#    listen 443 ssl http2;
#    server_name example.wiki;
#    # SSL[START]
#    ssl_certificate /usr/local/nginx1170/certbot/config/live/example.wiki/fullchain.pem;
#    ssl_certificate_key /usr/local/nginx1170/certbot/config/live/example.wiki/privkey.pem;
#    #「TLSv1.3」依賴[system/nginx]openssl 1.1.1+
#    ssl_protocols TLSv1.2 TLSv1.3;
#    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
#    ssl_prefer_server_ciphers on;
#    ssl_session_timeout 1d;
#    ssl_session_cache shared:SSL:50m;
#    ssl_session_tickets off;
#    add_header Strict-Transport-Security "max-age=63072000" always;
#    add_header X-Frame-Options "SAMEORIGIN" always;
#    add_header X-Content-Type-Options "nosniff" always;
#    # SSL[END]
#    root /v2ray/webside;
#    index module/signIn/signIn.html;
#    location /temp {
#        proxy_redirect off;
#        proxy_pass http://127.0.0.1:10703;
#        proxy_http_version 1.1;
#        proxy_set_header Upgrade $http_upgrade;
#        proxy_set_header Connection "upgrade";
#        proxy_set_header Host $host;
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#    }
# }
# [nginx]示例模板[END]
function funcPublicCertbot() {
  local variParameterDescList=("domain, example : xxxx.wiki" "model，value : webroot, standalone" "certbot path，example : /usr/local/nginx1170/certbot" "service name，example : nginx1170")
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
      /windows/code/backend/chunio/omni/init/system/system.sh port 80 kill
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
    systemctl reload crond
    crontab -l
  fi
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"