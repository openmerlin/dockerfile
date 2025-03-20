ARG BASE_VERSION=latest
FROM ascendai/cann:${BASE_VERSION} as official

# Arguments
ARG PYTORCH_VERSION=2.1.0

# Change the default shell
SHELL [ "/bin/bash", "-c" ]

# Install pytorch, torch-npu and related packages
RUN if [ "${PYTORCH_VERSION}" == "2.1.0" ]; then \
        TORCH_VISION_VERSION=0.16.0; \
        TORCH_AUDIO_VERSION=2.1.0; \
        TORCH_NPU_VERSION=2.1.0; \
    elif [ "${PYTORCH_VERSION}" == "2.2.0" ]; then \
        TORCH_VISION_VERSION=0.17.0; \
        TORCH_AUDIO_VERSION=2.2.0; \
        TORCH_NPU_VERSION=2.2.0; \
    else \
        echo "Not supported version: ${PYTORCH_VERSION}."; \
        exit 1; \
    fi && \
    pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu \
        torch==${PYTORCH_VERSION} \
        torchvision==${TORCH_VISION_VERSION} \
        torchaudio==${TORCH_AUDIO_VERSION} && \
    pip install --no-cache-dir \
        torch-npu==${TORCH_NPU_VERSION}