export MANYLINUX_IMAGE="manylinux2014_s390x"
export MINICONDA_FILE="https://repo.anaconda.com/miniconda/Miniconda3-py311_24.9.2-0-Linux-s390x.sh"
cd $(dirname $0)
# Pass the run_stage as the third argument to docker_run.sh
./docker_run.sh $1 $2 $3
