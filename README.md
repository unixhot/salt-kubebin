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
k8s-master:
  host: 192.168.56.20
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: master
      etcd-role: node
      etcd-name: etcd-node1

k8s-node1:
  host: 192.168.56.21
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: node
      etcd-role: node
      etcd-name: etcd-node2

k8s-node2:
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

```

## 5.执行SaltStack状态
```
[root@linux-node1 ~]# salt-ssh '*' state.highstate
```
