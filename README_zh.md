# 昇腾镜像

<p align="center">
    <a href="https://github.com/openmerlin/dockerfile/actions/workflows/docker.yml">
        <img src="https://github.com/openmerlin/dockerfile/actions/workflows/docker.yml/badge.svg" />
    </a>
    <a href="LICENSE">
        <img src="https://img.shields.io/github/license/openmerlin/dockerfile.svg" />
    </a>
    <img src="https://img.shields.io/github/v/release/openmerlin/dockerfile" />
    <img src="https://img.shields.io/badge/language-dockerfile-384D54.svg">
</p>

<p align="center">
    <a href="./README.md">
        <b>English</b>
    </a> •
    <a href="https://hub.docker.com/u/ascendai">
        <b>Docker Hub</b>
    </a> •
    <a href="https://github.com/orgs/ascend/packages?ecosystem=container">
        <b>GitHub Container</b>
    </a> •
    <a href="https://quay.io/organization/ascend">
        <b>Red Hat Quay</b>
    </a>
</p>

本仓库包含下列昇腾镜像，提供基于 Ubuntu 和 OpenEuler 的基础镜像，
具体信息请查看各镜像目录下的 README.md 文件：

- [CANN](./cann) 镜像：提供 cann-toolkit 运行环境
- [PyTorch](./pytorch) 镜像：提供 torch_npu 运行环境
- [MindSpore](./mindspore) 镜像：提供 mindspore 运行环境
- [Python](./python) 镜像：提供 python 基础环境

## 构建镜像

推荐使用 [Docker Buildx Bake][1] 构建镜像，构建细节详见
[docker-bake.hcl](./docker-bake.hcl)，构建参数定义详见
[arg.json](./arg.json)

[1]: https://docs.docker.com/build/bake/

> [!NOTE]
>
> 若您的构建环境不支持 Bake，可在镜像目录的 README.md 中获取 `docker build` 传统构建命令

使用 Bake 构建镜像需要 Docker Engine 20.10+，在仓库根目录运行下列命令：

```docker
docker buildx bake -f arg.json -f docker-bake.hcl
```

列出所有 Target：

```docker
docker buildx bake -f arg.json -f docker-bake.hcl --print
```

仅构建 linux/arm64 架构镜像：

```docker
docker buildx bake -f arg.json -f docker-bake.hcl \
    --set '*.platform=linux/arm64'
```

> [!NOTE]
>
> - 若需自定义构建配置，可使用 `--set` 指令，详见：https://docs.docker.com/reference/cli/docker/buildx/bake/#set
> - 若需自定义构建参数或 Tag 名称，可编辑文件 [arg.json](./arg.json)

## 运行容器

在镜像目录的 README.md 中获取 `docker run` 运行命令

## 获取支持

欢迎在 [GitHub issues][2] 页面提交 issue

[2]: https://github.com/openmerlin/dockerfile/issues

## 许可证

本仓库使用 [Apache License 2.0](./LICENSE) 许可证
