# 手动制作CA证书

## 1.安装 CFSSL
```
[root@linux-node1 ~]# cd /usr/local/src
[root@linux-node1 src]# wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
[root@linux-node1 src]# wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
[root@linux-node1 src]# wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
[root@linux-node1 src]# chmod +x cfssl*
[root@linux-node1 src]# mv cfssl-certinfo_linux-amd64 /opt/kubernetes/bin/cfssl-certinfo
[root@linux-node1 src]# mv cfssljson_linux-amd64  /opt/kubernetes/bin/cfssljson
[root@linux-node1 src]# mv cfssl_linux-amd64  /opt/kubernetes/bin/cfssl
复制cfssl命令文件到k8s-node1和k8s-node2节点。如果实际中多个节点，就都需要同步复制。
[root@linux-node1 ~]# scp /opt/kubernetes/bin/cfssl* 192.168.56.12: /opt/kubernetes/bin
[root@linux-node1 ~]# scp /opt/kubernetes/bin/cfssl* 192.168.56.13: /opt/kubernetes/bin
```

## 2.初始化cfssl
```
[root@linux-node1 src]# mkdir ssl && cd ssl
[root@linux-node1 ssl]# cfssl print-defaults config > config.json
[root@linux-node1 ssl]# cfssl print-defaults csr > csr.json
```

## 3.创建用来生成 CA 文件的 JSON 配置文件
```
[root@linux-node1 ssl]# vim ca-config.json
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
```


## 4.创建用来生成 CA 证书签名请求（CSR）的 JSON 配置文件
```
[root@linux-node1 ssl]# vim ca-csr.json
{
  "CN": "kubernetes",
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

## 5.生成CA证书（ca.pem）和密钥（ca-key.pem）
```
[root@ linux-node1 ssl]# cfssl gencert -initca ca-csr.json | cfssljson -bare ca
[root@ linux-node1 ssl]# ls -l ca*
-rw-r--r-- 1 root root  290 Mar  4 13:45 ca-config.json
-rw-r--r-- 1 root root 1001 Mar  4 14:09 ca.csr
-rw-r--r-- 1 root root  208 Mar  4 13:51 ca-csr.json
-rw------- 1 root root 1679 Mar  4 14:09 ca-key.pem
-rw-r--r-- 1 root root 1359 Mar  4 14:09 ca.pem
```

## 6.分发证书
```
# cp ca.csr ca.pem ca-key.pem ca-config.json /opt/kubernetes/ssl
SCP证书到k8s-node1和k8s-node2节点
# scp ca.csr ca.pem ca-key.pem ca-config.json 192.168.56.12:/opt/kubernetes/ssl 
# scp ca.csr ca.pem ca-key.pem ca-config.json 192.168.56.13:/opt/kubernetes/ssl
```
