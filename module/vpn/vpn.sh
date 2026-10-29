#!/usr/bin/env bash

# author : zengweitao@gmail.com
# datetime : 0000/00/00 00:00:00

:<<'MARK'
# ##################################################
入站方案（即：用戶終端連接至境外VPS）：
1，[xray]VLESS（代理層/一種不帶加密傳輸協議） + TCP/RAW（傳輸層） + reality（安全層/一種安全僞裝技術（即：僞裝瀏覽真實大站（本質：借用其TLS指紋），要求直連禁止CDN））
2，[v2ray]VMESS（代理層/一種自帶加密傳輸協議（注意：嚴格要求{客戶端 && 服務端}時間相差90秒內）） + websocket（傳輸層/雙向通信） + TLS（安全層/僞裝瀏覽常規網頁，並且由NGINX承載/終結TLS（即：加密/解密SSL）） + CDN（用於隱藏VPS真實IP，如：cloudflare）
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
# --------------------------------------------------
故障日志：
2025/08/15
問題描述：
1，VPN失效（此時：V2RAY正常運行）
2，本地可以ssh至搬瓦工服務器，但搬瓦工服務器內部無法訪問互聯網
3，[warp服務]後台獲取「warp ip」中,最大嘗試5次.../最後失敗
調式記錄：
1，systemctl stop wg-quick@warp.service可以恢復vpn服務
2，開通warp+賬戶，沒有作用（「免費賬戶」與「warp+/付費賬戶」區別：付費賬戶僅在訪問cloudflare網站時會觸發類似argo的加速技術，但在訪問非cloudflare網站時沒有任何差異）
最終解決：
1，warp u && wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
# ----------
2026/10/19
問題描述：
1，「gemini」提示處於禁用地區
2，皆是請求「https://www.google.com」，[情況1]使用「warp/cloudflare」作爲出口時{chrome && firefox}皆會自動重定向至「https://www.google.com.hk」，[情況2]使用「vps真實ip」作爲出口則正常
調式記錄：
1，warp u && wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh >> 報錯：bash版本過舊不兼容腳本的「local -n」等命令
最終解決：
1，omni.vpn xrayReinit && omni.vpn warpReinit
2，[ios/client]從「shadowrocket」調整至「hiddify/開源」
# ----------
2026/10/28
問題描述：
1，VPN失效
2，https://tcp.ping.pe >> 67.216.216.79:443 >> china, ... connection to 98.142.138.87:443 failed
調式記錄：
1，--
最終解決：
1，[VPS後台]migrate to another dc
2，omni.vpn releaseCloud ${account} ${ip} ${port} && omni.vpn nginxReinit && omni.vpn v2rayReinit
3，[ios/shadowrocket]alter id : 0
# --------------------------------------------------
MARK

# ##################################################
# compatible && validator[START]
# [zero length]bash
if [ -z "$ZSH_VERSION" ]; then
  [ "${BASH_VERSION%%.*}" -ge 4 ] 2>/dev/null || { echo "[ required ] {bash 4.0+ || zsh}"; return 1 2>/dev/null || exit 1; }
