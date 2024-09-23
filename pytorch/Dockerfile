ARG BASE_VERSION=latest
FROM ascendai/cann:${BASE_VERSION} as official

# Arguments
ARG TORCH_VERSION=2.1.0
ARG TORCH_VISION_VERSION=0.16.0
ARG TORCH_AUDIO_VERSION=2.1.0
ARG TORCH_NPU_VERSION=2.1.0.post3

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
    fi && \
    pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu \
        torch==${TORCH_VERSION} \
        torchvision==${TORCH_VISION_VERSION} \
        torchaudio==${TORCH_AUDIO_VERSION} && \
    pip install --no-cache-dir --index-url https://pypi.org/simple \
        torch-npu==${TORCH_NPU_VERSION}
