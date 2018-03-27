include:
  - k8s.modules.cni
  - k8s.modules.base-dir

kube-proxy-workdir:
  file.directory:
    - name: /var/lib/kube-proxy

kube-proxy-csr-json:
  file.managed:
    - name: /opt/kubernetes/ssl/kube-proxy-csr.json
    - source: salt://k8s/templates/kube-proxy/kube-proxy-csr.json.template
    - user: root
    - group: root
    - mode: 644

kube-proxy-pem:
  cmd.run:
    - name: cd /opt/kubernetes/ssl && /opt/kubernetes/bin/cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem -ca-key=/opt/kubernetes/ssl/ca-key.pem -config=/opt/kubernetes/ssl/ca-config.json -profile=kubernetes  kube-proxy-csr.json | /opt/kubernetes/bin/cfssljson -bare kube-proxy
    - unless: test -f /opt/kubernetes/ssl/kube-proxy.pem

kubeproxy-set-cluster:
  cmd.run:
    - name: cd /opt/kubernetes/cfg && /opt/kubernetes/bin/kubectl config set-cluster kubernetes --certificate-authority=/opt/kubernetes/ssl/ca.pem --embed-certs=true --server=https://{{ pillar['MASTER_IP'] }}:6443  --kubeconfig=kube-proxy.kubeconfig

kubeproxy-set-credentials:
  cmd.run:
    - name: cd /opt/kubernetes/cfg && /opt/kubernetes/bin/kubectl config set-credentials kube-proxy --client-certificate=/opt/kubernetes/ssl/kube-proxy.pem --client-key=/opt/kubernetes/ssl/kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig

kubeproxy-set-context:
  cmd.run:
    - name: cd /opt/kubernetes/cfg && /opt/kubernetes/bin/kubectl config set-context default --cluster=kubernetes --user=kube-proxy --kubeconfig=kube-proxy.kubeconfig

kubeproxy-use-context:
  cmd.run:
    - name: cd /opt/kubernetes/cfg && /opt/kubernetes/bin/kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

kube-proxy-bin:
  file.managed:
    - name: /opt/kubernetes/bin/kube-proxy
    - source: salt://k8s/files/k8s-v1.9.3/bin/kube-proxy
    - user: root
    - group: root
    - mode: 755

kube-proxy-service:
  file.managed:
    - name: /usr/lib/systemd/system/kube-proxy.service
    - source: salt://k8s/templates/kube-proxy/kube-proxy.service.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        NODE_IP: {{ pillar['NODE_IP'] }}
  cmd.run:
    - name: systemctl daemon-reload
    - watch:
      - file: kube-proxy-service
  service.running:
    - name: kube-proxy
    - enable: True
    - watch:
      - file: kube-proxy-service
