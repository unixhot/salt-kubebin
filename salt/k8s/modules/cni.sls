cni-dir:
  file.directory:
    - name: /etc/cni

cni-dir-net:
  file.directory:
    - name: /etc/cni/net.d

cni-default-conf:
  file.managed:
    - name: /etc/cni/net.d/10-default.conf
    - source: salt://k8s/templates/cni/10-default.conf.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        POD_CIDR: {{ pillar['POD_CIDR'] }}

cni-bin:
  file.recurse:
    - name: /opt/kubernetes/bin/cni
    - source: salt://k8s/files/cni-plugins-amd64-v0.7.0/
    - user: root
    - group: root
    - file_mode: 755
