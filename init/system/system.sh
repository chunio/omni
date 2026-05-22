#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 2024/05/23

:<<'MARK'
1/「#!/usr/bin/env bash」表示使用「$PATH/搜尋路徑」中首個匹配的「bash」(注意：{. || source}來執行腳本時，係統將無視「#!/usr/bin/env bash」)
2/etc/profile : 「登錄」時執行一次（含：1/ssh，2終端）>> [自動執行]/etc/profile.d/*.sh（影響：所有用戶，弊端：執行「source /etc/profile」亦無法加載最新變更至當前終端））
3/etc/bashrc : 開啟「新的終端窗口」時執行一次（影響：所有用戶（~/.bashrc（影響：當前用戶）））
4/「for...in...」&&「read...」所產生的迭代變量，默認全域（即：非「local」）
# ----------
兼容事項（即：LINUX支持，DARWIN缺失）：
1/LINUX:「grep -P」，[解決方案]DARWIN:「grep -E」
2/LINUX:「sed -i」，[解決方案]DARWIN:「sed -i '' # 額外依賴備份名稱」
3/LINUX:「date {-d，%3N，strftime}」，[解決方案]DARWIN:「date perl」
4/LINUX:「$(readlink -f "${BASH_SOURCE[0]}")」，[解決方案]DARWIN:「$(perl -MCwd -le 'print Cwd::abs_path(shift)' "${BASH_SOURCE[0]}")」
5/setopt NO_NOMATCH # 通配符號沒有匹配亦不報錯（區別：zsh/默認報錯，bash/不會報錯）
6/setopt KSH_ARRAYS # 數組索引從零開始（區別：zsh/從1開始，bash/從0開始）
7/setopt SH_WORD_SPLIT # 支持空格拆分變量（區別：zsh/不支持，bash/支持）
8/...
# ----------
1/find /windows/code/backend/chunio/omni -type f -name "*.sh" -exec dos2unix {} \;
MARK

# ##################################################
# compatible && validator[START]
# [zero length]bash
if [ -z "$ZSH_VERSION" ]; then
  [ "${BASH_VERSION%%.*}" -ge 4 ] 2>/dev/null || { echo "[ required ] {bash 4.0+ || zsh}"; return 1 2>/dev/null || exit 1; }
fi
# compatible && validator[END]
# ##################################################

# [已驗證]交替執行兩個不同的「SOURCE」級別腳本，同名{變量 && 函數}（如：${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}）不會覆蓋（即：互相獨立），測試用例：
# function funcPublicEchoBuiltinUnitRootPath() {
#    omni.system echoBuiltinUnitRootPath # /Users/zengweitao/archived/workspace/repository/chunio/omni/init/system
#    echo ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]} # /Users/zengweitao/archived/workspace/repository/chunio/omni/module/haohaiyou
#    return 0
# }
declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="SOURCE"
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"][START]
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 解釋軟鏈
if [ "${VARI_GLOBAL["BUILTIN_BASH_ENVI"]}" = "SOURCE" ];then
  VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)" # 不解軟鏈
fi
# VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"][END]
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE:-$0}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

funcProtectedConstruct # 二次執行（目的：提前獲取係統信息）

# ##################################################
# global variable[START]
variBuiltinOsDistroLower=$(echo "${VARI_GLOBAL["BUILTIN_OS_DISTRO"]}" | tr '[:upper:]' '[:lower:]')
VARI_GLOBAL["VERSION_URI"]="${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/init.${variBuiltinOsDistroLower}.version"
VARI_GLOBAL["CLOUD_INIT_REFRESH_TIMESTAMP"]=0
VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"]="internal vendor"
VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]="template"
# ----------
VARI_GLOBAL["OMNI_INIT_PATH"]="${HOME}/.omni.${variBuiltinOsDistroLower}" # 配置目錄
VARI_GLOBAL["OMNI_ENVI_PATH"]="${VARI_GLOBAL["OMNI_INIT_PATH"]}/envi" # 其他配置
VARI_GLOBAL["OMNI_BIN_PATH"]="${VARI_GLOBAL["OMNI_INIT_PATH"]}/bin" # 可執行的
VARI_GLOBAL["OMNI_COMPLETION_PATH"]="${VARI_GLOBAL["OMNI_INIT_PATH"]}/completion" # 命令補全
VARI_GLOBAL["OMNI_SH_BOOTSTRAP"]='[ -f "'${VARI_GLOBAL["OMNI_INIT_PATH"]}'/omni.'${variBuiltinOsDistroLower}'.sh" ] && source "'${VARI_GLOBAL["OMNI_INIT_PATH"]}'/omni.'${variBuiltinOsDistroLower}'.sh"' # 引導程序
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedCloudInit() {
  case ${VARI_GLOBAL["BUILTIN_OS_DISTRO"]} in
      "CENTOS"|"RHEL"|"REDHAT")
        funcProtectedCloudInit_Centos
        ;;
      "UBUNTU"|"DEBIAN")
        funcProtectedCloudInit_Ubuntu
        ;;
      "MACOS")
        funcProtectedCloudInit_Macos
        ;;
      *)
        return 1
        ;;
  esac
  return 0
}

function funcProtectedCloudInit_Centos(){
  funcProtectedCentos7YumRepositoryUpdater
  rm -f /var/run/yum.pid
  local variPackageList=(
    # centos[START]
    yum-utils
    # Extra Packages for Enterprise Linux/企業係統額外套件
    # epel-release
    # centos[END]
    chrony
    ca-certificates
    git
    lsof
    tree
    wget
    make
    gawk
    expect
    telnet
    dos2unix
    net-tools
    # 含：nslookup（用以測試域名解析等）
    bind-utils
    docker
    bash-completion
  )
  # default
  local variCloudInitSucceeded=1
  # 檢查整體套件安裝狀態，已完成則退出[START]
  local variAllPackageInstalledLabel="${variPackageList[*]} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
  grep -qF "${variAllPackageInstalledLabel}" "${VARI_GLOBAL["VERSION_URI"]}" 2> /dev/null && return 0
  # 檢查整體套件安裝狀態，已完成則退出[END]
  local variRetryNum=10
  local variRetryIndex
  local variSleep=2
  declare -A variCloudInstallResult
  local variEachPackage
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
      "chrony")
        if yum install -y chrony 2>/dev/null; then
          # ----------
          # [orbstack]無需啟用:
          # 1會自動同步宿主機器係統時間
          # 2當「arm64」虛擬化至「amd64（即：orbstack.x86-64(emulated)」時不兼容（報錯：Fatal error : Failed to load seccomp rules）
          if [ ! -d "/mnt/machines/$(hostname)" ];then
          # ----------
            # 服務名稱：[centos]chronyd，[ubuntu]chrony
            systemctl start chronyd && systemctl enable chronyd && chronyc makestep
          fi
          variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        fi
        ;;
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
        yum remove -y docker docker-engine docker-common docker-latest docker-client docker-client-latest docker-logrotate docker-latest-logrotate docker-compose-plugin
        yum install -y lvm2 device-mapper-persistent-data
        yum update -y nss curl openssl
        for ((variRetryIndex=1; variRetryIndex<variRetryNum; variRetryIndex++)); do
          if yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo; then
            sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/docker-ce.repo
            break
          fi
          sleep $variSleep
        done
        for ((variRetryIndex=1; variRetryIndex<variRetryNum; variRetryIndex++)); do
          if yum install -y containerd.io docker-ce docker-ce-cli docker-compose-plugin; then
            systemctl enable docker
            systemctl restart docker
            variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
            break
          fi
          sleep $variSleep
        done
        ;;
      *)
        for ((variRetryIndex=1; variRetryIndex<variRetryNum; variRetryIndex++)); do
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
    if [ "${variCloudInstallResult[${variEachPackage}]}" = ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]} ]; then
      local variEachPackageInstalledLabel="yum install -y ${variEachPackage} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
      echo "${variEachPackageInstalledLabel}" >> "${VARI_GLOBAL["VERSION_URI"]}"
    else
      variCloudInitSucceeded=0
    fi
  done
  [ ${variCloudInitSucceeded} -eq 1 ] && echo ${variAllPackageInstalledLabel} >> "${VARI_GLOBAL["VERSION_URI"]}"
  # --------------------------------------------------
  VARI_GLOBAL["CLOUD_INIT_REFRESH_TIMESTAMP"]=$(date +%s)
  return 0
}

function funcProtectedCloudInit_Ubuntu(){
  # 針對「ubuntu/debian」，移除「apt/dpkg」鎖定檔案以防止先前的執行衝突[START]
  sudo rm -f /var/lib/dpkg/lock
  sudo rm -f /var/lib/dpkg/lock-frontend
  sudo rm -f /var/cache/apt/archives/lock
  # 針對「ubuntu/debian」，移除「apt/dpkg」鎖定檔案以防止先前的執行衝突[END]
  local variPackageList=(
    # ubuntu[START]
    apt-utils
    dialog
    # ubuntu[END]
    chrony
    ca-certificates
    git
    lsof
    tree
    wget
    make
    gawk
    expect
    telnet
    dos2unix
    net-tools
    # 含：nslookup（用以測試域名解析等）
    dnsutils
    docker
    bash-completion
  )
  local variCloudInitSucceeded=1
  local variAllPackageInstalledLabel="${variPackageList[*]} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
  grep -qF "${variAllPackageInstalledLabel}" "${VARI_GLOBAL["VERSION_URI"]}" 2> /dev/null
  [ $? -eq 0 ] && return 0
  apt update
  local variRetryNum=10
  local variRetryIndex
  local variSleep=2
  declare -A variCloudInstallResult
  local variEachPackage
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
      "chrony")
        sudo mkdir -p /var/log/chrony
        sudo chown _chrony:_chrony /var/log/chrony
        if apt install -y chrony 2>/dev/null; then
          # ----------
          # [orbstack]無需啟用:
          # 1會自動同步宿主機器係統時間
          # 2當「arm64」虛擬化至「amd64（即：orbstack.x86-64(emulated)」時不兼容（報錯：Fatal error : Failed to load seccomp rules）
          if [ ! -d "/mnt/machines/$(hostname)" ];then
          # ----------
            # 服務名稱：[centos]chronyd，[ubuntu]chrony
            systemctl start chrony && systemctl enable chrony && chronyc makestep
          fi
          variCloudInstallResult["${variEachPackage}"]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
        fi
        ;;
      "docker")
        # https://docs.docker.com/engine/install/ubuntu/
        apt remove -y runc containerd docker.io docker-doc docker-compose podman-docker
        # 獲取公鑰（驗證套件哈希/真實性的）[START]
        # 等價於：mkdir -p /etc/apt/keyrings && chmod 0755 /etc/apt/keyrings
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        # 獲取公鑰（驗證套件哈希/真實性的）[END]
        # 動態構建資源倉庫
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
        apt update
        for ((variRetryIndex=1; variRetryIndex<variRetryNum; variRetryIndex++)); do
          if apt install -y containerd.io docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin; then
            systemctl enable docker
            systemctl restart docker
            variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
            break
          fi
          sleep $variSleep
        done
        ;;
      *)
        for ((variRetryIndex=1; variRetryIndex<variRetryNum; variRetryIndex++)); do
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
    if [ "${variCloudInstallResult[${variEachPackage}]}" = ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]} ]; then
      local variEachPackageInstalledLabel="apt install -y ${variEachPackage} ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}"
      echo "${variEachPackageInstalledLabel}" >> "${VARI_GLOBAL["VERSION_URI"]}"
    else
      variCloudInitSucceeded=0
    fi
  done
  [ ${variCloudInitSucceeded} -eq 1 ] && echo ${variAllPackageInstalledLabel} >> "${VARI_GLOBAL["VERSION_URI"]}"
  # --------------------------------------------------
  VARI_GLOBAL["CLOUD_INIT_REFRESH_TIMESTAMP"]=$(date +%s)
  return 0
}

function funcProtectedCloudInit_Macos() {
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
  if [ "${variBackupStatus:-0}" = "1" ]; then
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

# omni run command
function funcProtectedOmnircInit() {
  mkdir -p "${VARI_GLOBAL["OMNI_INIT_PATH"]}" \
           "${VARI_GLOBAL["OMNI_ENVI_PATH"]}" \
           "${VARI_GLOBAL["OMNI_BIN_PATH"]}" \
           "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}"
  cat > "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" <<EOF
#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 0000-00-00 00:00:00

# 更新係統搜尋目錄[START]
case ":\$PATH:" in
  *":${VARI_GLOBAL["OMNI_BIN_PATH"]}:"*) ;;
  *) export PATH="${VARI_GLOBAL["OMNI_BIN_PATH"]}:\$PATH" ;;
esac
# 更新係統搜尋目錄[END]
# 加載「額外配置」[START]
if [ -d "${VARI_GLOBAL["OMNI_ENVI_PATH"]}" ]; then
  # 使用獨立的文件描述符號（如：4~9）讀取數據，避免佔用「fd0/標準輸入（即：物理鍵盤）」，防止依賴終端檢測的腳本誤判（如：[ -t 0 ]）
  while IFS= read -u 9 -r variEachEnviUri; do
    if [ -f "\$variEachEnviUri" ]; then
      source "\$variEachEnviUri"
    fi
  done 9< <(find "${VARI_GLOBAL["OMNI_ENVI_PATH"]}" -maxdepth 1 -type f 2>/dev/null | sort)
  unset variEachEnviUri
fi
# 加載「額外配置」[END]
EOF
  if [ "${VARI_GLOBAL["BUILTIN_UNAME"]}" = "LINUX" ]; then
    cat >> "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" <<EOF
# [BASH]啟用命令補全機制[START]
if [ -n "\$BASH_VERSION" ]; then
  # 通配符號沒有匹配時會報錯[START]
  # for variEachCompletion in "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}"/*; do
  #   [ -f "\$variEachCompletion" ] && source "\$variEachCompletion"
  # done
  # 通配符號沒有匹配時會報錯[END]
  while IFS= read -r variEachCompletion; do
    source "\$variEachCompletion"
  done < <(find "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}" -maxdepth 1 -type f 2>/dev/null)
  unset variEachCompletion # 以免污染全局變量
fi
# [BASH]啟用命令補全機制[END]
EOF
  elif [ "${VARI_GLOBAL["BUILTIN_UNAME"]}" = "DARWIN" ]; then
    cat >> "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" <<EOF
# [ZSH]啟用命令補全機制[START]
if [ -n "\$ZSH_VERSION" ]; then
  # 檢查是否已經啟動了補全引擎，若無則啟動 (此判斷可加速終端啟動)
  if ! type compdef >/dev/null 2>&1; then
    autoload -Uz compinit && compinit -u
  fi
  # 通配符號沒有匹配時會報錯[START]
  # for variEachCompletion in "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}"/*; do
  #  [ -f "\$variEachCompletion" ] && source "\$variEachCompletion"
  # done
  # 通配符號沒有匹配時會報錯[END]
  while IFS= read -r variEachCompletion; do
    source "\$variEachCompletion"
  done < <(find "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}" -maxdepth 1 -type f 2>/dev/null)
  unset variEachCompletion # 以免污染全局變量
fi
# [ZSH]啟用命令補全機制[END]
EOF
  fi
  # 添加項目引導程序[START]
  [ ! -f "${VARI_GLOBAL["BUILTIN_SHELLRC_URI"]}" ] && touch "${VARI_GLOBAL["BUILTIN_SHELLRC_URI"]}"
  if ! grep -qF "${VARI_GLOBAL["OMNI_SH_BOOTSTRAP"]}" "${VARI_GLOBAL["BUILTIN_SHELLRC_URI"]}"; then
    echo "" >> "${VARI_GLOBAL["BUILTIN_SHELLRC_URI"]}"
    echo "${VARI_GLOBAL["OMNI_SH_BOOTSTRAP"]}" >> "${VARI_GLOBAL["BUILTIN_SHELLRC_URI"]}"
  fi
  # 添加項目引導程序[END]
  return 0
}

function funcProtectedCommandInit() {
  local variAbleUnitFileUriList=${1}
  # ----------
  # rm -rf "${VARI_GLOBAL["OMNI_BIN_PATH"]}/${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}."*
  find "${VARI_GLOBAL["OMNI_BIN_PATH"]}" -maxdepth 1 -type l -name "${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.*" -exec rm -f {} \; 2>/dev/null
  # ----------
  # for variAbleUnitFileUri in ${=variAbleUnitFileUriList}; do
  local variAbleUnitFileUri
  for variAbleUnitFileUri in $(echo "${variAbleUnitFileUriList}" | tr ' ' '\n'); do
    [ -z "$variAbleUnitFileUri" ] && continue
  # ----------
    local variEachUnitFilename=$(basename "${variAbleUnitFileUri}")
    local variEachUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    # 基於當前環境的命令[START]
    if grep -q 'VARI_GLOBAL\["BUILTIN_BASH_ENVI"\]="SOURCE"' "${variAbleUnitFileUri}"; then
      # [單一]精確清理[START]
      sed -e "/^alias ${variEachUnitCommand}=/d" \
          -e "/^function ${variEachUnitCommand}()/d" \
          -e "/^${variEachUnitCommand}()/d" \
          "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" > "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}.temp"
      /bin/mv "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}.temp" "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
      # [單一]精確清理[END]
      local variAddPattern="function ${variEachUnitCommand}() { source \"${variAbleUnitFileUri}\" \"\$@\"; }"
      echo "$variAddPattern" >> "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
    fi
    # 基於當前環境的命令[END]
    # 基於派生環境的命令（即：ln -sf ./omni/.../example.sh /usr/local/bin/omni.example）[START]
    # 檢索順序：alias > ln
    chmod +x "${variAbleUnitFileUri}"
    ln -sf "${variAbleUnitFileUri}" "${VARI_GLOBAL["OMNI_BIN_PATH"]}/${variEachUnitCommand}"
    # 基於派生環境的命令[END]
  done
  return 0
}

function funcProtectedOptionInit(){
  local variAbleUnitFileUriList=${1}
  # ----------
  local variDevNull=""
  local variEachIndex=""
  local variEachBashEnvi=""
  local variEachFuncName=""
  local variEachOptionList=""
  local variEachOptionName=""
  local variEachSortWeight=""
  local variAbleUnitFileUri=""
  local variEachUnitCommand=""
  local variOptionReportMap=""
  local variEachUnitFilename=""
  local variInheritOptionList=""
  local variFuncNameCollection=""
  local variEachInheritFuncName=""
  # ----------
  # rm -rf "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}/"{_,}"${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}."*
  find "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}" -maxdepth 1 -type f \
  \( -name "${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.*" -o -name "_${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.*" \) \
  -exec rm -f {} \; 2>/dev/null
  # ----------
  # inherit the public functions from builtin.sh[START]
  for variEachInheritFuncName in $(grep -oE 'function +funcPublic\w+' "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/internal/builtin/builtin.sh" | sed 's/^function *//'); do
    # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[START]
    variEachOptionName=$(echo "$variEachInheritFuncName" | sed 's/^funcPublic//')
    variEachOptionName=$(echo "$variEachOptionName" | awk '{print tolower(substr($0, 1, 1)) substr($0, 2)}')
    # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[END]
    variInheritOptionList="$variInheritOptionList $variEachOptionName"
  done
  # remove leading and trailing whitespace/移除首末空格
  # variInheritOptionList=$(echo ${variInheritOptionList} | sed 's/^[ \t]*//;s/[ \t]*$//')
  variInheritOptionList=$(echo "${variInheritOptionList}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  printf "%-5s %-15s -> %-70s\n" "[ COMMON ]" "--" "$variInheritOptionList" >> "${VARI_GLOBAL["VERSION_URI"]}"
  printf "%-5s %-15s -> %-70s\n" "[ COMMON ]" "--" "$variInheritOptionList" >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  # inherit the public functions from builtin.sh[END]
  # report1/3[START]
  declare -A variOptionReport
  # report1/3[END]
  # pull public function list/自動補全選項列表[START]
  # ----------
  for variAbleUnitFileUri in $(echo "${variAbleUnitFileUriList}" | tr ' ' '\n'); do
    [ -z "$variAbleUnitFileUri" ] && continue
  # ----------
    variEachUnitFilename=$(basename $variAbleUnitFileUri)
    variEachUnitCommand="${VARI_GLOBAL["BUILTIN_SYMBOL_LINK_PREFIX"]}.${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}"
    variFuncNameCollection=$(grep -oE 'function +funcPublic\w+' "$variAbleUnitFileUri" 2>/dev/null | sed 's/^function *//' || true)
    [ -z "$variFuncNameCollection" ] && continue
    variEachOptionList=""
    # ----------
    for variEachFuncName in $(echo "${variFuncNameCollection}" | tr ' ' '\n'); do
      [ -z "$variEachFuncName" ] && continue
    # ----------
      # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[START]
      variEachOptionName=$(echo "$variEachFuncName" | sed 's/^funcPublic//')
      variEachOptionName=$(echo "$variEachOptionName" | awk '{print tolower(substr($0, 1, 1)) substr($0, 2)}')
      # handle logic ：1remove「funcPublic」 ，2「first letter」upper >> lower[END]
      variEachOptionList="$variEachOptionList $variEachOptionName"
    done
    # remove leading and trailing whitespace/移除首末空格
    # variEachOptionList=$(echo "$variEachOptionList" | sed 's/^[ \t]*//;s/[ \t]*$//')
    variEachOptionList=$(echo "$variEachOptionList" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    variEachBashEnvi=""
    grep -q 'VARI_GLOBAL\["BUILTIN_BASH_ENVI"\]="SOURCE"' ${variAbleUnitFileUri} && variEachBashEnvi="SOURCE" || variEachBashEnvi="DETACH"
    if [ "${VARI_GLOBAL["BUILTIN_UNAME"]}" = "LINUX" ]; then
      funcProtectedCompletionInit_Linux "$variEachUnitCommand" "${variInheritOptionList} ${variEachOptionList}"
    elif [ "${VARI_GLOBAL["BUILTIN_UNAME"]}" = "DARWIN" ]; then
      funcProtectedCompletionInit_Darwin "$variEachUnitCommand" "${variInheritOptionList} ${variEachOptionList}"
    fi
    # report2/3 && 分配權重（規則：越小越前）[START]
    variEachSortWeight="99"
    if [ "${variEachBashEnvi}" = "SOURCE" ]; then
      if [ "${variEachUnitFilename%.${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}}" = 'system' ]; then
        variEachSortWeight="10"
      else
        variEachSortWeight="11"
      fi
    else
      variEachSortWeight="20"
    fi
    variEachIndex="${variEachSortWeight}_${variEachBashEnvi}_${variEachUnitCommand}"
    variOptionReport[${variEachIndex}]="${variEachOptionList}"
    # report2/3 && 分配權重（規則：越小越前）[END]
  done
  if [ "${VARI_GLOBAL["BUILTIN_UNAME"]}" = "LINUX" ]; then
    # 「source /usr/share/bash-completion/bash_completion」成功返回：exit 1
    source /usr/share/bash-completion/bash_completion 2>/dev/null || true
  fi
  # pull public function list/自動補全選項列表[END]
  # report3/3 && 執行排序（command sort：0-9a-zA-Z）[START]
  # array_keys()[START]
  variOptionReportMap=""
  if [ -n "$ZSH_VERSION" ]; then
    eval 'variOptionReportMap="${(@k)variOptionReport[@]}"'
  else
    eval 'variOptionReportMap="${!variOptionReport[@]}"'
  fi
  # array_keys()[END]
  for variEachIndex in $(echo "${variOptionReportMap}" | tr ' ' '\n' | sort); do
    # 欄位對應 ：1/排序權重(丟棄) 2/執行環境 3/命令名稱
    IFS='_' read -r variDevNull variEachBashEnvi variEachUnitCommand <<< "${variEachIndex}"
    # option sort：0-9a-zA-Z
    variEachOptionList=$(echo "${variOptionReport[$variEachIndex]}" | tr ' ' '\n' | sort | xargs)
    printf "%-5s %-15s -> %-70s\n" "[ ${variEachBashEnvi} ]" "$variEachUnitCommand" "$variEachOptionList" >> "${VARI_GLOBAL["VERSION_URI"]}"
    printf "%-5s %-15s -> %-70s\n" "[ ${variEachBashEnvi} ]" "$variEachUnitCommand" "$variEachOptionList" >> "${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}"
  done
  # report3/3 && 執行排序（command sort：0-9a-zA-Z）[END]
  return 0
}

function funcProtectedCompletionInit_Linux(){
  local variCommand=$1
  local variOptionList=$2
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
complete -F _'${variCommand}'_complete '${variCommand} > "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}/${variCommand}"
  # chmod +x "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}/${variCommand}"
  return 0
}

function funcProtectedCompletionInit_Darwin(){
  local variCommand=$1
  local variOptionList=$2
  local variCompletionUri="${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}/_${variCommand}"
  cat > "${variCompletionUri}" <<EOF
#compdef ${variCommand}
# 「#compdef ${variCommand}」表示「zsh.compinit」的魔法標籤，並非注釋
_${variCommand//./_}_complete() {
  local -a options
  options=(${variOptionList})
  if (( CURRENT == 2 )); then
    compadd -- \${options[@]}
  fi
}
compdef _${variCommand//./_}_complete ${variCommand}
EOF
  return 0
}

function funcProtectedCompletionRefresh(){
  if [ -n "$BASH_VERSION" ]; then
    local variEachCompletionUri
    # unset[START]
    for variEachCompletionUri in "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}"/*; do
      [ -f "$variEachCompletionUri" ] || continue
      [[ "$variEachCommand" == _* ]] && continue
      local variEachCommand=$(basename "$variEachCompletionUri")
      complete -r "$variEachCommand" 2>/dev/null || true
      local variEachFuncName="_${variEachCommand}_complete"
      unset -f "$variEachFuncName" 2>/dev/null || true
    done
    # unset[END]
    # reload[START]
    for variEachCompletionUri in "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}"/*; do
      [ -f "$variEachCompletionUri" ] && source "$variEachCompletionUri"
    done
    # reload[END]
  elif [ -n "$ZSH_VERSION" ]; then
    # unset[START]
    # ----------
    # for variEachCompletionUri in "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}"/_*; do
    while IFS= read -r variEachCompletionUri; do
    # ----------
      local variEachCompletionFilename=$(basename "$variEachCompletionUri")
      variEachCompletionFilename="${variEachCompletionFilename#_}"
      local variEachFuncName="_${variEachCompletionFilename//./_}_complete"
      unfunction "$variEachFuncName" 2>/dev/null || true
    done < <(find "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}" -maxdepth 1 -type f -name '_*' 2>/dev/null)
    # unset[END]
    # reload[START]
    # ----------
    # for variEachCompletionUri in "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}"/_*; do
    while IFS= read -r variEachCompletionUri; do
    # ----------
      [ -f "$variEachCompletionUri" ] && source "$variEachCompletionUri"
    done < <(find "${VARI_GLOBAL["OMNI_COMPLETION_PATH"]}" -maxdepth 1 -type f -name '_*' 2>/dev/null)
    # reload[END]
  fi
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicInit(){
  local variParameterDescList=("init model，value：0/cache（default），1/refresh")
  funcProtectedCheckOptionParameter 1 'variParameterDescList[@]'
  local variInitModel=${1:-0}
  if [ -z "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}" ] || [ "${variInitModel}" -eq 1 ]; then
    # install -m 755 <(echo '#!/usr/bin/env bash') ${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]} # 兼容不好
    echo '#!/usr/bin/env bash' > "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
    chmod 755 "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
    echo '' > ${VARI_GLOBAL["VERSION_URI"]}
    # 檢查間隔（要求：大於3秒）[START]
    # 避免首次「omni.system init 1」時，觸發兩次「funcProtectedCloudInit」
    if (( $(date +%s) - ${VARI_GLOBAL["CLOUD_INIT_REFRESH_TIMESTAMP"]} > 3 )); then
      funcProtectedCloudInit
    fi
    # 檢查間隔（要求：大於3秒）[END]
  fi
  # pull *.sh list[START]
  local variFindCommand="find \"${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}\""
  local variEachIgnoreDirectory
  for variEachIgnoreDirectory in $(echo "${VARI_GLOBAL["IGNORE_FIRST_LEVEL_DIRECTORY_LIST"]}" | tr ' ' '\n'); do
      [ -z "$variEachIgnoreDirectory" ] && continue
      variFindCommand="$variFindCommand -type d -path \"${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}/$variEachIgnoreDirectory\" -prune -o"
  done
  for variEachIgnoreDirectory in $(echo "${VARI_GLOBAL["IGNORE_SECOND_LEVEL_DIRECTORY_LIST"]}" | tr ' ' '\n'); do
      [ -z "$variEachIgnoreDirectory" ] && continue
      variFindCommand="$variFindCommand -type d -regex \".*/$variEachIgnoreDirectory\" -prune -o"
  done
  variFindCommand="$variFindCommand -type f -name \"*${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}\" -print"
  local variLikeUnitFileUriList=$(eval "$variFindCommand" | sort -u)
  # 僅保留「父目錄名 == 文件名稱（不含後綴）」的[START]
  local variMatchedUnitFileUriList=""
  local variEachLikeUnitFileUri
  for variEachLikeUnitFileUri in $(echo "${variLikeUnitFileUriList}" | tr ' ' '\n'); do
    [ -z "$variEachLikeUnitFileUri" ] && continue
    local variEachFilename=$(basename "${variEachLikeUnitFileUri}" ".${VARI_GLOBAL["BUILTIN_UNIT_FILE_SUFFIX"]}")
    local variEachParentDirectory=$(basename "$(dirname "${variEachLikeUnitFileUri}")")
    if [ "${variEachFilename}" = "${variEachParentDirectory}" ]; then
      variMatchedUnitFileUriList="${variMatchedUnitFileUriList} ${variEachLikeUnitFileUri}"
    fi
  done
  local variAbleUnitFileUriList=$(echo "${variMatchedUnitFileUriList}" | tr ' ' '\n' | sed '/^$/d')
  # 僅保留「父目錄名 == 文件名稱（不含後綴）」的[END]
  # pull *.sh list[END]
  # ----------
  local variBuiltinSourceUriMd5Before=""
  [ -f "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" ] && variBuiltinSourceUriMd5Before=$(openssl md5 "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" | awk '{print $NF}')
  # ----------
  # 係統兼容[START]
  if [ "${VARI_GLOBAL["BUILTIN_UNAME"]}" = "LINUX" ]; then
    # 設置「字符編碼」
    localectl set-locale LANG=en_US.UTF-8 2>/dev/null || true
  fi
  funcProtectedOmnircInit
  funcProtectedCommandInit "${variAbleUnitFileUriList}"
  funcProtectedOptionInit "${variAbleUnitFileUriList}"
  funcProtectedCompletionRefresh
  if [ "${VARI_GLOBAL["BUILTIN_OS_DISTRO"]}" = "UBUNTU" ]; then
    # 升級用戶執行權限
    # 過渡：清理舊數據[START]
    # TODO：待移除
    local variCommand='[ "$(id -u)" -ne 0 ] && [ -z "$SUDO_USER" ] && { [ -n "$SSH_CONNECTION" ] || [ -n "$TTY" ]; } && sudo -i'
    grep -qF -- "$variCommand" /home/ubuntu/.bashrc || echo "$variCommand" >> /home/ubuntu/.bashrc
    # 過渡：清理舊數據[END]
    # 「sudo -i」表示完全乾淨的「root/環境」
    # 「sudo -s -E」表示繼承當前環境變量的「root/環境」
    local variCommand='[ "$(id -u)" -ne 0 ] && [ -z "$SUDO_USER" ] && { [ -n "$SSH_CONNECTION" ] || [ -n "$TTY" ]; } && sudo -s -E'
    grep -qF -- "$variCommand" /home/ubuntu/.bashrc || echo "$variCommand" >> /home/ubuntu/.bashrc
    # grep -qF -- "$variCommand" "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" || echo "$variCommand" >> "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
  fi
  # 係統兼容[END]
  # ----------
  local variBuiltinSourceUriMd5After=""
  [ -f "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" ] && variBuiltinSourceUriMd5After=$(openssl md5 "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" | awk '{print $NF}')
  if [ "${variBuiltinSourceUriMd5After}" != "${variBuiltinSourceUriMd5Before}" ]; then
    echo "source ${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}" >> "${VARI_GLOBAL["BUILTIN_UNIT_TODO_URI"]}"
  fi
  # ----------
  source "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
  return 0
}

function funcPublicVersion() {
    echo "--------------------------------------------------"
    echo "[ https://github.com/chunio/omni.git ] version 1.0.0"
    echo "--------------------------------------------------"
    echo "cat ${VARI_GLOBAL["BUILTIN_SHELLRC_URI"]}"
    cat "${VARI_GLOBAL["BUILTIN_SHELLRC_URI"]}"
    echo "--------------------------------------------------"
    echo "cat ${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
    cat "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
    # ----------
    if [ -d "${VARI_GLOBAL["OMNI_ENVI_PATH"]}" ]; then
      while IFS= read -r variEachEnviUri; do
        if [ -f "${variEachEnviUri}" ]; then
          echo "--------------------------------------------------"
          echo "cat ${variEachEnviUri}"
          cat "${variEachEnviUri}"
          echo "--------------------------------------------------"
        fi
      done < <(find "${VARI_GLOBAL["OMNI_ENVI_PATH"]}" -maxdepth 1 -type f 2>/dev/null | sort)
      unset variEachEnviUri
    fi
    # ----------
    return 0
}

#「ohmyzsh」沒有分支/標籤的概念，鼓勵用戶使用最新（支持：使用「commit id」鎖定版本）
function funcPublicZshReinit() {
  local variParameterDescList=("status : 0/disable, 1/able（default）")
  funcProtectedCheckOptionParameter 1 'variParameterDescList[@]'
  case ${VARI_GLOBAL["BUILTIN_OS_DISTRO"]} in
      "CENTOS"|"RHEL"|"REDHAT")
        omni.centos zshReinit $1
        ;;
      "UBUNTU"|"DEBIAN")
        omni.ubuntu zshReinit $1
      ;;
      "MACOS")
          # 係統自帶
          ;;
      *)
          return 1
          ;;
  esac
  return 0
}


