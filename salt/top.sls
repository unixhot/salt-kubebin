# -*- coding: utf-8 -*-
#******************************************
# Author:       Jason Zhao
# Email:        shundong.zhao@linuxhot.com
# Organization: http://www.devopsedu.com/
# Description:  SaltStack Top File
#******************************************

base:
  'k8s-role:master':
    - match: grain
    - k8s.master
  'k8s-role:node':
    - match: grain
    - k8s.node
  'etcd-role:node':
    - match: grain
    - k8s.etcd

