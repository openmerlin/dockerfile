# Multi-arch builders, see https://github.com/docker/buildx/issues/805
FROM pytorch/manylinuxaarch64-builder:cpu-aarch64-main AS builder-arm64
FROM pytorch/manylinux-builder:cpu-main AS builder-amd64
FROM builder-${TARGETARCH} AS builder

#RUN apt-get update \
#    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
#        git \
#        gcc-10 \
#        g++-10 \
#        make \
#        cmake \
#        ninja-build \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* \
#    && rm -rf /var/tmp/* \
#    && rm -rf /tmp/*
#
## torch_npu requires gcc-10 and g++-10
#RUN ln -s /usr/bin/gcc-10 /usr/bin/gcc && \
#    ln -s /usr/bin/g++-10 /usr/bin/g++

# Get source code and install dependencies
RUN git clone https://gitee.com/ascend/pytorch.git --depth 1
RUN pip install --no-cache-dir wheel && \
    pip install --no-cache-dir -r pytorch/requirements.txt

# The distribution package can be found at /pytorch/dist/torch_npu-xxx.whl
RUN py_version=$(python --version | awk '{print $2}' | cut -d '.' -f 1,2) && \
    bash pytorch/ci/build.sh --python=${py_version}

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
    if [ ${TORCH_VERSION == "nightly"} ]; then \
      exit 0; \
    fi
