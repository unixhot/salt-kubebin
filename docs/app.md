创建一个测试用的deployment
```
[root@linux-node1 ~]# kubectl run net-test --image=alpine --replicas=2 sleep 360000
```

查看获取IP情况
``
[root@linux-node1 ~]# kubectl get pod -o wide
NAME                        READY     STATUS    RESTARTS   AGE       IP          NODE
net-test-74f45db489-gmgv8   1/1       Running   0          1m        10.2.83.2   192.168.56.13
net-test-74f45db489-pr5jc   1/1       Running   0          1m        10.2.59.2   192.168.56.12
```
