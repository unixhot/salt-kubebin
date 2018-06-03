# -*- coding: utf-8 -*-
#******************************************
# Author:       Jason Zhao
# Email:        shundong.zhao@linuxhot.com
# Organization: http://www.devopsedu.com/
# Description:  CfSSL Tools
#******************************************
{% set cfssl_version = "cfssl-1.2" %}

include:
  - k8s.modules.base-dir

cfssl-certinfo:
  file.managed:
    - name: /opt/kubernetes/bin/cfssl-certinfo
    - source: salt://k8s/files/{{ cfssl_version }}/cfssl-certinfo_linux-amd64
    - user: root
    - group: root
    - mode: 755

cfssl-json:
  file.managed:
    - name: /opt/kubernetes/bin/cfssljson
    - source: salt://k8s/files/{{ cfssl_version }}/cfssljson_linux-amd64
    - user: root
    - group: root
    - mode: 755

cfssl:
  file.managed:
    - name: /opt/kubernetes/bin/cfssl
    - source: salt://k8s/files/{{ cfssl_version }}/cfssl_linux-amd64
    - user: root
    - group: root
    - mode: 755
