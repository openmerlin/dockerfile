# Arguments
ARG BASE_VERSION=latest
ARG PY_VERSION=3.8

# Stage 1: Install CANN
FROM ascendai/python:${PY_VERSION}-openeuler${BASE_VERSION} AS cann-installer

# Arguments
ARG PLATFORM=${TARGETPLATFORM}
ARG CANN_CHIP=910b
ARG CANN_VERSION=8.0.0

# Install dependencies
RUN yum update -y && \
    yum install -y \
        gcc \
        gcc-c++ \
        make \
        cmake \
        unzip \
        zlib-devel \
        libffi-devel \
        openssl-devel \
        pciutils \
        net-tools \
        sqlite-devel \
        lapack-devel \
        gcc-gfortran \
        util-linux \
        findutils \
        curl \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /tmp/*

COPY ./cann.sh /tmp/cann.sh
RUN bash /tmp/cann.sh --download
RUN bash /tmp/cann.sh --install

# Stage 2: Copy results from previous stages
FROM openeuler/openeuler:${BASE_VERSION} AS official

# Arguments
ARG PY_VERSION

# Environment variables
ENV PATH=/usr/local/python${PY_VERSION}/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:${LD_LIBRARY_PATH}
ENV ASCEND_TOOLKIT_HOME=/usr/local/Ascend/ascend-toolkit/latest
ENV ASCEND_TOOLKIT_PATH=${ASCEND_TOOLKIT_HOME}/toolkit
ENV ASCEND_OPP_PATH=${ASCEND_TOOLKIT_HOME}/opp
ENV ASCEND_NNAL_PATH=/usr/local/Ascend/nnal/atb
ENV PATH=${ASCEND_TOOLKIT_HOME}:${PATH}


# Change the default shell
SHELL [ "/bin/bash", "-c" ]

# Install dependencies
RUN yum update -y && \
    yum install -y \
        ca-certificates \
        bash \
        glibc \
        sqlite-devel \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /tmp/*

# Copy files
COPY --from=cann-installer /usr/local/python${PY_VERSION} /usr/local/python${PY_VERSION}
COPY --from=cann-installer /usr/local/Ascend /usr/local/Ascend
COPY --from=cann-installer /etc/Ascend /etc/Ascend
