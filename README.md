# Ascend Docker Images

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
    <a href="./README_zh.md">
        <b>中文文档</b>
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

We have the following Docker images, you can find details in their README.md:

## CANN

## PyTorch

## MindSpore

## Build

In order to build Ascend Docker images, ensure you have the following.

- Docker Engine 20.10+

Run from the repository directory after cloning. All Ascend Docker images will
be built using [Docker Buildx Bake][1]. Please note that this process will spend
a lot of time and disk space.

[1]: https://docs.docker.com/build/bake/

```docker
docker buildx bake -f arg.json -f docker-bake.hcl
```

To build single-arch images only:

```docker
docker buildx bake -f arg.json -f docker-bake.hcl \
    --set '*.platform=linux/arm64'
```

To customize Docker registry or build arguments, please edit
[arg.json](./arg.json) using JSON format.

## Support

The team tracks bugs and enhancement requests using [GitHub issues][2]. Before
submitting a suggestion or bug report, search the existing GitHub issues to
see if your issue has already been reported.

[2]: https://github.com/openmerlin/dockerfile/issues

## License

This repository is licensed under the [Apache License 2.0](./LICENSE).
