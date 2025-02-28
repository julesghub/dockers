###########################
# To build the Docker images
# podman build . \
#     --format docker \
#     --rm \
#     -t underworldcode/underworld3
###########################
ARG BASE_IMAGE_TAG=latest
FROM ghcr.io/pyvista/pyvista:$BASE_IMAGE_TAG

COPY . ${HOME}
WORKDIR ${HOME}
RUN mamba env update -n base -f environment.yml && \
    mamba clean --all --yes

ARG MAMBA_DOCKERFILE_ACTIVATE=1

EXPOSE 8888
USER ${NB_USER}

WORKDIR ${HOME}
RUN pip install -r requirements.txt && \
    pip install --no-build-isolation 'git+https://github.com/underworldcode/underworld3.git@development' && \
    git clone --depth 1 https://github.com/underworldcode/underworld3-documentation.git documents

# Declare a volume space
VOLUME ${HOME}/workspace

CMD ["jupyter-lab", "--no-browser", "--ip='0.0.0.0'"]
