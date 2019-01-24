# Kubernetes Dashboard

## 创建Dashboard
 
  需要CoreDNS部署成功之后再安装Dashboard。
```
[root@linux-node1 ~]# kubectl create -f /srv/addons/dashboard/
[root@linux-node1 ~]# kubectl cluster-info
Kubernetes master is running at https://172.18.1.11:6443
kubernetes-dashboard is running at https://172.18.1.11:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

```
## 访问Dashboard

  https://172.18.1.11:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy

用户名:admin  密码：admin 选择Token令牌模式登录。

### 获取Token
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```
