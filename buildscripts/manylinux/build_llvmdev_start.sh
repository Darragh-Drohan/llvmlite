#!/bin/bash
# This script performs the initial setup for the LLVM build.
# It is designed to be run inside the Podman container.
# $1 is the miniconda download link
if [ -z "$1" ]; then
    echo "Error: Miniconda download link argument is required"
    exit 1
fi
set -xe
cd $(dirname $0)
# Use a temporary directory for the build to avoid issues with host volumes
export BUILD_ROOT=/root/build_root
mkdir -p $BUILD_ROOT
cd $BUILD_ROOT

source /root/llvmlite/buildscripts/manylinux/prepare_miniconda.sh $1
if [[ "$(uname -m)" == "aarch64" ]]; then
    conda create -n buildenv -y conda conda-build "py-lief<0.16"
else
    conda create -n buildenv -y conda conda-build
fi
conda activate buildenv
conda list
export CMAKE_ARGS="-DCMAKE_SKIP_RPATH=ON"
# We only do the conda build prepare step to get the environment ready
# and the cmake files created. The ninja build will happen in the 'continue' stage.
conda-build /root/llvmlite/conda-recipes/llvmdev_for_wheel --output-folder=/root/llvmlite/docker_output --no-test --build-only
