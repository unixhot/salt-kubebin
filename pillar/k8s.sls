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
