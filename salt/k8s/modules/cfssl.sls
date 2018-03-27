include:
  - k8s.modules.base-dir

cfssl-certinfo:
  file.managed:
    - name: /opt/kubernetes/bin/cfssl-certinfo
    - source: salt://k8s/files/cfssl-1.2/cfssl-certinfo_linux-amd64
    - user: root
    - group: root
    - mode: 755

cfssl-json:
  file.managed:
    - name: /opt/kubernetes/bin/cfssljson
    - source: salt://k8s/files/cfssl-1.2/cfssljson_linux-amd64
    - user: root
    - group: root
    - mode: 755

cfssl:
  file.managed:
    - name: /opt/kubernetes/bin/cfssl
    - source: salt://k8s/files/cfssl-1.2/cfssl_linux-amd64
    - user: root
    - group: root
    - mode: 755
