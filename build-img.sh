#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd -P)
IMAGE_FILE=${IMAGE_FILE:-"hub.easystack.cn/production/vcuda"}
IMAGE_TAG=${IMAGE_TAG:-"v1.0.6-es"}

function cleanup() {
    rm -rf ${ROOT}/cuda-control.tar
}

trap cleanup EXIT SIGTERM SIGINT

function build_img() {
    readonly local commit=$(git log --oneline | wc -l | sed -e 's,^[ \t]*,,')
    readonly local version=$(<"${ROOT}/VERSION")
    readonly local arch=$(uname -m)

    rm -rf ${ROOT}/build
    mkdir ${ROOT}/build
    git archive -o ${ROOT}/build/cuda-control.tar --format=tar --prefix=cuda-control/ HEAD
    cp ${ROOT}/vcuda.spec ${ROOT}/build
    cp ${ROOT}/Dockerfile ${ROOT}/build
    (
      cd ${ROOT}/build
      docker build ${BUILD_FLAGS:-} --build-arg version=${version} --build-arg commit=${commit} --build-arg arch=${arch} -t ${IMAGE_FILE}:${IMAGE_TAG} .
    )
}

build_img
