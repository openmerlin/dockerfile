<!-- Please update the overview on DockerHub once changes are made to this doc -->
<!-- https://hub.docker.com/r/ascendai/cann -->

# Ascend CANN

[CANN][1]（Compute Architecture for Neural Networks）是华为针对AI场景推出的异构计算架构，
对上支持多种AI框架，对下服务AI处理器与编程，发挥承上启下的关键作用，是提升昇腾AI处理器计算效率的关键平台。
同时针对多样化应用场景，提供高效易用的编程接口，支持用户快速构建基于昇腾平台的AI应用和业务。

[1]: https://www.hiascend.com/zh/software/cann

## 快速参考

- 维护人员:
  - [shink][11]

- 支撑方式:
  - [GitHub issues][12]

[11]: https://github.com/shink
[12]: https://github.com/openmerlin/dockerfile/issues

## 使用

假设你将 NPU 设备挂载到了 `/dev/davinci1`，NPU 驱动安装在 `/usr/local/Ascend`：

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

## 构建

如果你的 Docker Engine 版本大于 20.10，那么就可以使用 Bake 来构建镜像，在仓库根目录下运行下列命令，将会一次构建所有 CANN 镜像：

```docker
docker buildx bake -f arg.json -f docker-bake.hcl cann
```

如果你的 Docker 不支持 Bake，也可以直接运行 `docker build` 命令来构建单个镜像，在仓库根目录下运行下列命令：

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

## Supported tags

> 构建参数见：[arg.json](../arg.json)

- `7.0.1.beta1-910b-ubuntu22.04-py3.8` (shorter: `7.0.1.beta1`)
- `7.0.1.beta1-910b-openeuler22.03-py3.8`
- `8.0.rc1.beta1-910b-ubuntu22.04-py3.8` (shorter: `8.0.rc1.beta1`)
- `8.0.rc1.beta1-910b-openeuler22.03-py3.8`
- `8.0.rc2.beta1-910b-ubuntu22.04-py3.9` (shorter: `8.0.rc2.beta1`)
- `8.0.rc2.beta1-910b-openeuler22.03-py3.9`
- `8.0.rc3.beta1-910b-ubuntu22.04-py3.10` (shorter: `8.0.rc3.beta1`, `latest`)
- `8.0.rc3.beta1-910b-openeuler22.03-py3.10`

> [!NOTE]
>
> 如果你想要的版本不在其中，欢迎向我们提出诉求或尝试自行构建

We provide multi-arch, multi-chip, multi-os, and multi-python versions of CANN Docker images. Each image
contains the minimum set of dependencies required by the cann-toolkit runtime, as follows:

- `bash`
- `glibc`
- `sqlite`
- `python`
- `pip`
