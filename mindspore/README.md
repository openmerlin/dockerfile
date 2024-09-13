# MindSpore Docker Image

## Usage

```docker
docker run \
    --name mindspore_container \
    --device /dev/davinci1 \
    --device /dev/davinci_manager \
    --device /dev/devmm_svm \
    --device /dev/hisi_hdc \
    -v /usr/local/dcmi:/usr/local/dcmi \
    -v /usr/local/bin/npu-smi:/usr/local/bin/npu-smi \
    -v /usr/local/Ascend/driver/lib64/:/usr/local/Ascend/driver/lib64/ \
    -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info \
    -v /etc/ascend_install.info:/etc/ascend_install.info \
    -it ascendai/mindspore:2.3.0rc1 bash
```

## Build

If you have Docker Engine 20.10+, then you can use Bake to build Docker images:

```docker
docker buildx bake -f arg.json -f docker-bake.hcl mindspore
```

Don't have Bake? Use `docker build` instead. It requires Docker Engine 18+.

```docker
docker build \
    -t ascendai/mindspore:latest \
    -f mindspore/Dockerfile \
    --build-arg BASE_VERSION=latest \
    --build-arg MINDSPORE_VERSION=2.3.0rc1 \
    mindspore/
```
