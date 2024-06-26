# Omni
## Installation
```
[root@localhost /]# mkdir -p /windows/code/backend/chunio && cd /windows/code/backend/chunio
[root@localhost /]# git clone https://github.com/chunio/omni.git
[root@localhost /]# cd ./omni && chmod 777 -R . && ./init/system/system.sh init && source /etc/bashrc
[root@localhost /]# omni.system version
```
## New Unit
```
[root@localhost /]# omni.system newUnit example
[root@localhost /]# # [unit]公共函數僅適用於外部調用，並且禁止內部調用
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



