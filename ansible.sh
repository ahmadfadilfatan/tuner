#!/usr/bin/env bash
# Wrapper: run Ansible inside Docker as if it were installed locally.
#
# Usage:
#   ./ansible.sh --version
#   ./ansible.sh --syntax-check playbooks/site.yml
#   ./ansible.sh -i inventories/dev/hosts.yml playbooks/site.yml

LAST_ARG="${@: -1}"

if [[ "$LAST_ARG" == *.yml || "$LAST_ARG" == *.yaml ]]; then
  BINARY="ansible-playbook"
else
  BINARY="ansible"
fi

MSYS_NO_PATHCONV=1 docker run --rm -it \
  -e ANSIBLE_CONFIG=/work/ansible.cfg \
  -v "$(pwd)":/work \
  -w /work \
  alpine/ansible:latest \
  $BINARY "$@"