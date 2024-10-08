#!/bin/bash

# author : zengweitao@gmail.com
# datetime : 2024/10/07

:<<'MARK'
https://www.php.net/distributions/php-8.3.12.tar.gz
擴展列表 : php -m
擴展詳情 : php --ri ${extensionName}
編譯參數 : php -i | grep configure
MARK

declare -A VARI_GLOBAL
VARI_GLOBAL["BUILTIN_BASH_EVNI"]="SLAVE"
VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/builtin/builtin.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/utility/utility.sh"
source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/encrypt.envi" 2> /dev/null || true

# ##################################################
# global variable[START]
VARI_GLOBAL["BIN_NAME"]="php8312"
VARI_GLOBAL["SERVICE_NAME"]="php8312"
VARI_GLOBAL["CONTAINER_NAME"]="php8312environment"
# global variable[END]
# ##################################################

# ##################################################
# protected function[START]
function funcProtectedCloudInit() {
  funcProtectedSyncQiniu
  return 0
}

function funcProtected8312CloudInit() {
    # 更新倉庫(1)[START]
    #「centos7.9」已停止維護（截止2024/06/30），官方倉庫 ：mirrorlist.centos.org >> vault.centos.org
    sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo
    # 更新倉庫(1)[END]
    rm -f /var/run/yum.pid
    variPackageList=(
      epel-release
      git
      tar
      gcc
      gcc-c++
      make
      cmake3
      # curl
      # libcurl-devel.x86_64
      re2c
      wget
      zlib
      zlib-devel
      bison
      unzip
      bzip2-devel
      autoconf
      libgsasl
      libgsasl-devel
      libatomic
      libmcrypt
      libmcrypt-devel
      oniguruma
      oniguruma-devel
      # 提供:編譯依賴（儘管：自行安裝「brotli 1.1.0」）
      # [google]壓縮算法
      brotli-devel
      # 提供:編譯依賴（儘管：自行安裝「openssl 1.1.1」）
      # openssl-devel
      # 網絡編程/異步事件
      libevent-devel
      cyrus-sasl-devel
      libpng-devel
      sqlite-devel
      # libxml2
      # libxml2-devel
      libjpeg-devel
      freetype-devel
      # cmake[START]
      # 順序敏感（centos-release-scl >> devtoolset-9）
      centos-release-scl
      devtoolset-9
      # cmake[END]
      # zstd[START]
      # [facebook]壓縮算法
      # 「remi-release-7.rpm」提供「libzstd-devel.x86_64」(搜尋命令：yum list available | grep zstd-devel)
      http://rpms.remirepo.net/enterprise/remi-release-7.rpm
      zstd
      libzstd-devel.x86_64
      # zstd[END]
      # openladp[START]
      libtool
      libtool-ltdl-devel
      libdb-devel
      # openladp[END]
      # yaml.so[START]
      libyaml-devel.x86_64
      # yaml.so[END]
      # geoip.so[START]
      geoip
      geoip-devel
      # geoip.so[END]
      # swoole.so[START]
      # 提供「librt」
      glibc
      glibc-devel
      glibc-headers
      # swoole.so[END]
      libxslt-devel
      libwebp-devel
      readline-devel
    )
    local variRetry=3
    declare -A variCloudInstallResult
    for variEachPackage in "${variPackageList[@]}"; do
      local variCount=0
      while [ $variCount -lt $variRetry ]; do
        if yum install -y "${variEachPackage}"; then
          # --------------------------------------------------
          case "${variEachPackage}" in
              "centos-release-scl")
                  # 更新倉庫(2)[START]
                  # update /etc/yum.repos.d/CentOS-SCLo-scl.repo
                  sed -i '/\[centos-sclo-sclo\]/,/^$/{
                      s|^\s*mirrorlist=|#mirrorlist=|g
                      s|^\s*#\?\s*baseurl=.*|baseurl=http://vault.centos.org/7.9.2009/sclo/$basearch/sclo/|g
                      s|^\s*gpgcheck=.*|gpgcheck=0|g
                  }' /etc/yum.repos.d/CentOS-SCLo-scl.repo
                  # update /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
                  sed -i '/\[centos-sclo-rh\]/,/^$/{
                      s|^\s*mirrorlist=|#mirrorlist=|g
                      s|^\s*#\?\s*baseurl=.*|baseurl=http://vault.centos.org/7.9.2009/sclo/$basearch/rh/|g
                      s|^\s*gpgcheck=.*|gpgcheck=0|g
                  }' /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
                  # 更新倉庫(2)[END]
                  ;;
              *)
                  # [其他]特殊處理 ...
                  ;;
          esac
          # --------------------------------------------------
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_TRUE_LABEL"]}
          break
        else
          variCloudInstallResult[${variEachPackage}]=${VARI_GLOBAL["BUILTIN_FALSE_LABEL"]}
          ((variCount++))
        fi
      done
    done
    ln -sf /usr/bin/cmake3 /usr/bin/cmake
    source /opt/rh/devtoolset-9/enable
    package-cleanup --oldkernels --count=1 && yum -y autoremove && yum clean all && rm -rf /var/cache/yum
    # --------------------------------------------------
    for variEachPackage in "${!variCloudInstallResult[@]}"; do
      echo "${variEachPackage} : ${variCloudInstallResult[${variEachPackage}]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    done
    echo "${FUNCNAME} finished" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    # --------------------------------------------------
    return 0
}

