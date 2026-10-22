#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 0000/00/00 00:00:00

:<<'MARK'
# ##################################################
入站方案（即：用戶終端連接至境外VPS）：
1，[xray]VLESS（代理層/一種不帶加密傳輸協議） + TCP/RAW（傳輸層） + reality（安全層/一種安全僞裝技術（即：僞裝瀏覽真實大站（本質：借用其TLS指紋），要求直連禁止CDN））
2，[v2ray]VMESS（代理層/一種自帶加密傳輸協議（注意：嚴格要求{客戶端 && 服務端}時間同步）） + websocket（傳輸層/雙向通信） + TLS（安全層/僞裝瀏覽常規網頁，並且由NGINX承載/終結TLS（即：加密/解密SSL）） + CDN（用於隱藏VPS真實IP，如：cloudflare）
[2026/10/20]總結：自2023年起，「裸露IP的方案1」相對「隱藏IP的方案2」抗封（原因：[GFW/防火長城]打擊策略已從「檢測連接哪個IP」升級至「DPI/分析用戶流量特徵」，因此「reality/規避檢測」優於「CDN/隱藏IP」，前提：VPS真實IP不被[針對性的]精確打擊）
# ##################################################
出站方案（即：境外VPS連接至目標內容）：
1，[fscarmen/warp]cloudflare
2，residential ip
# ##################################################
1，https://www.youtube.com/watch?v=RNS2yiVvRVE //「fscarmen/warp」功能介紹（含：1可解鎖「chatgpt」等地區限制問題，原因：「cloudflare」自有「ASN」相對普通機房信任度高）
2，https://gitlab.com/fscarmen/warp //將「VPS」接入至「cloudflare」的局域網，再由其提供代理流量出口/入口）
3，直接於「VPS」服務器執行（已驗證：已安裝v2ray的基礎上）：wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh [option] [lisence/url/token]
# ----------
wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
安裝引導
-> 2. 簡體中文
-> 1. 爲「ipv4 only」添加「warp ipv4」網絡接口 (bash menu.sh 4) # 優於：爲「ipv4 only」添加warp雙棧網絡接口 (bash menu.sh d)
-> 1. wireguard内核 (默認)
-> 1. 全局 (默認)
-> 1. 使用免費賬戶 (默認)
-> 3. 使用vps初始設置 (默認)
# ----------
查看配置: cat /etc/wireguard/warp.conf
檢查端口：nc -u engage.cloudflareclient.com 2408
卸載套件（不影響：v2ray）：warp u
管理服務（不影響：v2ray）：systemctl {stop/status/restart} wg-quick@warp.service
# ----------
故障日志：
2025/08/15
問題描述：
1，vpn忽然失效（此時：v2ray正常運行）
2，本地可以ssh至搬瓦工服務器，但搬瓦工服務器內部無法訪問互聯網
3，[warp服務]後台獲取「warp ip」中,最大嘗試5次.../最後失敗
操作記錄：
1，systemctl stop wg-quick@warp.service可以恢復vpn服務
2，開通warp+賬戶，沒有作用（「免費賬戶」與「warp+/付費賬戶」區別：付費賬戶僅在訪問cloudflare網站時會觸發類似argo的加速技術，但在訪問非cloudflare網站時沒有任何差異）
最終解決：
warp u && wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
2026/10/19
問題描述：
1，「gemini」提示處於禁用地區
2，皆是請求「https://www.google.com」，[情況1]使用「warp/cloudflare」作爲出口時{chrome && firefox}皆會自動重定向至「https://www.google.com.hk」，[情況2]使用「vps真實ip」作爲出口則正常
操作記錄：
1，warp u && wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh >> 報錯：bash版本過舊不兼容腳本的「local -n」等命令
最終解決：
1，重裝VPS，採用「xray/vless + tcp/raw + reality + warp/wireproxy」方案
2，[ios/client]從「shadowrocket」調整至「hiddify/開源」
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
VARI_GLOBAL["XRAY_HOME"]="/usr/local/etc/xray"
VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]="/usr/local/etc/xray/config.json"
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicRealityReinit() {
    # ----------
    local variCurrentVpsIp=$(curl -s -4 https://api.ipify.org || curl -s -4 https://ifconfig.me)
    # ----------
    # 僞裝目標[START]
    local variTarget=${1:-"www.bing.com:443"}
    local variServerName=${2:-"www.bing.com"}
    # 僞裝目標[END]
    # install xray-core[START]
    if ! command -v xray &> /dev/null; then
        apt update
        apt install -y unzip
        bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version 26.6.27
    fi
    # install xray-core[END]
    # ----------
    local variXrayX25519Output=$(xray x25519)
    local variPrivateKey=$(printf '%s\n' "$variXrayX25519Output" | awk '/^[[:space:]]*(PrivateKey|Private key):/ {print $NF; exit}')
    local variPublicKey=$(printf '%s\n' "$variXrayX25519Output" | awk '/^[[:space:]]*(Password|PublicKey|Public key)[^:]*:/ {print $NF; exit}')
    # ----------
    local variClientId=$(xray uuid)
    local variShortId=$(openssl rand -hex 8)
    # ----------
    if [[ -z "$variPrivateKey" || -z "$variPublicKey" || -z "$variClientId" || -z "$variShortId" ]]; then
        echo "error : {variPrivateKey || variPublicKey || variClientId || variShortId} is(are) empty"
        return 1
    fi
    mkdir -p $(dirname ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]})
    cat > ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]} <<EOF
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
    if xray run -test -config ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]}; then
        systemctl restart xray
        systemctl enable xray
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
        local variYamlFilename="vless-raw-reality-${variShortId}"
        local variVlessLink="vless://${variClientId}@${variCurrentVpsIp}:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${variServerName}&fp=chrome&pbk=${variPublicKey}&sid=${variShortId}&type=tcp#${variYamlFilename}"
        echo "${variVlessLink}"
        local variYamlUri="${VARI_GLOBAL["XRAY_HOME"]}/${variYamlFilename}.yaml"
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
    server: ${variCurrentVpsIp}
    port: 443
    uuid: ${variClientId}
    network: tcp
    flow: xtls-rprx-vision
    tls: true
    udp: true
    servername: ${variServerName}
    client-fingerprint: chrome
    reality-opts:
      public-key: ${variPublicKey}
      short-id: "${variShortId}"
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
        cat ${VARI_GLOBAL["XRAY_HOME"]}/${variYamlFilename}.yaml
        echo "--------------------------------------------------"
    else
        echo "error : xray run -test -config ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]}"
        return 1
    fi
    return 0
}

