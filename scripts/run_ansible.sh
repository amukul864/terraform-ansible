#!/usr/bin/env bash
set -e

ANSIBLE_PATH="${ANSIBLE_DIR:-$(dirname "$0")/../../ansible}"

echo "==> Navigating to Ansible directory: ${ANSIBLE_PATH}"
cd "${ANSIBLE_PATH}"

echo "==> Flushing Ansible dynamic inventory cache..."
ansible-inventory -i inventory/aws_ec2.yml --list --flush-cache > /dev/null

echo "==> Triggering Ansible Playbook execution..."
ansible-playbook -i inventory/aws_ec2.yml playbooks/site.yml

echo "==> Ansible execution completed successfully!"