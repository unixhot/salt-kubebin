# salt-kubernetes
SaltStack自动化部署Kubernetes v1.9.3版本（支持TLS 双向认证、RBAC 授权、ETCD集群等）

版本明细：Release-v1.0

- Kubernetes： v1.9.3
- Etcd: v3.3.1
- Docker: 17.12.1-ce

建议部署节点：最少三个节点，请配置好主机名解析

## 1.设置部署节点到其它所有节点的SSH免密码登录（包括本机）
```
[root@linux-node1 ~]# ssh-keygen -t rsa
[root@linux-node1 ~]# ssh-copy-id linux-node1
[root@linux-node1 ~]# ssh-copy-id linux-node2
[root@linux-node1 ~]# ssh-copy-id linux-node3
```

## 2.Salt SSH管理的机器以及角色分配

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

## 3.安装Salt-SSH并设置文件路径。
```
[root@linux-node1 ~]# yum install -y salt-ssh
[root@linux-node1 ~]# vim /etc/salt/master
file_roots:
  base:
    - /srv/salt
pillar_roots:
  base:
    - /srv/pillar
```

## 4.修改对应的配置参数，本项目使用Salt Pillar保存配置
```
[root@linux-node1 ~]# vim /srv/pillar/k8s.sls
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

#设置ETCD集群访问地址
ETCD_ENDPOINTS: "https://192.168.56.20:2379,https://192.168.56.21:2379,https://192.168.56.22:2379"

#设置ETCD集群初始化列表
ETCD_CLUSTER: "etcd-node1=https://192.168.56.20:2380,etcd-node2=https://192.168.56.21:2380,etcd-node3=https://192.168.56.22:2380"

#设置POD的IP地址段
POD_CIDR: "10.2.0.0/16"

#设置Master的IP地址
MASTER_IP: "192.168.56.20"

#设置集群的DNS域名
CLUSTER_DNS_DOMAIN: "cluster.local."

```

## 5.执行SaltStack状态
```
[root@linux-node1 ~]# salt-ssh '*' state.highstate
```
