## 1.部署Kubernetes API服务部署
### 0.准备软件包
```
[root@linux-node1 ~]# cd /usr/local/src/kubernetes
[root@linux-node1 kubernetes]# cp server/bin/kube-apiserver /opt/kubernetes/bin/
[root@linux-node1 kubernetes]# cp server/bin/kube-controller-manager /opt/kubernetes/bin/
[root@linux-node1 kubernetes]# cp server/bin/kube-scheduler /opt/kubernetes/bin/
```

### 1.创建生成CSR的 JSON 配置文件
```
[root@linux-node1 src]# vim kubernetes-csr.json
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "192.168.56.11",
    "10.1.0.1",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
```

### 2.生成 kubernetes 证书和私钥
```
 [root@linux-node1 src]# cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem \
   -ca-key=/opt/kubernetes/ssl/ca-key.pem \
   -config=/opt/kubernetes/ssl/ca-config.json \
   -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
[root@linux-node1 src]# cp kubernetes*.pem /opt/kubernetes/ssl/
[root@linux-node1 ~]# scp kubernetes*.pem 192.168.56.12:/opt/kubernetes/ssl/
[root@linux-node1 ~]# scp kubernetes*.pem 192.168.56.13:/opt/kubernetes/ssl/
```

### 3.创建 kube-apiserver 使用的客户端 token 文件
```
[root@linux-node1 ~]#  head -c 16 /dev/urandom | od -An -t x | tr -d ' '
ad6d5bb607a186796d8861557df0d17f 
[root@linux-node1 ~]# vim /opt/kubernetes/ssl/ bootstrap-token.csv
ad6d5bb607a186796d8861557df0d17f,kubelet-bootstrap,10001,"system:kubelet-bootstrap"
```

### 4.创建基础用户名/密码认证配置
```
[root@linux-node1 ~]# vim /opt/kubernetes/ssl/basic-auth.csv
admin,admin,1
readonly,readonly,2
```

### 5.部署Kubernetes API Server
```
[root@linux-node1 ~]# vim /usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
ExecStart=/opt/kubernetes/bin/kube-apiserver \
  --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota,NodeRestriction \
  --bind-address=192.168.56.11 \
  --insecure-bind-address=127.0.0.1 \
  --authorization-mode=Node,RBAC \
  --runtime-config=rbac.authorization.k8s.io/v1 \
  --kubelet-https=true \
  --anonymous-auth=false \
  --basic-auth-file=/opt/kubernetes/ssl/basic-auth.csv \
  --enable-bootstrap-token-auth \
  --token-auth-file=/opt/kubernetes/ssl/bootstrap-token.csv \
  --service-cluster-ip-range=10.1.0.0/16 \
  --service-node-port-range=20000-40000 \
  --tls-cert-file=/opt/kubernetes/ssl/kubernetes.pem \
  --tls-private-key-file=/opt/kubernetes/ssl/kubernetes-key.pem \
  --client-ca-file=/opt/kubernetes/ssl/ca.pem \
  --service-account-key-file=/opt/kubernetes/ssl/ca-key.pem \
  --etcd-cafile=/opt/kubernetes/ssl/ca.pem \
  --etcd-certfile=/opt/kubernetes/ssl/kubernetes.pem \
  --etcd-keyfile=/opt/kubernetes/ssl/kubernetes-key.pem \
  --etcd-servers=https://192.168.56.11:2379,https://192.168.56.12:2379,https://192.168.56.13:2379 \
  --enable-swagger-ui=true \
  --allow-privileged=true \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/opt/kubernetes/log/api-audit.log \
  --event-ttl=1h \
  --v=2 \
  --logtostderr=false \
  --log-dir=/opt/kubernetes/log
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### 6.启动API Server服务
```
[root@linux-node1 ~]# systemctl daemon-reload
[root@linux-node1 ~]# systemctl enable kube-apiserver
[root@linux-node1 ~]# systemctl start kube-apiserver
```

查看API Server服务状态
```
[root@linux-node1 ~]# systemctl status kube-apiserver
```

## 部署Controller Manager服务
```
[root@linux-node1 ~]# vim /usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/opt/kubernetes/bin/kube-controller-manager \
  --address=127.0.0.1 \
  --master=http://127.0.0.1:8080 \
  --allocate-node-cidrs=true \
  --service-cluster-ip-range=10.1.0.0/16 \
  --cluster-cidr=10.2.0.0/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/opt/kubernetes/ssl/ca.pem \
  --cluster-signing-key-file=/opt/kubernetes/ssl/ca-key.pem \
  --service-account-private-key-file=/opt/kubernetes/ssl/ca-key.pem \
  --root-ca-file=/opt/kubernetes/ssl/ca.pem \
  --leader-elect=true \
  --v=2 \
  --logtostderr=false \
  --log-dir=/opt/kubernetes/log

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 3.启动Controller Manager
```
[root@linux-node1 ~]# systemctl daemon-reload
[root@linux-node1 scripts]# systemctl enable kube-controller-manager
[root@linux-node1 scripts]# systemctl start kube-controller-manager
```

