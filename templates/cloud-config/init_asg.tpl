#cloud-config
#
# Cloud-Config template for the Apache Zookeeper instances (in Autoscaling
# Group mode).
#
# Copyright 2016-2020, Compare Group
#   Author: Compare Group <http://github.com/comparegroup>
#
# SPDX-License-Identifier: MIT
#

#cloud-config
locale: en_US.UTF-8
output: { all: "| tee -a /var/log/zk-init-output.log" }

write_files:
  - content: |
      #!/bin/bash

      set -x
      echo "=== Setting Variables ==="
      __AWS_METADATA_ADDR__="169.254.169.254"
      REGION=`curl -s http://$${__AWS_METADATA_ADDR__}/latest/dynamic/instance-identity/document | jq -r .region`
      export AWS_DEFAULT_REGION=$${REGION}

      __MAC_ADDRESS__=$(curl -s http://$${__AWS_METADATA_ADDR__}/latest/meta-data/network/interfaces/macs/ 2>/dev/null | head -n1 | awk '{print $1}')
      __INSTANCE_ID__=`curl -s http://$${__AWS_METADATA_ADDR__}/latest/meta-data/instance-id`
      __SUBNET_ID__=`curl -s http://$${__AWS_METADATA_ADDR__}/latest/meta-data/network/interfaces/macs/$${__MAC_ADDRESS__}subnet-id`
      __ENI_NAME__=$(aws ec2 describe-network-interfaces --filters "Name=tag:Reference,Values=${eni_reference}" "Name=subnet-id,Values=$${__SUBNET_ID__}" --output json --query "NetworkInterfaces[0].TagSet[?Key==\`Name\`].Value" | grep -o "[a-z0-9\.-]*")

      HOSTNAME=$${__ENI_NAME__}
      FQDN="$${HOSTNAME}.${domain}"

      # Setup local vanity hostname
      echo $${HOSTNAME} | sed 's/\.$//' > /etc/hostname
      hostname `cat /etc/hostname`

      cat >/etc/hosts <<EOF
      # The following lines are desirable for IPv4 capable hosts
      127.0.0.1 $${FQDN} $${HOSTNAME}
      127.0.0.1 localhost.localdomain localhost
      127.0.0.1 localhost4.localdomain4 localhost4
      # The following lines are desirable for IPv6 capable hosts
      ::1 $${FQDN} $${HOSTNAME}
      ::1 localhost.localdomain localhost
      ::1 localhost6.localdomain6 localhost6
      EOF

    path: /usr/local/bin/hostmod.sh
    permissions: '0755'
  - content: |
      #!/bin/bash

      set -x
      echo "=== Setting Variables ==="
      __AWS_METADATA_ADDR__="169.254.169.254"
      REGION=`curl -s http://$${__AWS_METADATA_ADDR__}/latest/dynamic/instance-identity/document | jq -r .region`
      export AWS_DEFAULT_REGION=$${REGION}

      __MAC_ADDRESS__=$(curl -s http://$${__AWS_METADATA_ADDR__}/latest/meta-data/network/interfaces/macs/ 2>/dev/null | head -n1 | awk '{print $1}')
      __INSTANCE_ID__=`curl -s http://$${__AWS_METADATA_ADDR__}/latest/meta-data/instance-id`
      __SUBNET_ID__=`curl -s http://$${__AWS_METADATA_ADDR__}/latest/meta-data/network/interfaces/macs/$${__MAC_ADDRESS__}subnet-id`
      __ATTACHMENT_ID__=$(aws ec2 describe-network-interfaces --filters "Name=tag:Reference,Values=${eni_reference}" "Name=subnet-id,Values=$${__SUBNET_ID__}" --query "NetworkInterfaces[0].[Attachment][0].[AttachmentId]" | grep -o 'eni-attach-[a-z0-9]*' || echo '')
      __ENI_ID__=$(aws ec2 describe-network-interfaces --filters "Name=tag:Reference,Values=${eni_reference}" "Name=subnet-id,Values=$${__SUBNET_ID__}" --output json --query "NetworkInterfaces[0].NetworkInterfaceId" | grep -o 'eni-[a-z0-9]*')
      __ENI_IP__=$(aws ec2 describe-network-interfaces --filters "Name=tag:Reference,Values=${eni_reference}" "Name=subnet-id,Values=$${__SUBNET_ID__}" --output json --query "NetworkInterfaces[0].PrivateIpAddress" | grep -o "[0-9\.]*")
      __ENI_NAME__=$(aws ec2 describe-network-interfaces --filters "Name=tag:Reference,Values=${eni_reference}" "Name=subnet-id,Values=$${__SUBNET_ID__}" --output json --query "NetworkInterfaces[0].TagSet[?Key==\`Name\`].Value" | grep -o "[a-z0-9\.-]*")

      echo "=== ADD counter to name ==="
      ID=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .instanceId`
      aws ec2 create-tags --resources $${ID} --tags Key=Name,Value="$${__ENI_NAME__}"

      echo "=== Disabling source-dest-check ==="
      aws ec2 modify-instance-attribute --instance-id $${__INSTANCE_ID__} --no-source-dest-check &>/dev/null || echo "skipped"

      echo "=== Detach ENI ==="
      if [[ "x$${__ATTACHMENT_ID__}" != "x" ]]; then aws ec2 detach-network-interface --attachment-id $${__ATTACHMENT_ID__}; sleep 60; fi

      echo "=== Attach ENI ==="
      aws ec2 attach-network-interface --network-interface-id $${__ENI_ID__} --instance-id $${__INSTANCE_ID__} --device-index 1

      echo "=== Setting up Apache Zookeeper Instance ==="
      echo "  instance: $${__ENI_NAME__}.${domain}"
      sudo /usr/local/bin/zookeeper_config -i $(echo '${zookeeper_addr}' | sed -r -n -e "s/.*(([0-9]+):$${__ENI_IP__}).*/\2/p" ) ${zookeeper_args} -E -S -W 60

      echo "=== All Done ==="


    path: /root/setup_zookeeper_asg.sh
    permissions: '0755'
  - content: |
      #!/usr/bin/env bash
      #
      # Script to check the process and to post the status to CloudWatch.
      set -ex

      REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region`
      # get the process status
      value=`ps -ef | grep ${service} | grep -v grep | grep -v $0 | wc -l`

      # post the status
      aws --region $${REGION} cloudwatch put-metric-data --metric-name ${metric} \
          --namespace CMXAM/Kafka --value $value \
          --dimensions InstanceId=`curl http://169.254.169.254/latest/meta-data/instance-id` \
          --timestamp `date '+%FT%T.%N%Z'`

    path: /srv/${service}/${service}-status.sh
    permissions: '0700'
  - content: |
      while [ ! -f /root/.provisioning-finished ]
      do
          echo -n "#"
          sleep 1
      done
    path: /root/ensure-provisioned.sh
    permissions: '0777'

runcmd:
  - /usr/local/bin/hostmod.sh
  - /root/setup_zookeeper_asg.sh
  #- rm /tmp/setup_zookeeper_asg.sh
  - touch /root/.provisioning-finished && chmod 644 /root/.provisioning-finished
  - sh /root/ensure-provisioned.sh
  - echo '* * * * * /srv/${service}/${service}-status.sh' > /tmp/crontab
  - crontab -u ${service} /tmp/crontab
  - rm /tmp/crontab

fqdn: $${HOSTNAME}.${domain}
hostname: $${HOSTNAME}
manage_etc_hosts: true

