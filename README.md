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



