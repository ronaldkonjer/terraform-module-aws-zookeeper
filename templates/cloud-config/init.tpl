#cloud-config
#
# Cloud-Config template for the Apache Zookeeper instances.
#
# Copyright 2016-2020, Compare Group
#   Author: Compare Group <http://github.com/comparegroup>
#
# SPDX-License-Identifier: MIT
#

fqdn: ${hostname}.${domain}
hostname: ${hostname}
manage_etc_hosts: true

write_files:
  - content: |
      #!/bin/bash
      echo "=== Setting up Apache Zookeeper Instance ==="
      echo "  instance: ${hostname}.${environment}.${domain}"
      sudo /usr/local/bin/zookeeper_config ${zookeeper_args} -E -S -W 60
      echo "=== All Done ==="
    path: /root/setup_zookeeper.sh
    permissions: '0755'

runcmd:
  - /root/setup_zookeeper.sh
  #- rm /root/setup_zookeeper.sh
