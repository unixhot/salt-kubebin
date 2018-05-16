# Kubernetes Dashboard

## 创建CoreDNS
```
[root@linux-node1 ~]# kubectl create -f coredns.yaml 

[root@linux-node1 ~]# kubectl get pod -n kube-system
NAME                                    READY     STATUS    RESTARTS   AGE
coredns-77c989547b-9pj8b                1/1       Running   0          6m
coredns-77c989547b-kncd5                1/1       Running   0          6m
```

## 创建Dashboard
```
[root@linux-node1 ~]# kubectl create -f dashboard/
```

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```
