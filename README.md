# salt-kubernetes
SaltStack自动化部署Kubernetes

## 1.设置部署节点到其它所有节点的SSH免密码登录（包括本机）



## 2.Salt SSH管理的机器以及角色分配
    - k8s-role: 用来设置K8S的角色
    - etcd-role: 用来设置etcd的角色，如果只需要部署一个etcd，只需要在一台机器上设置即可
    - etcd-name: 如果对一台机器设置了etcd-role就必须设置etcd-name

```
[root@k8s-master ~]# vim /etc/salt/roster 
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

## 3.克隆本项目代码，并执行SaltStack状态。
