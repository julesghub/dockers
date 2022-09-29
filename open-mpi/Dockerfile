FROM ubuntu:22.04

# Build options for Dockerfile
ARG OMPI_MAJOR_VERSION="v4.1"
ARG OMPI_VERSION="4.1.4"
ARG OMPI_CONFIGURE_OPTIONS=""
ARG OMPI_MAKE_OPTIONS="-j4"

RUN apt-get update -qq \
&&  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        wget \
        openssh \
        bash \
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
ARG OMPI_URL="https://download.open-mpi.org/release/open-mpi/${OMPI_MAJOR_VERSION}/openmpi-${OMPI_VERSION}.tar.gz"
RUN wget $OMPI_URL --no-check-certificate
RUN tar -zxf openmpi-${OMPI_VERSION}.tar.gz 
WORKDIR /tmp/src/openmpi-${OMPI_VERSION}              
RUN ./configure ${OMPI_CONFIGURE_OPTIONS} \
 && make ${OMPI_MAKE_OPTIONS} \
 && make install \
 && ldconfig

ENV PATH ${OMPI_DIR}/bin:$PATH
ENV LD_LIBRARY_PATH ${OMPI_DIR}/lib:$LD_LIBRARY_PATH

# ENV NB_USER jovyan
# ENV NB_WORK /home/$NB_USER
# RUN useradd -m -s /bin/bash -N $NB_USER -g users \
# &&  mkdir -p /$NB_WORK/workspace \
# &&  chown -R $NB_USER:users $NB_WORK
# 
# USER $NB_USER
# COPY . $NB_WORK
# WORKDIR $NB_WORK
# RUN mpicc -o mpitest mpitest.c
