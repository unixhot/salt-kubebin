
# 系统环境初始化

## 1.安装Docker

第一步：使用国内Docker源
```
[root@linux-node1 ~]# cd /etc/yum.repos.d/
[root@linux-node1 yum.repos.d]# wget \
 https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

第二步：Docker安装：
```
[root@linux-node1 ~]# yum install -y docker-ce
```

第三步：启动后台进程：
```
[root@linux-node1 ~]# systemctl start docker
```

## 2.准备部署目录
```
    mkdir -p /opt/kubernetes/{cfg,bin,ssl,log}
```

## 3.准备软件包
```
百度网盘下载地址：
[https://pan.baidu.com/s/1zs8sCouDeCQJ9lghH1BPiw](https://pan.baidu.com/s/1zs8sCouDeCQJ9lghH1BPiw)
```

## 4.解压软件包

```
 # tar zxf kubernetes.tar.gz 
 # tar zxf kubernetes-server-linux-amd64.tar.gz 
 # tar zxf kubernetes-client-linux-amd64.tar.gz
 # tar zxf kubernetes-node-linux-amd64.tar.gz
```

## 5.配置内核参数

```bash
[root@linux-node1 ~]vim /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.ip_forward = 1

# see details in https://help.aliyun.com/knowledge_detail/39428.html
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.conf.all.arp_announce=2


# see details in https://help.aliyun.com/knowledge_detail/41334.html
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
kernel.sysrq = 1

# iptables透明网桥的实现
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
```