# --------------------------------------------------
# language:
# 01.english (default)
# 02.簡體中文
# --------------------------------------------------
# 01.add warp ipv4 interface to ipv4 only vps (bash menu.sh 4)
# 02.add warp ipv6 interface to ipv4 only vps (bash menu.sh 6)
# 03.add warp dualstack interface to ipv4 only vps (bash menu.sh d)
# 04.turn on warp (warp o)
# 05.install cloudflare client and set mode to proxy (bash menu.sh c)
# 06.change the warp ip to support netflix (warp i)
# 07.turn off, uninstall warp interface, linux client and wireproxy (warp u)
# 08.upgrade kernel, turn on bbr, change linux system (warp b)
# 09.sync the latest version (warp v)
# 10.professional one-click script for warp to unblock streaming media (supports multi-platform, multi-mode and tg push)
# 11.install iptable + dnsmasq + ipset. let warp only take over the streaming media traffic (not available for ipv6 only) (bash menu.sh e)
# 12.install wireproxy. wireguard client that exposes itself as a socks5 proxy or tunnels (bash menu.sh w)
# 13.install cloudflare client and set mode to warp (bash menu.sh l)
# 00.exit
# choose:
# ----------
# 01.爲 ipv4 only 添加 warp ipv4 網絡接口 (bash menu.sh 4)
# 02.爲 ipv4 only 添加 warp ipv6 網絡接口 (bash menu.sh 6)
# 03.爲 ipv4 only 添加 warp 雙棧網絡接口 (bash menu.sh d)
# 04.打開 warp (warp o)
# 05.安裝 cloudflare client 並設置爲 proxy 模式 (bash menu.sh c)
# 06.更換支持 netflix 的 ip (warp i)
# 07.永久關閉 warp 網絡接口，並刪除 warp、 linux client 和 wireproxy (warp u)
# 08.升級內核、安裝bbr、dd腳本 (warp b)
# 09.同步最新版本 (warp v)
# 10.warp 解鎖 netflix 等流媒體專業一鍵(支持多平台、多方式和 tg 通知)
# 11.安裝 iptable + dnsmasq + ipset，讓 warp ipv4 only 接管流媒體流量 (不適用於 ipv6 only vps) (bash menu.sh e)
# 12.安裝 wireproxy，讓 warp 在本地創建一個 socks5 代理 (bash menu.sh w)
# 13.安裝 cloudflare client 並設置爲 warp 模式 (bash menu.sh l)
# 00.退出腳本
# [01/02/03會默認將全部流量繞至「warp」(含：ssh)，12則支持用戶設置出口規則]
# 請選擇:
# --------------------------------------------------
# please customize the client port (1000-65535. default to 40000 if it is blank):
# ----------
# 請自定義 client 端口號 (1000-65535，如果不輸入，會默認: 40000):
# --------------------------------------------------
function funcPublicWarpReinit() {
    # 更新「systemd-resolved」[START]
    # 「127.0.0.53:53」是「[linux/systemd]systemd-resolved」默認使用的本地DNS存根監聽端點，用於處理發送至該端點的DNS查詢（順序：本地記錄 >> 有效緩存 >> 上游DNS（來自：上游查詢列表配置））
    # [存根DNS入口配置]/run/systemd/resolve/stub-resolv.conf
    # [上游DNS列表配置]/run/systemd/resolve/resolv.conf（由「systemd-resolved」根據「/etc/systemd/resolved.conf && DHCP && 網卡配置」等自動生成/更新）
    if :; then # :內置命令，表示{無操作 && 返回成功狀態}
    # if [ -f /etc/systemd/resolved.conf ] && systemctl list-unit-files | grep -q systemd-resolved; then
        # 係統自帶「systemd-resolved」
        if ! grep -q "^DNS=" /etc/systemd/resolved.conf; then
            echo "DNS=1.1.1.1 8.8.8.8" >> /etc/systemd/resolved.conf
        fi
        ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
        systemctl restart systemd-resolved
    else
        # 係統沒有「systemd-resolved」
        echo "warning : systemd-resolved not found"
        rm -f /etc/resolv.conf # 刪除可能存在的軟連接
        echo "nameserver 1.1.1.1" > /etc/resolv.conf
        echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    fi
    if ! nslookup engage.cloudflareclient.com > /dev/null 2>&1; then
        echo "error : [ nslookup engage.cloudflareclient.com failed ] systemd-resolved repair failed"
        return 1
    fi
    # 更新「systemd-resolved」[END]
    # 安裝「wireproxy」[START]
    wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh -O /tmp/warp-menu.sh
    # 安裝 wireproxy（端口默認：40000），讓 warp 在本地創建一個 socks5 代理 (bash menu.sh w)
    # 設置「menu.sh」語言（避免：触发交互）[START]
    # mkdir -p /etc/wireguard
    # echo "E" > /etc/wireguard/language
    # 設置「menu.sh」語言（避免：触发交互）[END]
    expect <<'EOF'
# 不設超時
set timeout -1
# 函數封裝[START]
# 等待目標指示，成功匹配則歸還控制權
proc expect_prompt {pattern description} {
    # [expect]內置變量
    global spawn_id timeout
    expect {
        # -nocase : 忽略大小寫，-re : 正則匹配
        -nocase -re $pattern {
            return
        }
        eof {
            send_error "\nerror : process exited before $description\n"
            exit 1
        }
    }
}
# 函數封裝[END]
spawn bash /tmp/warp-menu.sh
# [expect]內置函數[START]
expect_before {
    -nocase -re {\*\*\*[^\r\n]*\(y/i/n/o/d/z\)[^\r\n]*\[default=n\][ \t]*\?} {
        send -- "N\r"
        # 回到外層「expect」
        exp_continue
    }
}
# [expect]內置函數[END]
expect {
    -nocase -re {language[ \t]*:} {
        expect_prompt {choose[ \t]*:} "language selection"
        send -- "1\r"
        exp_continue
    }
    -nocase -re {([0-9]+)\.[^\r\n]*install[ \t]+wireproxy} {
        # 將正則匹配得到的「菜單序號」存儲至「$expect_out」（[expect]內置變量）
        # 從「$expect_out」讀取首個捕獲結果，賦值至「vari_install_wireproxy_index」
        set vari_install_wireproxy_index $expect_out(1,string)
    }
    eof {
        send_error "\nerror : process exited before wireproxy selection\n"
        exit 1
    }
}
expect_prompt {choose[ \t]*:} "menu selection"
send -- "$vari_install_wireproxy_index\r"
expect_prompt {please customize[^\r\n]*port[^\r\n]*:} "port selection"
send -- "\r"
expect eof
EOF
    # 等待N秒至服務啟動[START]
    local variRetryMax=10
    local variRetryIndex
    for ((variRetryIndex = 1; variRetryIndex <= variRetryMax; variRetryIndex++)); do
        if systemctl is-active --quiet wireproxy; then
            break
        fi
        if ((variRetryIndex == variRetryMax)); then
            echo "error : wireproxy install failed（ detail : journalctl -u wireproxy.service ）"
            return 1
        fi
        sleep 1
    done
    # 等待N秒至服務啟動[END]
    if ! curl -x socks5h://127.0.0.1:40000 -I --connect-timeout 10 https://www.google.com > /dev/null 2>&1; then
        echo "error : curl -x socks5h://127.0.0.1:40000 -I --connect-timeout 10 https://www.google.com"
    fi
    systemctl enable wireproxy
    echo "wireproxy install succeeded"
    # 安裝「wireproxy」[END]
    # 更新「[xray]config.json」出站規則[START]
    local ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]}="/usr/local/etc/xray/config.json"
    python3 - <<EOF
