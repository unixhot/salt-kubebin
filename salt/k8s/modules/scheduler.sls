kube-scheduler-bin:
  file.managed:
    - name: /opt/kubernetes/bin/kube-scheduler
    - source: salt://k8s/files/k8s-v1.9.3/bin/kube-scheduler
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
