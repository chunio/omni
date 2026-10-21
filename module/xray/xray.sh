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
function funcPublicRealityReinit() {
    # ----------
    local variServiceName="xray"
    local variConfigJsonUri="/usr/local/etc/xray/config.json"
    local customIp=$(curl -s -4 https://api.ipify.org || curl -s -4 https://ifconfig.me)
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
    mkdir -p $(dirname ${variConfigJsonUri})
    touch /usr/local/etc/xray/access.log
    touch /usr/local/etc/xray/error.log
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
        cat /tmp/xray-${variShortId}.yaml
        echo "--------------------------------------------------"
    else
        echo "error : xray run -test -config ${variConfigJsonUri}"
        return 1
    fi
    return 0
}

function funcPublicWarpReinit() {
    # 更新「systemd-resolved」[START]
    # 解決：GO程序解釋失敗的問題
    if [ -f /etc/systemd/resolved.conf ] && systemctl list-unit-files | grep -q systemd-resolved; then
        # 係統自帶「systemd-resolved」
        if ! grep -q "^DNS=" /etc/systemd/resolved.conf; then
            echo "DNS=1.1.1.1 8.8.8.8" >> /etc/systemd/resolved.conf
        fi
        # 「systemd-resolved」會根據「/etc/systemd/resolved.conf」自動生成「/run/systemd/resolve/resolv.conf」
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
set timeout 120
# 忽略大小寫匹配
# 各匹配分支使用 -nocase

# 調試時改爲 1，顯示收到的內容及匹配過程
exp_internal 0

proc expect_prompt {pattern description} {
    global spawn_id

    expect {
        -nocase -re $pattern {
            return
        }
        timeout {
            send_error "\nerror : timeout while waiting for $description\n"
            exit 1
        }
        eof {
            send_error "\nerror : process exited before $description\n"
            exit 1
        }
    }
}

spawn bash /tmp/warp-menu.sh
# --------------------------------------------------
# language:
# 1.english (default)
# 2.簡體中文
# --------------------------------------------------
# 1.add warp ipv4 interface to ipv4 only vps (bash menu.sh 4)
# 2.add warp ipv6 interface to ipv4 only vps (bash menu.sh 6)
# 3.add warp dualstack interface to ipv4 only vps (bash menu.sh d)
# 4.turn on warp (warp o)
# 5.install cloudflare client and set mode to proxy (bash menu.sh c)
# 6.change the warp ip to support netflix (warp i)
# 7.turn off, uninstall warp interface, linux client and wireproxy (warp u)
# 8.upgrade kernel, turn on bbr, change linux system (warp b)
# 9.sync the latest version (warp v)
# 10.professional one-click script for warp to unblock streaming media (supports multi-platform, multi-mode and tg push)
# 11.install iptable + dnsmasq + ipset. let warp only take over the streaming media traffic (not available for ipv6 only) (bash menu.sh e)
# 12.install wireproxy. wireguard client that exposes itself as a socks5 proxy or tunnels (bash menu.sh w)
# 13.install cloudflare client and set mode to warp (bash menu.sh l)
# 0.exit
# choose:
# ----------
# 1.爲 ipv4 only 添加 warp ipv4 網絡接口 (bash menu.sh 4)
# 2.爲 ipv4 only 添加 warp ipv6 網絡接口 (bash menu.sh 6)
# 3.爲 ipv4 only 添加 warp 雙棧網絡接口 (bash menu.sh d)
# 4.打開 warp (warp o)
# 5.安裝 cloudflare client 並設置爲 proxy 模式 (bash menu.sh c)
# 6.更換支持 netflix 的 ip (warp i)
# 7.永久關閉 warp 網絡接口，並刪除 warp、 linux client 和 wireproxy (warp u)
# 8.升級內核、安裝bbr、dd腳本 (warp b)
# 9.同步最新版本 (warp v)
# 10.warp 解鎖 netflix 等流媒體專業一鍵(支持多平台、多方式和 tg 通知)
# 11.安裝 iptable + dnsmasq + ipset，讓 warp ipv4 only 接管流媒體流量 (不適用於 ipv6 only vps) (bash menu.sh e)
# 12.安裝 wireproxy，讓 warp 在本地創建一個 socks5 代理 (bash menu.sh w)
# 13.安裝 cloudflare client 並設置爲 warp 模式 (bash menu.sh l)
# 0.退出腳本
# 請選擇:
# ----------

# 先處理語言選擇，再識別 WireProxy 菜單；已有語言配置時可直接識別菜單
expect {
    -nocase -re {language[[:space:]]*:} {
        expect_prompt \
            {choose[[:space:]]*:|请选择[[:space:]]*:} \
            "language selection"

        send -- "1\r"
        exp_continue
    }

    -nocase -re {([0-9]+)\.[^\r\n]*(install[[:space:]]+wireproxy|安装[[:space:]]*wireproxy)} {
        set wireproxy_menu_number $expect_out(1,string)
    }

    timeout {
        send_error "\nerror : timeout while waiting for language selection or WireProxy menu\n"
        exit 1
    }

    eof {
        send_error "\nerror : process exited before WireProxy menu\n"
        exit 1
    }
}

# 菜單項出現不代表已開始等待輸入，因此繼續等待選擇提示
expect_prompt \
    {choose[[:space:]]*:|请选择[[:space:]]*:} \
    "main menu selection"

send -- "$wireproxy_menu_number\r"

# --------------------------------------------------
# please customize the client port (1000-65535. default to 40000 if it is blank):
# ----------
# 請自定義 client 端口號 (1000-65535，如果不輸入，會默認: 40000):
# ----------
expect_prompt \
    {please customize[^\r\n]*port[^\r\n]*:|请自定义[^\r\n]*端口[^\r\n]*:|請自定義[^\r\n]*端口[^\r\n]*:} \
    "SOCKS5 port configuration"

send -- "\r"

# --------------------------------------------------
# 安裝階段使用獨立超時，避免下載耗時導致提前退出
set timeout 600

expect {
    eof {
        # 輸出結束，繼續取得子程序退出碼
    }
    timeout {
        send_error "\nerror : WireProxy installation timed out\n"
        exit 1
    }
}

set result [wait]

if {[lindex $result 2] != 0 || [llength $result] > 4} {
    send_error "\nerror : installer terminated abnormally: $result\n"
    exit 1
}

exit [lindex $result 3]
EOF
    if [ $? -ne 0 ]; then
        echo "error : expect execution failed"
        return 1
    fi
    sleep 5 # TODO:[倒計時]等待服務啟動
    if ! systemctl is-active --quiet wireproxy; then
        echo "error : wireproxy install failed（ detail : journalctl -u wireproxy.service ）"
        return 1
    fi
    if ! curl -x socks5h://127.0.0.1:40000 -I --connect-timeout 10 https://www.google.com > /dev/null 2>&1; then
        echo "error : curl -x socks5h://127.0.0.1:40000 -I --connect-timeout 10 https://www.google.com"
    fi
    systemctl enable wireproxy
    echo "wireproxy install succeeded"
    # 安裝「wireproxy」[END]
    # 更新「[xray]config.json」出站規則[START]
    local variConfigJsonUri="/usr/local/etc/xray/config.json"
    python3 - <<EOF
import json
import sys
config_json_uri = "${variConfigJsonUri}"
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
        print("[ ${variConfigJsonUri} ] warp_outbound_tag success")
    else:
        print("[ ${variConfigJsonUri} ] warp_outbound_tag skipped")
except Exception as e:
    print(f"[ ${variConfigJsonUri} ] warp_outbound_tag failed : {e}")
    sys.exit(1)
EOF
    if [ $? -ne 0 ]; then
        echo "error : ${variConfigJsonUri} update failed"
        return 1
    fi
    systemctl restart xray
    if ! systemctl is-active --quiet xray; then
        echo "error : systemctl restart xray ( try ：xray run -test -config ${variConfigJsonUri} )"
        return 1
    fi
    # 更新「[xray]config.json」出站規則[END]
    systemctl status xray
    systemctl status wireproxy
    return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../internal/orchestrator/orchestrator.sh"