import json
import sys
config_json_uri = "${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]}"
try:
    with open(config_json_uri, 'r') as f:
        config = json.load(f)
    warp_outbound_tag_status = False
    for outbound in config.get("outbounds", []):
        if outbound.get("tag") == "warp_outbound_tag":
            warp_outbound_tag_status = True
            break
    if not warp_outbound_tag_status:
        new_outbound_dict = {
            "protocol": "socks",
            "settings": {
                "servers": [
                    {
                        "address": "127.0.0.1",
                        "port": 40000
                    }
                ]
            },
            "tag": "warp_outbound_tag"
        }
        if "outbounds" not in config:
            config["outbounds"] = []
        # 插至「outbounds」頭部（確保：優先匹配）
        config["outbounds"].insert(0, new_outbound_dict)
        with open(config_json_uri, 'w') as f:
            json.dump(config, f, indent=2)
        print("[ ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]} ] warp_outbound_tag success")
    else:
        print("[ ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]} ] warp_outbound_tag skipped")
except Exception as e:
    print(f"[ ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]} ] warp_outbound_tag failed : {e}")
    sys.exit(1)
EOF
    if [ $? -ne 0 ]; then
        echo "error : ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]} update failed"
        return 1
    fi
    systemctl restart xray
    if ! systemctl is-active --quiet xray; then
        echo "error : systemctl restart xray ( try ：xray run -test -config ${VARI_GLOBAL["XRAY_CONFIG_JSON_URI"]} )"
        # ----------
        local variJournalctlLogUri
        variJournalctlLogUri="/tmp/wireproxy.service.log"
        journalctl -xeu wireproxy.service > "$variJournalctlLogUri" 2>&1
        cat "$variJournalctlLogUri"
        rm -f "$variJournalctlLogUri"
        # ----------
        return 1
    fi
    # 更新「[xray]config.json」出站規則[END]
    # systemctl status xray
    # systemctl status wireproxy
    return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"