# Omni

## System Dependency

```
centos 7.9
ubuntu 24.04
```

## Install Wizard

```
[root@localhost /]# mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
[root@localhost /]# [ -f /etc/redhat-release ] && yum install -y git
[root@localhost /]# [ -f /etc/debian_version ] && apt-get update && apt-get install -y git
[root@localhost /]# git clone https://github.com/chunio/omni.git && chmod -R 777 ./omni
[root@localhost /]# ./omni/init/system/system.sh init

[root@macos /]# mkdir -p /Users/zengweitao/archived/workspace/repository/chunio && cd /Users/zengweitao/archived/workspace/repository/chunio
[root@macos /]# xcode-select --install # 交互安裝
[root@macos /]# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
[root@macos /]# brew install bash
[root@macos /]# echo >> /Users/zengweitao/.zshrc # 確保換行
[root@macos /]# echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/zengweitao/.zshrc
[root@macos /]# eval "$(/opt/homebrew/bin/brew shellenv)"
[root@macos /]# rehash # 重置命令路徑緩存
[root@macos /]# git clone https://github.com/chunio/omni.git
[root@macos /]# find ./omni -type f -name "*.sh" ! -path "*/.git/*" -exec chmod +x {} \;
[root@macos /]# ./omni/init/system/system.sh init
```

## New Unit

```
[root@localhost /]# omni.system newUnit example
[root@localhost /]# # [unit]funcPublicXXXX is only for external call and internal call are prohibited
```

## Directory Structure

```
omni
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
├── include
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
│   └── workflow
│   │   ├── cloud
│   │   ├── runtime
│   │   ├── encrypt.envi
│   |   └── workflow.sh
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