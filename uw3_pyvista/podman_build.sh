set -x
podman build . \
    --format docker \
    --rm \
    -t underworldcode/underworld3
