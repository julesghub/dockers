ARG BASE_IMAGE="underworldcode/petsc:3.18.0"
FROM ${BASE_IMAGE} as petsc-image

FROM ubuntu:23.10 as runtime
LABEL maintainer="https://github.com/underworldcode/"

### Dockerfile ENV vars - for all image stages
ENV LANG=C.UTF-8
# mpi lib will be install at /usr/local/lib
ENV PYVER=3.11
ENV PYOPT=/opt/venv
ENV PATH=$PYOPT/bin:$PATH
ENV PYTHONPATH=$PYTHONPATH:$PYOPT/lib/python${PYVER}/site-packages
ENV PETSC_DIR=/usr/local
ENV PYTHONPATH=$PYTHONPATH:$PETSC_DIR/lib
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# add user jovyan
ENV NB_USER jovyan
ENV NB_HOME /home/$NB_USER
RUN useradd -m -s /bin/bash -N $NB_USER

RUN apt-get update -qq \
&&  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        ca-certificates \
        wget \
        ssh \
        build-essential \
        gfortran \
        cmake \
        git \
        libopenblas-dev \
        libocct-visualization-dev libocct-data-exchange-dev libocct-draw-dev \
        tcl8.6-dev \
        libz-dev \
        libxcursor-dev \
        libxft2 \
        libxinerama1 \
        libgmsh-dev \
        libfreetype6-dev \
        python${PYVER}-venv \
        python${PYVER}-dev \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

FROM runtime as build

# copy in from petsc container
COPY --from=petsc-image --chown=$NB_USER:users /opt /opt
COPY --from=petsc-image --chown=$NB_USER:users /usr/local /usr/local

RUN apt-get update -qq \
&&  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends $(awk '{print $1'} /opt/installed.txt) \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

# build gmsh from source with NO FLTK support - why?
# because arm64 linux pypi packages aren't suppied for gmsh
RUN git clone https://gitlab.onelab.info/gmsh/gmsh.git \
&& cd gmsh && mkdir build && cd build \ 
&& cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_BUILD_SHARED=1 -DENABLE_FLTK=0 -DCMAKE_INSTALL_PREFIX=/usr/local/ .. \
&& make -j8 shared && make install \
&& cd .. && rm -rf gmsh/

FROM runtime as minimal
COPY --from=build --chown=$NB_USER:users /opt /opt
COPY --from=build --chown=$NB_USER:users /usr/local /usr/local

USER $NB_USER
WORKDIR $NB_HOME

# build and open virtual environment
RUN python${PYVER} -m venv $NB_HOME/venv \
&&  . ${NB_HOME}/venv/bin/activate \
&&  python${PYVER} -m pip install -U --no-cache-dir \
                    setuptools \
                    wheel 

RUN python${PYVER} -m pip install -U --no-cache-dir \
                    cython numpy mpi4py \
                    sympy pyvista panel xxhash \ 
                    pytest 

RUN git clone --branch boundary_integrals --depth 1 https://github.com/underworldcode/underworld3.git uw3 \
&& cd $NB_HOME/uw3 \
&& python${PYVER} -m pip install -e .

# expose port for jupyter lab
EXPOSE 8888 
