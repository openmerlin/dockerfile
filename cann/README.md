# CANN Docker Image

We provide multi-arch, multi-chip, multi-OS, and multi-Python versions of CANN Docker images. Each image
contains the minimum set of dependencies required by the cann-toolkit runtime, as follows:

- `bash`
- `glibc`
- `sqlite`
- `python`
- `pip`

Here are available tags and the build args can be found at [arg.json](../arg.json).

- `7.0.1-910b-ubuntu22.04-py3.8`
- `7.0.1-910b-openeuler22.03-py3.8`
- `8.0.rc2-910b-ubuntu22.04-py3.8`
- `8.0.rc2-910b-openeuler22.03-py3.8`
- `8.0.rc3.alpha002-910b-ubuntu22.04-py3.9`
- `8.0.rc3.alpha002-910b-openeuler22.03-py3.9`

> ![!NOTE]
>
> If the tag you expect is not here, feel free to file an issue with us or
> try to build it yourself.

## Usage

Assuming your NPU device is mounted at `/dev/davinci1` and your NPU driver is installed at `/usr/local/Ascend`:

```docker
docker run \
    --name cann_container \
    --device /dev/davinci1 \
    --device /dev/davinci_manager \
    --device /dev/devmm_svm \
    --device /dev/hisi_hdc \
    -v /usr/local/dcmi:/usr/local/dcmi \
    -v /usr/local/bin/npu-smi:/usr/local/bin/npu-smi \
    -v /usr/local/Ascend/driver/lib64/:/usr/local/Ascend/driver/lib64/ \
    -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info \
    -v /etc/ascend_install.info:/etc/ascend_install.info \
    -it ascendai/cann:latest bash
```

## Build

If you have Docker Engine 20.10+, then you can use Bake to build Docker images. Run the following command
in the root directory:

```docker
docker buildx bake -f arg.json -f docker-bake.hcl cann
```

Don't have Bake? Use `docker build` instead. It requires Docker Engine 18+. Run the following command
in the root directory:

```docker
docker build \
    -t ascendai/cann:latest \
    -f cann/ubuntu.Dockerfile \
    --build-arg BASE_VERSION=22.04 \
    --build-arg PY_VERSION=3.10 \
    --build-arg CANN_CHIP=910b \
    --build-arg CANN_VERSION=8.0.RC1 \
    cann/
```
