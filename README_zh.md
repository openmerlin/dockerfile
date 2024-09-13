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

本仓库包含下列昇腾镜像，具体内容可查看相应 README.md:

## CANN

## PyTorch

## MindSpore

## 构建镜像

构建需要 Docker Engine 20.10+，在仓库根目录运行下列命令，
使用 [Docker Buildx Bake][1] 构建镜像：

[1]: https://docs.docker.com/build/bake/

```docker
docker buildx bake -f arg.json -f docker-bake.hcl
```

仅构建 arm 架构镜像：

```docker
docker buildx bake -f arg.json -f docker-bake.hcl \
    --set '*.platform=linux/arm64'
```

自定义 Docker registry 或构建参数，可编辑文件 [arg.json](./arg.json)。

## 获取支持

欢迎在 [GitHub issues][2] 页面提交 issue。

[2]: https://github.com/openmerlin/dockerfile/issues

## 许可证

[Apache License 2.0](./LICENSE)
