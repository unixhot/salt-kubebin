include:
  - k8s.modules.cni
  - k8s.modules.base-dir

kubelet-workdir:
  file.directory:
    - name: /var/lib/kubelet

clusterrolebinding:
  cmd.run:
    - name: /opt/kubernetes/bin/kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
    - unless: /opt/kubernetes/bin/kubectl get clusterrolebinding | grep kubelet-bootstrap

kubeconfig-set-cluster:
  cmd.run:
    - name: cd /opt/kubernetes/cfg && /opt/kubernetes/bin/kubectl config set-cluster kubernetes --certificate-authority=/opt/kubernetes/ssl/ca.pem --embed-certs=true --server=https://{{ pillar['MASTER_IP'] }}:6443 --kubeconfig=bootstrap.kubeconfig

kubeconfig-set-credentials:
  cmd.run:
    - name: cd /opt/kubernetes/cfg && /opt/kubernetes/bin/kubectl config set-credentials kubelet-bootstrap --token={{ pillar['BOOTSTRAP_TOKEN'] }} --kubeconfig=bootstrap.kubeconfig

kubeconfig-set-context:
  cmd.run:
    - name: cd /opt/kubernetes/cfg && /opt/kubernetes/bin/kubectl config set-context default --cluster=kubernetes --user=kubelet-bootstrap --kubeconfig=bootstrap.kubeconfig

kubeconfig-use-context:
  cmd.run:
    - name: cd /opt/kubernetes/cfg && /opt/kubernetes/bin/kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

kubelet-bin:
  file.managed:
    - name: /opt/kubernetes/bin/kubelet
    - source: salt://k8s/files/k8s-v1.9.3/bin/kubelet
    - user: root
    - group: root
    - mode: 755

kubelet-service:
  file.managed:
    - name: /usr/lib/systemd/system/kubelet.service
    - source: salt://k8s/templates/kubelet/kubelet.service.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        NODE_IP: {{ pillar['NODE_IP'] }}
        CLUSTER_DNS_SVC_IP: {{ pillar['CLUSTER_DNS_SVC_IP'] }}
        CLUSTER_DNS_DOMAIN: {{ pillar['CLUSTER_DNS_DOMAIN'] }}
  cmd.run:
    - name: systemctl daemon-reload
    - watch:
      - file: kubelet-service
  service.running:
    - name: kubelet
    - enable: True
    - watch:
      - file: kubelet-service
