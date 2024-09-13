# Torch-NPU Docker Image

## Usage

```docker
docker run \
    --name torch_container \
    --device /dev/davinci1 \
    --device /dev/davinci_manager \
    --device /dev/devmm_svm \
    --device /dev/hisi_hdc \
    -v /usr/local/dcmi:/usr/local/dcmi \
    -v /usr/local/bin/npu-smi:/usr/local/bin/npu-smi \
    -v /usr/local/Ascend/driver/lib64/:/usr/local/Ascend/driver/lib64/ \
    -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info \
    -v /etc/ascend_install.info:/etc/ascend_install.info \
    -it ascendai/pytorch:2.2.0 bash
```

## Build

If you have Docker Engine 20.10+, then you can use Bake to build Docker images:

```docker
docker buildx bake -f arg.json -f docker-bake.hcl pytorch
```

Don't have Bake? Use `docker build` instead. It requires Docker Engine 18+.

```docker
docker build \
    -t ascendai/pytorch:latest \
    -f pytorch/new.Dockerfile \
    --build-arg BASE_VERSION=latest \
    --build-arg PYTORCH_VERSION=2.2.0 \
    pytorch/
```
