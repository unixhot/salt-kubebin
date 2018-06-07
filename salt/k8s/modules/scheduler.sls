# -*- coding: utf-8 -*-
#******************************************
# Author:       Jason Zhao
# Email:        shundong.zhao@linuxhot.com
# Organization: http://www.devopsedu.com/
# Description:  Kubernetes Scheduler
#******************************************

{% set k8s_version = "k8s-v1.10.3" %}

kube-scheduler-bin:
  file.managed:
    - name: /opt/kubernetes/bin/kube-scheduler
    - source: salt://k8s/files/{{ k8s_version }}/bin/kube-scheduler
    - user: root
    - group: root
    - mode: 755

kube-scheduler-service:
  file.managed:
    - name: /usr/lib/systemd/system/kube-scheduler.service
    - source: salt://k8s/templates/kube-scheduler/kube-scheduler.service.template
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: systemctl daemon-reload
    - watch:
      - file: kube-scheduler-service
  service.running:
    - name: kube-scheduler
    - enable: True
    - watch:
      - file: kube-scheduler-service