function funcProtected8312LocalInit(){
    cat <<'ETCBASHRC' >> /etc/bashrc
# [LD_LIBRARY_PATH]custom linker search path（default ：/lib || /usr/lib）
export LD_LIBRARY_PATH=/usr/lib:/usr/lib64:/usr/local/lib:/usr/local/lib64:/usr/local/openssl/lib:/usr/local/brotli/lib64:/usr/local/curl/lib:/usr/local/libxml2/lib:/usr/local/libssh2/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/openssl/lib/pkgconfig:/usr/local/brotli/lib64/pkgconfig:/usr/local/curl/lib/pkgconfig:/usr/local/libxml2/lib/pkgconfig:$PKG_CONFIG_PATH
ETCBASHRC
    source /etc/bashrc
    # --------------------------------------------------
    # update brotli[START]
    # use : curl && swoole/5.1.4
    rm -rf /usr/local/src/brotli-1.1.0
    cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf brotli-1.1.0.tar.gz -C /usr/local/src/ && cd /usr/local/src/brotli-1.1.0
    mkdir out && cd out
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/brotli ..
    make -j8 && make install
    # 編譯報錯 ：... undefined reference to「BrotliSharedDictionaryAttach || BrotliSharedDictionaryDestroyInstance」
    # 解決方法 ：移除舊版「libbrotli*.so*」
    rm -f /usr/lib/libbrotli*.so*
    rm -f /usr/lib64/libbrotli*.so*
    ln -sf /usr/local/brotli/bin/brotli /usr/bin/brotli
    ln -sf /usr/local/openssl/include/brotli /usr/include/brotli
    # libbrotlidec
    ln -sf /usr/local/brotli/lib64/libbrotlidec.so.1 /usr/lib64/libbrotlidec.so
    ln -sf /usr/local/brotli/lib64/libbrotlidec.so.1.1.0 /usr/lib64/libbrotlidec.so.1
    ln -sf /usr/local/brotli/lib64/libbrotlidec.so.1.1.0 /usr/lib64/libbrotlidec.so.1.1.0
    # libbrotlienc
    ln -sf /usr/local/brotli/lib64/libbrotlienc.so.1 /usr/lib64/libbrotlienc.so
    ln -sf /usr/local/brotli/lib64/libbrotlienc.so.1.1.0 /usr/lib64/libbrotlienc.so.1
    ln -sf /usr/local/brotli/lib64/libbrotlienc.so.1.1.0 /usr/lib64/libbrotlienc.so.1.1.0
    # libbrotlicommon
    ln -sf /usr/local/brotli/lib64/libbrotlicommon.so.1 /usr/lib64/libbrotlicommon.so
    ln -sf /usr/local/brotli/lib64/libbrotlicommon.so.1.1.0 /usr/lib64/libbrotlicommon.so.1
    ln -sf /usr/local/brotli/lib64/libbrotlicommon.so.1.1.0 /usr/lib64/libbrotlicommon.so.1.1.0
    if [ "$(brotli --version | awk '{print $2}')" != "1.1.0" ]; then
      brotli --version
      echo "brotli != 1.1.0"
      return 1
    fi
    # ----------
    # 自行添加「pkg-config/libbrotli.pc」
#       cat << 'EOF' > /usr/local/brotli/lib64/pkgconfig/libbrotli.pc
# prefix=/usr/local/brotli
# libdir=${prefix}/lib64
# includedir=${prefix}/include
# Name: libbrotli
# Description: Brotli Compression Library
# Version: 1.1.0
# Libs: -L${libdir} -lbrotlienc -lbrotlidec -lbrotlicommon
# Cflags: -I${includedir}
# EOF
#       if [ "$(pkg-config --modversion libbrotli)" != "1.1.0" ]; then
#         pkg-config --modversion libbrotli
#         echo "brotli != 1.1.0"
#         return 1
#       fi
    # ----------
    # update brotli[END]
    # --------------------------------------------------
    # update openssl[START]
    rm -rf /usr/local/src/openssl-1.1.1
    cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf openssl-1.1.1.tar.gz -C /usr/local/src/ && cd /usr/local/src/openssl-1.1.1
    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib
    make -j8 && make install
    ln -sf /usr/local/openssl/bin/openssl /usr/bin/openssl
    ln -sf /usr/local/openssl/include/openssl /usr/include/openssl
    ln -sf /usr/local/openssl/lib/libssl.so /usr/lib/libssl.so
    ln -sf /usr/local/openssl/lib/libcrypto.so /usr/lib/libcrypto.so
    # 查看鏈接至「openssl」的程序列表
    # ldd /usr/bin/openssl
    if [ "$(pkg-config --modversion openssl)" != "1.1.1" ]; then
      pkg-config --modversion openssl
      echo "openssl != 1.1.1"
      return 1
    fi
    # updeate openssl[END]
    # --------------------------------------------------
    # update ssh2[START]
    # depend on ：openssl 1.1.1
    rm -rf /usr/local/src/libssh2-1.10.0
    cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf libssh2-1.10.0.tar.gz -C /usr/local/src/ && cd /usr/local/src/libssh2-1.10.0
    ./configure \
    --prefix=/usr/local/libssh2 \
    --with-libssl-prefix=/usr/local/openssl \
    --with-openssl
    make -j8 && make install
    # update ssh2[END]
    # --------------------------------------------------
    # update ldap[START]
    # 安裝原因 ：因編譯PHP/error（old openladp depend on old openssl）
    # 編譯報錯 ：/usr/local/src/openldap-2.4.58/libraries/libldap_r/os-ip.c:262: warning: sys_nerr' is deprecated; use strerror' or `strerror_r' instead
    # 解決方法 ：可以忽略（建議使用「strerror || strerror_r」代替「sys_errlist || sys_nerr」）
    cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf openldap-2.4.58.tgz -C /usr/local/src/ && cd /usr/local/src/openldap-2.4.58
    ./configure \
    --prefix=/usr/local/openldap \
    --with-ssl=/usr/local/openssl \
    --with-tls=openssl \
    --with-cyrus-sasl 
    make depend
    make -j8 && make install
    # update ldap[END]
    # --------------------------------------------------
    # update curl[START]
    # depend on : openssl 1.1.1 && libssh2 
    #「--with-brotli」depend on :「yum install -y zlib-devel」
    rm -rf /usr/local/src/curl-7.88.1
    cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf curl-7.88.1.tar.gz -C /usr/local/src/ && cd /usr/local/src/curl-7.88.1
    ./configure \
    --prefix=/usr/local/curl \
    --with-ssl=/usr/local/openssl \
    --with-brotli=/usr/local/brotli \
    --with-libssh2=/usr/local/libssh2 \
    --with-zstd \
    --with-gssapi 
    make -j8 && make install
    ln -sf /usr/local/curl/bin/curl /usr/bin/curl
    if [ "$(curl --version | head -n 1 | awk '{print $2}')" != "7.88.1" ]; then
        curl --version
        echo "curl != 7.88.1"
        return 1
    fi
    if ! curl --version | grep -q "brotli/1.1.0"; then
        echo "curl/7.88.1 is not linked brotli/1.1.0"
        return 1
    fi
    # update curl[END]
    # --------------------------------------------------
    # update zip[START]
    rm -rf /usr/local/src/libzip-1.8.0
    cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -zxf libzip-1.8.0.tar.gz -C /usr/local/src && cd /usr/local/src/libzip-1.8.0
    mkdir build && cd build
    cmake .. -DOPENSSL_ROOT_DIR=/usr/local/openssl -DOPENSSL_LIBRARIES=/usr/local/openssl/lib
    make -j8 && make install
    if [ "$(pkg-config --modversion libzip)" != "1.8.0" ]; then
      pkg-config --modversion libzip
      echo "libzip != 1.8.0"
      return 1
    fi
    # update zip[END]
    # --------------------------------------------------
    # update libxml2[START]
    # php/8312 depend on : libxml2/latest
    # https://download.gnome.org/sources/libxml2/
    cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -Jxf libxml2-2.13.4.tar.xz -C /usr/local/src && cd /usr/local/src/libxml2-2.13.4
    ./configure --prefix=/usr/local/libxml2 --with-python=no
    make -j8 && make install
    # remove old version
    rm -rf /usr/lib/libxml2*.so*
    rm -rf /usr/lib64/libxml2*.so*
    rm -rf /usr/include/libxml2
    rm -rf /usr/bin/xml2-config
    rm -rf /usr/lib/pkgconfig/libxml-2.0.pc
    rm -rf /usr/lib64/pkgconfig/libxml-2.0.pc
    if [ "$(pkg-config --modversion libxml-2.0)" != "2.13.4" ]; then
      pkg-config --modversion libxml-2.0
      echo "libxml2 != 2.13.4"
      return 1
    fi
    # --------------------------------------------------
    # update dynamic link library[START]
cat <<LDSOCONF >> /etc/ld.so.conf
/usr/local/lib/
/usr/local/lib64/
/usr/local/curl/lib/
/usr/local/libssh2/lib/
/usr/local/openssl/lib/
/usr/local/libxml2/lib/
/usr/local/openldap/lib/
/usr/local/brotli/lib64/
LDSOCONF
    # 更新緩存 && 顯示詳情
    # 顯示錯誤 ：ldconfig: Can't stat /libx32: No such file or directory / ldconfig: Path `/usr/lib' given more than once / ...
    # 解決方法 ：可以忽略 
    ldconfig -v
    # update dynamic link library[END]
    # --------------------------------------------------
    echo "${FUNCNAME} finished" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    # --------------------------------------------------
    return 0
}

