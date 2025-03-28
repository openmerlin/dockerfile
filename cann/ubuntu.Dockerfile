# Arguments
ARG BASE_VERSION=latest
ARG PY_VERSION=3.8

# Stage 1: Install CANN
FROM ascendai/python:${PY_VERSION}-ubuntu${BASE_VERSION} AS cann-installer

# Arguments
ARG PLATFORM=${TARGETPLATFORM}
ARG CANN_CHIP=910b
ARG CANN_VERSION=8.0.0
ARG NNAL_VERSION=${CANN_VERSION}

# Change the default shell
SHELL [ "/bin/bash", "-c" ]

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        bash \
        git \
        wget \
        gcc \
        g++ \
        make \
        cmake \
        zlib1g \
        zlib1g-dev \
        openssl \
        libsqlite3-dev \
        libssl-dev \
        libffi-dev \
        unzip \
        pciutils \
        net-tools \
        libblas-dev \
        gfortran \
        patchelf \
        libblas3 \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/tmp/* \
    && rm -rf /tmp/*

# Note: If you put your installers here, they won't be downloaded again.
COPY ./cann.sh /tmp/
RUN cp -nv *.run /tmp/ || true
RUN bash /tmp/cann.sh --download
RUN bash /tmp/cann.sh --install

# Stage 2: Copy results from previous stages
FROM ubuntu:${BASE_VERSION} AS official

# Arguments
ARG PY_VERSION

# Toolkit Environment variables
ENV ASCEND_TOOLKIT_HOME=/usr/local/Ascend/ascend-toolkit/latest
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common/:/usr/local/Ascend/driver/lib64/driver/:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${ASCEND_TOOLKIT_HOME}/lib64:${ASCEND_TOOLKIT_HOME}/lib64/plugin/opskernel:${ASCEND_TOOLKIT_HOME}/lib64/plugin/nnengine:${ASCEND_TOOLKIT_HOME}/opp/built-in/op_impl/ai_core/tbe/op_tiling:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${ASCEND_TOOLKIT_HOME}/tools/aml/lib64:${ASCEND_TOOLKIT_HOME}/tools/aml/lib64/plugin:$LD_LIBRARY_PATH
ENV PYTHONPATH=${ASCEND_TOOLKIT_HOME}/python/site-packages:${ASCEND_TOOLKIT_HOME}/opp/built-in/op_impl/ai_core/tbe:$PYTHONPATH
ENV PATH=${ASCEND_TOOLKIT_HOME}/bin:${ASCEND_TOOLKIT_HOME}/compiler/ccec_compiler/bin:${ASCEND_TOOLKIT_HOME}/tools/ccec_compiler/bin:$PATH
ENV ASCEND_AICPU_PATH=${ASCEND_TOOLKIT_HOME}
ENV ASCEND_OPP_PATH=${ASCEND_TOOLKIT_HOME}/opp
ENV TOOLCHAIN_HOME=${ASCEND_TOOLKIT_HOME}/toolkit
ENV ASCEND_HOME_PATH=${ASCEND_TOOLKIT_HOME}

# Nnal Environment variables
ENV ATB_HOME_PATH=/usr/local/Ascend/nnal/atb/latest/atb/cxx_abi_1
ENV LD_LIBRARY_PATH=${ATB_HOME_PATH}/lib:${ATB_HOME_PATH}/examples:${ATB_HOME_PATH}/tests/atbopstest:${LD_LIBRARY_PATH}
ENV PATH=${ATB_HOME_PATH}/bin:$PATH

# Acceleration Library Environment variables
ENV ATB_STREAM_SYNC_EVERY_KERNEL_ENABLE=0
ENV ATB_STREAM_SYNC_EVERY_RUNNER_ENABLE=0
ENV ATB_STREAM_SYNC_EVERY_OPERATION_ENABLE=0
ENV ATB_OPSRUNNER_SETUP_CACHE_ENABLE=1
ENV ATB_OPSRUNNER_KERNEL_CACHE_TYPE=3
ENV ATB_OPSRUNNER_KERNEL_CACHE_LOCAL_COUNT=1
ENV ATB_OPSRUNNER_KERNEL_CACHE_GLOABL_COUNT=5
ENV ATB_OPSRUNNER_KERNEL_CACHE_TILING_SIZE=10240
ENV ATB_WORKSPACE_MEM_ALLOC_ALG_TYPE=1
ENV ATB_WORKSPACE_MEM_ALLOC_GLOBAL=0
ENV ATB_COMPARE_TILING_EVERY_KERNEL=0
ENV ATB_HOST_TILING_BUFFER_BLOCK_NUM=128
ENV ATB_DEVICE_TILING_BUFFER_BLOCK_NUM=32
ENV ATB_SHARE_MEMORY_NAME_SUFFIX=""
ENV ATB_LAUNCH_KERNEL_WITH_TILING=1
ENV ATB_MATMUL_SHUFFLE_K_ENABLE=1
ENV ATB_RUNNER_POOL_SIZE=64

# Operator Library Environment variables
ENV ASDOPS_HOME_PATH=${ATB_HOME_PATH}
ENV ASDOPS_MATMUL_PP_FLAG=1
ENV ASDOPS_LOG_LEVEL=ERROR
ENV ASDOPS_LOG_TO_STDOUT=0
ENV ASDOPS_LOG_TO_FILE=1
ENV ASDOPS_LOG_TO_FILE_FLUSH=0
ENV ASDOPS_LOG_TO_BOOST_TYPE=atb
ENV ASDOPS_LOG_PATH=/root
ENV ASDOPS_TILING_PARSE_CACHE_DISABLE=0
ENV LCCL_DETERMINISTIC=0

# Change the default shell
SHELL [ "/bin/bash", "-c" ]

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        bash \
        libc6 \
        libsqlite3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/tmp/* \
    && rm -rf /tmp/*

# Copy files
COPY --from=cann-installer /usr/local/python${PY_VERSION} /usr/local/python${PY_VERSION}
COPY --from=cann-installer /usr/local/Ascend /usr/local/Ascend
COPY --from=cann-installer /etc/Ascend /etc/Ascend
