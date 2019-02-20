#!/bin/sh
set -e

printf "[defaults]\nroles_path=/etc/ansible/roles\n" > /ansible/ansible.cfg

test -z ${jenkins_use_official_repo} && \
  echo "Missing environment variable: jenkins_use_official_repo" && exit 1
(test "${jenkins_use_official_repo}" = "false" && \
  test -z ${jenkins_version}) && \
  echo "Missing environment variable: jenkins_version" && exit 1

ansible-lint -c /etc/ansible/roles/${ansible_role}/.ansible-lint \
  /etc/ansible/roles/${ansible_role}
ansible-lint -c /etc/ansible/roles/${ansible_role}/.ansible-lint \
  /ansible/test.yml

ansible-playbook /ansible/test.yml \
  -i /ansible/inventory \
  --syntax-check

ansible-playbook /ansible/test.yml \
  -i /ansible/inventory \
  --connection=local \
  --become \
  -e "{ jenkins_use_official_repo: ${jenkins_use_official_repo} }" \
  -e "{ jenkins_version: ${jenkins_version} }" \
  $(test -z ${travis} && echo "-vvvv")

ansible-playbook /ansible/test.yml \
  -i /ansible/inventory \
  --connection=local \
  --become \
  -e "{ jenkins_use_official_repo: ${jenkins_use_official_repo} }" \
  -e "{ jenkins_version: ${jenkins_version} }" | \
  grep -q "changed=0.*failed=0" && \
  (echo "Idempotence test: pass" && exit 0) || \
  (echo "Idempotence test: fail" && exit 1)

port=$(grep HTTP_PORT /ansible/test.yml | awk '{print $2}')
curl -Ikso /dev/null http://localhost:${port} && \
  (echo "Jenkins port response test: pass" && exit 0) || \
  (echo "Jenkins port response test: fail" && exit 1)
