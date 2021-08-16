#!/bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# This script is to automate the docker image push & cleanup process of OpenSearch and OpenSearch-Dashboards

set -e

function usage() {
    echo ""
    echo "This script is used to push & clean the OpenSearch Docker image, which were generated by build-image.sh"
    echo "--------------------------------------------------------------------------"
    echo "Usage: $0 [args]"
    echo ""
    echo "Required arguments:"
    echo -e "-v VERSION\tSpecify the OpenSearch version number that you are building, e.g. '1.0.0' or '1.0.0-beta1'. This will be used to label the Docker image. If you do not use the '-o' option then this tool will download a public OPENSEARCH release matching this version."
    echo -e "-p PRODUCT\tSpecify the product, e.g. opensearch or opensearch-dashboards, make sure this is the name of your config folder and the name of your .tgz defined in dockerfile."
    echo ""
    echo -e "-t TASK\tSpecify the task to perform eg: create or push or cleanup."
    echo "Optional arguments:"
    echo -e "-h\t\tPrint this message."
    echo "--------------------------------------------------------------------------"
}

while getopts ":ho:v:f:p:t:" arg; do
    case $arg in
        h)
            usage
            exit 1
            ;;
        v)
            VERSION=$OPTARG
            ;;
        p)
            PRODUCT=$OPTARG
            ;;
        t)
            TASK=$OPTARG
            ;;
        :)
            echo "-${OPTARG} requires an argument"
            usage
            exit 1
            ;;
        ?)
            echo "Invalid option: -${arg}"
            exit 1
            ;;
    esac
done

# Validate the required parameters to present
if [ -z "$VERSION" ] || [ -z "$TASK" ] || [ -z "$PRODUCT" ]; then
  echo "You must specify '-v VERSION', '-p PRODUCT', '-t TASK'"
  usage
  exit 1
else
  echo $VERSION $PRODUCT $TASK
fi

# Default registry
if [ -z "${DOCKER_REGISTRY}" ]; then
    DOCKER_REGISTRY="arcsight-docker.svsartifactory.swinfra.net/dev"
fi

function push_image {
    # Build Verion Tag for our docker registry
    docker tag "opensearchproject/$PRODUCT:$VERSION" "${DOCKER_REGISTRY}/opensearchproject/$PRODUCT:$VERSION"
    docker push "${DOCKER_REGISTRY}/opensearchproject/$PRODUCT:$VERSION"

    # Build latest tag
    docker tag "opensearchproject/$PRODUCT:latest" "${DOCKER_REGISTRY}/opensearchproject/$PRODUCT:latest"
    docker push "${DOCKER_REGISTRY}/opensearchproject/$PRODUCT:latest"
}


function clean_image {
    # Remove all the built images
    docker rmi "opensearchproject/$PRODUCT:$VERSION"
    docker rmi "opensearchproject/$PRODUCT:latest"
    docker rmi "${DOCKER_REGISTRY}/opensearchproject/$PRODUCT:$VERSION"
    docker rmi "${DOCKER_REGISTRY}/opensearchproject/$PRODUCT:latest"
    docker system prune -f
}

if [ "$TASK" == "push" ]; then
    push_image
elif [ "$TASK" == "cleanup" ]; then
    clean_image
else
    echo "Only push_image and clean_image are valid options"
fi
