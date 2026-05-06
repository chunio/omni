# Omni

## System Dependency

```
linux : centos 7.9 , ubuntu 24.04
darwin : macos 26.4.1
```

## Install Wizard

```
[root@linux /]# # linux[START]
[root@linux /]# mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
[root@linux /]# [ -f /etc/redhat-release ] && yum install -y git
[root@linux /]# [ -f /etc/debian_version ] && apt-get update && apt-get install -y git
[root@linux /]# git clone https://github.com/chunio/omni.git && chmod -R 777 ./omni
[root@linux /]# ./omni/init/system/system.sh init
[root@linux /]# # linux[END]

[root@darwin /]# # darwin[START]
[root@darwin /]# mkdir -p /Users/zengweitao/archived/workspace/repository/chunio && cd /Users/zengweitao/archived/workspace/repository/chunio
[root@darwin /]# export http_proxy=http://192.168.3.163:7897 # ifconfig | grep inet
[root@darwin /]# export https_proxy=http://192.168.3.163:7897 # ifconfig | grep inet
[root@darwin /]# xcode-select --install # 交互安裝
[root@darwin /]# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # 交互安裝
[root@darwin /]# echo >> /Users/zengweitao/.zshrc # 確保換行
[root@darwin /]# echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/zengweitao/.zshrc
[root@darwin /]# eval "$(/opt/homebrew/bin/brew shellenv)"
[root@darwin /]# brew install bash
[root@darwin /]# rehash # 重置命令路徑緩存
[root@darwin /]# git clone https://github.com/chunio/omni.git
[root@darwin /]# find ./omni -type f -name "*.sh" ! -path "*/.git/*" -exec chmod +x {} \;
[root@darwin /]# chmod -R 777 ./omni
[root@darwin /]# ./omni/init/system/system.sh init
[root@darwin /]# # darwin[END]
```

## New Unit

```
[root@localhost /]# omni.system newUnit example
[root@localhost /]# # [unit]funcPublicXXXX is only for external call and internal call are prohibited
```

## Directory Structure

```
omni
├── init
│   ├── system
│   │   ├── cloud
│   │   ├── runtime
│   │   ├── encrypt.envi
│   │   └── system.sh
│   └── template
│   │   ├── cloud
│   │   ├── runtime
│   │   ├── encrypt.envi
│   |   └── template.sh
├── internal
│   └── orchestrator
│   │   ├── cloud
│   │   ├── runtime
│   │   ├── encrypt.envi
│   |   └── orchestrator.sh
│   ├── builtin
│   │   ├── cloud
│   │   ├── runtime
│   │   ├── encrypt.envi
│   │   └── builtin.sh
│   ├── utility
│   │   ├── cloud
│   │   ├── runtime
│   │   ├── encrypt.envi
│   │   └── utility.sh
├── common
│   ├── docker
│   │   ├── cloud
│   │   ├── runtime
│   │   ├── encrypt.envi
│   │   └── docker.sh
│   └── qiniu
│   │   ├── cloud
│   │   ├── runtime
│   │   ├── encrypt.envi
│   |   └── qiniu.sh
├── module
│   └── unit
│       ├── cloud
│       ├── runtime
│       ├── encrypt.envi
│       └── unit.sh
├── README.md
└── .gitignore
```

## Common Symbol

```
「」
```