function funcProtected8312Main(){
    # php process user[START]
    if ! id www > /dev/null 2>&1; then
        useradd -s /bin/false -M www
    fi
    # php process user[END]
    # install php main
    local variPart1Button=true 
    # install php extension
    local variPart2Button=true
    source /etc/bashrc 
    source /opt/rh/devtoolset-9/enable 
    if [ "${variPart1Button}" = true ]; then
      {
        # 編譯報錯 ：/opt/rh/devtoolset-9/root/usr/libexec/gcc/x86_64-redhat-linux/9/ld: warning: libssl.so.10, needed by /usr/lib64/libldap-2.4.so.2, may conflict with libssl.so.1.1
        # 解決方法 ：基於「openssl 1.1.1」，更新「openldap 2.4.58」
        rm -rf /usr/local/src/php-8.3.12
        cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf php-8.3.12.tar.gz -C /usr/local/src && cd /usr/local/src/php-8.3.12
        local variOldcflags="${CFLAGS}"
        local variOldldflags="${LDFLAGS}"
        export CFLAGS="-I/usr/local/curl/include -I/usr/local/libxml2/include ${CFLAGS}"
        export LDFLAGS="-L/usr/local/curl/lib -L/usr/local/libxml2/lib ${LDFLAGS}"
        ./configure \
        --prefix=/usr/local/${VARI_GLOBAL["BIN_NAME"]} \
        --exec-prefix=/usr/local/${VARI_GLOBAL["BIN_NAME"]} \
        --bindir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin \
        --sbindir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/sbin \
        --includedir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/include \
        --libdir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/lib \
        --mandir=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/man \
        --with-libxml=/usr/local/libxml2 \
        --with-fpm-user=www \
        --with-fpm-group=www \
        --with-config-file-path=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc \
        --with-mysql-sock=/usr/local/mysql/runtime/mysql.sock \
        --with-curl=/usr/local/curl \
        --with-openssl=/usr/local/openssl \
        --with-openssl-dir=/usr/local/openssl \
        --with-libzip=/usr/local/libzip/lib64 \
        --with-ldap=/usr/local/openldap \
        --with-ldap-sasl \
        --with-mysql=shared,mysqlnd \
        --with-mysqli=shared,mysqlnd \
        --with-pdo-mysql=shared,mysqlnd \
        --with-gd \
        --with-bz2 \
        --with-zip \
        --with-zlib \
        --with-iconv \
        --with-mhash \
        --with-xmlrpc \
        --with-gettext \
        --with-jpeg-dir \
        --with-freetype-dir \
        --without-gdbm \
        --without-pear \
        --enable-ftp \
        --enable-zip \
        --enable-xml \
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
        --enable-session \
        --enable-mbstring \
        --enable-calendar \
        --enable-inline-optimization \
        --disable-debug \
        --disable-rpath \
        --disable-fileinfo
        make -j8 && make install
        export CFLAGS="${variOldcflags}"
        export LDFLAGS="${variOldldflags}"
        mkdir -p /usr/local/${VARI_GLOBAL["BIN_NAME"]}/{log,runtime,session}
        chown -R www:www /usr/local/${VARI_GLOBAL["BIN_NAME"]}
        # ----------
        touch /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.sock
        chmod 777 /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.sock
        chown www:www /usr/local/${VARI_GLOBAL["BIN_NAME"]}/runtime/php-fpm.sock
        # ----------
        touch /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/xdebug.log
        chmod 777 /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/xdebug.log
        # cp /usr/local/src/php-8.3.12/php.ini-production /usr/local/src/php-8.3.12/etc/php.ini
        # cp /usr/local/php8312/etc/php-fpm.conf.default /usr/local/src/php-8.3.12/etc/php-fpm.conf
        # cp /usr/local/php8312/etc/php-fpm.d/www.conf.default /usr/local/src/php-8.3.12/etc/php-fpm.d/www.conf
        # --------------------------------------------------
        # /usr/local/php8312/etc/php.ini
  cat <<PHPINI > /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
[PHP]
;禁止信息暴露至「http header」
expose_php = Off
engine = On
short_open_tag = On
precision = 14
output_buffering = 4096
;gzip[START]
;[gzip]功能開關
zlib.output_compression = On
;[gzip]壓縮級別（1--9）
zlib.output_compression_level = 4
;[gzip]壓縮方式
;zlib.output_handler =
;gzip[END]
implicit_flush = Off
unserialize_callback_func =
serialize_precision = -1
disable_functions =
disable_classes =
zend.enable_gc = On
max_EXEC_TIME = 300
max_input_time = 60
;[進程佔用]最大內存
memory_limit = 1024M
error_reporting = E_ALL & ~E_NOTICE
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = On
ignore_repeated_source = On
report_memleaks = On
html_errors = Off
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 32M
;首端加載（即：公共邏輯）
auto_prepend_file =
;末端加載（即：公共邏輯）
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
doc_root =
user_dir =
enable_dl = Off
file_uploads = On
upload_max_filesize = 8M
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
error_log = /usr/local/${VARI_GLOBAL["BIN_NAME"]}/log/error.log
upload_tmp_dir = /data/download
;設置時區
date.timezone = Asia/Shanghai
;[允許進程]操作目錄
;open_basedir = /tmp:/windows:/usr/local/src
open_basedir = /
[CLI Server]
cli_server.color = On
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
mail.add_x_header = Off
[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
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
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off
;mysql.default_socket = /usr/local/mysql/runtime/mysql.sock
mysqli.default_socket = /usr/local/mysql/runtime/mysql.sock
[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off
[OCI8]
[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
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
tidy.clean_output = Off
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
;RemoteHost爲IDE所在主機IPAddress
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
[swoole]
swoole.use_shortname = off
;設置擴展
extension_dir = "/usr/local/${VARI_GLOBAL["BIN_NAME"]}/lib/extensions/no-debug-non-zts-20230831"
extension = mysqli.so
extension = pdo_mysql.so
PHPINI
        # --------------------------------------------------
        # /usr/local/php8312/etc/php-fpm.conf
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
        # /lib/systemd/system/php-fpm-8312.service（官方模板/8312：/usr/local/src/php-8.3.12/sapi/fpm/php-fpm.service）
cat <<'SYSTEMCTLPHPFPM8312SERVICE' > /lib/systemd/system/${VARI_GLOBAL["SERVICE_NAME"]}.service
[Unit]
Description=The PHP FastCGI Process Manager
After=network.target
[Service]
Type=simple
PIDFile=/usr/local/php8312/var/run/php-fpm.pid
ExecStart=/usr/local/php8312/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php8312/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID
ProtectedTmp=true
# 錯誤信息 ：systemctl status php-fpm-8312.service >> ERROR: failed to open error_log (/usr/local/php8312/log/php-fpm-error.log): Read-only file system (30)
# 原因分析 ：/usr/lib/systemd/system/php-fpm-8312.service >> ProtectSystem={true || full（default）}，「php-fpm」將[只讀]掛載目錄：/boot，/usr，/etc
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
SYSTEMCTLPHPFPM8312SERVICE
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
              # example : "extensionPackageFullName extensionPackageShortName extionsionName"
              # "psr-1.2.0.tgz psr-1.2.0 psr"
              "zip-1.22.4.tgz zip-1.22.4 zip"
              # wget https://github.com/phpredis/phpredis/archive/4.1.1.tar.gz -O /data/download/phpredis-4.1.1.tar.gz
              "phpredis-6.0.2.tar.gz phpredis-6.0.2 redis"
              # mcrypt（備註：解決「PHP7.2+」移除「mcrypt/加密支持」導致的兼容問題）
              # http://pecl.php.net/get/mcrypt-1.0.4.tgz
              "mcrypt-1.0.7.tgz mcrypt-1.0.7 mcrypt"
              # "yaconf-1.1.0.tgz yaconf-1.1.0 yaconf"
              # wget https://pecl.php.net/get/mongodb-1.5.3.tgz
              "mongodb-1.20.0.tgz mongodb-1.20.0 mongodb"
              # https://github.com/TarsPHP/tars-extension.git
              # "tars-extension.tar tars-extension phptars"
              "igbinary-3.2.15.tgz igbinary-3.2.15 igbinary"
              "protobuf-4.27.5.tgz protobuf-4.27.5 protobuf"
              # 要求 ：編譯PHP時開啟線程安全「--enable-maintainer-zts」
              # "pthreads-3.1.6.tgz pthreads-3.1.6 pthreads"
          )
          for ((index=0; index<${#variExtensionList[*]}; index+=1)); do
              variEachExtensionInfo=(${variExtensionList[$index]})
              case ${variEachExtensionInfo[2]} in
                  "protobuf")
                      source /opt/rh/devtoolset-9/enable
                      ;;
                  *)
              ;;
              esac
                  rm -rf /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/${variEachExtensionInfo[1]}
                  cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf ${variEachExtensionInfo[0]} -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/${variEachExtensionInfo[1]}
                  /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                  ./configure \
                  --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config
                  make -j8 && make install
                  echo 'extension = '${variEachExtensionInfo[2]}'.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                  variExtensionInstallResult[${variEachExtensionInfo[2]}]=${variEachExtensionInfo[2]}
          done
          # standard install[END]
          # custom install[START]
          {
            mkdir -p /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}
            echo ';custom external extension' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
            {
                # swoole[START]
                # ----------
                # 編譯報錯 : configure: error: We have to link to librt on your os, but librt not found.
                # 解決方法 ：yum install -y brotli-devel
                # ----------
                # 編譯報錯 ：/usr/local/src/extension/php8312/swoole-5.1.4/ext-src/swoole_http_response.cc:979:17: warning: ‘name_len’ may be used uninitialized in this function [-Wmaybe-uninitialized]
                # 解決方法 : 未解決的
                # ----------
                # 運行報錯 ：skeleton.Worker.1: symbol lookup error: /usr/local/php8312/lib/extensions/no-debug-non-zts-20230831/swoole.so: undefined symbol: BrotliEncoderMaxCompressedSize
                # 解決方法 ：export {CFLAGS && LDFLAGS}
                # ----------
                variExtensionInstallResult["swoole"]="swoole"
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf swoole-5.1.4.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/swoole-5.1.4
                local variOldcflags=${CFLAGS}
                local variOldldflags=${LDFLAGS}
                export CFLAGS="-I/usr/local/brotli/include"
                export LDFLAGS="-L/usr/local/brotli/lib64 -lbrotlidec -lbrotlienc -lbrotlicommon"
                /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                ./configure \
                --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config \
                --with-brotli-dir=/usr/local/brotli \
                --with-openssl-dir=/usr/local/openssl \
                --enable-http2  \
                --enable-openssl \
                --enable-sockets \
                --enable-mysqlnd
                make -j8 && make install
                if ! ldd /usr/local/${VARI_GLOBAL["BIN_NAME"]}/lib/extensions/no-debug-non-zts-20230831/swoole.so | grep brotli > /dev/null; then
                    echo "swoole is not linked brotli"
                    return 1
                fi
                export CFLAGS="${variOldcflags}"
                export LDFLAGS="${variOldldflags}"
                echo 'extension = swoole.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
            }
            {
                # amqp[start]
                # rabbitmq-c : https://github.com/alanxz/rabbitmq-c/releases
                # amqp : http://pecl.php.net/package/amqp
                variExtensionInstallResult["amqp"]="amqp"
                # latest : rabbitmq-c-0.14.0.tar.gz（need : cmake 3.22）
                rm -rf /usr/local/src/rabbitmq-c-0.13.0
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf rabbitmq-c-0.13.0.tar.gz -C /usr/local/src && cd /usr/local/src/rabbitmq-c-0.13.0
                mkdir build && cd build
                cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/rabbitmq-c -DOPENSSL_ROOT_DIR=/usr/local/openssl -DOPENSSL_LIBRARIES=/usr/local/openssl/lib -DOPENSSL_INCLUDE_DIR=/usr/local/openssl/include
                cmake --build . --target install
                # echo '/usr/local/rabbitmq-c/lib64/' >> /etc/ld.so.conf
                # ldconfig -v
                ln -sf /usr/local/rabbitmq-c/lib64/ /usr/local/rabbitmq-c/lib
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf amqp-2.1.2.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/amqp-2.1.2
                /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                ./configure \
                --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config \
                --with-librabbitmq-dir=/usr/local/rabbitmq-c \
                --with-amqp
                make -j8 && make install
                echo 'extension = amqp.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
            }
            {
                # yaml[START]
                variExtensionInstallResult["yaml"]="yaml"
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf yaml-2.2.3.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/yaml-2.2.3
                /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                ./configure \
                --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config
                make -j8 && make install
                echo 'extension = yaml.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
            }
            {
                # geoip[START]
                # ip database file : /usr/share/GeoIP
                variExtensionInstallResult["geoip"]="geoip"
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf geoip-1.1.1.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/geoip-1.1.1
                # 「PHP7+」安全機制已調整至 ：不再需要{TSRMLS_CC && TSRMLS_DC}
                sed -i 's/ TSRMLS_CC//g' geoip.c
                sed -i 's/ TSRMLS_DC//g' geoip.c
                /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                ./configure \
                --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config
                make -j8 && make install
                echo 'extension = geoip.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
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
                  make -j8 && make install
                  echo 'extension = inotify.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                fi
            }
            {
                # xdebug[START]
                if [[ ${variXdebugButton:-false} == true ]]; then
                  variExtensionInstallResult["xdebug"]="xdebug"
                  cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf xdebug-3.3.2.tgz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]} && cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/xdebug-3.3.2
                  /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                  ./configure \
                  --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config \
                  --enable-xdebug
                  make -j8 && make install
                  echo 'zend_extension = xdebug.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
                fi
            }
            {
                # sodium[START]
                # 加密算法
                variExtensionInstallResult["sodium"]="sodium"
                # 安裝依賴 : libsodium
                # 編譯報錯 ：libtool: warning: '-version-info/-version-number' is ignored for convenience libraries || /usr/include/features.h:330:4: warning: #warning _FORTIFY_SOURCE requires compiling with optimization (-O) [-Wcpp] || 330 | #  warning _FORTIFY_SOURCE requires compiling with optimization (-O)
                # 解決方法 ：可以忽略
                # https://download.libsodium.org/libsodium/releases
                cd ${VARI_GLOBAL["BUILTIN_UNIT_CLOUD_PATH"]} && tar -xvf libsodium-1.0.20-stable.tar.gz -C /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}
                mv /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/libsodium-stable /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/libsodium-1.0.20
                cd /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}/libsodium-1.0.20
                #使用「--prefix=/usr/local」，則安装至 ：/usr/local/include/sodium
                local variOldcflags=${CFLAGS}
                local variOldCxxflags=${CXXFLAGS}
                export CFLAGS="-O2"
                export CXXFLAGS="-O2"
                ./configure --prefix=/usr/local
                make -j8 && make install
                cd /usr/local/src/php-8.3.12/ext/sodium
                /usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/phpize
                ./configure \
                --with-php-config=/usr/local/${VARI_GLOBAL["BIN_NAME"]}/bin/php-config
                make -j8 && make install
                export CFLAGS="${variOldcflags}"
                export CXXFLAGS="${variOldCxxflags}"
                echo 'extension = sodium.so;' >> /usr/local/${VARI_GLOBAL["BIN_NAME"]}/etc/php.ini
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
                # swoole >= 5.0 &&「echo swoole.use_shortname = 'Off' >> php.ini」
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
            cp composer.phar /usr/local/bin/composer
            chmod +x /usr/local/bin/composer
            # 關閉提示：Continue as root/super user [yes]?
            echo "export COMPOSER_ALLOW_SUPERUSER=1" >> /etc/bashrc
            source /etc/bashrc
            composer --version >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
            # composer[END]
            composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
            # composer config --global --auth github-oauth.github.com ${token1}
            # composer update --prefer-source
          }
        }
    fi
    # --------------------------------------------------
    echo "${FUNCNAME} finished" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
    # --------------------------------------------------
    return 0
}

