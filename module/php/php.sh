#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2025/08/18

:<<'MARK'
https://www.php.net/distributions/php-8.3.24.tar.gz
擴展列表 : php -m
擴展詳情 : php --ri ${extensionName}
編譯參數 : php -i | grep configure
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
VARI_GLOBAL["BIN_NAME"]="php8324"
VARI_GLOBAL["SERVICE_NAME"]="php8324"
VARI_GLOBAL["CONTAINER_NAME"]="chunio-php-8.3.24"
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedCloudInit() {
    return 0
}

function funcProtected8324CloudInit() {
    export DEBIAN_FRONTEND=noninteractive
    # 允許安裝「man」幫助手冊[START]
    # 解决警告xN：update-alternatives: warning: skip creation of /usr/share/man/man1/js.1.gz because associated file /usr/share/man/man1/nodejs.1.gz (of link group js) doesn't exist
    sed -i 's/^path-exclude=\/usr\/share\/man/#path-exclude=\/usr\/share\/man/' /etc/dpkg/dpkg.cfg.d/excludes || true
    sed -i 's/^path-exclude=\/usr\/share\/doc/#path-exclude=\/usr\/share\/doc/' /etc/dpkg/dpkg.cfg.d/excludes || true
    # 允許安裝「man」幫助手冊[END]
    apt update
    variPackageList=(
      # 係統輔助[START]
      tar
      vim
      wget
      curl
      unzip
      ca-certificates
      bash-completion
      # 係統輔助[END]
      # 核心依賴[START]
      gcc
      g++
      re2c
      make
      cmake
      bison
      libtool
      autoconf
      automake
      pkg-config
      build-essential
      libssl-dev # --with-openssl
      libbz2-dev # --with-bz2
      libzip-dev # --with-zip
      zlib1g-dev # --with-zlib
      libxml2-dev # --with-libxml
      libldap2-dev # --with-ldap
      libsasl2-dev # --with-ldap-sasl
      libpcre3-dev # 优化：正則性能
      libargon2-dev  # 支持：密碼哈希
      libcurl4-openssl-dev # --with-curl
      libgd-dev # 支持：gd
      libpng-dev # 支持：gd-png
      libjpeg-dev # 支持：gd-jpeg
      libwebp-dev # 支持：gd-webp
      libmagic-dev # 支持：fileinfo
      libsqlite3-dev # 支持：sqlite（默認：開啟）
      libfreetype6-dev # 支持：gd-font
      libmaxminddb-dev # 支持：geoip2（maxmind已轉至「[composer]geoip2/geoip2 && libmaxminddb」）
      libonig-dev # 支持：mbstring
      libkrb5-dev # 支持：ldap/sasl kerberos
      libxslt1-dev # 支持：xslt
      libsodium-dev # 支持：sodium
      libreadline-dev # 支持：readline
      # 核心依賴[END]
      # 擴展依賴[START]
      libyaml-dev # yaml
      libgeoip-dev # geoip
      libmcrypt-dev # mcrypt
      liburing-dev # swoole
      libbrotli-dev # swoole
      libc-ares-dev # swoole
      libnghttp2-dev # swoole
      # 擴展依賴[END]
    )
    local variRetry=3
    declare -A variCloudInstallResult
    for variEachPackage in "${variPackageList[@]}"; do
      local variCount=0
      while [ $variCount -lt $variRetry ]; do
        if apt install -y "${variEachPackage}"; then
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
          break
        else
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}
          ((variCount++))
        fi
      done
    done
    # --------------------------------------------------
    for variEachPackage in "${!variCloudInstallResult[@]}"; do
      echo "${variEachPackage} : ${variCloudInstallResult[${variEachPackage}]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    done
    echo "${FUNCNAME} finished" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    # --------------------------------------------------
    return 0
}

function funcProtected8324LocalInit(){
    # --------------------------------------------------
    echo "${FUNCNAME} finished" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    # --------------------------------------------------
    return 0
}

