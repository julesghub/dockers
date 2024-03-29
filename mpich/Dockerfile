#####################################################################
# Multi stage Dockerfile structure:
# 1. runtime 
# 2. build
# 3. final == runtime + min. build
#
# It begins with layers for runtime execution. 
# The runtime environment (packages, permissions, ENV vars.) 
# are consistent accross all layer of this Dockerfile. 
# The build layer takes the runtime layer and builds the software
# stack in /usr/local.
# The final image is a composite of the runtime layer and 
# minimal sections of the build layer.
#####################################################################

ARG MPICH_VERSION="3.4.3"

FROM ubuntu:23.10 as runtime
LABEL maintainer="https://github.com/underworldcode/"

################
## 1. Runtime ##
################

# add user jovyan
ENV NB_USER jovyan
ENV NB_HOME /home/$NB_USER
RUN useradd -m -s /bin/bash -N $NB_USER

#install runtime packages
RUN apt-get update -qq \
&&  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        ssh  \
        bash \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

################
## 2. Build   ##
################

FROM runtime as build

# Build options for mpich
ARG MPICH_VERSION
ARG MPICH_CONFIGURE_OPTIONS="--enable-fast=all,O3 --prefix=/usr/local --with-device=ch4:ofi FFLAGS=-fallow-argument-mismatch FCFLAGS=-fallow-argument-mismatch"
ARG MPICH_MAKE_OPTIONS="-j4"

RUN apt-get update -qq \
&&  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        wget \
        gcc \
        gfortran \
        g++ \
        make \
        file \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

# build mpi
RUN mkdir -p /tmp/src
WORKDIR /tmp/src
RUN wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz --no-check-certificate \
&& tar -zxf mpich-${MPICH_VERSION}.tar.gz 
WORKDIR /tmp/src/mpich-${MPICH_VERSION}              
RUN ./configure ${MPICH_CONFIGURE_OPTIONS} \
 && make ${MPICH_MAKE_OPTIONS} \
 && make install \
 && ldconfig \
 && rm -rf /tmp/src/

# record build packages used
RUN apt-mark showmanual > /opt/installed.txt

################
## 3. Final   ##
################
FROM runtime as final

COPY --from=build /usr/local /usr/local
COPY --from=build /opt/installed.txt /opt/installed.txt

# switch to user and workspace
WORKDIR $NB_HOME
USER $NB_USER
