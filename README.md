# salt-kubernetes
SaltStack自动化部署Kubernetes v1.9.3版本（支持TLS 双向认证、RBAC 授权、ETCD集群等）

## 版本明细：Release-v1.0

- 测试通过系统：CentOS 7.4
- salt-ssh: 2017.7.4
- Kubernetes： v1.9.3
- Etcd: v3.3.1
- Docker: 17.12.1-ce
- CNI-Plugins： v0.7.0

请注意，请使用2017.7.4或者以上版本的Salt SSH。


建议部署节点：最少三个节点，请配置好主机名解析

## 架构介绍

1. 使用Salt Grains进行角色定义，增加灵活性。
2. 使用Salt Pillar进行配置项管理，保证安全性。
3. 使用Salt SSH执行状态，不需要安装Agent，保证通用性。
4. 使用Kubernetes当前稳定版本v1.9.3，保证稳定性。

## 技术交流QQ群（加群请备注来源于Github）：
- 自动化运维工程师：439084446
- 云计算与容器架构师：252370310
- 运维开发工程师：399033250

# 使用手册

## 1.设置部署节点到其它所有节点的SSH免密码登录（包括本机）
```
[root@linux-node1 ~]# ssh-keygen -t rsa
[root@linux-node1 ~]# ssh-copy-id linux-node1
[root@linux-node1 ~]# ssh-copy-id linux-node2
[root@linux-node1 ~]# ssh-copy-id linux-node3
```

安装Docker-ce
```
[root@linux-node1 ~]# yum install -y docker-ce
```

## 2.安装Salt-SSH并克隆本项目代码。

1. 安装Salt SSH
```
[root@linux-node1 ~]# yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm 
[root@linux-node1 ~]# yum install -y salt-ssh
```

2. 获取本项目代码，并放置在/srv目录
```
[root@linux-node1 ~]# cd /srv/
[root@linux-node1 srv]# git clone git@github.com:unixhot/salt-kubernetes.git
[root@linux-node1 srv]# cd salt-kubernetes/
[root@linux-node1 srv]# mv * /srv/
[root@linux-node1 srv]# cp roster /etc/salt/roster
[root@linux-node1 srv]# cp master /etc/salt/master
```

3.下载二进制文件，也可以自行官方下载，为了方便国内用户访问，请在百度云盘下载，下载完成后，将文件解压到/srv/salt/k8s/files目录下。
Kubernetes二进制文件下载地址： https://pan.baidu.com/s/1zs8sCouDeCQJ9lghH1BPiw

```
[root@linux-node1 ~]# cd /srv/salt/k8s/files/
[root@linux-node1 files]# ls -l
total 161760
drwxr-xr-x 2 root root        94 Mar 28 00:33 cfssl-1.2
drwxrwxr-x 2 root root       195 Mar 27 23:15 cni-plugins-amd64-v0.7.0
drwxr-xr-x 2 root root        33 Mar 28 00:33 etcd-v3.3.1-linux-amd64
drwxr-xr-x 3 root root        17 Mar 28 00:47 k8s-v1.9.3
```

## 3.Salt SSH管理的机器以及角色分配

- k8s-role: 用来设置K8S的角色
- etcd-role: 用来设置etcd的角色，如果只需要部署一个etcd，只需要在一台机器上设置即可
- etcd-name: 如果对一台机器设置了etcd-role就必须设置etcd-name

```
[root@linux-node1 ~]# vim /etc/salt/roster 
linux-node1:
  host: 192.168.56.20
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: master
      etcd-role: node
      etcd-name: etcd-node1

linux-node2:
  host: 192.168.56.21
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: node
      etcd-role: node
      etcd-name: etcd-node2

linux-node3:
  host: 192.168.56.22
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: node
      etcd-role: node
      etcd-name: etcd-node3
```

## 4.修改对应的配置参数，本项目使用Salt Pillar保存配置
```
[root@linux-node1 ~]# vim /srv/pillar/k8s.sls
#设置Master的IP地址(必须修改)
MASTER_IP: "192.168.56.20"

#设置ETCD集群访问地址（必须修改）
ETCD_ENDPOINTS: "https://192.168.56.20:2379,https://192.168.56.21:2379,https://192.168.56.22:2379"

#设置ETCD集群初始化列表（必须修改）
ETCD_CLUSTER: "etcd-node1=https://192.168.56.20:2380,etcd-node2=https://192.168.56.21:2380,etcd-node3=https://192.168.56.22:2380"

#通过Grains FQDN自动获取本机IP地址，请注意保证主机名解析到本机IP地址
NODE_IP: {{ grains['fqdn_ip4'][0] }}

#设置BOOTSTARP的TOKEN，可以自己生成
BOOTSTRAP_TOKEN: "ad6d5bb607a186796d8861557df0d17f"

#配置Service IP地址段
SERVICE_CIDR: "10.1.0.0/16"

#Kubernetes服务 IP (从 SERVICE_CIDR 中预分配)
CLUSTER_KUBERNETES_SVC_IP: "10.1.0.1"

#Kubernetes DNS 服务 IP (从 SERVICE_CIDR 中预分配)
CLUSTER_DNS_SVC_IP: "10.1.0.2"

#设置Node Port的端口范围
NODE_PORT_RANGE: "20000-40000"



#设置POD的IP地址段
POD_CIDR: "10.2.0.0/16"



#设置集群的DNS域名
CLUSTER_DNS_DOMAIN: "cluster.local."

```



## 6.执行SaltStack状态
```
测试Salt SSH联通性
[root@linux-node1 ~]# salt-ssh '*' state.highstate

执行高级状态，会根据定义的角色再对应的机器部署对应的服务
[root@linux-node1 ~]# salt-ssh '*' state.highstate
```

## 7.如何新增Kubernetes节点

- 1.设置SSH无密码登录
- 2.在/etc/salt/roster里面，增加对应的机器
- 3.执行SaltStack状态salt-ssh '*' state.highstate。
```
[root@linux-node1 ~]# vim /etc/salt/roster 
linux-node4:
  host: 192.168.56.23
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: node
```