fi
# compatible && validator[END]
# ##################################################

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
VARI_GLOBAL["XRAY_CLIENT_ENVI_URI"]="/usr/local/etc/xray/client.envi"
VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]="/usr/local/etc/xray/config.json"
VARI_GLOBAL["V2RAY_CLIENT_ENVI_URI"]="/usr/local/etc/v2ray/client.envi"
VARI_GLOBAL["V2RAY_SERVER_ENVI_URI"]="/usr/local/etc/v2ray/config.json"
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedCloudInit() {
  # funcProtectedSyncQiniu # 存在判斷：[ -z "$(ls -A "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}")" ]
  # omni.vpn releaseCloud ${account} ${ip} ${port}
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
# omni.vpn nginxReinit
function funcPublicNginxReinit(){
  local variParameterDescList=("domain")
  funcProtectedCheckOptionParameter 1 'variParameterDescList[@]'
  local variDomain=${1:-"baichuan.wiki"}
  local variImage="nginx:1.31.8"
  local variContainerName="nginx"
  if [[ ! -d "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/webside" ]]; then
    echo "error : ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/webside is nil" >&2
    return 1
  fi
  mkdir -p "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/nginx.runtime" "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/webroot/.well-known/acme-challenge"
  if [[ ! -r "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/${variDomain}.pem" || ! -r "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/${variDomain}.key" ]]; then
    if [[ -r "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/config/live/${variDomain}/fullchain.pem" ]]; then
      cp -fL "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/config/live/${variDomain}/fullchain.pem" "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/${variDomain}.pem"
      cp -fL "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/config/live/${variDomain}/privkey.pem" "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/${variDomain}.key"
    else
      # 自簽證書[START]
      openssl req -x509 -nodes -newkey rsa:2048 -days 7 -subj "/CN=${variDomain}" \
        -keyout "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/${variDomain}.key" \
        -out "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/${variDomain}.pem" &> /dev/null
      # 自簽證書[END]
    fi
    chmod 600 "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot/${variDomain}.key"
  fi
  # 核心配置[START]
  cat <<NGINXCONF > "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/nginx.conf"
error_log /usr/local/nginx/runtime/error.log;
worker_processes 1;
events {
    worker_connections 1024;
}
http {
    include              mime.types;
    default_type         application/octet-stream;
    sendfile             on;
    keepalive_timeout    65;
    client_max_body_size 50m;
    access_log           /usr/local/nginx/runtime/access.log combined;
    # log format[START]
    map \$time_iso8601 \$time {
         '~(.*)([+-])(.*)'               \$1;
         default                         'nodate';
    }
    map \$time_iso8601 \$zone {
         '~(.*)([+-])(.*)'               \$2;
         default                         'nodate';
    }
    map \$time_iso8601 \$zonetime {
         '~(.*)([+-])(.*)'               \$3;
         default                         'nodate';
    }
    map \$msec \$millisecond {
         '~(\d{10}).(\d{3})'             \$2;
         default                         'nodate';
    }
    # 支持自定義變量，但需於「conf/slave/*.conf」的每份配置的「server{}」中添加「set \$\$customVariabel 0;」
    log_format json '{"@timestamp":"\$time_iso8601",'
                     '"host":"\$server_addr",'
                     '"clientip":"\$http_x_forwarded_for",'
                     '"size":\$body_bytes_sent,'
                     '"responsetime":\$request_time,'
                     '"http_host":"\$host",'
                     '"request":"\$request",'
                     '"request_method":"\$request_method",'
                     '"request_body":"\$request_body",'
                     '"agent":"\$http_user_agent",'
                     '"status":\$status}';
    log_format json1 escape=json '{"@timestamp":"\$time.\$millisecond\$zone\$zonetime",'
                     '"server_addr":"\$server_addr",'
                     '"clientip":"\$remote_addr",'
                     '"size":\$body_bytes_sent,'
                     '"responsetime":\$request_time,'
                     '"http_host":"\$host",'
                     '"request":"\$request",'
                     '"request_body":"\$request_body",'
                     '"request_method":"\$request_method",'
                     '"http_user_agent":"\$http_user_agent",'
                     '"status":\$status}';
    # log format[END]
    include             /usr/local/nginx/conf/slave/*.conf;
}
NGINXCONF
  # 核心配置[END]
  # 虛擬主機[START]
  cat <<VIRTUALHOSTCONF > "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variDomain}.conf"
# 虛擬主機/${variDomain}[START]
# 80[START]
server {
    listen 80;
    server_name ${variDomain};
    #「Let’s Encrypt」挑戰認證（宿主機：certbot/webroot）[START]
    location ^~ /.well-known/acme-challenge/ {
        root /usr/local/nginx/certbot/webroot;
        default_type "text/plain";
        allow all;
        auth_basic off;
        try_files \$uri =404;
    }
    #「Let’s Encrypt」挑戰認證[END]
    location / {
        return 301 https://\$host\$request_uri;
    }
}
# 80[END]
# 443[START]
server {
    #「listen ... http2」已於 nginx 1.25.1 棄用，改用「http2 on」
    listen 443 ssl;
    http2 on;
    server_name ${variDomain};
    # SSL（由 funcPublicCertbot 的 deploy-hook 下發 fullchain/privkey 至此路徑）[START]
    ssl_certificate /usr/local/nginx/certbot/${variDomain}.pem;
    ssl_certificate_key /usr/local/nginx/certbot/${variDomain}.key;
    #「TLSv1.3」依賴[system/nginx]openssl 1.1.1+
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    # SSL[END]
    root /usr/local/nginx/webside;
    index module/signIn/signIn.html;
    location /temp {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10703;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
# 443[END]
# 虛擬主機/${variDomain}[END]
VIRTUALHOSTCONF
  # 虛擬主機[END]
  # 容器編排[START]
  cat <<DOCKERCOMPOSEYML > "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/docker-compose.yml"
services:
  ${variContainerName}:
    image: ${variImage}
    container_name: ${variContainerName}
    # 開機自啟
    restart: unless-stopped
    network_mode: host
    volumes:
      - ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot:/usr/local/nginx/certbot:ro
      - ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/webside:/usr/local/nginx/webside:ro
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/nginx.conf:/etc/nginx/nginx.conf:ro
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/${variDomain}.conf:/usr/local/nginx/conf/slave/${variDomain}.conf:ro
      - ${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/nginx.runtime:/usr/local/nginx/runtime:rw
DOCKERCOMPOSEYML
  # 容器編排[END]
  cd "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}"
  docker compose -p ${variContainerName} config --quiet
  docker compose -p ${variContainerName} pull
  docker compose -p ${variContainerName} run --rm --no-deps --entrypoint nginx ${variContainerName} -t
  docker rm -f ${variContainerName} &> /dev/null
  docker compose -p ${variContainerName} down -v
  docker compose -p ${variContainerName} up -d
  sleep 2
  if [[ "$(docker inspect -f '{{.State.Running}}' ${variContainerName} 2> /dev/null)" != "true" ]]; then
    docker logs --tail 50 ${variContainerName} >&2
    return 1
  fi
  docker ps -a | grep ${variContainerName}
  # 證書管理[START]
  omni.vpn certbotRenew "${variDomain}" "webroot" "${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}/certbot" "${variContainerName}"
  # 證書管理[END]
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
# [證書目錄] /usr/local/nginx/certbot/config/live/example.domain
# [證書測試] curl -vI https://example.domain
# [續簽測試] certbot renew --dry-run（#續簽時機：[默認]在證書過期前30天開始嘗試續簽）
# [證書評分] https://www.ssllabs.com/ssltest/
function funcPublicCertbotRenew() {
  local variParameterDescList=(
    "domain"
    "model，value(enum) : webroot, standalone"
    "certbot path，example : /usr/local/nginx/certbot"
    "container name，example : nginx"
  )
  funcProtectedCheckRequiredParameter 4 'variParameterDescList[@]' $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  local variDomain=${1}
  local variModel=${2-"webroot"}
  local variCertbotPath=${3-"/usr/local/nginx/certbot"}
  local variServiceName=${4-"nginx"}
  local variRenewShellUri=${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/cerbot.${variDomain}.renew.sh
  local variServiceStopCommand="docker stop ${variServiceName}"
  local variServiceStartCommand="docker start ${variServiceName}"
  local variServiceReloadCommand="docker exec ${variServiceName} nginx -s reload"
  # -L：跟隨符號鏈接（即：源文件是一個軟鏈接時，則會作用於其指向的真實文件）
  local variDeployHookCommand="/usr/bin/cp -fL ${variCertbotPath}/config/live/${variDomain}/fullchain.pem ${variCertbotPath}/${variDomain}.pem && /usr/bin/cp -fL ${variCertbotPath}/config/live/${variDomain}/privkey.pem ${variCertbotPath}/${variDomain}.key && chmod 600 ${variCertbotPath}/${variDomain}.key && ${variServiceReloadCommand}"
  if ! command -v certbot &> /dev/null; then
    [ -f /etc/redhat-release ] && yum install -y certbot
    [ -f /etc/debian_version ] && apt-get update && apt-get install -y certbot
  fi
  # 備份證書[START]
  if [[ -d "${variCertbotPath}/config/live/${variDomain}" ]]; then
    local variBackupPath="${variCertbotPath}/backup/$(date +%Y%m%d%H%M%S)"
    mkdir -p "${variBackupPath}"
    /usr/bin/cp -rfL "${variCertbotPath}/config/live/${variDomain}" "${variBackupPath}/"
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
        --non-interactive \
        --keep-until-expiring \
        --register-unsafely-without-email \
        --config-dir ${variCertbotPath}/config \
        --work-dir ${variCertbotPath}/work \
        --logs-dir ${variCertbotPath}/runtime \
        --deploy-hook "${variDeployHookCommand}"
      cat <<WEBROOTRENEWSHELL > ${variRenewShellUri}
#!/bin/bash
certbot renew --quiet \
  --config-dir ${variCertbotPath}/config \
  --work-dir ${variCertbotPath}/work \
  --logs-dir ${variCertbotPath}/runtime \
  --deploy-hook "${variDeployHookCommand}"
WEBROOTRENEWSHELL
    ;;
    "standalone")
      ${variServiceStopCommand}
      certbot certonly \
        --standalone \
        --preferred-challenges http \
        -d ${variDomain} \
        --agree-tos \
        --non-interactive \
        --keep-until-expiring \
        --register-unsafely-without-email \
        --config-dir ${variCertbotPath}/config \
        --work-dir ${variCertbotPath}/work \
        --logs-dir ${variCertbotPath}/runtime \
        --deploy-hook "${variDeployHookCommand}"
      ${variServiceStartCommand}
      cat <<STANDALONERENEWSHELL > ${variRenewShellUri}
#!/bin/bash
certbot renew --quiet \
  --standalone \
  --config-dir ${variCertbotPath}/config \
  --work-dir ${variCertbotPath}/work \
  --logs-dir ${variCertbotPath}/runtime \
  --pre-hook "${variServiceStopCommand}" \
  --post-hook "${variServiceStartCommand}" \
  --deploy-hook "${variDeployHookCommand}"
STANDALONERENEWSHELL
    ;;
  *)
   echo "Unknown Mode : ${variModel}";
   return 1
  ;;
  esac
  chmod +x ${variRenewShellUri}
  # 定時任務[START]
  # crontab命令寫入，無需reload {[centos]crond || [ubuntu]cron}
  if ! crontab -l 2> /dev/null | grep -qF "${variRenewShellUri}"; then
    ( crontab -l 2> /dev/null; echo "0 0 * * 1 ${variRenewShellUri}" ) | crontab -
    crontab -l
  fi
  # 定時任務[END]
  return 0
}

# 入站處理
function funcPublicV2rayReinit() {
  local variParameterDescList=("client id")
  funcProtectedCheckOptionParameter 1 'variParameterDescList[@]'
  local variClientId=${1:-$(cat /proc/sys/kernel/random/uuid)}
  local variCurrentVpsIp=$(curl -s -4 https://api.ipify.org || curl -s -4 https://ifconfig.me)
  if ! command -v curl || ! command -v unzip &> /dev/null; then
    apt-get update && apt-get install -y curl unzip
  fi
  # ----------
  curl -fsSL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh -o "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/install-release.sh"
  curl -fsSL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh -o "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/install-dat-release.sh"
  # ----------
  # install v2ray
  bash "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/install-release.sh"
  # remove v2ray
  # bash "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/install-release.sh" --remove
  # install {geoip.dat && geosite.dat}，使用於{IP && 域名}分流（默認：關閉（即：需自行添加路由規則））
  bash "${VARI_GLOBAL["BUILTIN_UNIT_RUNTIME_PATH"]}/install-dat-release.sh"
  # ----------
  mkdir -p /var/log/v2ray /usr/local/etc/v2ray
  # 核心配置[START]
  # 僅監聽「127.0.0.1」，由「nginx[:443] -> /temp」反向代理至「websocket」
  cat <<V2RAYCONF > ${VARI_GLOBAL["V2RAY_SERVER_ENVI_URI"]}
{
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [{
    "listen": "127.0.0.1",
    "port": 10703,
    "protocol": "vmess",
    "settings": {
      "clients": [{
        "id": "${variClientId}",
        "level": 1,
        "alterId": 0,
        "security": "chacha20-poly1305"
      }]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/temp"
      }
    }
  }],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [{
      "type": "field",
      "ip": ["geoip:private"],
      "outboundTag": "blocked"
    }]
  }
}
V2RAYCONF
  # 核心配置[END]
  /usr/local/bin/v2ray test -c /usr/local/etc/v2ray/config.json
  # 嚴格要求{客戶端 && 服務端}時間相差90秒內
  timedatectl set-timezone Etc/GMT-8
  systemctl enable v2ray
  systemctl restart v2ray
  systemctl --no-pager status v2ray | head -n 5
  # ----------
  local variYamlFilename
  variYamlFilename="vmess-$(TZ=UTC0 date +%Y%m%d%H%M%S)"
  local variXrayYamlUri="/usr/local/etc/v2ray/${variYamlFilename}.yaml"
  cat > ${variXrayYamlUri} <<EOF
port: 7890
socks-port: 7891
allow-lan: true
bind-address: 0.0.0.0
mode: rule
log-level: info
external-controller: 127.0.0.1:9090
proxies:
  - name: ${variYamlFilename}
    type: vmess
    server: ${variCurrentVpsIp}
    port: 443
    uuid: ${variClientId}
    alterId: 0
    cipher: auto
    tls: true
    servername: baichuan.wiki
    network: ws
    ws-opts:
      path: /temp
      headers:
        Host: baichuan.wiki
proxy-groups:
  - name: --
    type: select
    proxies:
      - DIRECT
      - ${variYamlFilename}
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
  # ----------
  cat ${variXrayYamlUri} >> ${VARI_GLOBAL["V2RAY_CLIENT_ENVI_URI"]}
  cat ${VARI_GLOBAL["V2RAY_CLIENT_ENVI_URI"]}
  funcProtectedTodo "cat ${VARI_GLOBAL["V2RAY_CLIENT_ENVI_URI"]}"
  # ----------
  return 0
}

# 入站處理
function funcPublicXrayReinit() {
    local variCurrentVpsIp=$(curl -s -4 https://api.ipify.org || curl -s -4 https://ifconfig.me)
    # 僞裝目標[START]
    local variTarget=${1:-"www.bing.com:443"}
    local variServerName=${2:-"www.bing.com"}
    # 僞裝目標[END]
    # install xray-core[START]
    if ! command -v xray &> /dev/null; then
        apt update && apt install -y unzip
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
    mkdir -p $(dirname ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]})
    cat > ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]} <<EOF
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
    if xray run -test -config ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]}; then
        systemctl enable xray
        systemctl restart xray
        local variYamlFilename
        variYamlFilename="vless-$(TZ=UTC0 date +%Y%m%d%H%M%S)"
        local variVlessLink="vless://${variClientId}@${variCurrentVpsIp}:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${variServerName}&fp=chrome&pbk=${variPublicKey}&sid=${variShortId}&type=tcp#${variYamlFilename}"
        # ----------
        echo "--------------------------------------------------" > ${VARI_GLOBAL["XRAY_CLIENT_ENVI_URI"]}
        echo "${variVlessLink}" >> ${VARI_GLOBAL["XRAY_CLIENT_ENVI_URI"]}
        echo "--------------------------------------------------" >> ${VARI_GLOBAL["XRAY_CLIENT_ENVI_URI"]}
        # ----------
        local variXrayYamlUri="/usr/local/etc/xray/${variYamlFilename}.yaml"
        cat > ${variXrayYamlUri} <<EOF
port: 7890
socks-port: 7891
allow-lan: true
bind-address: 0.0.0.0
mode: rule
log-level: info
external-controller: 127.0.0.1:9090

proxies:
  - name: ${variYamlFilename}
    type: vless
    server: ${variCurrentVpsIp}
    port: 443
    uuid: ${variClientId}
    network: tcp
    flow: xtls-rprx-vision
    tls: true
    udp: true
    servername: ${variServerName}
    # client-fingerprint：指定使用目標瀏覽器的TLS指紋發起連接
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
      - ${variYamlFilename}

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
        # ----------
        cat ${variXrayYamlUri} >> ${VARI_GLOBAL["XRAY_CLIENT_ENVI_URI"]}
        cat ${VARI_GLOBAL["XRAY_CLIENT_ENVI_URI"]}
        funcProtectedTodo "cat ${VARI_GLOBAL["XRAY_CLIENT_ENVI_URI"]}"
        # ----------
    else
        echo "error : xray run -test -config ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]}"
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
# 出站處理
function funcPublicWarpReinit() {
    # 更新「systemd-resolved」[START]
    # 「127.0.0.53:53」是「[linux/systemd]systemd-resolved」默認使用的本地DNS存根監聽端點，用於處理發送至該端點的DNS查詢（順序：本地記錄 >> 有效緩存 >> 上游DNS（來自：上游查詢列表配置））
    # [存根DNS入口配置]/run/systemd/resolve/stub-resolv.conf
    # [上游DNS列表配置]/run/systemd/resolve/resolv.conf（由「systemd-resolved」根據{/etc/systemd/resolved.conf && DHCP && 網卡配置}等自動生成/更新）
    # if :; then # :內置命令，表示{無操作 && 返回成功狀態}
    if ! systemctl list-unit-files --type=service | grep -q '^systemd-resolved\.service'; then
        rm -f /etc/resolv.conf # 刪除[可能存在的]軟連接
        sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
        apt update && apt install -y systemd-resolved
    fi
    if [ -f /etc/systemd/resolved.conf ] && ! grep -q "^DNS=" /etc/systemd/resolved.conf; then
        echo "DNS=1.1.1.1 8.8.8.8" >> /etc/systemd/resolved.conf
    else
      cat > /etc/systemd/resolved.conf <<'EOF'
[Resolve]
DNS=1.1.1.1 8.8.8.8
EOF
    fi
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    systemctl enable systemd-resolved
    systemctl restart systemd-resolved
    if ! nslookup engage.cloudflareclient.com > /dev/null 2>&1; then
        echo "error : [ nslookup engage.cloudflareclient.com failed ] systemd-resolved repair failed"
        return 1
    fi
    # 更新「systemd-resolved」[END]
    # 安裝「wireproxy」[START]
    mkdir -p /usr/local/etc/warp
    wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh -O /usr/local/etc/warp/menu.sh
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
spawn bash /usr/local/etc/warp/menu.sh
# [expect]內置函數[START]
# expect_before {
#    -nocase -re {\*\*\*[^\r\n]*\(y/i/n/o/d/z\)[^\r\n]*\[default=n\][ \t]*\?} {
#        send -- "N\r"
#        # 回到外層「expect」
#        exp_continue
#    }
# }
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
        echo "try(systemctl is-active --quiet wireproxy) ${variRetryIndex} ..."
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
    python3 - <<EOF
import json
import sys
config_json_uri = "${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]}"
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
        print("[ ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]} ] warp_outbound_tag success")
    else:
        print("[ ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]} ] warp_outbound_tag skipped")
except Exception as e:
    print(f"[ ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]} ] warp_outbound_tag failed : {e}")
    sys.exit(1)
EOF
    if [ $? -ne 0 ]; then
        echo "error : ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]} update failed"
        return 1
    fi
    systemctl restart xray
    if ! systemctl is-active --quiet xray; then
        echo "error : systemctl restart xray ( try ：xray run -test -config ${VARI_GLOBAL["XRAY_SERVER_ENVI_URI"]} )"
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