function funcProtected8312Destruct(){
  rm -rf /usr/local/src/php-8.3.12 /usr/local/src/extension/${VARI_GLOBAL["BIN_NAME"]}
  return 0
}
# protected function[END]
# ##################################################

# ##################################################
# public function[START]
function funcPublic8312EnvironmentInit(){
  funcProtected8312CloudInit
  funcProtected8312LocalInit
  funcProtected8312Main
  funcProtected8312Destruct
  return 0
}

function funcPublicRebuildImage(){
  # 構建鏡像[START]
  variParameterDescList=("image pattern（example ：chunio/php:8312）")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=$1
  docker rm -f ${VARI_GLOBAL["CONTAINER_NAME"]} 2> /dev/null
  # 當本地鏡像不存在時，則自動執行 ：docker pull $variImageName（from : hub.docker.com）
  #「-v /sys/fs/cgroup:/sys/fs/cgroup:ro --tmpfs /run --tmpfs /run/lock」表示支持「systemctl」
  docker run -d --privileged --name ${VARI_GLOBAL["CONTAINER_NAME"]} -v /windows:/windows -v /sys/fs/cgroup:/sys/fs/cgroup:ro --tmpfs /run --tmpfs /run/lock centos:7.9.2009 /sbin/init
  # 執行命令，並停留至遠端窗口
  # docker exec -it php8312 /bin/bash -c "cd /windows/code/backend/chunio/automatic/docker/php && ./php.sh funcPublicBuiltinMain; exec /bin/bash" 
  docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash -c "cd ${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]} && ./$(basename ${VARI_GLOBAL["BUILTIN_UNIT_FILENAME"]}) 8312EnvironmentInit;"
  variContainerId=$(docker ps --filter "name=${VARI_GLOBAL["CONTAINER_NAME"]}" --format "{{.ID}}")
  echo "docker commit ${variContainerId} ${variImagePattern} ..."
  docker commit ${variContainerId} ${variImagePattern}
  docker ps --filter "name=${VARI_GLOBAL["CONTAINER_NAME"]}"
  docker images --filter "reference=${variImagePattern}"
  echo "${FUNCNAME} ${VARI_GLOBAL["SUCCESS_LABEL"]}" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  echo "docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash" >> ${VARI_GLOBAL["BUILTIN_UNIT_TRACE_URI"]}
  return 0
}

