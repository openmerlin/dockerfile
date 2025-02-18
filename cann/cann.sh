#!/bin/bash

# set -e

# bash fonts colors
cyan='\e[96m'
yellow='\e[33m'
red='\e[31m'
none='\e[0m'

_cyan() { echo -e "${cyan}$*${none}"; }
_yellow() { echo -e "${yellow}$*${none}"; }
_red() { echo -e "${red}$*${none}"; }

_info() { _cyan "Info: $*"; }
_warn() { _yellow "Warn: $*"; }
_err() { _red "Error: $*" && exit 1; }

_get_architecture() {
    # not case sensitive
    shopt -s nocasematch

    case "${PLATFORM}" in
        "linux/x86_64"|"linux/amd64")
            arch="x86_64"
            ;;
        "linux/aarch64"|"linux/arm64")
            arch="aarch64"
            ;;
        *)
            _err "Unsupported architecture ${PLATFORM}."
            ;;
    esac

    echo "${arch}"
}

_retry() {
    "$@" || (sleep 10 && "$@") || (sleep 20 && "$@") || (sleep 40 && "$@")
}

_download_file() {
    _info "Downloading file from $1"
    _retry curl -fsSL -o "$2" "$1"
}

download_cann() {
    declare -A version_dict
    version_dict["8.0.RC2.alpha001"]="V100R001C18B800TP015"
    version_dict["8.0.RC2.alpha002"]="V100R001C18SPC805"
    version_dict["8.0.RC2.alpha003"]="V100R001C18SPC703"
    version_dict["8.0.RC3.alpha002"]="V100R001C19SPC702"

    local url="https://ascend-repo.obs.cn-east-2.myhuaweicloud.com"
    if [[ ${CANN_VERSION} == *alpha* ]]; then
        local version=${version_dict[${CANN_VERSION}]}
        if [[ ${version} ]]; then
            local url_prefix="${url}/Milan-ASL/Milan-ASL%20${version}"
        else
            _err "The version is not defined for CANN ${CANN_VERSION}, please file an issue on GitHub."
        fi
    else
        local url_prefix="${url}/CANN/CANN%20${CANN_VERSION}"
    fi

    # Download cann-toolkit
    if [ ! -f "${TOOLKIT_PATH}" ]; then
        local toolkit_url="${url_prefix}/${TOOLKIT_FILE}"
        _download_file "${toolkit_url}" "${TOOLKIT_PATH}"
    fi

    # Download cann-kernels
    if [ ! -f "${KERNELS_PATH}" ]; then
        local kernels_url="${url_prefix}/${KERNELS_FILE}"
        _download_file "${kernels_url}" "${KERNELS_PATH}"
    fi

    # Download cann-kernels
    if [[ ${CANN_VERSION} == "8.0.0" ]]; then
        local nnal_url="${url_prefix}/${NNAL_FILE}"
        _download_file "${nnal_url}" "${NNAL_PATH}"
    fi

    _info "CANN ${CANN_VERSION} download successful."
}

set_env() {
    local cann_toolkit_env_file="${CANN_HOME}/ascend-toolkit/set_env.sh"
    if [ ! -f "${cann_toolkit_env_file}" ]; then
        _err "No such file: ${cann_toolkit_env_file}"
    else
        local driver_path_env="LD_LIBRARY_PATH=${CANN_HOME}/driver/lib64/common/:${CANN_HOME}/driver/lib64/driver/:\${LD_LIBRARY_PATH}" && \
        echo "export ${driver_path_env}" >> /etc/profile
        echo "export ${driver_path_env}" >> ~/.bashrc
        echo "source ${cann_toolkit_env_file}" >> /etc/profile
        echo "source ${cann_toolkit_env_file}" >> ~/.bashrc
        if [ -n "$PS1" ]; then
            source ${cann_toolkit_env_file}
        fi

        local cann_nnal_env_file="${CANN_HOME}/nnal/atb/set_env.sh"
        if [ -f "${cann_nnal_env_file}" ]; then
            echo "source ${cann_nnal_env_file}" >> /etc/profile
            echo "source ${cann_nnal_env_file}" >> ~/.bashrc
            if [ -n "$PS1" ]; then
                source ${cann_nnal_env_file}
            fi
        fi
    fi
}

install_cann() {
    # Download installers
    if [ ! -f "${TOOLKIT_PATH}" ] || [ ! -f "${KERNELS_PATH}" ]; then
        _warn "Installers do not exist in the /tmp directory, re-download them."
        download_cann
    fi

    # Install dependencies
    pip install --no-cache-dir --upgrade pip
    pip install --no-cache-dir \
        attrs cython numpy==1.24.0 decorator sympy cffi pyyaml pathlib2 \
        psutil protobuf==3.20 scipy requests absl-py

    # Install CANN Toolkit
    _info "Installing ${TOOLKIT_FILE}"
    chmod +x "${TOOLKIT_PATH}"
    bash "${TOOLKIT_PATH}" --quiet --install --install-for-all --install-path="${CANN_HOME}"
    rm -f "${TOOLKIT_PATH}"

    # Set environment variables
    set_env

    # Install CANN Kernels
    _info "Installing ${KERNELS_FILE}"
    chmod +x "${KERNELS_PATH}"
    bash "${KERNELS_PATH}" --quiet --install --install-for-all --install-path="${CANN_HOME}"
    rm -f "${KERNELS_PATH}"

    # Install CANN NNAL
    if [[ ${CANN_VERSION} == "8.0.0" ]]; then
        _info "Installing ${NNAL_PATH}"
        chmod +x "${NNAL_PATH}"
        bash "${NNAL_PATH}" --quiet --install --install-for-all --install-path="${CANN_HOME}"
        rm -f "${NNAL_PATH}"

        # Print error logs
        local err_log_path="/var/log/ascend_seclog/ascend_nnal_install.log"
        _warn "Failed to install ${NNAL_PATH}, check out the following logs for more details:"
        echo "${err_log_path}:"
        cat ${err_log_path}
    fi

    _info "CANN ${CANN_VERSION} installation successful."
}

PLATFORM=${PLATFORM:=$(uname -s)/$(uname -m)}
ARCH=$(_get_architecture)
CANN_HOME=${CANN_HOME:="/usr/local/Ascend"}
CANN_CHIP=${CANN_CHIP:="910b"}
CANN_VERSION=${CANN_VERSION:="8.0.0"}

# NOTE: kernels are arch-specific after 8.0.RC3.alpha002
if [[ ${CANN_VERSION} == "8.0.RC3" || ${CANN_VERSION} == "8.0.0" ]]; then
  KERNELS_ARCH="linux-${ARCH}"
else
  KERNELS_ARCH="linux"
fi

TOOLKIT_FILE="Ascend-cann-toolkit_${CANN_VERSION}_linux-${ARCH}.run"
KERNELS_FILE="Ascend-cann-kernels-${CANN_CHIP}_${CANN_VERSION}_${KERNELS_ARCH}.run"
NNAL_FILE="Ascend-cann-nnal_${CANN_VERSION}_linux-${ARCH}.run"
TOOLKIT_PATH="/tmp/${TOOLKIT_FILE}"
KERNELS_PATH="/tmp/${KERNELS_FILE}"
NNAL_PATH="/tmp/${NNAL_FILE}"

# Parse arguments
if [ "$1" == "--download" ]; then
    download_cann
elif [ "$1" == "--install" ]; then
    install_cann
elif [ "$1" == "--set_env" ]; then
    set_env
else
    _err "Unexpected arguments, use '--download', '--install' or '--set_env' instead"
fi
