# MindSpore Docker Image

The mindspore image is based on the [cann](../cann) image, and `mindspore` is installed using `pip`. 

Here are available tags and the build args can be found at [arg.json](../arg.json).

- `2.3.0rc1`

> [!NOTE]
>
> If your desired tag is not here, feel free to file an issue with us or
> try to build it yourself.

## Usage

Assuming your NPU device is mounted at `/dev/davinci1` and your NPU driver is installed at `/usr/local/Ascend`:

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

If you have Docker Engine 20.10+, then you can use Bake to build Docker images. Run the following command
in the root directory:

```docker
docker buildx bake -f arg.json -f docker-bake.hcl mindspore
```

Don't have Bake? Use `docker build` instead. It requires Docker Engine 18+. Run the following command
in the root directory:

```docker
docker build \
    -t ascendai/mindspore:2.3.0rc1 \
    -f mindspore/Dockerfile \
    --build-arg BASE_VERSION=8.0.rc1-910b-ubuntu22.04-py3.8 \
    --build-arg MINDSPORE_VERSION=2.3.0rc1 \
    mindspore/
```
