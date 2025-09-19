#!/bin/bash
# This script is designed to be run inside the Podman container
# to continue the Ninja build process.
set -xe
cd $(dirname $0)
# Navigate to the build directory created in the 'start' stage.
# The `conda-build` output from the start stage is in a temporary folder.
# We need to find the correct path to the build directory.
# This assumes there is only one subdirectory in the conda-build output.
BUILD_ROOT=$(find /opt/conda/conda-bld -maxdepth 1 -type d -name "llvmdev_for_wheel-*" -print -quit)
if [ -z "$BUILD_ROOT" ]; then
  echo "Error: Could not find build directory to resume ninja."
  exit 1
fi
cd "$BUILD_ROOT/work/build"

echo "Resuming ninja build..."
# Continue the ninja build from where it left off
ninja -j$(nproc)
echo "Ninja build finished."
echo "Performing ninja install..."
ninja install
echo "Ninja install finished."

echo "Running conda build install and test steps..."
# The original conda-build command also handles installation and testing.
# We can't easily re-run those steps from the continue script, so we'll
# rely on the final `end` stage of the GitHub workflow to handle the
# artifact creation and upload.
# For now, this script just finishes the ninja build and install.