function funcPublicReleaseImage(){
  variParameterDescList=("image pattern（example：chunio/php:8312）")
  funcProtectedCheckRequiredParameter 1 variParameterDescList[@] $# || return ${VARI_GLOBAL["BUILTIN_SUCCESS_CODE"]}
  variImagePattern=${1}
  omni.docker releaseImage $variImagePattern
  return 0
}

function funcPublicExec(){
  if ! docker ps | grep -q "${VARI_GLOBAL["CONTAINER_NAME"]}"; then
    mkdir -p /windows
    docker stop ${VARI_GLOBAL["CONTAINER_NAME"]} 2> /dev/null || true
    docker rm -f ${VARI_GLOBAL["CONTAINER_NAME"]} 2> /dev/null || true
    docker run -d --privileged --name ${VARI_GLOBAL["CONTAINER_NAME"]} -v /windows:/windows -v /sys/fs/cgroup:/sys/fs/cgroup:ro --tmpfs /run --tmpfs /run/lock -p 9501:9501 chunio/php:8312 /sbin/init
  fi
  docker exec -it ${VARI_GLOBAL["CONTAINER_NAME"]} /bin/bash -c "cd /windows/code/backend/haohaiyou/gopath/src/skeleton; exec /bin/bash"
  return 0
}

# public function[END]
# ##################################################

source "${VARI_GLOBAL["BUILTIN_UNIT_ROOT_PATH"]}/../../include/workflow/workflow.sh"