kubernetes-csr-json:
  file.managed:
    - name: /opt/kubernetes/ssl/kubernetes-csr.json
    - source: salt://k8s/templates/kube-api-server/kubernetes-csr.json.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        NODE_IP: {{ pillar['NODE_IP'] }}
        CLUSTER_KUBERNETES_SVC_IP: {{ pillar['CLUSTER_KUBERNETES_SVC_IP'] }}
  cmd.run:
    - name: cd /opt/kubernetes/ssl && /opt/kubernetes/bin/cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem -ca-key=/opt/kubernetes/ssl/ca-key.pem -config=/opt/kubernetes/ssl/ca-config.json -profile=kubernetes kubernetes-csr.json | /opt/kubernetes/bin/cfssljson -bare kubernetes
    - unless: test -f /opt/kubernetes/ssl/kubernetes.pem

api-auth-token:
  file.managed:
    - name: /opt/kubernetes/ssl/bootstrap-token.csv
    - source: salt://k8s/templates/kube-api-server/bootstrap_token.csv.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        BOOTSTRAP_TOKEN: {{ pillar['BOOTSTRAP_TOKEN'] }}

basic-auth:
  file.managed:
    - name: /opt/kubernetes/ssl/basic-auth.csv
    - source: salt://k8s/templates/kube-api-server/basic-auth.csv.template
    - user: root
    - group: root
    - mode: 644

kube-apiserver-bin:
  file.managed:
    - name: /opt/kubernetes/bin/kube-apiserver
    - source: salt://k8s/files/k8s-v1.9.3/bin/kube-apiserver
    - user: root
    - group: root
    - mode: 755

kube-apiserver-service:
  file.managed:
    - name: /usr/lib/systemd/system/kube-apiserver.service
    - source: salt://k8s/templates/kube-api-server/kube-apiserver.service.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        NODE_IP: {{ pillar['NODE_IP'] }}
        SERVICE_CIDR: {{ pillar['SERVICE_CIDR'] }}
        NODE_PORT_RANGE: {{ pillar['NODE_PORT_RANGE'] }}
        ETCD_ENDPOINTS: {{ pillar['ETCD_ENDPOINTS'] }}
  cmd.run:
    - name: systemctl daemon-reload
    - watch:
      - file: kube-apiserver-service
  service.running:
    - name: kube-apiserver 
    - enable: True
    - watch:
      - file: kube-apiserver-service
