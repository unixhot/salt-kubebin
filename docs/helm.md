1.部署Helm客户端
```
[root@linux-node1 ~]# cd /usr/local/src
[root@linux-node1 src]# wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
[root@linux-node1 src]# tar zxf helm-v2.9.1-linux-amd64.tar.gz
[root@linux-node1 src]# mv linux-amd64/helm /usr/local/bin/
```

2.初始化Helm并部署Tiller服务端
```
[root@linux-node1 ~]# helm init --upgrade –i \
 registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1 \
--stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```

3.所有节点安装socat命令
```
[root@linux-node1 ~]# yum install -y socat
```

4.验证安装是否成功
```
[root@linux-node1 ~]# helm version
Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
```

5.查看helm tiller的服务
```
[root@linux-node1 ~]# kubectl get pod --all-namespaces|grep tiller
kube-system   tiller-deploy-744cfb67cf-pws4d                1/1       Running   0          2m
```

6.使用Helm部署第一个应用

6.1创建服务账号
```
[root@linux-node1 ~]# kubectl create serviceaccount --namespace kube-system tiller
serviceaccount "tiller" created
```

6.2.创建集群的角色绑定
```
[root@linux-node1 ~]# kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
clusterrolebinding.rbac.authorization.k8s.io "tiller-cluster-rule" created
```

 6.3.为应用程序设置serviceAccount
 ```
[root@linux-node1 ~]# kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
deployment.extensions "tiller-deploy" patched
```

6.4.搜索Helm应用
```
[root@linux-node1 ~]# helm search jenkins
NAME          	CHART VERSION	APP VERSION	DESCRIPTION                                       
stable/jenkins	0.13.5       	2.73       	Open source continuous integration server. It s...


[root@linux-node1 ~]# helm repo list
NAME  	URL                                                   
stable	https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
local 	http://127.0.0.1:8879/charts   

[root@linux-node1 ~]# helm install stable/jenkins
```
