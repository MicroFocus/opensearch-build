#!/bin/bash

# Copyright 2022-2023 OpenText or one of its affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under Apache-2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#                   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

set -x

# ensure JAVA_HOME is set
export JAVA_HOME=/usr/share/opensearch/jdk

# wait for OpenSearch to be up and running
while true; do
  STATUS=$(curl -X GET -k "https://admin:admin@opensearch-svc:9200/_cat/health" | tr -s ' ' | cut -d ' ' -f 4)
  echo "Received a cluster status of ${STATUS}"
  if [ "green" = ${STATUS} ] || [ "yellow" = ${STATUS} ]; then
    break;
  fi
  sleep 2
done

# Create a hash version of the configured password
pushd /usr/share/opensearch/plugins/opensearch-security/tools
  export HASH_PASSWORD=$(sh hash.sh -p ${OPENSEARCH_PASSWORD})
popd

# Set the value in the users.yml
pushd /usr/share/opensearch/plugins/opensearch-security/securityconfig
cat << EOF >> ./internal_users.yml

$OPENSEARCH_USER:
  hash: $HASH_PASSWORD
  reserved: false
  backend_roles:
  - "admin"
  description: "Interset's OpenSearch user."
EOF
popd

# Refresh the users in the cluster
pushd /usr/share/opensearch/plugins/opensearch-security/tools
  sh securityadmin.sh -cd ../securityconfig/ -icl -nhnv -cacert ../../../config/certs/issue_ca.crt -cert ../../../config/certs/opensearch-adm-crt.pem -key ../../../config/certs/opensearch-adm-key.pem
popd
