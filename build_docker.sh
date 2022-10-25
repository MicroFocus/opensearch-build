#!/bin/bash

# Copyright OpenSearch Contributors
# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.

VERSION=1.3.9
PRODUCT=opensearch
DOCKERFILE=dockerfiles/opensearch.microfocus.dockerfile
ARCH=x64

pushd docker/release
./build-image-single-arch.sh -v ${VERSION} -p ${PRODUCT} -f ${DOCKERFILE} -a ${ARCH}
popd
