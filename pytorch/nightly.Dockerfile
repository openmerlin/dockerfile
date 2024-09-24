# Multi-arch builders, see https://github.com/docker/buildx/issues/805
FROM pytorch/manylinuxaarch64-builder:cpu-aarch64-main AS builder-arm64
FROM pytorch/manylinux-builder:cpu-main AS builder-amd64
FROM builder-${TARGETARCH} AS builder

# Get source code and install dependencies
ARG PY_VERSION=3.9
RUN git clone https://gitee.com/ascend/pytorch.git --depth 1
RUN python${PY_VERSION} -m pip install --no-cache-dir -r pytorch/requirements.txt

# The distribution package can be found at /pytorch/dist/torch_npu-xxx.whl
RUN bash pytorch/ci/build.sh --python=${PY_VERSION}

ARG BASE_VERSION
FROM ascendai/cann:${BASE_VERSION} as official

# Change the default shell
SHELL [ "/bin/bash", "-c" ]

# Install pytorch, torch-npu and related packages
RUN \
    # Uninstall the latest numpy and sympy first, as the right versions will be installed again \
    # after installing following packages \
    pip uninstall -y numpy sympy && \
    # Nightly build \
