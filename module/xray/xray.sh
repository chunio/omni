#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 0000/00/00 00:00:00

:<<'MARK'
入站方案（即：用戶終端連接至境外VPS）：
1，[xray]VLESS（代理層/一種不帶加密傳輸協議） + TCP/RAW（傳輸層） + reality（安全層/一種安全僞裝技術（即：僞裝瀏覽真實大站（本質：借用其TLS指紋），要求直連禁止CDN））
2，[v2ray]VMESS（代理層/一種自帶加密傳輸協議（注意：嚴格要求{客戶端 && 服務端}時間同步）） + websocket（傳輸層/雙向通信） + TLS（安全層/僞裝瀏覽常規網頁，並且由NGINX承載/終結TLS（即：加密/解密SSL）） + CDN（用於隱藏VPS真實IP，如：cloudflare）
[2026/10/20]總結：自2023年起，「裸露IP的方案1」相對「隱藏IP的方案2」抗封（原因：[GFW/防火長城]打擊策略已從「檢測連接哪個IP」升級至「DPI/分析用戶流量特徵」，因此「reality/規避檢測」優於「CDN/隱藏IP」，前提：VPS真實IP不被[針對性的]精確打擊）
出站方案（即：境外VPS連接至目標內容）：
1，[cloudflare]warp
2，residential ip
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
VARI_GLOBAL["BUILTIN_BASH_ENVI"]="DETACH"
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
function funcPublicXrayReinit() {
    # ----------
    local variServiceName="xray"
    local variConfigJsonUri="/usr/local/etc/xray/config.json"
    local customIp=$(curl -s -4 https://api.ipify.org || curl -s -4 https://ifconfig.me)
    # ----------
    # 僞裝目標[START]
    local variTarget=${1:-"www.apple.com:443"}
    local variServerName=${2:-"www.apple.com"}
    # 僞裝目標[END]
    # install xray-core[START]
    if ! command -v xray &> /dev/null; then
      apt update
      apt install -y unzip
      bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    fi
    # install xray-core[END]
    # ----------
    local variXrayX25519Output=$(xray x25519)
    local variPrivateKey=$(echo "$variXrayX25519Output" | head -n 1 | awk '{print $NF}')
    local variPublicKey=$(echo "$variXrayX25519Output" | tail -n 1 | awk '{print $NF}')
    # ----------
    local variClientId=$(xray uuid)
    local variShortId=$(openssl rand -hex 8)
    # ----------
    if [[ -z "$variPrivateKey" || -z "$variPublicKey" || -z "$variClientId" || -z "$variShortId" ]]; then
        echo "error : {variPrivateKey || variPublicKey || variClientId || variShortId} is(are) empty"
        return 1
    fi
    mkdir -p $(dirname ${variConfigJsonUri})
    cat > ${variConfigJsonUri} <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${variClientId}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "raw",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "target": "${variTarget}",
          "xver": 0,
          "serverNames": [
            "${variServerName}"
          ],
          "privateKey": "${variPrivateKey}",
          "shortIds": [
            "${variShortId}"
          ],
          "minClientVer": "1.0.0"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    }
  ]
}
EOF
    if xray run -test -config ${variConfigJsonUri}; then
        systemctl restart ${variServiceName}
        systemctl enable ${variServiceName}
        echo "--------------------------------------------------"
        echo "Address（IP地址）: xxxx"
        echo "Port（端口）: 443"
        echo "Uuid : ${variClientId}"
        echo "Flow（流控插件）: xtls-rprx-vision"
        echo "Network (傳輸層) : tcp (raw)"
        echo "Security (安全層) : reality"
        echo "SNI: ${variServerName}"
        echo "Fingerprint（作用：指定使用目標瀏覽器的TLS指紋發起連接）: chrome"
        echo "PrivateKey : ${variPrivateKey}"
        echo "PublicKey (pbk) : ${variPublicKey}"
        echo "ShortId (sid) : ${variShortId}"
        echo "--------------------------------------------------"
        local variVlessLink="vless://${variClientId}@${customIp}:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${variServerName}&fp=chrome&pbk=${variPublicKey}&sid=${variShortId}&type=tcp#xray-${variShortId}"
        echo "${variVlessLink}"
        local variYamlUri="/tmp/xray-${variShortId}.yaml"
        cat > ${variYamlUri} <<EOF
port: 7890
socks-port: 7891
allow-lan: true
bind-address: 0.0.0.0
mode: rule
log-level: info
external-controller: 127.0.0.1:9090

proxies:
  - name: xray-${variShortId}
    type: vless
    server: ${customIp}
    port: 443
    uuid: ${variClientId}
    network: tcp
    tls: true
    udp: true
    flow: xtls-rprx-vision
    servername: ${variServerName}
    client-fingerprint: chrome
    reality-opts:
      public-key: ${variPublicKey}
      short-id: ${variShortId}
    packet-encoding: xudp

proxy-groups:
  - name: --
    type: select
    proxies:
      - DIRECT
      - xray-${variShortId}

rules:
  - DOMAIN-SUFFIX,local,DIRECT
  - DOMAIN-SUFFIX,jd.com,DIRECT
  - DOMAIN-SUFFIX,baidu.com,DIRECT
  - DOMAIN-SUFFIX,bejson.com,DIRECT
  - DOMAIN-SUFFIX,feishu.cn,DIRECT
  - DOMAIN-SUFFIX,taobao.com,DIRECT
  - DOMAIN-SUFFIX,chaoxing.com,DIRECT
  - DOMAIN-SUFFIX,tencentcloud.com,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,100.64.0.0/10,DIRECT
  - IP-CIDR,127.0.0.0/8,DIRECT
  - IP-CIDR,172.16.0.0/12,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  - IP-CIDR6,::1/128,DIRECT
  - IP-CIDR6,fc00::/7,DIRECT
  - IP-CIDR6,fe80::/10,DIRECT
  - IP-CIDR6,fd00::/8,DIRECT
  - MATCH,--
EOF
    echo "--------------------------------------------------"
    cat /tmp/xray-${variShortId}.yaml
    echo "--------------------------------------------------"
    else
        echo "error : xray run -test -config ${variConfigJsonUri}"
        return 1
    fi
    return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"