## 4.查看服务状态
```
[root@linux-node1 scripts]# systemctl status kube-controller-manager
```

## 部署Kubernetes Scheduler
```
[root@linux-node1 ~]# vim /usr/lib/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/opt/kubernetes/bin/kube-scheduler \
  --address=127.0.0.1 \
  --master=http://127.0.0.1:8080 \
  --leader-elect=true \
  --v=2 \
  --logtostderr=false \
  --log-dir=/opt/kubernetes/log

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 2.部署服务
```
[root@linux-node1 ~]# systemctl daemon-reload
[root@linux-node1 scripts]# systemctl enable kube-scheduler
[root@linux-node1 scripts]# systemctl start kube-scheduler
[root@linux-node1 scripts]# systemctl status kube-scheduler
```

## 部署kubectl 命令行工具

1.准备二进制命令包
```
[root@linux-node1 ~]# cd /usr/local/src/kubernetes/client/bin
[root@linux-node1 bin]# cp kubectl /opt/kubernetes/bin/
```

2.创建 admin 证书签名请求
```
[root@linux-node1 ~]# cd /usr/local/src/ssl/
[root@linux-node1 ssl]# vim admin-csr.json
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
```

3.生成 admin 证书和私钥：
```
[root@linux-node1 ssl]# cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem \
   -ca-key=/opt/kubernetes/ssl/ca-key.pem \
   -config=/opt/kubernetes/ssl/ca-config.json \
   -profile=kubernetes admin-csr.json | cfssljson -bare admin
[root@linux-node1 ssl]# ls -l admin*
-rw-r--r-- 1 root root 1009 Mar  5 12:29 admin.csr
-rw-r--r-- 1 root root  229 Mar  5 12:28 admin-csr.json
-rw------- 1 root root 1675 Mar  5 12:29 admin-key.pem
-rw-r--r-- 1 root root 1399 Mar  5 12:29 admin.pem

[root@linux-node1 src]# mv admin*.pem /opt/kubernetes/ssl/
```

4.设置集群参数
```
[root@linux-node1 src]# kubectl config set-cluster kubernetes \
   --certificate-authority=/opt/kubernetes/ssl/ca.pem \
   --embed-certs=true \
   --server=https://192.168.56.11:6443
Cluster "kubernetes" set.
```

5.设置客户端认证参数
```
[root@linux-node1 src]# kubectl config set-credentials admin \
   --client-certificate=/opt/kubernetes/ssl/admin.pem \
   --embed-certs=true \
   --client-key=/opt/kubernetes/ssl/admin-key.pem
User "admin" set.
```

6.设置上下文参数
```
[root@linux-node1 src]# kubectl config set-context kubernetes \
   --cluster=kubernetes \
   --user=admin
Context "kubernetes" created.
```

7.设置默认上下文
```
[root@linux-node1 src]# kubectl config use-context kubernetes
Switched to context "kubernetes".
```

8.使用kubectl工具
```
[root@linux-node1 ~]# kubectl get cs
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-1               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"}   
etcd-0               Healthy   {"health":"true"}   
```