function funcPublicZshExtensionReinit() {
  # ----------
  if [ "${VARI_GLOBAL["BUILTIN_SHELL_TYPE"]}" != "ZSH" ]; then
    funcProtectedTrace "zsh extension(s) skipped : only compatible with zsh"
    return 1
  fi
  # ----------
  local variParameterDescList=("status: 0/disable, 1/able（default）")
  funcProtectedCheckOptionParameter 1 'variParameterDescList[@]'
  local variStatus=${1:-1}
  local variEnviUri="${VARI_GLOBAL["OMNI_ENVI_PATH"]}/zsh.extension.sh"
  local variExtensionPath="${VARI_GLOBAL["OMNI_ENVI_PATH"]}/extension"
  mkdir -p "${variExtensionPath}"
  # reset[START]
  rm -f "${variEnviUri}"
  # reset[END]
  if [ "${variStatus}" = "0" ]; then
    rm -rf "${variExtensionPath}/zsh-autosuggestions"
    rm -rf "${variExtensionPath}/zsh-syntax-highlighting"
    rm -rf "${variExtensionPath}/zsh-history-substring-search"
    exec $(echo "${VARI_GLOBAL["BUILTIN_SHELL_TYPE"]}" | tr '[:upper:]' '[:lower:]')
    return 0
  elif [ "${variStatus}" = "1" ]; then
    local variExtensionRepoSlice=(
      "zsh-users/zsh-autosuggestions" # 命令建議
      "zsh-users/zsh-syntax-highlighting" # 語法高亮
      "zsh-users/zsh-history-substring-search" # 歷史搜索
    )
    local variCommandMulti=""
    for variEachExtensionRepo in "${variExtensionRepoSlice[@]}"; do
      local variEachExtensionName=$(basename "${variEachExtensionRepo}")
      local variEachExtensionUri="${variExtensionPath}/${variEachExtensionName}"
      if [ ! -d "${variEachExtensionUri}" ]; then
        echo "[ command ] git clone --depth 1 https://github.com/${variEachExtensionRepo}.git ${variEachExtensionUri}"
        git clone --depth 1 "https://github.com/${variEachExtensionRepo}.git" "${variEachExtensionUri}" # >/dev/null 2>&1 || continue
      fi
      variCommandMulti+="source \"${variEachExtensionUri}/${variEachExtensionName}.zsh\""$'\n'
    done
    cat >> "${variEnviUri}" <<EOF
#!/usr/bin/env bash
${variCommandMulti}
if [[ -f "${variExtensionPath}/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
  zle -N history-substring-search-up
  zle -N history-substring-search-down
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey "^[OA" history-substring-search-up
  bindkey "^[OB" history-substring-search-down
fi
EOF
  source "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
  return 0
  fi
}

function funcPublicBashExtensionReinit() {
  # ----------
  if [ "${VARI_GLOBAL["BUILTIN_SHELL_TYPE"]}" != "BASH" ]; then
    funcProtectedTrace "bash extension(s) skipped : only compatible with bash"
    return 1
  fi
  # ----------
  local variParameterDescList=("status: 0/disable, 1/able（default）")
  funcProtectedCheckOptionParameter 1 'variParameterDescList[@]'
  local variStatus=${1:-1}
  local variEnviUri="${VARI_GLOBAL["OMNI_ENVI_PATH"]}/zzzzbash.extension.sh" # 「zzzz」前綴確保最後加載，以保證語法高亮
  local variExtensionPath="${VARI_GLOBAL["OMNI_ENVI_PATH"]}/extension"
  # reset[START]
  rm -f "${variEnviUri}"
  # reset[END]
  if [ "${variStatus}" = "0" ];then
    rm -rf "${variExtensionPath}/ble.sh"
    rm -rf "${variExtensionPath}/ble.sh-install"
    exec $(echo "${VARI_GLOBAL["BUILTIN_SHELL_TYPE"]}" | tr '[:upper:]' '[:lower:]')
    return 0
  elif [ "${variStatus}" = "1" ]; then
    mkdir -p "${variExtensionPath}"
    local variExtensionRepoSlice=(
      # ----------
      # 含：命令建議/語法高亮/歷史搜索
      # 高度依賴I/O攔截，因此僅適用於交互式的終端
      "akinomyoga/ble.sh"
      # ----------
    )
    local variCommandMulti=""
    for variEachExtensionRepo in "${variExtensionRepoSlice[@]}"; do
      local variEachExtensionName=$(basename "${variEachExtensionRepo}")
      local variEachExtensionUri="${variExtensionPath}/${variEachExtensionName}"
      if [ ! -d "${variEachExtensionUri}" ]; then
        echo "[ command ] git clone --recursive --depth 1 --shallow-submodules https://github.com/${variEachExtensionRepo}.git ${variEachExtensionUri}"
        git clone --recursive --depth 1 --shallow-submodules "https://github.com/${variEachExtensionRepo}.git" "${variEachExtensionUri}"
      fi
      case "${variEachExtensionRepo}" in
        "akinomyoga/ble.sh")
          local variInstallPath="${variExtensionPath}/${variEachExtensionName}-install"
          if [ ! -f "${variInstallPath}/share/blesh/ble.sh" ]; then
            echo "[ command ] make -C ${variEachExtensionUri} install PREFIX=${variInstallPath}"
            make -C "${variEachExtensionUri}" install PREFIX="${variInstallPath}"
          fi
          variCommandMulti+="if [[ \$- == *i* ]] && [[ -t 0 ]] && [[ -t 1 ]] && [[ -z \"\${BLE_VERSION-}\" ]] && [[ -f \"${variInstallPath}/share/blesh/ble.sh\" ]]; then"$'\n'
          variCommandMulti+="  source \"${variInstallPath}/share/blesh/ble.sh\""$'\n'
          variCommandMulti+="  bleopt complete_auto_complete=1"$'\n'
          variCommandMulti+="  ble-bind -f up history-search-backward"$'\n'
          variCommandMulti+="  ble-bind -f down history-search-forward"$'\n'
          variCommandMulti+="  ble-bind -k 'UP' history-search-backward"$'\n'
          variCommandMulti+="  ble-bind -k 'DOWN' history-search-forward"$'\n'
          variCommandMulti+="fi"$'\n'
          # funcProtectedTodo "同一終端重複加載「${variEachExtensionRepo}」時會造成崩潰，建議 ：新建終端"
          ;;
      esac
    done
    cat > "${variEnviUri}" <<EOF
#!/usr/bin/env bash
${variCommandMulti}
EOF
  source "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
  funcProtectedTrace "--------------------------------------------------"
  funcProtectedTrace "akinomyoga/ble.sh version :"
  funcProtectedTrace "${BLE_VERSION}"
  funcProtectedTrace "--------------------------------------------------"
  return 0
  fi
}

function funcPublicStarshipReinit(){
  local variParameterDescList=("action : 0/disable, 1/able（default）")
  funcProtectedCheckOptionParameter 1 'variParameterDescList[@]'
  local variStarshipMainStatus=${1:-1}
  local variEnviUri="${VARI_GLOBAL["OMNI_ENVI_PATH"]}/starship.main.sh"
  local variBinUri="${VARI_GLOBAL["OMNI_BIN_PATH"]}/starship"
  local variBuiltinShellTypeLower=$(echo "${VARI_GLOBAL["BUILTIN_SHELL_TYPE"]}" | tr '[:upper:]' '[:lower:]')
  # reset[START]
  if [ "${variStarshipMainStatus}" = "0" ]; then
    rm -f "${variEnviUri}"
    rm -f "${variBinUri}"
    rm -f ~/.config/starship.toml
    exec ${variBuiltinShellTypeLower}
    return 0
  fi
  # reset[END]
  # install[START]
  if [ "${variStarshipMainStatus}" = "1" ]; then
    if ! command -v starship >/dev/null 2>&1 && [ ! -x "${variBinUri}" ]; then
      if command -v curl >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "${VARI_GLOBAL["OMNI_BIN_PATH"]}"
      elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://starship.rs/install.sh | sh -s -- -y -b "${VARI_GLOBAL["OMNI_BIN_PATH"]}"
      else
        funcProtectedTrace "curl/wget not found, cannot install starship"
      fi
    fi
    cat >> "${variEnviUri}" <<EOF
#!/usr/bin/env bash
if command -v starship >/dev/null 2>&1; then
  eval "\$(starship init ${variBuiltinShellTypeLower})"
elif [ -x "${variBinUri}" ]; then
  eval "\$("${variBinUri}" init ${variBuiltinShellTypeLower})"
fi
EOF
  fi
  # install[END]
  source "${VARI_GLOBAL["BUILTIN_OMNIRC_URI"]}"
  # theme[START]
  mkdir -p ~/.config
  if [ -f "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/starship.toml" ];then
    /bin/cp -f "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/starship.toml" ~/.config/starship.toml
  elif [ -f "${variBinUri}" ];then
    starship preset catppuccin-powerline -o ~/.config/starship.toml
  fi
  # theme[END]
  return 0
}

function funcPublicNewUnit(){
  local variParameterDescList=("unit name")
  funcProtectedCheckRequiredParameter 1 'variParameterDescList[@]' $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variUnitName=${1}
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
  funcProtectedCheckRequiredParameter 2 'variParameterDescList[@]' $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variUnitName=${1}
  local variSaveToThePath=${2}
  local variArchiveCommand=omni.${variUnitName}
  # [ ${variSaveToThePath} == "/" ] && variSaveToThePath=""
  local variArchivePath=${variSaveToThePath}/${variArchiveCommand}
  rm -rf ${variArchivePath} ${variSaveToThePath}/${variArchiveCommand}.tgz
  mkdir -p ${variArchivePath}/module
  /usr/bin/cp -rf "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}"/{common,internal,init} ${variArchivePath}
  /usr/bin/cp -rf "${VARI_GLOBAL["BUILTIN_OMNI_ROOT_PATH"]}"/module/${variUnitName} ${variArchivePath}/module
  # flush the useless data[START]
  find ${variArchivePath} -type f -name "encrypt.envi" -exec truncate -s 0 {} \;
  local variRuntimePathList=$(find ${variArchivePath} -type d -name "runtime")
  local variEachRuntimePath
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
      "CENTOS"|"RHEL"|"REDHAT")
          omni.centos proxy $1 $2
          ;;
      "UBUNTU"|"DEBIAN")
          omni.ubuntu proxy $1 $2
          ;;
      "MACOS")
          omni.macos proxy $1 $2
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
  funcProtectedCheckRequiredParameter 1 'variParameterDescList[@]' $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
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
  if [ "${variExpectAction}" = "kill" ];then
    variInput="kill"
  else
    read -p "do you want to kill the ${variProcessCount} process(es) listening on port '${variPort}' ? ( type 'kill' to confirm ) : " variInput
  fi
  if [[ "$variInput" = "kill" ]]; then
    local variEachProcessId
    for variEachProcessId in $(echo "${variProcessIdList}" | tr ' ' '\n'); do
        [ -z "$variEachProcessId" ] && continue
        local variEachCommand=$(ps -p ${variEachProcessId} -f -o cmd --no-headers)
        /usr/bin/kill -9 $variEachProcessId
        funcProtectedEchoGreen "kill -9 $variEachProcessId success ( command : ${variEachCommand} ) "
    done
    funcProtectedEchoGreen "${variProcessCount} process(es) with port '${variPort}' has(have) been terminated"
  fi
  return 0
}

function funcPublicProcess() {
    local variParameterDescList=("keyword")
    funcProtectedCheckRequiredParameter 1 'variParameterDescList[@]' $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
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
    if [ "${variExpectAction}" = "kill" ]; then
        variInput="kill"
    else
        read -p "do you want to kill the ${variProcessCount} process(es) matching the keyword '${variKeyword}' ? ( type 'kill' to confirm ) : " variInput
    fi
    if [[ "$variInput" = "kill" ]]; then
      local variEachProcessId
        for variEachProcessId in $(echo "${variProcessIdList}" | tr ' ' '\n'); do
            [ -z "$variEachProcessId" ] && continue
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
  funcProtectedCheckRequiredParameter 4 'variParameterDescList[@]' $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
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

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"