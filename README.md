## Omni
#### Installation
```
[root@localhost /]# git clone https://github.com/chunio/omni.git
[root@localhost /]# ./omni/init/system/system.sh init && source /etc/bashrc
[root@localhost /]# omni.system init
```
#### New Module
```
1[root@localhost /]# cp -rf ./omni/init/template ./omni/module/example
2[root@localhost /]# mv ./omni/module/example/template.sh ./omni/module/example/example.sh
3[root@localhost /]# vim ./omni/module/example/example.sh
```
#### Directory Structure
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
├── a000ac7b2867e2e68319b20d58e8203b.omni
├── README.md
└── .gitignore
```

#### Common Symbol
```
「」
```

