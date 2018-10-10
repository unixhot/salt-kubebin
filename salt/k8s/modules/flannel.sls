# -*- coding: utf-8 -*-
#******************************************
# Author:       Jason Zhao
# Email:        shundong.zhao@linuxhot.com
# Organization: http://www.devopsedu.com/
# Description:  Flannel
#******************************************
{% set flannel_version = "flannel-v0.10.0-linux-amd64" %}

flannel-key:
  file.managed:
    - name: /opt/kubernetes/ssl/flanneld-csr.json
    - source: salt://k8s/templates/flannel/flanneld-csr.json.template
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cd /opt/kubernetes/ssl && /opt/kubernetes/bin/cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem -ca-key=/opt/kubernetes/ssl/ca-key.pem -config=/opt/kubernetes/ssl/ca-config.json -profile=kubernetes flanneld-csr.json | /opt/kubernetes/bin/cfssljson -bare flanneld
    - unless: test -f /opt/kubernetes/ssl/flanneld.pem

remove-docker0:
  file.managed:
    - name: /opt/kubernetes/bin/remove-docker0.sh
    - source: salt://k8s/templates/flannel/remove-docker0.sh.template
    - user: root
    - group: root
    - mode: 755

mk-docker-opts:
  file.managed:
    - name: /opt/kubernetes/bin/mk-docker-opts.sh
    - source: salt://k8s/files/{{ flannel_version }}/mk-docker-opts.sh
    - user: root
    - group: root
    - mode: 755

flannel-config:
  file.managed:
    - name: /opt/kubernetes/cfg/flannel
    - source: salt://k8s/templates/flannel/flannel-config.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        ETCD_ENDPOINTS: {{ pillar['ETCD_ENDPOINTS'] }}

flannel-etcd:
  file.managed:
    - name: /opt/kubernetes/bin/flannel-etcd.sh
    - source: salt://k8s/templates/flannel/flannel-etcd.sh.template
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - defaults:
        ETCD_ENDPOINTS: {{ pillar['ETCD_ENDPOINTS'] }}
        POD_CIDR: {{ pillar['POD_CIDR'] }}
  cmd.run:
    - name: /bin/bash /opt/kubernetes/bin/flannel-etcd.sh

flannel-bin:
  file.managed:
    - name: /opt/kubernetes/bin/flanneld
    - source: salt://k8s/files/{{ flannel_version }}/flanneld
    - user: root
    - group: root
    - mode: 755

flannel-service:
  file.managed:
    - name: /usr/lib/systemd/system/flannel.service
    - source: salt://k8s/templates/flannel/flannel.service.template
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: systemctl daemon-reload
  service.running:
    - name: flannel
    - enable: True
    - watch:
      - file: flannel-service
    - require:
      - file: flannel-etcd
