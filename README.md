# Omni

## System Dependency

```
linux : centos 7.9 , ubuntu 24.04
darwin : macos 26.4.1
```

## Install Wizard

```shell
# linux[START]
mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
[ -f /etc/redhat-release ] && yum install -y git
[ -f /etc/debian_version ] && apt-get update && apt-get install -y git
git clone https://github.com/chunio/omni.git && chmod -R 777 ./omni
sudo -i # ubuntu
./omni/init/system/system.sh init 1
# linux[END]

# darwin[START]
mkdir -p /Users/zengweitao/archived/workspace/repository/chunio && cd /Users/zengweitao/archived/workspace/repository/chunio
export http_proxy=http://192.168.3.132:7897 # ifconfig | grep inet
export https_proxy=http://192.168.3.132:7897 # ifconfig | grep inet
xcode-select --install # 交互安裝
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # 交互安裝
echo >> /Users/zengweitao/.zshrc # 確保換行
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/zengweitao/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install bash
rehash # 重置命令路徑緩存
git clone https://github.com/chunio/omni.git
find ./omni -type f -name "*.sh" ! -path "*/.git/*" -exec chmod +x {} \;
chmod -R 777 ./omni
./omni/init/system/system.sh init 1
# darwin[END]
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