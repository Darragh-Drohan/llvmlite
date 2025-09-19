#!/bin/bash
# $1 is the filename of the script to run inside docker.
#    The file must exist in buildscripts/manylinux/.
# $2 is the python version name in /opt/python of the manylinux docker image.
#    Only used for build_llvmlite.sh.
# $3 is the stage of the build (start, continue, or end)
# Check if required parameters are provided
if [ -z "$1" ] ; then
    echo "Error: Missing required parameters"
    echo "Usage: $0 <script-filename> [<python-version>]"
    exit 1
fi
set -xe
# Use this to make the llvmdev packages that are manylinux compatible
SRCDIR=$( cd "$(dirname $0)/../.."  && pwd )
echo "SRCDIR=$SRCDIR"

echo "MINICONDA_FILE=$MINICONDA_FILE"
# Ensure the latest docker image
IMAGE_URI="quay.io/pypa/${MANYLINUX_IMAGE}:latest"
podman pull $IMAGE_URI

# Check for the run stage input. Default to start if not provided.
RUN_STAGE=${3:-start}

# The name of the non-ephemeral container
CONTAINER_NAME="llvm20-s390x"

if [ "$RUN_STAGE" == "start" ]; then
    # Start the non-ephemeral container
    podman run --name $CONTAINER_NAME -d -v $SRCDIR:/root/llvmlite $IMAGE_URI /bin/bash -c "sleep infinity"
    # Execute the start script inside the running container
    podman exec -it $CONTAINER_NAME /root/llvmlite/buildscripts/manylinux/$1 ${MINICONDA_FILE} $2
elif [ "$RUN_STAGE" == "continue" ]; then
    # Continue the build inside the existing container
    podman exec -it $CONTAINER_NAME /root/llvmlite/buildscripts/manylinux/$1
else
    echo "Error: Invalid run stage provided: $RUN_STAGE"
    exit 1
fi
