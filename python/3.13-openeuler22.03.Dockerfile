# Arguments
ARG BASE_VERSION=22.03
ARG PY_VERSION=3.13
ARG OS_NAME=openeuler

# Stage 1: Install Python
FROM ${OS_NAME}/${OS_NAME}:${BASE_VERSION} AS py-installer

ARG PY_VERSION
ENV PATH=/usr/local/python${PY_VERSION}/bin:${PATH}

# Install dependencies
RUN yum update -y && \
    yum install -y \
        gcc \
        gcc-c++ \
        make \
        cmake \
        curl \
        zlib-devel \
        bzip2-devel \
        openssl-devel \
        ncurses-devel \
        sqlite-devel \
        readline-devel \
        tk-devel \
        gdbm-devel \
        libpcap-devel \
        xz-devel \
        libev-devel \
        expat-devel \
        libffi-devel \
        systemtap-sdt-devel \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /tmp/*

# Find the latest Python version
RUN PY_LATEST_VERSION=$(curl -s https://www.python.org/ftp/python/ | grep -oE "${PY_VERSION}\.[0-9]+" | sort -V | tail -n 1) && \
    if [ -z "${PY_LATEST_VERSION}" ]; then \
        echo "[WARNING] Could not find the latest version for Python ${PY_VERSION}"; \
        exit 1; \
    else \
        echo "Latest Python version found: ${PY_LATEST_VERSION}"; \
        echo "${PY_LATEST_VERSION}" > /tmp/python_version.txt;  \
    fi

RUN PY_LATEST_VERSION=$(cat /tmp/python_version.txt) && \
    PY_HOME=/usr/local/python${PY_VERSION} && \
    PY_INSTALLER_TGZ=Python-${PY_LATEST_VERSION}.tgz && \
    PY_INSTALLER_DIR=Python-${PY_LATEST_VERSION} && \
    PY_INSTALLER_URL=https://repo.huaweicloud.com/python/${PY_LATEST_VERSION}/${PY_INSTALLER_TGZ} && \
    curl -fsSL -o "/tmp/${PY_INSTALLER_TGZ}" "${PY_INSTALLER_URL}" && \
    tar -xf /tmp/${PY_INSTALLER_TGZ} -C /tmp && \
    cd /tmp/${PY_INSTALLER_DIR} && \
    mkdir -p ${PY_HOME}/lib && \
    ./configure --prefix=${PY_HOME} --enable-shared LDFLAGS="-Wl,-rpath ${PY_HOME}/lib" && \
    make -j "$(nproc)" && \
    make altinstall && \
    ln -sf ${PY_HOME}/bin/python${PY_VERSION} ${PY_HOME}/bin/python3 && \
    ln -sf ${PY_HOME}/bin/pip3 ${PY_HOME}/bin/pip3 && \
    ln -sf ${PY_HOME}/bin/python3 ${PY_HOME}/bin/python && \
    ln -sf ${PY_HOME}/bin/pip3 ${PY_HOME}/bin/pip && \
    rm -rf /tmp/${PY_INSTALLER_TGZ} /tmp/${PY_INSTALLER_DIR} && \
    ${PY_HOME}/bin/python -c "import sys; print(sys.version)"

# Stage 2: Copy results from previous stages
FROM ${OS_NAME}/${OS_NAME}:${BASE_VERSION} AS official

ARG PY_VERSION
ENV PATH=/usr/local/python${PY_VERSION}/bin:${PATH}

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
COPY --from=py-installer /usr/local/python${PY_VERSION} /usr/local/python${PY_VERSION}

# Set environment variables
RUN \
    # Set environment variables for Python \
    PY_PATH="PATH=/usr/local/python${PY_VERSION}/bin:\${PATH}" && \
    echo "export ${PY_PATH}" >> /etc/profile && \
    echo "export ${PY_PATH}" >> ~/.bashrc