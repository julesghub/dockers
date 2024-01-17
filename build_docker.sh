#!/bin/bash

set -o history -o histexpand
set -e 

ARCH=$(uname -m)
OSVER="23.04"
PYVER="3.11"

ARGS="--cpuset-cpus 0-$(nproc)"
echo $ARGS

# first build open-mpi docker image
DOCKER_BUILDKIT=0 podman build ${ARGS} open-mpi/ \
     --build-arg UBUNTU_VERSION=$OSVER \
     -t julesg/open-mpi:4.1.4-${ARCH}


DOCKER_BUILDKIT=0 podman build ${ARGS} petsc/ \
    --build-arg MPI_IMAGE="julesg/open-mpi:4.1.4-${ARCH}" \
    --build-arg PYVER=${PYVER} \
    --build-arg UBUNTU_VERSION=${OSVER} \
    -t julesg/petsc:lm-${ARCH}


DOCKER_BUILDKIT=0 podman build ${ARGS} uw3/ \
    --build-arg PETSC_IMAGE="julesg/petsc:lm-${ARCH}" \
    --build-arg PYVER=${PYVER} \
    --build-arg UBUNTU_VERSION=${OSVER} \
    -t julesg/underworld3:0.9-${ARCH}
