# Arguments
ARG BASE_VERSION=22.03
ARG PY_VERSION=3.10
ARG OS_NAME=openeuler

# Stage 1: Install CANN
FROM ascendai/python:${PY_VERSION}-${OS_NAME}${BASE_VERSION} AS cann-installer

# Arguments
ARG TARGETPLATFORM
ARG CANN_CHIP=910b
ARG CANN_VERSION=8.0.0
ARG BASE_URL=https://ascend-repo.obs.cn-east-2.myhuaweicloud.com

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
        ARCH="x86_64"; \
    else \
        ARCH="aarch64"; \
    fi && \
    # NOTE: kernels are arch-specific after 8.0.RC3.alpha002
    if [ "${CANN_VERSION}" = "8.0.0"  ||  "${CANN_VERSION}" = "8.0.RC3" ]; then \
        KERNELS_ARCH="linux-${ARCH}"; \
    else \
        KERNELS_ARCH="linux"; \
    fi && \
    TOOLKIT_FILE="Ascend-cann-toolkit_${CANN_VERSION}_linux-${ARCH}.run" && \
    KERNELS_FILE="Ascend-cann-kernels-${CANN_CHIP}_${CANN_VERSION}_${KERNELS_ARCH}.run" && \
    NNAL_FILE="Ascend-cann-nnal_${CANN_VERSION}_linux-${ARCH}.run" && \
    echo "${TOOLKIT_FILE}" > /tmp/toolkit_file.txt && \
    echo "${KERNELS_FILE}" > /tmp/kernels_file.txt && \
    echo "${NNAL_FILE}" > /tmp/nnal_file.txt

# NOTE: Different CANN VERSION has different Download url
RUN if echo "${CANN_VERSION}" | grep -q "alpha"; then \
        if [ "${CANN_VERSION}" = "8.0.RC2.alpha001" ]; then \
            version="V100R001C18B800TP015"; \
        elif [ "${CANN_VERSION}" = "8.0.RC2.alpha002" ]; then \
            version="V100R001C18SPC805"; \
        elif [ "${CANN_VERSION}" = "8.0.RC2.alpha003" ]; then \
            version="V100R001C18SPC703"; \
        elif [ "${CANN_VERSION}" = "8.0.RC3.alpha002" ]; then \
            version="V100R001C19SPC702"; \
        else \
            echo "Error: Unsupported CANN_VERSION: ${CANN_VERSION}"; \
            exit 1; \
        fi; \
        URL_PREFIX="${BASE_URL}/Milan-ASL/Milan-ASL%20${version}"; \
    else \
        URL_PREFIX="${BASE_URL}/CANN/CANN%20${CANN_VERSION}"; \
    fi && \
    TOOLKIT_FILE=$(cat /tmp/toolkit_file.txt) && \
    KERNELS_FILE=$(cat /tmp/kernels_file.txt) && \
    NNAL_FILE=$(cat /tmp/nnal_file.txt) && \
    CANN_TOOLKIT_URL="${URL_PREFIX}/${TOOLKIT_FILE}" && \
    CANN_KERNELS_URL="${URL_PREFIX}/${KERNELS_FILE}" && \
    CANN_NNAL_URL="${URL_PREFIX}/${NNAL_FILE}" && \
    echo "${CANN_TOOLKIT_URL}" > /tmp/toolkit_url_file.txt && \
    echo "${CANN_KERNELS_URL}" > /tmp/kernels_url_file.txt && \
    echo "${CANN_NNAL_URL}" > /tmp/nnal_url_file.txt

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
        wget \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN CANN_TOOLKIT_URL=$(cat /tmp/toolkit_url_file.txt) && \
    wget ${CANN_TOOLKIT_URL} -O ~/Ascend-cann-toolkit.run && \
    chmod +x ~/Ascend-cann-toolkit.run && \
    printf "Y\n" | ~/Ascend-cann-toolkit.run --install && \
    rm -f ~/Ascend-cann-toolkit.run
  
RUN CANN_KERNELS_URL=$(cat /tmp/kernels_url_file.txt) && \
    wget ${CANN_KERNELS_URL} -O ~/Ascend-cann-kernels.run && \
    chmod +x ~/Ascend-cann-kernels.run && \
    printf "Y\n" | ~/Ascend-cann-kernels.run --install && \
    rm -f ~/Ascend-cann-kernels.run

RUN if [ "${CANN_VERSION}" = "8.0.0" ]; then \
        CANN_NNAL_URL=$(cat /tmp/nnal_url_file.txt) && \
        wget ${CANN_NNAL_URL} -O ~/Ascend-cann-nnal.run && \
        chmod +x ~/Ascend-cann-nnal.run && \
        printf "Y\n" | ~/Ascend-cann-nnal.run --install && \
        rm -f ~/Ascend-cann-nnal.run \
    fi

# Stage 2: Select OS
FROM ${OS_NAME}/${OS_NAME}:${BASE_VERSION} AS official-openeuler
FROM ${OS_NAME}:${BASE_VERSION} AS official-ubuntu

# Stage 3: Copy results from previous stages
FROM official-${OS_NAME} AS py-installer

# Arguments
ARG PY_VERSION

# Environment variables
ENV PATH=/usr/local/python${PY_VERSION}/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:${LD_LIBRARY_PATH}

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

# Set environment variables
RUN \
    # Set environment variables for Python \
    PY_PATH="PATH=/usr/local/python${PY_VERSION}/bin:\${PATH}" && \
    echo "export ${PY_PATH}" >> /etc/profile && \
    echo "export ${PY_PATH}" >> ~/.bashrc && \
    # Set environment variables for CANN \
    CANN_TOOLKIT_ENV_FILE="/usr/local/Ascend/ascend-toolkit/set_env.sh" && \
    DRIVER_LIBRARY_PATH="LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:\${LD_LIBRARY_PATH}" && \
    echo "export ${DRIVER_LIBRARY_PATH}" >> /etc/profile && \
    echo "export ${DRIVER_LIBRARY_PATH}" >> ~/.bashrc && \
    echo "source ${CANN_TOOLKIT_ENV_FILE}" >> /etc/profile && \
    echo "source ${CANN_TOOLKIT_ENV_FILE}" >> ~/.bashrc && \
    echo "source ${CANN_TOOLKIT_ENV_FILE}" >> ~/.bashrc && \
    CANN_NNAL_ENV_FILE="/usr/local/Ascend/nnal/atb/set_env.sh" && \
    if [ -f "${CANN_NNAL_ENV_FILE}" ]; then \
        echo "source ${CANN_NNAL_ENV_FILE}" >> /etc/profile && \
        echo "source ${CANN_NNAL_ENV_FILE}" >> ~/.bashrc; \
    fi

ENTRYPOINT ["/bin/bash", "-c", "\
  source /usr/local/Ascend/ascend-toolkit/set_env.sh && \
  if [ -f /usr/local/Ascend/nnal/atb/set_env.sh ]; then \
    source /usr/local/Ascend/nnal/atb/set_env.sh; \
  fi && \
  exec \"$@\"", "--"]