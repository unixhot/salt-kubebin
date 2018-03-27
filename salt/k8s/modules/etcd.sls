include:
  - k8s.modules.base-dir
  - k8s.modules.cfssl
  - k8s.modules.ca-file

etcd-bin:
  file.managed:
    - name: /opt/kubernetes/bin/etcd
    - source: salt://k8s/files/etcd-v3.3.1-linux-amd64/etcd
    - user: root
    - group: root
    - mode: 755

etcdctl-bin:
  file.managed:
    - name: /opt/kubernetes/bin/etcdctl
    - source: salt://k8s/files/etcd-v3.3.1-linux-amd64/etcdctl
    - user: root
    - group: root
    - mode: 755

ectd-csr-json:
  file.managed:
    - name: /opt/kubernetes/ssl/etcd-csr.json
    - source: salt://k8s/templates/etcd/etcd-csr.json.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        NODE_IP: {{ grains['fqdn_ip4'][0] }}

etcd-ssl:
  cmd.run:
    - name: cd /opt/kubernetes/ssl && /opt/kubernetes/bin/cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem -ca-key=/opt/kubernetes/ssl/ca-key.pem -config=/opt/kubernetes/ssl/ca-config.json -profile=kubernetes etcd-csr.json | /opt/kubernetes/bin/cfssljson -bare etcd
    - unless: test -f /opt/kubernetes/ssl/etcd.pem

etcd-dir:
  file.directory:
    - name: /var/lib/etcd

etcd-config:
  file.managed:
    - name: /opt/kubernetes/cfg/etcd.conf
    - source: salt://k8s/templates/etcd/etcd.conf.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        NODE_IP: {{ grains['fqdn_ip4'][0] }}
        ETCD_NAME: {{ grains['etcd-name'] }}
        ETCD_CLUSTER: {{ pillar['ETCD_CLUSTER'] }}

etcd-service:
  file.managed:
    - name: /usr/lib/systemd/system/etcd.service
    - source: salt://k8s/templates/etcd/etcd.service
    - user: root
    - group: root
    - mode: 644
    - watch:
      - file: etcd-config
  cmd.run:
    - name: systemctl daemon-reload
    - watch:
      - file: etcd-service
  service.running:
    - name: etcd
    - enable: True
    - watch:
      - file: etcd-service
