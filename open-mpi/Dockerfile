#####################################################################
# Multi stage Dockerfile structure:
# 1. runtime 
# 2. build
# 3. final == runtime + min. build
#
# It begins with layers for runtime execution. 
# The runtime environment (packages, permissions, ENV vars.) 
# are consistent accross all layer of this Dockerfile. 
# The final image is a composite for the runtime layer and 
# minimal sections of the build layer.
#####################################################################
ARG UBUNTU_VERSION="23.04"

FROM ubuntu:${UBUNTU_VERSION} as runtime
LABEL maintainer="https://github.com/underworldcode/"

#### Dockerfile ENV vars - for all image stages
ENV LANG=C.UTF-8
# openmpi lib will be install at /usr/local/lib
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
# add user jovyan
ENV NB_USER jovyan
ENV NB_HOME /home/$NB_USER
RUN useradd -m -s /bin/bash -N $NB_USER
 
# install runtime packages
RUN apt-get update -qq \
&&  apt-get upgrade -y \
&&  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        ssh  \
        bash \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

################
## 2. Build   ##
################

FROM runtime as build

# Build options for openmpi
ARG OMPI_MAJOR_VERSION="v4.1"
ARG OMPI_VERSION="4.1.4"
ARG OMPI_CONFIGURE_OPTIONS="--prefix=/usr/local"
ARG OMPI_MAKE_OPTIONS="-j4"

# apt get install dependency packages
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

# build mpi and remove tarball at the end
RUN mkdir -p /tmp/src
WORKDIR /tmp/src
RUN wget https://download.open-mpi.org/release/open-mpi/${OMPI_MAJOR_VERSION}/openmpi-${OMPI_VERSION}.tar.gz --no-check-certificate \
&& tar -zxf openmpi-${OMPI_VERSION}.tar.gz 
WORKDIR /tmp/src/openmpi-${OMPI_VERSION}              
RUN ./configure ${OMPI_CONFIGURE_OPTIONS} \
&&  make ${OMPI_MAKE_OPTIONS} \
&&  make install \
&&  rm -rf /tmp/src/

# record build packages used
RUN apt-mark showmanual > /opt/installed.txt


# Build smaller image
FROM runtime as final

COPY --from=build /usr/local /usr/local
COPY --from=build /opt/installed.txt /opt/installed.txt

# switch to user and workspace
WORKDIR $NB_HOME
USER $NB_USER
