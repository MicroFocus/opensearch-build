#!/bin/bash
VERSION=1.3.2
PRODUCT=opensearch
DOCKERFILE=dockerfiles/opensearch.microfocus.dockerfile
ARCH=x64

pushd docker/release
./build-image-single-arch.sh -v ${VERSION} -p ${PRODUCT} -f ${DOCKERFILE} -a ${ARCH}
popd