function funcProtected8324KernelCompile(){
    # php process user[START]
    if ! id www > /dev/null 2>&1; then
        useradd -s /bin/false -M www
    fi
    # php process user[END]
    # install php main
    local variPart1Button=true 
    # install php extension
    local variPart2Button=true
    if [ "${variPart1Button}" = true ]; then
      {
        rm -rf /usr/local/src/php-8.3.24
        cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf php-8.3.24.tar.gz -C /usr/local/src && cd /usr/local/src/php-8.3.24
        ./configure \
        --prefix=/usr/local/${VARI_GLOBAL["BIN_NAME"]} \
        --exec-prefix=/usr/local/${VARI_GLOBAL["BIN_NAME"]} \
        --bindir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin \
        --mandir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/man \
        --libdir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/lib \
        --sbindir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/sbin \
        --includedir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/include \
        --with-fpm-user=www \
        --with-fpm-group=www \
        --with-config-file-path=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc \
        --with-mysql-sock=/usr/local/mysql/runtime/mysql.sock \
        --with-zip \
        --with-curl \
        --with-libxml \
        --with-openssl \
        --with-bz2 \
        --with-zlib \
        --with-webp \
        --with-jpeg \
        --with-ldap \
        --with-ldap-sasl \
        --with-freetype \
        --with-external-gd \
        --with-mysqli=shared,mysqlnd \
        --with-pdo-mysql=shared,mysqlnd \
        --with-iconv \
        --with-sodium \
        --with-gettext \
        --without-gdbm \
        --enable-gd \
        --enable-xml \
        --enable-ftp \
        --enable-fpm \
        --enable-soap \
        --enable-shmop \
        --enable-pcntl \
        --enable-shared \
        --enable-bcmath \
        --enable-sysvsem \
        --enable-mbregex \
        --enable-mysqlnd \
        --enable-sockets \
        --enable-opcache \
        --enable-opcache-jit \
        --enable-session \
        --enable-mbstring \
        --enable-calendar \
        --disable-debug \
        --disable-rpath
        make -j$(nproc) && make install
        mkdir -p /usr/local/${VARI_GLOBAL["BIN_NAME"]}/{log,runtime,session}
        chown -R www:www /usr/local/${VARI_GLOBAL["BIN_NAME"]}
        # ----------
        touch /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.sock
        chmod 777 /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.sock
        chown www:www /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.sock
        # ----------
        touch /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/xdebug.log
        chmod 777 /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/xdebug.log
        # cp /usr/local/src/php-8.3.24/php.ini-production /usr/local/src/php-8.3.24/etc/php.ini
        # cp /usr/local/php8324/etc/php-fpm.conf.default /usr/local/src/php-8.3.24/etc/php-fpm.conf
        # cp /usr/local/php8324/etc/php-fpm.d/www.conf.default /usr/local/src/php-8.3.24/etc/php-fpm.d/www.conf
        # --------------------------------------------------
        # /usr/local/php8324/etc/php.ini
  cat <<PHPINI > /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
[PHP]
;禁止信息暴露至「http header」
expose_php = off
engine = on
short_open_tag = on
precision = 14
output_buffering = 4096
;gzip[START]
;[gzip]功能開關
zlib.output_compression = on
;[gzip]壓縮級別（1--9）
zlib.output_compression_level = 4
;[gzip]壓縮方式
;zlib.output_handler =
;gzip[END]
implicit_flush = off
unserialize_callback_func =
serialize_precision = -1
disable_functions =
disable_classes =
zend.enable_gc = on
max_input_time = 60
;[進程佔用]最大內存
;swoole下应設至0
max_execution_time = 0
memory_limit = 1024M
error_reporting = E_ALL & ~E_NOTICE
display_errors = off
display_startup_errors = off
log_errors = on
log_errors_max_len = 1024
ignore_repeated_errors = on
ignore_repeated_source = on
report_memleaks = on
html_errors = off
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = off
auto_globals_jit = on
post_max_size = 32M
;首端加載（即：公共邏輯）
auto_prepend_file =
;末端加載（即：公共邏輯）
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
doc_root =
user_dir =
enable_dl = off
file_uploads = on
upload_max_filesize = 8M
max_file_uploads = 20
allow_url_fopen = on
allow_url_include = off
default_socket_timeout = 60
error_log = /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/error.log
upload_tmp_dir = /data/download
;設置時區
date.timezone = Asia/Shanghai
;[允許進程]操作目錄
;open_basedir = /tmp:/windows:/usr/local/src
open_basedir = /
[CLI Server]
cli_server.color = on
[Date]
[filter]
[iconv]
[intl]
[sqlite3]
[Pcre]
[Pdo]
[Pdo_mysql]
pdo_mysql.cache_size = 2000
pdo_mysql.default_socket = /usr/local/mysql/runtime/mysql.sock
[Phar]
[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = off
[ODBC]
odbc.allow_persistent = on
odbc.check_persistent = on
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1
[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
ibase.dateformat = "%Y-%m-%d"
ibase.timeformat = "%H:%M:%S"
[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = on
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = off
;mysql.default_socket = /usr/local/mysql/runtime/mysql.sock
mysqli.default_socket = /usr/local/mysql/runtime/mysql.sock
[mysqlnd]
mysqlnd.collect_statistics = on
mysqlnd.collect_memory_statistics = off
[OCI8]
[PostgreSQL]
pgsql.allow_persistent = on
pgsql.auto_reset_persistent = off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0
[bcmath]
bcmath.scale = 0
[browscap]
[Session]
;##################################################
;session.save_handler = redis
;session.save_path = "tcp://127.0.0.1:6379?auth=0000"
;##################################################
session.save_handler = files
session.use_strict_mode = 0
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 1
session.gc_divisor = 1000
session.gc_maxlifetime = 14400
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.sid_length = 26
session.trans_sid_tags = "a=href,area=href,frame=src,form="
session.sid_bits_per_character = 5
[Assertion]
zend.assertions = -1
[COM]
[mbstring]
[gd]
[exif]
[Tidy]
tidy.clean_output = off
[soap]
soap.wsdl_cache_enabled = 1
soap.wsdl_cache_dir = "/tmp"
soap.wsdl_cache_ttl = 86400
soap.wsdl_cache_limit = 5
[sysvshm]
[ldap]
ldap.max_links = -1
[dba]
[xdebug]
;基本調試
;xdebug.auto_trace = on
;xdebug.collect_params = on
;xdebug.collect_return = on
;xdebug.profiler_enable = on
;xdebug.trace_output_dir = "/usr/local/${VARI_GLOBAL["BIN_NAME"]}/log"
;xdebug.profiler_output_dir ="/usr/local/${VARI_GLOBAL["BIN_NAME"]}/log"
;xdebug.profiler_output_name = "profiler.output.%t-%s"
;遠程調試
;xdebug.remote_enable = on
;「remote_host」表示ide所在主機的「ip address」
;xdebug.remote_host = 0.0.0.0
;xdebug.remote_port = 9500
;xdebug.remote_autostart = on
;xdebug.remote_handler = "dbgp"
;xdebug.remote_log = /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/xdebug.log
;xdebug.idekey= PHPSTORM
[xhprof]
;xhprof.output_dir = "/windows/LocalBranch/37/quantum/mobquantum.37.com.cn/wwwroot/XhprofTrace"
[curl]
[openssl]
[opcache]
opcache.enable = 1
;生產環境最佳實踐是「tracing」
opcache.jit = tracing
;hyperf基於swoole以cli常駐內存
opcache.enable_cli = 1
;更新代碼需重啟服務
opcache.validate_timestamps = 0
opcache.memory_consumption = 128
[swoole]
swoole.use_shortname = off
;啟用內置函數
swoole.enable_library = on
swoole.enable_coroutine = on
;啟用搶佔調度
swoole.enable_preemptive_scheduler = on
;設置擴展
;「zend_extension/核心擴展」應於「extension/普通擴展」之前加載
extension_dir = "/usr/local/${VARI_GLOBAL["BIN_NAME"]}/lib/extensions/no-debug-non-zts-20230831"
;zend_extension = xdebug.so
zend_extension = opcache.so
extension = mysqli.so
extension = pdo_mysql.so
PHPINI
        # --------------------------------------------------
        # /usr/local/php8324/etc/php-fpm.conf
cat <<PHPFPMCONF > /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php-fpm.conf
pid = /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.pid
error_log = /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/php-fpm-error.log
;開啟加載時，如子配置文件不存在則產生警告
;include=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php-fpm.d/*.conf
[www]
user = www
group = www
;監聽方式1（不建議的）
;listen = 127.0.0.1:9000
;監聽方式2（需同步設置「nginx.conf」 >> fastcgi_pass unix:/dev/shm/php-fpm.sock)
listen = /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.sock
listen.owner = www
listen.group = www
listen.mode = 0777
listen.allowed_clients = /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.sock
;[動態]進程模式
pm = dynamic
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 50
;[靜態]進程模式（pm.max_children={內存/512},且需大於pm.max_spare_servers）
;pm = static
pm.max_children = 50
pm.max_requests = 0
pm.status_path = /fpmStatus
request_slowlog_timeout = 15s
request_terminate_timeout = 0
slowlog = /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/php-fpm-slow.log
PHPFPMCONF
        # --------------------------------------------------
        # /lib/systemd/system/php-fpm-8324.service（官方模板/8324：/usr/local/src/php-8.3.24/sapi/fpm/php-fpm.service）
cat <<'SYSTEMCTLPHPFPM8324SERVICE' > /lib/systemd/system/${VARI_GLOBAL["SERVICE_NAME"]}.service
[Unit]
Description=The PHP FastCGI Process Manager
After=network.target
[Service]
Type=simple
PIDFile=/usr/local/php8324/runtime/php-fpm.pid
ExecStart=/usr/local/php8324/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php8324/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID
ProtectedTmp=true
# 錯誤信息 ：systemctl status php-fpm-8324.service >> ERROR: failed to open error_log (/usr/local/php8324/log/php-fpm-error.log): Read-only file system (30)
# 原因分析 ：/usr/lib/systemd/system/php-fpm-8324.service >> ProtectSystem={true || full（default）}，「php-fpm」將[只讀]掛載目錄：/boot，/usr，/etc
# 解决方法 ：1/ProtectSystem=false（but:unsafe），2/php-fpm.conf >> 「error_log」等選項調整至非「/boot，/usr，/etc」
ProtectSystem=false
ProtectedDevices=true
ProtectKernelModules=true
ProtectKernelTunables=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_NETLINK AF_UNIX
RestrictNamespaces=true
[Install]
WantedBy=multi-user.target
SYSTEMCTLPHPFPM8324SERVICE
        chmod 745 /lib/systemd/system/${VARI_GLOBAL["SERVICE_NAME"]}.service
        systemctl enable ${VARI_GLOBAL["SERVICE_NAME"]}.service
        systemctl restart ${VARI_GLOBAL["SERVICE_NAME"]}.service
        systemctl status ${VARI_GLOBAL["SERVICE_NAME"]}.service
        ln -sf /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php /usr/local/bin/php
        ln -sf /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php /usr/local/bin/${VARI_GLOBAL["BIN_NAME"]}
      }
    fi
    if [ "${variPart2Button}" = true ]; then
      {
          declare -A variExtensionInstallResult
          # --------------------------------------------------
          # standard install[START]
          echo ';common external extension' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
          mkdir -p /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}
          variExtensionList=(
              # example："extensionPackageFullName extensionPackageShortName extionsionName"
              "zip-1.22.5.tgz zip-1.22.5 zip"
              "apcu-5.1.25.tgz apcu-5.1.25 apcu"
              # 已廢棄的
              # "mcrypt-1.0.7.tgz mcrypt-1.0.7 mcrypt"
              "mongodb-2.1.1.tgz mongodb-2.1.1 mongodb"
              #「igbinary」應於「redis」之前加載
              "igbinary-3.2.15.tgz igbinary-3.2.15 igbinary"
              # wget https://github.com/phpredis/phpredis/archive/6.2.0.tar.gz -O /data/download/phpredis-6.2.0.tar.gz
              "phpredis-6.2.0.tar.gz phpredis-6.2.0 redis"
              # https://github.com/TarsPHP/tars-extension.git
              # "tars-extension.tar tars-extension phptars"
              "protobuf-4.32.0.tgz protobuf-4.32.0 protobuf"
              # 要求 ：編譯PHP時開啟線程安全「--enable-maintainer-zts」
              # "pthreads-3.1.6.tgz pthreads-3.1.6 pthreads"
          )
          for ((index=0; index<${#variExtensionList[*]}; index+=1)); do
              variEachExtensionInfo=(${variExtensionList[$index]})
              rm -rf /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/${variEachExtensionInfo[1]}
              cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf ${variEachExtensionInfo[0]} -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/${variEachExtensionInfo[1]}
              /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
              ./configure \
              --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config
              make -j$(nproc) && make install
              echo 'extension = '${variEachExtensionInfo[2]}'.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
              variExtensionInstallResult[${variEachExtensionInfo[2]}]=${variEachExtensionInfo[2]}
          done
          # standard install[END]
          # custom install[START]
          {
            mkdir -p /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}
            echo ';custom external extension' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
            {
                # amqp[START]
                # rabbitmq-c : https://github.com/alanxz/rabbitmq-c/releases
                # amqp : http://pecl.php.net/package/amqp
                variExtensionInstallResult["amqp"]="amqp"
                rm -rf /usr/local/src/rabbitmq-c-0.15.0
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf rabbitmq-c-0.15.0.tar.gz -C /usr/local/src && cd /usr/local/src/rabbitmq-c-0.15.0
                mkdir build && cd build
                cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/rabbitmq-c
                cmake --build . --target install
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf amqp-2.1.2.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/amqp-2.1.2
                /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                ./configure \
                --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config \
                --with-librabbitmq-dir=/usr/local/rabbitmq-c \
                --with-amqp
                make -j$(nproc) && make install
                echo 'extension = amqp.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                # amqp[EMD]
            }
            {
                # yaml[START]
                variExtensionInstallResult["yaml"]="yaml"
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf yaml-2.2.5.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/yaml-2.2.5
                /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                ./configure \
                --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config
                make -j$(nproc) && make install
                echo 'extension = yaml.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                # yaml[END]
            }
            {
                # swoole[START]
                variExtensionInstallResult["swoole"]="swoole"
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf swoole-5.1.8.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/swoole-5.1.8
                /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                ./configure \
                --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config \
                --enable-brotli \
                --enable-openssl \
                --enable-sockets \
                --enable-mysqlnd \
                --enable-swoole-curl
                # 已廢棄的[START]
                # --enable-http2
                # --enable-iouring
                # --enable-swoole-json
                # 已廢棄的[END]
                make -j$(nproc) && make install
                echo 'extension = swoole.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                # swoole[END]
            }
            {
                # xdebug[START]
                if [[ ${variXdebugButton:-false} == true ]]; then
                  variExtensionInstallResult["xdebug"]="xdebug"
                  cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf xdebug-3.4.5.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/xdebug-3.4.5
                  /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                  ./configure \
                  --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config \
                  --enable-xdebug
                  make -j$(nproc) && make install
                  # echo 'zend_extension = xdebug.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                  sed -i 's/;zend_extension = xdebug.so/zend_extension = xdebug.so/' /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                fi
                # xdebug[END]
            }
            {
                # inotify[START]
                if [[ ${variInotifyButton:-false} == true ]]; then
                  variExtensionInstallResult["inotify"]="inotify"
                  cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf inotify-3.0.0.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/inotify-3.0.0
                  /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                  ./configure \
                  --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config \
                  --enable-inotify
                  make -j$(nproc) && make install
                  echo 'extension = inotify.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                fi
                # inotify[END]
            }
            # custom install[END]
            # --------------------------------------------------
            for variExtenstionName in "${!variExtensionInstallResult[@]}"; do
                if ${VARI_GLOBAL["BIN_NAME"]} -m | grep -q "${variExtenstionName}"; then
                    echo "${variExtenstionName} : ${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
                else
                    echo "${variExtenstionName} : ${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
                fi
            done
            # --------------------------------------------------
          }
          {
            variRequiredExtensionList=(
                pdo
                json
                pcntl
                redis
                # swoole >= 5.0 &&「echo swoole.use_shortname = 'off' >> php.ini」
                swoole
                openssl
                protobuf
            )
            variConflictExtensionList=(
                # 開啟報錯 ：Fatal error: Declaration of Monolog\Logger::emergency(Stringable|string $message, array $context = []): void must be compatible with PsrExt\Log\LoggerInterface::emergency($message, array $context = [])
                # 解決方案 : 更新代碼
                psr
                uopz
                trace
                # 開啟報錯 ：WARNING Server::check_worker_exit_status(): worker(pid=35270, id=4) abnormal exit, status=0, signal=11
                # 解決方法 ：雖然官網說明「PHP >= 8.1 && swoole >= 5.0.2」即可支持「xdebug」，但實際依然報錯
                xdebug
                xhprof
                blackfire
            )
            # composer[START]
            # php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
            # HASH=`curl -sS https://composer.github.io/installer.sig`
            # php -r "if (hash_file('sha384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
            # php composer-setup.php --install-dir=/usr/local/bin --filename=composer
            # php -r "unlink('composer-setup.php');"
            cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]}
            /usr/bin/cp -rf composer-2.8.10.phar /usr/local/bin/composer
            chmod +x /usr/local/bin/composer
            # 更新環境變量[START]
            # 關閉提示「Continue as root/super user [yes]?」
            #「/etc/bash.bashrc」中存在「[ -z "$PS1" ] && return」用來判斷當前腳本是否爲「交互模式」，如果不是則直接退出
            export COMPOSER_ALLOW_SUPERUSER=1
            echo "export COMPOSER_ALLOW_SUPERUSER=1" >> /etc/bash.bashrc
            source /etc/bash.bashrc
            # 更新環境變量[END]
            composer --version >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
            # composer[END]
            composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
            variGithubCommonToken=$(funcProtectedPullEncryptEnvi "GITHUB_COMMON_TOKEN")
            composer config --global --auth github-oauth.github.com ${variGithubCommonToken}
          }
        }
    fi
    # --------------------------------------------------
    echo "${FUNCNAME} finished" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    # --------------------------------------------------
    return 0
}

function funcProtected8324EnviDestruct(){
  rm -rf /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublicRebuildImage(){
  # 構建鏡像[START]
  variParameterDescList=("image pattern（example ：chunio/php:8.3.24）")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=$1
  docker rm -f ${VARI_GLOBAL["CONTAINER_NAME"]} 2> /dev/null
  # 當本地鏡像不存在時，則自動執行 ：docker pull $variImageName（from : hub.docker.com）
  #「-v /sys/fs/cgroup:/sys/fs/cgroup:rw ---tmpfs /tmp --tmpfs /run --tmpfs /run/lock --cgroupns=host」表示支持「systemctl」
  omni.docker buildSystemdUbuntuImage
  docker run -d \
    --privileged \
    --name ${VARI_GLOBAL["CONTAINER_NAME"]} \
    --tmpfs /tmp \
    --tmpfs /run \
    --tmpfs /run/lock \
    --cgroupns=host \
    -v /windows:/windows \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    systemd.ubuntu /sbin/init
  # 執行命令，並停留至遠端窗口，示例：
  # docker exec -it php8324 /bin/bash -c "cd /windows/code/backend/chunio/automatic/docker/php && ./php.sh funcPublicBuiltinMain; exec /bin/bash" 
  docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash -c "cd ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]} && ./$(basename ${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]}) 8324Main;"
  variContainerId=$(docker ps --filter "name=${VARI_GLOBAL["CONTAINER_NAME"]}" --format "{{.ID}}")
  echo "docker commit ${variContainerId} ${variImagePattern} ..."
  docker commit ${variContainerId} ${variImagePattern}
  docker ps --filter "name=${VARI_GLOBAL["CONTAINER_NAME"]}"
  docker images --filter "reference=${variImagePattern}"
  echo "${FUNCNAME} ${VARI_GLOBAL["SUCCESS_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}

function funcPublic8324Main(){
  funcProtected8324CloudInit
  funcProtected8324LocalInit
  funcProtected8324KernelCompile
  funcProtected8324EnviDestruct
  return 0
}

function funcPublicExec(){
  if ! docker ps | grep -q "${VARI_GLOBAL["CONTAINER_NAME"]}"; then
    mkdir -p /windows
    docker stop ${VARI_GLOBAL["CONTAINER_NAME"]} 2> /dev/null || true
    docker rm -f ${VARI_GLOBAL["CONTAINER_NAME"]} 2> /dev/null || true
    docker run -d \
      --privileged \
      --name ${VARI_GLOBAL["CONTAINER_NAME"]} \
      --tmpfs /tmp \
      --tmpfs /run \
      --tmpfs /run/lock \
      --cgroupns=host \
      -v /windows:/windows \
      -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
      -p 9501:9501 \
      chunio/php:8324 /sbin/init
  fi
  docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash -c "cd /windows/code/backend/haohaiyou/gopath/src/skeleton; exec /bin/bash"
  return 0
}
# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"