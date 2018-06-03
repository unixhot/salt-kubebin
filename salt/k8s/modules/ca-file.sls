# -*- coding: utf-8 -*-
#******************************************
# Author:       Jason Zhao
# Email:        shundong.zhao@linuxhot.com
# Organization: http://www.devopsedu.com/
# Description:  Ca File
#******************************************

include:
  - k8s.modules.base-dir

ca-pem:
  file.managed:
    - name: /opt/kubernetes/ssl/ca.pem
    - source: salt://k8s/templates/ca/ca.pem
    - user: root
    - group: root
    - mode: 644

ca-key-pem:
  file.managed:
    - name: /opt/kubernetes/ssl/ca-key.pem
    - source: salt://k8s/templates/ca/ca-key.pem
    - user: root
    - group: root
    - mode: 644

ca-csr:
  file.managed:
    - name: /opt/kubernetes/ssl/ca.csr
    - source: salt://k8s/templates/ca/ca.csr
    - user: root
    - group: root
    - mode: 644

ca-config-json:
  file.managed:
    - name: /opt/kubernetes/ssl/ca-config.json
    - source: salt://k8s/templates/ca/ca-config.json
    - user: root
    - group: root
    - mode: 644
