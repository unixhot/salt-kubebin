
# 手动部署ETCD集群

## 0.准备etcd软件包
```
wget https://github.com/coreos/etcd/releases/download/v3.2.18/etcd-v3.2.18-linux-amd64.tar.gz
[root@linux-node1 src]# tar zxf etcd-v3.2.18-linux-amd64.tar.gz
[root@linux-node1 src]# cd etcd-v3.2.18-linux-amd64
[root@linux-node1 etcd-v3.2.18-linux-amd64]# cp etcd etcdctl /opt/kubernetes/bin/ 
[root@linux-node1 etcd-v3.2.18-linux-amd64]# scp etcd etcdctl 192.168.56.12:/opt/kubernetes/bin/
[root@linux-node1 etcd-v3.2.18-linux-amd64]# scp etcd etcdctl 192.168.56.13:/opt/kubernetes/bin/
```


## 1.创建 etcd 证书签名请求：
```
 [root@linux-node1 ~]# vim etcd-csr.json
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
"192.168.56.11",
"192.168.56.12",
"192.168.56.13"
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

## 2.生成 etcd 证书和私钥：
```
[root@linux-node1 ~]# cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem \
  -ca-key=/opt/kubernetes/ssl/ca-key.pem \
  -config=/opt/kubernetes/ssl/ca-config.json \
  -profile=kubernetes etcd-csr.json | cfssljson -bare etcd
会生成以下证书文件
[root@k8s-master ~]# ls -l etcd*
-rw-r--r-- 1 root root 1045 Mar  5 11:27 etcd.csr
-rw-r--r-- 1 root root  257 Mar  5 11:25 etcd-csr.json
-rw------- 1 root root 1679 Mar  5 11:27 etcd-key.pem
-rw-r--r-- 1 root root 1419 Mar  5 11:27 etcd.pem
```

## 3.将证书移动到/opt/kubernetes/ssl目录下
```
[root@k8s-master ~]# cp etcd*.pem /opt/kubernetes/ssl
[root@linux-node1 ~]# scp etcd*.pem 192.168.56.12:/opt/kubernetes/ssl
[root@linux-node1 ~]# scp etcd*.pem 192.168.56.13:/opt/kubernetes/ssl
[root@k8s-master ~]# rm -f etcd.csr etcd-csr.json
```

## 4.设置ETCD配置文件
```
[root@linux-node1 ~]# vim /opt/kubernetes/cfg/etcd.conf
#[member]
ETCD_NAME="etcd-node1"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_SNAPSHOT_COUNTER="10000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
ETCD_LISTEN_PEER_URLS="https://192.168.56.11:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.56.11:2379,https://127.0.0.1:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.56.11:2380"
# if you use different ETCD_NAME (e.g. test),
# set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="etcd-node1=https://192.168.56.11:2380,etcd-node2=https://192.168.56.12:2380,etcd-node3=https://192.168.56.13:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.56.11:2379"
#[security]
CLIENT_CERT_AUTH="true"
ETCD_CA_FILE="/opt/kubernetes/ssl/ca.pem"
ETCD_CERT_FILE="/opt/kubernetes/ssl/etcd.pem"
ETCD_KEY_FILE="/opt/kubernetes/ssl/etcd-key.pem"
PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_CA_FILE="/opt/kubernetes/ssl/ca.pem"
ETCD_PEER_CERT_FILE="/opt/kubernetes/ssl/etcd.pem"
ETCD_PEER_KEY_FILE="/opt/kubernetes/ssl/etcd-key.pem"
```

## 5.创建ETCD系统服务
```
[root@linux-node1 ~]# vim /etc/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/etcd
EnvironmentFile=-/opt/kubernetes/cfg/etcd.conf
# set GOMAXPROCS to number of processors
ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /opt/kubernetes/bin/etcd"
Type=notify

[Install]
WantedBy=multi-user.target
```

## 6.重新加载系统服务
```
[root@linux-node1 ~]# systemctl daemon-reload
[root@linux-node1 ~]# systemctl enable etcd


# scp /opt/kubernetes/cfg/etcd.conf 192.168.56.12:/opt/kubernetes/cfg/
# scp /etc/systemd/system/etcd.service 192.168.56.12:/etc/systemd/system/
# scp /opt/kubernetes/cfg/etcd.conf 192.168.56.13:/opt/kubernetes/cfg/
# scp /etc/systemd/system/etcd.service 192.168.56.13:/etc/systemd/system/
在所有节点上创建etcd存储目录并启动etcd
[root@linux-node1 ~]# mkdir /var/lib/etcd
[root@linux-node1 ~]# systemctl start etcd
[root@linux-node1 ~]# systemctl status etcd
```
下面需要大家在所有的 etcd 节点重复上面的步骤，直到所有机器的 etcd 服务都已启动。

## 7.验证集群
```
[root@linux-node1 ~]# etcdctl --endpoints=https://192.168.56.11:2379 \
  --ca-file=/opt/kubernetes/ssl/ca.pem \
  --cert-file=/opt/kubernetes/ssl/etcd.pem \
  --key-file=/opt/kubernetes/ssl/etcd-key.pem cluster-health
member 435fb0a8da627a4c is healthy: got healthy result from https://192.168.56.12:2379
member 6566e06d7343e1bb is healthy: got healthy result from https://192.168.56.11:2379
member ce7b884e428b6c8c is healthy: got healthy result from https://192.168.56.13:2379
cluster is healthy
```
